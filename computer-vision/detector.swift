//
//  detector.swift
//  obstacle_avoidance
//
//  Created by Kenny Collins on 2/22/24.
//


import UIKit
import SwiftUI
import AVFoundation
import Vision


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var permissionGranted = false // Flag for permission
    private let captureSession = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private var previewLayer = AVCaptureVideoPreviewLayer()
    var screenRect: CGRect! = nil // For view dimensions
    
    // Detector
    private var videoOutput = AVCaptureVideoDataOutput()
    var requests = [VNRequest]()
    var detectionLayer: CALayer! = nil
    
    // Function to set up any additional layers or views needed for the camera preview
    func setupLayers() {
        // Create a preview layer for displaying the camera feed
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill // Adjust the content to fill the layer bounds
        
        // Add the preview layer to the view's layer
        view.layer.addSublayer(previewLayer)
    }

    // Function to update any layers or views when needed
    func updateLayers() {
        // Update the preview layer's frame to match the current view bounds
        previewLayer.frame = view.bounds
    }
    
    // Function to process the results of object detection
    func processDetectionResults(_ results: [VNRecognizedObjectObservation]) {
        // Process the detected objects here
        for result in results {
            // Access information about the detected object
            let objectLabel = result.labels.first?.identifier ?? "Unknown"
            let confidence = result.labels.first?.confidence ?? 0.0
            let boundingBox = result.boundingBox

            // You can use this information to perform further actions, such as displaying bounding boxes or labels on the screen
            print("Detected object: \(objectLabel), Confidence: \(confidence), Bounding Box: \(boundingBox)")
        }
    }
    
    // Function to set up the object detection
    func setupDetector() {
        // Load the object detection model
        guard let mlModel = try? yolov8n(configuration: MLModelConfiguration()).model else {
            print("Failed to load the model")
            return
        }

        // Create a VNCoreMLModel object
        guard let visionModel = try? VNCoreMLModel(for: mlModel) else {
            print("Failed to create VNCoreMLModel")
            return
        }

        // Create a request for object detection
        let request = VNCoreMLRequest(model: visionModel) { [weak self] request, error in
            guard let results = request.results as? [VNRecognizedObjectObservation], !results.isEmpty else {
                return
            }

            // Process the results
            self?.processDetectionResults(results)
        }

        // Add the request to the array of requests
        self.requests = [request]
    }

    override func viewDidLoad() {
        checkPermission()
        
        sessionQueue.async { [unowned self] in
            guard permissionGranted else { return }
            self.setupCaptureSession()
            
            self.setupLayers()
            self.setupDetector()
            
            self.captureSession.startRunning()
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        screenRect = UIScreen.main.bounds
        self.previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)

        switch UIDevice.current.orientation {
            // Home button on top
            case UIDeviceOrientation.portraitUpsideDown:
                self.previewLayer.connection?.videoOrientation = .portraitUpsideDown
             
            // Home button on right
            case UIDeviceOrientation.landscapeLeft:
                self.previewLayer.connection?.videoOrientation = .landscapeRight
            
            // Home button on left
            case UIDeviceOrientation.landscapeRight:
                self.previewLayer.connection?.videoOrientation = .landscapeLeft
             
            // Home button at bottom
            case UIDeviceOrientation.portrait:
                self.previewLayer.connection?.videoOrientation = .portrait
                
            default:
                break
            }
        
        // Detector
        updateLayers()
    }
    
    func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            // Permission has been granted before
            case .authorized:
                permissionGranted = true
                
            // Permission has not been requested yet
            case .notDetermined:
                requestPermission()
                    
            default:
                permissionGranted = false
            }
    }
    
    func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: .video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    
    func setupCaptureSession() {
        // Camera input
        guard let videoDevice = AVCaptureDevice.default(.builtInDualWideCamera,for: .video, position: .back) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
           
        guard captureSession.canAddInput(videoDeviceInput) else { return }
        captureSession.addInput(videoDeviceInput)
                         
        // Preview layer
        screenRect = UIScreen.main.bounds
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(x: 0, y: 0, width: screenRect.size.width, height: screenRect.size.height)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill // Fill screen
        previewLayer.connection?.videoOrientation = .portrait
        
        // Detector
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sampleBufferQueue"))
        captureSession.addOutput(videoOutput)
        
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
        
        // Updates to UI must be on main queue
        DispatchQueue.main.async { [weak self] in
            self!.view.layer.addSublayer(self!.previewLayer)
        }
    }
}

struct HostedViewController: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
