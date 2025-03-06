// Obstacle Avoidance App
// FrameHandler.swift
//
//
//  Swift file that is used to setup the camera/frame capture.
// This is what will likely be modified for CoreML implementation.
//
//

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
    public var angle: String = ""

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
        captureSession.stopRunning()
    }
    func startCamera() {
        CameraSetup.setupCaptureSession(frameHandler: self)
        captureSession.startRunning() // this should run in a background thread
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
            }
        }
    }
    private func createBoundingBoxes(from observation: VNRecognizedObjectObservation,
                                     screenRect: CGRect) -> [BoundingBox] {
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
            let direction = calculateDirection(centerXPercentage)
            let box = BoundingBox(
                classIndex: 0,
                score: confidence,
                rect: transformedBounds,
                name: labelIdentifier,
                direction: direction
            )
            boxes.append(box)
        }
        return boxes
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
    // Helper function to calculate direction from percentage // RDA
    private func calculateDirection(_ percentage: CGFloat) -> String { // RDA
        switch percentage {
        case 0..<16.67:
            return "9 o'clock"
        case 16.67..<33.33:
            return "10 o'clock"
        case 33.33..<50:
            return "11 o'clock"
        case 50..<66.67:
            return "12 o'clock"
        case 66.67..<83.33:
            return "1 o'clock"
        case 83.33..<100:
            return "2 o'clock"
        default:
            return "Unknown"
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
        // Need to finish
        return boxLayer
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
        guard let largestBox = self.boundingBoxes.max(by: {
            ($0.rect.width * $0.rect.height) < ($1.rect.width * $1.rect.height)
        }) else {
            // No bounding box detected; skip processing.
            CVPixelBufferUnlockBaseAddress(depthMap, .readOnly)
            return
        }
        boxCenter = CGPoint(x: largestBox.rect.midX, y: largestBox.rect.midY)
        self.objectName = largestBox.name
        self.objectCoordinates = largestBox.rect
        self.confidence = largestBox.score
        self.angle = largestBox.direction
        
        // Get the baseadress of pixel and turn it into a Float16 so it is readable.
        let baseAddress = unsafeBitCast(
            CVPixelBufferGetBaseAddress(depthMap),
            to: UnsafeMutablePointer<Float16>.self
        )
    
        let centerX = Float(CGFloat(width) * (boxCenter.x / screenRect.width))
        let centerY = Float(CGFloat(height) * (boxCenter.y / screenRect.height))
        let windowSize = 5
        //Max and min ensure that when the bounty box is far left or far right of screen we do not get nevative value or values taht exceed the width
        let leftX = max(centerX - Float(windowSize), 0)
        let rightX = min(centerX + Float(windowSize), width - 1)
        let bottomY = max(centerY - Float(windowSize), 0)
        let topY = min(centerY + Float(windowSize), width - 1)
//        var totalDepth: Float16 = 0
        var count = 0
        var depthSamples = [Float16]()
        //For each X and Y value find the depth and add it to a list to find the median value
        for yVal in Int(bottomY)...Int(topY) {
            for xVal in Int(leftX)...Int(rightX){
                depthSamples.append(baseAddress[yVal * Int(width) + xVal])
//                totalDepth += baseAddress[y * Int(width) + x]
                count += 1
            }
        }
//        let averageDepth = count > 0 ? totalDepth / Float16(count) : 0
        let medianDepth = self.findMedian(distances: depthSamples)
        // This inverts the depth value as the distance is inversed naturally
        let correctedDepth: Float16 = medianDepth > 0 ? 1.0 / medianDepth : 0
        CVPixelBufferUnlockBaseAddress(depthMap, .readOnly)
           
        DispatchQueue.main.async {
            // print("Measured distance: \(depthVal) meters")
//            print("Coordinates: \(self.objectCoordinates)")
//            print("Detections per second: \(self.detectionTimestamps.count)")
            let newDetection = DetectionOutput(objcetName: self.objectName, distance: correctedDepth, angle: self.angle)
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
            for detection in recentDetections {
                if detection.objcetName == commonLabel {
                    simplifiedDetection.append(detection.distance)
                    //gets the last, and most accuract angle of the common object
                    self.angle = detection.angle
                }
            }
            self.objectDistance = self.findMedian(distances: simplifiedDetection)
            self.objectName = commonLabel
            print("Object detected: \(self.objectName)")
//            print("Box centerX: \(self.boxCenter.x) Box CenterY: \(self.boxCenter.y)")
//            print("Confidence score: \(self.confidence)")
            print("Corrected distance: \(self.objectDistance) meters")
            print("angle: \(self.angle) o'clock")

        }
    }
    func findMedian(distances: [Float16]) -> Float16
    {
        let count = distances.count
        guard count > 0 else { return 0 }
        if count % 2 == 1 {
            // Odd number of elements: return the middle one.
            return distances[count / 2]
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
        // Add the layer to the view's layer
        uiView.layer.addSublayer(layer)
    }
}

struct DetectionOutput{
    let objcetName: String
    let distance: Float16
    let angle: String
}
