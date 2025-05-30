// Obstacle Avoidance App
// FrameHandler.swift
//  Swift file that is used to setup the camera/frame capture. This is what will likely be modified for CoreML implementation.
import SwiftUI
import AVFoundation
import Foundation
import CoreImage
import Vision
class FrameHandler: NSObject, ObservableObject {
    enum ConfigurationError: Error {
        case lidarDeviceUnavailable
        case requiredFormatUnavailable
    }
    @Published var frame: CGImage?
    @Published var boundingBoxes: [BoundingBox] = []
    @Published var objectDistance: Float16 = 0.0
    @Published var corridorGeometry: CorridorGeometry? = nil // represents the area created by the corridor
    // Initializing variables related to capturing image.
    private var permissionGranted = true
    public let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let context = CIContext()
    private var requests = [VNRequest]() // To hold detection requests
    private var detectionLayer: CALayer! = nil
    public var depthDataOutput: AVCaptureDepthDataOutput!
    public var videoDataOutput: AVCaptureVideoDataOutput!
    public var outputVideoSync: AVCaptureDataOutputSynchronizer!
    public let preferredWidthResolution = 1920
    public var sessionConfigured = false
    public var boxCoordinates: [CGRect] = []
    public var boxCenter = CGPoint(x: 0, y: 0)
    public var objectName: String = ""
    public var detectionTimestamps: [TimeInterval] = []
    public var objectCoordinates: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    public var confidence: Float = 0.0
    public var corridorPosition: String = ""
    public var vert: String = ""
    public var objectIDD: Int = -1
//    public var middlePoint: (Int, Int) = ()
    var screenRect: CGRect!
    override init() {
        super.init()
        self.checkPermission()
        // Initialize screenRect here before setting up the capture session and detector
        self.screenRect = UIScreen.main.bounds
//        sessionQueue.async { [unowned self] in
////            self.setupCaptureSession()
////            self.captureSession.startRunning()
////            self.setupDetector()
//        }
    }
    func stopCamera() {
//        captureSession.stopRunning()
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    func startCamera() {
//        CameraSetup.setupCaptureSession(frameHandler: self)
//        captureSession.startRunning() // this should run in a background thread
//        setupDetector()
        if !sessionConfigured {
              CameraSetup.setupCaptureSession(frameHandler: self)
              sessionConfigured = true
          }
          if !captureSession.isRunning {
              captureSession.startRunning()
          }
          setupDetector()
    }
    func setupDetector() {
        guard let modelURL = Bundle.main.url(forResource: "YOLOv3Tiny", withExtension: "mlmodelc") else {
            print("Error: Model file not found")
            return
        }
        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel,
                                                    completionHandler: detectionDidComplete)
            self.requests = [objectRecognition]
        } catch let error {
            print("Error loading Core ML model: \(error)")
        }
    }
    func detectionDidComplete(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if let results = request.results {
                /* print("Detection Results:", results) */ // Check detection results
                self.extractDetections(results)

                /**commented out since the v8 decoder is not yet functional, **/
                //self.handleRawModelOutput(from: results)
            }
        }
    }
    private func createBoundingBoxes(from observation: VNRecognizedObjectObservation, screenRect: CGRect) -> [BoundingBox] {
        var boxes: [BoundingBox] = []
        for label in observation.labels {
            let labelIdentifier = label.identifier
            let confidence = label.confidence
            let objectBounds = VNImageRectForNormalizedRect(
                observation.boundingBox,
                Int(screenRect.size.width),
                Int(screenRect.size.height)
            )
            let transformedBounds = CGRect(
                x: objectBounds.minX,
                y: screenRect.size.height - objectBounds.maxY,
                width: objectBounds.maxX - objectBounds.minX,
                height: objectBounds.maxY - objectBounds.minY
            )
            if let corridor = self.corridorGeometry{
//                let inCorridor = CorridorUtils.isBoundingBoxInCorridor(transformedBounds, corridor: corridor)
//                if !inCorridor{
//                    print("object outside corridor")
//                }
//                else{
//                    print("object inside corridor")
//                }
                let objectPos = CorridorUtils.determinePosition(transformedBounds, corridor: corridor)
                let centerXPercentage = (transformedBounds.midX / screenRect.width) * 100
                let centerYPercentage = (transformedBounds.midY / screenRect.height) * 100
                let direction = DetectionUtils.calculateDirection(centerXPercentage)
                let verticalLocation = DetectionUtils.verticalCorridor(centerYPercentage)
                let box = BoundingBox(
                    classIndex: 0,
                    score: confidence,
                    rect: transformedBounds,
                    name: labelIdentifier,
                    direction: objectPos,
                    vert: verticalLocation
                )
                boxes.append(box)

            }

        }
        return boxes
    }

    /**handleRawModelOutout takes the raw tensors returned by the YOLOV8 model and puts them in a suitable format
       for our NMSHandler function.
         **/
    func handleRawModelOutput(from results: [VNObservation]){
        for result in results{

            if let observation = result as? VNCoreMLFeatureValueObservation,
               let multiArray = observation.featureValue.multiArrayValue{
                print("name???: ",observation.featureName)
                let decodedBoxes = YOLODecoder.decodeOutput(multiArray: multiArray, confidenceThreshold: 0.5)
                let filteredIndices = nonMaxSuppressionMultiClass(
                                numClasses: YOLODecoder.labels.count,
                                boundingBoxes: decodedBoxes,
                                scoreThreshold: 0.5,
                                iouThreshold: 0.4,
                                maxPerClass: 5,
                                maxTotal: 20
                            )
                let filteredBoxes = filteredIndices.map { decodedBoxes[$0] }
                self.boundingBoxes = filteredBoxes

                //let nmsBoxes = NMSHandler.performNMS(on: decodedBoxes)
                //self.boundingBoxes = nmsBoxes
            }
        }
    }


    func extractDetections(_ results: [VNObservation]) {
        // Ensure screenRect is initialized
        guard let screenRect = self.screenRect else {
            print("Error: screenRect is nil")
            return
        }
        // Initialize detectionLayer if needed
        if detectionLayer == nil {
            detectionLayer = CALayer()
            updateLayers() // Ensure detectionLayer frame is updated
        }
        // Set up producer consumer for this part and set up unique ids for bounding boxes for tracking
        DispatchQueue.main.async { [weak self] in
            self?.detectionLayer?.sublayers = nil
            // Create an array to store BoundingBox objects
            var boundingBoxResults: [BoundingBox] = []
            // Iterate through all results
            for result in results {
                // Check if the result is a recognized object observation
                if let observation = result as? VNRecognizedObjectObservation {
                    let boxes = self?.createBoundingBoxes(from: observation, screenRect: screenRect)
                    if let boxes = boxes {
                        boundingBoxResults.append(contentsOf: boxes)
                        // Uncommented debug prints remain preserved:
                        // print("Bounding box: \(boxes)")
                    }
                }
            }
            // Call the NMS function
            self?.boundingBoxes = []
            let filteredResults = NMSHandler.performNMS(on: boundingBoxResults)
            self?.boundingBoxes = filteredResults
        }
    }
    private func calculateAngle(centerX: CGFloat) -> Int { // RDA
        let centerPercentage = (centerX / self.screenRect.width) * 100 // RDA
        return Int(centerPercentage * 360 / 100) // Simplified calculation for the angle // RDA
    }
    func updateLayers() {
        detectionLayer?.frame = CGRect(
            x: 0,
            y: 0,
            width: screenRect.size.width,
            height: screenRect.size.height
        )
    }
    func drawBoundingBox(_ bounds: CGRect) -> CALayer {
        let boxLayer = CALayer()
        if bounds.isEmpty {
            print("Error: Invalid bounds in drawBoundingBox")
            return boxLayer  // Return an empty layer
        }
        return boxLayer // Need to finish
    }
    // Function that checks to ensure that the user has agreed to allow the use of the camera.
    // Unavoidable as this is integral to Apple infrastructure
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            self.permissionGranted = true
        case .notDetermined: // The user has not yet been asked for camera access.
            self.requestPermission()
        // Combine the two other cases into the default case
        default:
            self.permissionGranted = false
        }
    }
    // Function that requests permission from the user to use the camera.
    func requestPermission() {
        // Strong reference not a problem here but might become one in the future.
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
        }
    }
    // SwiftUI View for displaying camera output
    struct DetectionView: View {
        @ObservedObject var frameHandler: FrameHandler = FrameHandler()
        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    CameraPreview(session: frameHandler.captureSession)
                        .scaledToFill()
                        .frame(width: geometry.size.width,
                               height: geometry.size.height)
                    BoundingBoxLayer(layer: frameHandler.detectionLayer)
                        .frame(width: geometry.size.width,
                               height: geometry.size.height)
                }
            }
        }
    }
}
extension FrameHandler: AVCaptureDataOutputSynchronizerDelegate {
    func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer,
                                didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection) {
        // Retrieve the synchronized depth data
        guard let syncedDepthData = synchronizedDataCollection
                .synchronizedData(for: depthDataOutput) as? AVCaptureSynchronizedDepthData,
              let syncedVideoData = synchronizedDataCollection
                .synchronizedData(for: videoDataOutput) as? AVCaptureSynchronizedSampleBufferData
        else { return }
        // Process the video frame for yolo
        if let cgImage = imageFromSampleBuffer(sampleBuffer: syncedVideoData.sampleBuffer) {
            DispatchQueue.main.async { [unowned self] in
                self.frame = cgImage
            }
        }
        //creates array that will hold the recent detections to help us parse out outlers.
    
        var recentDetections: [DetectionOutput] = []
        let depthMap = syncedDepthData.depthData.depthDataMap
        CVPixelBufferLockBaseAddress(depthMap, .readOnly)
        let width = Float(CVPixelBufferGetWidth(depthMap))
        let height = CVPixelBufferGetHeight(depthMap)
        // Lock the pixel address so we are not moving around too much
        //            ($0.rect.width * $0.rect.height) < ($1.rect.width * $1.rect.height)
        //WE ARE USING SCORE BUT IT SAYS LARGEST
        guard let largestBox = self.boundingBoxes.max(by: {
            ($0.score < $1.score)
        }) else {
            // No bounding box detected; skip processing.
            CVPixelBufferUnlockBaseAddress(depthMap, .readOnly)
            return
        }
        boxCenter = CGPoint(x: largestBox.rect.midX, y: largestBox.rect.midY)
        self.objectName = largestBox.name
        self.objectCoordinates = largestBox.rect
        self.confidence = largestBox.score
        self.corridorPosition = largestBox.direction
        self.objectIDD = largestBox.classIndex
        self.vert = largestBox.vert
        // Get the baseadress of pixel and turn it into a Float16 so it is readable.
        let baseAddress = unsafeBitCast(
            CVPixelBufferGetBaseAddress(depthMap),
            to: UnsafeMutablePointer<Float16>.self
        )
//        let centerX = Float(CGFloat(width) * (boxCenter.x / screenRect.width))
//        let centerY = Float(CGFloat(height) * (boxCenter.y / screenRect.height))
//        let windowSize = 100
//        //Max and min ensure that when the bounty box is far left or far right of screen we do not get nevative value or values taht exceed the width
//        let leftX = max(centerX - Float(windowSize), 0)
//        let rightX = min(centerX + Float(windowSize), width - 1)
//        let bottomY = max(centerY - Float(windowSize), 0)
//        let topY = min(centerY + Float(windowSize), width - 1)
////        var totalDepth: Float16 = 0
//        var count = 0
//        var depthSamples = [Float16]()
//        //For each X and Y value find the depth and add it to a list to find the median value
//        for yVal in Int(bottomY)...Int(topY) {
//            for xVal in Int(leftX)...Int(rightX){
//                depthSamples.append(baseAddress[yVal * Int(width) + xVal])
////                totalDepth += baseAddress[y * Int(width) + x]
//                count += 1
//            }
//        }
        //  Compute bounding box corners in screen coordinates
        let boxMinX = largestBox.rect.minX
        let boxMaxX = largestBox.rect.maxX
        let boxMinY = largestBox.rect.minY
        let boxMaxY = largestBox.rect.maxY

        // Convert from screen coordinates to depth-map coordinates
        let depthMinX = Int((boxMinX / screenRect.width) * CGFloat(width))
        let depthMaxX = Int((boxMaxX / screenRect.width) * CGFloat(width))
        let depthMinY = Int((boxMinY / screenRect.height) * CGFloat(height))
        let depthMaxY = Int((boxMaxY / screenRect.height) * CGFloat(height))

        // Clamp the values so they never go outside the depth buffer array
        let clampedMinX = max(depthMinX, 0)
        let clampedMaxX = min(depthMaxX, Int(width) - 1)
        let clampedMinY = max(depthMinY, 0)
        let clampedMaxY = min(depthMaxY, Int(height) - 1)
        var count: Float16 = 0
        var totalDepth: Float16 = 0
        
        // Collect all depth samples from the bounding box
        var depthSamples = [Float16]()
        for yVal in clampedMinY...clampedMaxY {
            for xVal in clampedMinX...clampedMaxX {
                let depthIndex = yVal * Int(width) + xVal
                depthSamples.append(baseAddress[depthIndex])
                totalDepth += baseAddress[yVal * Int(width) + xVal]
                count += 1
            }
        }
        var invDepthSum: Float32 = 0        // sum of (1 / disparity) = metres
        var validCount = 0

        for raw in depthSamples {
            if raw > 0 {                    // skip invalid / zero disparities
                invDepthSum += 1.0 / Float32(raw)   // convert to metres first
                validCount += 1
            }
        }


        // Now store the value you actually want to use:
//        let correctedDepth: Float16 = Float16(meanDistanceMetres)
//        let averageDepth = count > 0 ? totalDepth / Float16(count) : 0
        let medianDepth = self.findMedian(distances: depthSamples)
        // This inverts the depth value as the distance is inversed naturally
        let correctedDepth: Float16 = medianDepth > 0 ? 1.0 / medianDepth : 0
        CVPixelBufferUnlockBaseAddress(depthMap, .readOnly)
        DispatchQueue.main.async {
            let newDetection = DetectionOutput(objcetName: self.objectName, distance: correctedDepth, corridorPosition: self.corridorPosition, id: self.objectIDD, vert: self.vert)
            if recentDetections.count > 5 {
                recentDetections.removeFirst()
            }
            recentDetections.append(newDetection)
            var frequency: [String: Int] = [ :]
            var simplifiedDetection: [Float16] = []
            //Finds the string that appears the most
            for detection in recentDetections {
                frequency[detection.objcetName, default: 0] += 1
            }
            let sortedFrequency = frequency.sorted(by: {$0.value < $1.value})
            let commonLabel = sortedFrequency[0].key
            var totalDistance: Float16 = 0
            var finalCount: Float16 = 0
            for detection in recentDetections {
                if detection.objcetName == commonLabel {
                    totalDistance = detection.distance
                    finalCount += 1
                    simplifiedDetection.append(detection.distance)
                    self.corridorPosition = detection.corridorPosition //gets the last, and most accuract angle of the common object
                    self.objectIDD = detection.id
                }
            }
//            self.objectDistance = self.findMedian(distances: simplifiedDetection)
            self.objectDistance = finalCount > 0 ? totalDistance / Float16(finalCount) : 0
            self.objectName = commonLabel

            // Get XY coords; Functionality unused as of now, but may be needed in future development
            // let objectCoords = DetectionUtils.polarToCartesian(distance: Float(self.objectDistance), direction: self.angle)

            let objectDetected = DetectedObject(objName: self.objectName, distance: self.objectDistance, corridorPosition: self.corridorPosition, vert: self.vert)
            let block = DecisionBlock(detectedObject: objectDetected)
            let objectThreatLevel = block.computeThreatLevel(for: objectDetected)
            let processedObject = ProcessedObject(objName: self.objectName, distance: self.objectDistance, corridorPosition: self.corridorPosition, vert: self.vert, threatLevel: objectThreatLevel)
            block.processDetectedObjects(processed: processedObject)

            //let audioOutput = AudioQueue.popHighestPriorityObject(threshold: 1)
//            if audioOutput?.threatLevel ?? 0 > 1{
//                content.append("Object name: \(audioOutput!.objName),")
//                content.append("Object direction: \(audioOutput!.corridorPosition),")
//                content.append("Object Verticality: \(audioOutput!.vert),")
//                content.append("Object distance: \(audioOutput!.distance),")
//                content.append("Threat level: \(audioOutput!.threatLevel),")
//                content.append("Distance as a Float: \(Float(audioOutput!.distance)),\n")

//                //print(content)
//            }
        }
    }
    func findMedian(distances: [Float16]) -> Float16
    {
        let count = distances.count
        guard count > 0 else { return 0 }
        if count % 2 == 1 {
            return distances[count / 2] // Odd number of elements: return the middle one.
        } else {
            // Even number of elements: average the two middle ones.
            let lower = distances[count / 2 - 1]
            let upper = distances[count / 2]
            return (lower + upper) / 2
        }
    }
}
extension FrameHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        guard let cgImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else {
            return
        }
        // All UI updates should be performed on the main queue.
        DispatchQueue.main.async { [unowned self] in
            self.frame = cgImage
            // self.boundingBoxes = []
        }
        do {
            let requestHandler = VNImageRequestHandler(cgImage: cgImage) // Create an instance
            try requestHandler.perform(self.requests) // Use the instance
        } catch {
            print(error)
        }
    }
    // Private function that creates the sample buffer
    private func imageFromSampleBuffer(sampleBuffer: CMSampleBuffer) -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return nil
        }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        return cgImage
    }
}
// Everything below is me trying to figure out the display of bounding boxes on the screen
struct CameraPreview: UIViewRepresentable {
    var session: AVCaptureSession

    func makeUIView(context: Context) -> some UIView {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        let view = UIView()
        previewLayer.frame = view.layer.bounds
        view.layer.addSublayer(previewLayer)
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}
}
struct BoundingBoxLayer: UIViewRepresentable {
    var layer: CALayer?
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        return view
    }
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let layer = layer else { return }
        // Remove any existing sublayers
        uiView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        // Scale the layer to match the size of the preview
        let scale = UIScreen.main.scale
        layer.frame = CGRect(
            x: 0,
            y: 0,
            width: uiView.bounds.width * scale,
            height: uiView.bounds.height * scale
        )
        uiView.layer.addSublayer(layer)  // Add the layer to the view's layer
    }
}
struct DetectionOutput{
    let objcetName: String
    let distance: Float16
    let corridorPosition: String
    let id: Int
    let vert: String
}
