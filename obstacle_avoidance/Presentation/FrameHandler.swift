// Obstacle Avoidance App
// FrameHandler.swift
//  Swift file that is used to setup the camera/frame capture. This is what will likely be modified for CoreML implementation.
import SwiftUI
import ARKit
import Vision
import CoreImage
class FrameHandler: NSObject, ObservableObject, ARSessionDelegate {
    enum ConfigurationError: Error {
        case lidarDeviceUnavailable
        case requiredFormatUnavailable
    }
    //OLD CODE THAT ACESSED CAMERAS
    //    @Published var frame: CGImage?
    //    @Published var boundingBoxes: [BoundingBox] = []
    //    @Published var objectDistance: Float32 = 0.0
    //    // Initializing variables related to capturing image.
    //    private var permissionGranted = true
    //    public let captureSession = AVCaptureSession()
    //    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    //    private let context = CIContext()
    //    private var requests = [VNRequest]() // To hold detection requests
    //    private var detectionLayer: CALayer! = nil
    //    public var depthDataOutput: AVCaptureDepthDataOutput!
    //    public var videoDataOutput: AVCaptureVideoDataOutput!
    //    public var outputVideoSync: AVCaptureDataOutputSynchronizer!
    //    public let preferredWidthResolution = 1920
    //    public var sessionConfigured = false
    //    public var boxCoordinates: [CGRect] = []
    //    public var boxCenter = CGPoint(x: 0, y: 0)
    //    public var objectName: String = ""
    //    public var detectionTimestamps: [TimeInterval] = []
    //    public var objectCoordinates: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    //    public var confidence: Float = 0.0
    //    public var angle: String = ""
    //    public var vert: String = ""
    //    public var objectIDD: Int = -1
    ////    public var middlePoint: (Int, Int) = ()
    //    var screenRect: CGRect!
    //    override init() {
    //        super.init()
    //        self.checkPermission()
    //        // Initialize screenRect here before setting up the capture session and detector
    //        self.screenRect = UIScreen.main.bounds
    ////        sessionQueue.async { [unowned self] in
    //////            self.setupCaptureSession()
    //////            self.captureSession.startRunning()
    //////            self.setupDetector()
    ////        }
    //    }
    //    func stopCamera() {
    ////        captureSession.stopRunning()
    //        if captureSession.isRunning {
    //            captureSession.stopRunning()
    //        }
    //    }
    //    func startCamera() {
    ////        CameraSetup.setupCaptureSession(frameHandler: self)
    ////        captureSession.startRunning() // this should run in a background thread
    ////        setupDetector()
    //        if !sessionConfigured {
    //              CameraSetup.setupCaptureSession(frameHandler: self)
    //              sessionConfigured = true
    //          }
    //          if !captureSession.isRunning {
    //              captureSession.startRunning()
    //          }
    //          setupDetector()
    //    }
    @Published var frame: CGImage?
    @Published var boundingBoxes: [BoundingBox] = []
    @Published var objectDistance: Float32 = 0.0
    
    // Keep your existing YOLO request array, context, etc.
    private var requests = [VNRequest]()
    private let context = CIContext()
    private var permissionGranted = true
    
    private var arSession: ARSession = ARSession()
    private var screenRect: CGRect = .zero
    private var rollingDetections: [DetectionOutput] = []
    private let maxHistory = 5
    private let visionQueue = DispatchQueue(label: "vision", qos: .userInitiated)
    private var isProcessing = false
    public var vert: String = ""
    public var angle: String = ""
    public var objectName: String = ""
    public var objectIDD: Int = -1
    
    override init() {
        super.init()
        setupDetector()
        checkPermission()
    }
    
    // Start the AR session and register as the session’s delegate.
    func startSession() {
        // Starts the AR kit and enables us to start tracking the scene depth
        guard self.permissionGranted == true else{return}
        let configuration = ARWorldTrackingConfiguration()
        if ARWorldTrackingConfiguration.supportsFrameSemantics(.sceneDepth) {
            configuration.frameSemantics = .sceneDepth
        }
        // Might be able to do plane detection with configuration.planeDetection = [.horizontal, .vertical]
        
        arSession.delegate = self
        arSession.run(configuration)
        
        // We can store screen bounds here for bounty box transforms
        self.screenRect = UIScreen.main.bounds
    }
    
    // Stop the AR session. Apple says its needed
    func stopSession() {
        arSession.pause()
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
    // Converts a CVPixelBuffer from ARKit to CGImage so we can run it through Vision.
    private func convertToCGImage(pixelBuffer: CVPixelBuffer) -> CGImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.right)
        return context.createCGImage(ciImage, from: ciImage.extent)
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
            let centerXPercentage = (transformedBounds.midX / screenRect.width) * 100
            let centerYPercentage = (transformedBounds.midY / screenRect.height) * 100
            let direction = DetectionUtils.calculateDirection(centerXPercentage)
            let verticalLocation = DetectionUtils.verticalCorridor(centerYPercentage)
            let box = BoundingBox(
                classIndex: 0,
                score: confidence,
                rect: transformedBounds,
                name: labelIdentifier,
                direction: direction,
                vert: verticalLocation
            )
            boxes.append(box)
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
        guard screenRect != .zero else {
            print("Error: screenRect is nil")
            return
        }
        // Initialize detectionLayer if needed
        //FOR AR KIT DO NOT NEED THIS
        //        if detectionLayer == nil {
        //            detectionLayer = CALayer()
        //            updateLayers() // Ensure detectionLayer frame is updated
        //        }
        //I moved this outside of async because we do not want to be doing all of this per frame. We can do it before
        var boundingBoxResults: [BoundingBox] = []
        for result in results {
            if let observation = result as? VNRecognizedObjectObservation {
                let boxes = self.createBoundingBoxes(from: observation, screenRect: screenRect)
                boundingBoxResults.append(contentsOf: boxes)
                // Uncommented debug prints remain preserved:
                // print("Bounding box: \(boxes)")
            }
        }
        let filteredResults = NMSHandler.performNMS(on: boundingBoxResults)
        // Set up producer consumer for this part and set up unique ids for bounding boxes for tracking
        DispatchQueue.main.async {
            self.boundingBoxes = filteredResults
            //            self?.detectionLayer?.sublayers = nil
            //            // Create an array to store BoundingBox objects
            //            var boundingBoxResults: [BoundingBox] = []
            //            // Iterate through all results
            //            for result in results {
            //                // Check if the result is a recognized object observation
            //                if let observation = result as? VNRecognizedObjectObservation {
            //                    let boxes = self?.createBoundingBoxes(from: observation, screenRect: screenRect)
            //                    if let boxes = boxes {
            //                        boundingBoxResults.append(contentsOf: boxes)
            //                        // Uncommented debug prints remain preserved:
            //                        // print("Bounding box: \(boxes)")
            //                    }
            //                }
            //            }
            //            // Call the NMS function
            //            self?.boundingBoxes = []
            //            let filteredResults = NMSHandler.performNMS(on: boundingBoxResults)
            //            self?.boundingBoxes = filteredResults
            //        }
        }
    }
    private func calculateAngle(centerX: CGFloat) -> Int { // RDA
        let centerPercentage = (centerX / self.screenRect.width) * 100 // RDA
        return Int(centerPercentage * 360 / 100) // Simplified calculation for the angle // RDA
    }
    //    func updateLayers() {
    //        detectionLayer?.frame = CGRect(
    //            x: 0,
    //            y: 0,
    //            width: screenRect.size.width,
    //            height: screenRect.size.height
    //        )
    //    }
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
    //    // SwiftUI View for displaying camera output
    //    struct DetectionView: View {
    //        @ObservedObject var frameHandler: FrameHandler = FrameHandler()
    //        var body: some View {
    //            GeometryReader { geometry in
    //                ZStack {
    //                    CameraPreview(session: frameHandler.captureSession)
    //                        .scaledToFill()
    //                        .frame(width: geometry.size.width,
    //                               height: geometry.size.height)
    //                    BoundingBoxLayer(layer: frameHandler.detectionLayer)
    //                        .frame(width: geometry.size.width,
    //                               height: geometry.size.height)
    //                }
    //            }
    //        }
    //    }
    //}
}
    extension FrameHandler {
        func session(_ session: ARSession,
                     didUpdate frame: ARFrame) {
            // Retrieve the synchronized depth data
            //        guard let syncedDepthData = synchronizedDataCollection
            //                .synchronizedData(for: depthDataOutput) as? AVCaptureSynchronizedDepthData,
            //              let syncedVideoData = synchronizedDataCollection
            //                .synchronizedData(for: videoDataOutput) as? AVCaptureSynchronizedSampleBufferData
            //        else { return }
            // Process the video frame for yolo
            // 1) Convert the camera image to CGImage
            guard !isProcessing else { return }     // drop frame if busy
            isProcessing = true

            autoreleasepool{
                let cgImage = convertToCGImage(pixelBuffer: frame.capturedImage)
                
                guard let image = cgImage else {return}
                //  Run YOLO on that CGImage
                visionQueue.async { [weak self] in
                    guard let self = self else { return }
                    let requestHandler = VNImageRequestHandler(cgImage: image, orientation: .right, options: [:])
                    try? requestHandler.perform(self.requests)
                    DispatchQueue.main.async {
                        self.frame = image
                    }
                    self.isProcessing = false       // ready for next frame
                }
                
                
                //creates array that will hold the recent detections to help us parse out outlers.
                //        var content = ""
                //        let fileName = "logs.txt"
                //        var recentDetections: [DetectionOutput] = []
                //        let depthMap = syncedDepthData.depthData.depthDataMap
                //        CVPixelBufferLockBaseAddress(depthMap, .readOnly)
                //        let width = Float(CVPixelBufferGetWidth(depthMap))
                //        let height = CVPixelBufferGetHeight(depthMap)
                // Lock the pixel address so we are not moving around too much
                //            ($0.rect.width * $0.rect.height) < ($1.rect.width * $1.rect.height)
                //WE ARE USING SCORE BUT IT SAYS LARGEST
                
                // grab the depth map from ARKit if its available
                if let depthMap = frame.sceneDepth?.depthMap,
                      let bestBox = self.boundingBoxes.max(by: { $0.score < $1.score }) {
                          
                          let distance = self.sampleDepth(at: bestBox.rect, depthMap: depthMap)
                          self.postProcess(bestBox: bestBox, distance: distance)
                      }
            }
        }
        private func sampleDepth(at box: CGRect, depthMap: CVPixelBuffer) -> Float32{
            CVPixelBufferLockBaseAddress(depthMap, .readOnly)
            let fmt = CVPixelBufferGetPixelFormatType(depthMap)
            let width = CGFloat(CVPixelBufferGetWidth(depthMap))
            let height = CGFloat(CVPixelBufferGetHeight(depthMap))
            let x = box.midX / screenRect.width * width
            let y = box.midY / screenRect.height * height
            let windowSize = 50
            let leftX = max(x - CGFloat(windowSize), 0)
            let rightX = min(x + CGFloat(windowSize), width - 1)
            let bottomY = max(y - CGFloat(windowSize), 0)
            let topY = min(y + CGFloat(windowSize), height - 1)
            var depthSamples = [Float32]()
            var count = 0
            let baseAddress = unsafeBitCast(
                CVPixelBufferGetBaseAddress(depthMap),
                to: UnsafeMutablePointer<Float32>.self)
            for yVal in Int(bottomY)...Int(topY) {
                for xVal in Int(leftX)...Int(rightX){
                    depthSamples.append(baseAddress[yVal * Int(width) + xVal])
    //                totalDepth += baseAddress[y * Int(width) + x]
                    count += 1
                }
            }
            CVPixelBufferUnlockBaseAddress(depthMap, .readOnly)
            depthSamples.sort()
            let medianDepth = self.findMedian(distances: depthSamples)
            return medianDepth
            
        }
        
        private func postProcess(bestBox: BoundingBox, distance: Float32){
            rollingDetections.append(
                    DetectionOutput(objcetName: bestBox.name,
                                    distance: Float32(distance),
                                    angle: bestBox.direction,
                                    vert: bestBox.vert)
                )
                if rollingDetections.count > maxHistory {
                    rollingDetections.removeFirst()
                }

                // --- Pick the most common label in the cache
                let modeLabel = rollingDetections
                    .reduce(into: [:]) { $0[$1.objcetName, default: 0] += 1 }
                    .max(by: { $0.value < $1.value })?.key ?? bestBox.name

                // --- Gather distances for that label and take the median
                let labelDistances = rollingDetections
                    .filter { $0.objcetName == modeLabel }
                    .map(\.distance)
                    .sorted()
            
                let robustDistance = findMedian(distances: labelDistances)

                // Save for UI / threat logic
                self.objectDistance = robustDistance
                self.objectName = modeLabel
                self.angle = bestBox.direction
                self.vert = bestBox.vert
                self.objectIDD = bestBox.classIndex

                // Existing threat-level pipeline
                let detected = DetectedObject(objName: objectName,
                                              distance: robustDistance,
                                              angle: angle,
                                              vert: vert)
                let block  = DecisionBlock(detectedObject: detected)
                let threat = block.computeThreatLevel(for: detected)

                block.processDetectedObjects(processed:
                    ProcessedObject(objName: objectName,
                                    distance: robustDistance,
                                    angle: angle,
                                    vert: vert,
                                    threatLevel: threat)
                )

            // Get XY coords; Functionality unused as of now, but may be needed in future development
            // let objectCoords = DetectionUtils.polarToCartesian(distance: Float(self.objectDistance), direction: self.angle)

//            let objectDetected = DetectedObject(objName: self.objectName, distance: self.objectDistance, angle: self.angle, vert: self.vert)
//            let block = DecisionBlock(detectedObject: objectDetected)
//            let objectThreatLevel = block.computeThreatLevel(for: objectDetected)
//            let processedObject = ProcessedObject(objName: self.objectName, distance: self.objectDistance, angle: self.angle, vert: self.vert, threatLevel: objectThreatLevel)
//            block.processDetectedObjects(processed: processedObject)
//            let audioOutput = AudioQueue.popHighestPriorityObject(threshold: 10)
//            if audioOutput?.threatLevel ?? 0 > 1{
//                content.append("Object name: \(audioOutput!.objName),")
//                content.append("Object angle: \(audioOutput!.angle),")
//                content.append("Object Verticality: \(audioOutput!.vert),")
//                content.append("Object distance: \(audioOutput!.distance),")
//                content.append("Threat level: \(audioOutput!.threatLevel),")
//                content.append("Distance as a Float: \(Float(audioOutput!.distance)),\n")
//                print(content)
//            }
        }
    func findMedian(distances: [Float32]) -> Float32
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
    let distance: Float32
    let angle: String
    let vert: String
}
