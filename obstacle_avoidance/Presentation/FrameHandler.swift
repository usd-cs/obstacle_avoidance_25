//Obstacle Avoidance App
//FrameHandler.swift
//
//
//  Swift file that is used to setup the camera/frame capture. This is what will likely be modified for CoreML implementation.
//
//

import SwiftUI
import AVFoundation
import CoreImage
import Vision

class FrameHandler: NSObject, ObservableObject {
    @Published var frame: CGImage?
    @Published var boundingBoxes: [BoundingBox] = []
    
    // Initializing variables related to capturing image.
    private var permissionGranted = true
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let context = CIContext()
    private var requests = [VNRequest]() // To hold detection requests
    private var detectionLayer: CALayer! = nil
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
    
    func startCamera(){
        setupCaptureSession()
        captureSession.startRunning() // TODO: Run in a background thread
        setupDetector()
    }

    
    func setupDetector() {
        guard let modelURL = Bundle.main.url(forResource: "YOLOv3Tiny", withExtension: "mlmodelc") else {
            print("Error: Model file not found")
            return
        }

        do {
            let visionModel = try VNCoreMLModel(for: MLModel(contentsOf: modelURL))
            let objectRecognition = VNCoreMLRequest(model: visionModel, completionHandler: detectionDidComplete)
            self.requests = [objectRecognition]
        } catch let error {
            print("Error loading Core ML model: \(error)")
        }
    }
    
    func detectionDidComplete(request: VNRequest, error: Error?) {
        DispatchQueue.main.async(execute: {
            if let results = request.results {
               /* print("Detection Results:", results)*/ // Check detection results
                self.extractDetections(results)
            }
        })
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

        // TODO: Set up producer consumer for this part and set up unique ids for bounding boxes for tracking
        DispatchQueue.main.async { [weak self] in
            self?.detectionLayer?.sublayers = nil

            // Create an array to store BoundingBox objects
            var boundingBoxResults: [BoundingBox] = []

            // Iterate through all results
            for result in results {
                // Check if the result is a recognized object observation
                if let observation = result as? VNRecognizedObjectObservation {
                    // Iterate through labels in the observation
                    for label in observation.labels {
                        // Extract label identifier, confidence, and bounding box
                        let labelIdentifier = label.identifier
//                        print(labelIdentifier)
                        let confidence = label.confidence
                        
                        // Transform bounding box
                        let objectBounds = VNImageRectForNormalizedRect(observation.boundingBox, Int(screenRect.size.width), Int(screenRect.size.height))
                        let transformedBounds = CGRect(x: objectBounds.minX, y: screenRect.size.height - objectBounds.maxY, width: objectBounds.maxX - objectBounds.minX, height: objectBounds.maxY - objectBounds.minY)
                        
                    // Calculate direction based on the bounding box's center x percentage //RDA
                        let centerXPercentage = (transformedBounds.midX / screenRect.width) * 100 //RDA
                        let direction = self?.calculateDirection(centerXPercentage) //RDA

                        // Create BoundingBox object
                        let boundingBox = BoundingBox(classIndex: 0, score: confidence, rect: transformedBounds, name: labelIdentifier, direction: direction!) //RDA

                        // Add BoundingBox object to the array
                        boundingBoxResults.append(boundingBox)
                    }
                }
            }

            // Call the NMS function
            self?.boundingBoxes = []
            let filteredResults = NMSHandler.performNMS(on: boundingBoxResults)
            self?.boundingBoxes = filteredResults

            // // Find the observation with the highest confidence
            // if let highestObservation = results
            //     .compactMap({ $0 as? VNRecognizedObjectObservation })
            //     .max(by: { $0.confidence < $1.confidence }) {

            //     // Extract the label with the highest confidence
            //     let highestLabel = highestObservation.labels.first?.identifier ?? "Unknown"
            //     print("Highest Confidence Label: \(highestLabel)")
            //     self?.objectName = highestLabel

            //     // Transform bounding box
            //     let objectBounds = VNImageRectForNormalizedRect(highestObservation.boundingBox, Int(screenRect.size.width), Int(screenRect.size.height))
            //     let transformedBounds = CGRect(x: objectBounds.minX, y: screenRect.size.height - objectBounds.maxY, width: objectBounds.maxX - objectBounds.minX, height: objectBounds.maxY - objectBounds.minY)
                
            //     self?.boundingBoxes = []
            //     let transformedBox = BoundingBox(rect: transformedBounds)
            //     self?.boundingBoxes.append(transformedBox)

            //     let boxLayer = self?.drawBoundingBox(transformedBounds)

            //     // Safely unwrap detectionLayer before accessing
            //     if let detectionLayer = self?.detectionLayer {
            //         detectionLayer.addSublayer(boxLayer ?? CALayer())
            //     }
            // }
        }
    }
    
    // Helper function to calculate direction from percentage //RDA
    private func calculateDirection(_ percentage: CGFloat) -> String { //RDA
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

    private func calculateAngle(centerX: CGFloat) -> Int { //RDA
        let centerPercentage = (centerX / self.screenRect.width) * 100 //RDA
        return Int(centerPercentage * 360 / 100) // Simplified calculation for the angle //RDA
    }


    
    func updateLayers(){
        detectionLayer?.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
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
    
    // Function that creates the variables needed for video capturing.
    func setupCaptureSession() {
        let videoOutput = AVCaptureVideoDataOutput()
        
        guard permissionGranted else { return }
        guard let videoDevice = AVCaptureDevice.default(.builtInDualWideCamera,for: .video, position: .back) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(videoOutput)
        
        videoOutput.connection(with: .video)?.videoOrientation = .portrait //NOTE: .videoOrientation was depreciated in ios 17 but still works as of the current version.
    }
    
    // SwiftUI View for displaying camera output
    struct DetectionView: View {
            @ObservedObject var frameHandler: FrameHandler = FrameHandler()

            var body: some View {
                GeometryReader { geometry in
                    ZStack {
                        CameraPreview(session: frameHandler.captureSession)
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                        
                        BoundingBoxLayer(layer: frameHandler.detectionLayer)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                }
            }
        }
}


// AVCaptureVideoDataOutputSampleBufferDelegate implementation
extension FrameHandler: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cgImage = imageFromSampleBuffer(sampleBuffer: sampleBuffer) else { return }
        
        // All UI updates should be performed on the main queue.
        DispatchQueue.main.async { [unowned self] in
            self.frame = cgImage
            //self.boundingBoxes = []
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
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: imageBuffer)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        
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
        layer.frame = CGRect(x: 0, y: 0, width: uiView.bounds.width * scale, height: uiView.bounds.height * scale)
        
        // Add the layer to the view's layer
        uiView.layer.addSublayer(layer)
    }
}
