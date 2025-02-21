//
//  CameraSetup.swift
//  obstacle_avoidance
//
//  Created by Jacob Fernandez on 2/21/25.
//

import Foundation
import AVFoundation
class CameraSetup {
    static func setupCaptureSession(frameHandler: FrameHandler) {
        // Setup video capture
        setupVideoCapture(frameHandler: frameHandler)
        
        // Setup LiDAR depth camera if available
        setupLiDARCapture(frameHandler: frameHandler)
        
        // Setup data outputs for video and depth data
        setupDataOutputs(frameHandler: frameHandler)
        
        frameHandler.sessionConfigured = true
    }
    
    // Setup the video camera input
    private static func setupVideoCapture(frameHandler: FrameHandler) {
        let videoOutput = AVCaptureVideoDataOutput()
        guard let videoDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        guard frameHandler.captureSession.canAddInput(videoDeviceInput) else { return }
        
        frameHandler.captureSession.addInput(videoDeviceInput)
        videoOutput.setSampleBufferDelegate(frameHandler, queue: DispatchQueue(label: "sampleBufferQueue"))
        frameHandler.captureSession.addOutput(videoOutput)
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
    }
    
    // Setup the LiDAR device and add it to the capture session if available
    private static func setupLiDARCapture(frameHandler: FrameHandler) {
        guard let lidarDevice = AVCaptureDevice.default(.builtInLiDARDepthCamera, for: .video, position: .back) else {
            print("Error: LiDAR device is not available")
            return
        }

        guard let lidarInput = try? AVCaptureDeviceInput(device: lidarDevice) else { return }
        if frameHandler.captureSession.canAddInput(lidarInput) {
            frameHandler.captureSession.addInput(lidarInput)
        }
        // Find the best supported format for LiDAR depth data
        guard let format = (lidarDevice.formats.last { format in
            format.formatDescription.dimensions.width == frameHandler.preferredWidthResolution &&
            format.formatDescription.mediaSubType.rawValue == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange &&
            !format.isVideoBinned &&
            !format.supportedDepthDataFormats.isEmpty
        }) else {
            print("Error: Required format is unavailable")
            return
        }
        
        guard let depthFormat = (format.supportedDepthDataFormats.last { depthFormat in
            depthFormat.formatDescription.mediaSubType.rawValue == kCVPixelFormatType_DepthFloat16
        }) else {
            print("Error: Required format for depth is unavailable")
            return
        }
        
        // Configure the LiDAR camera with the selected format
        do {
            try lidarDevice.lockForConfiguration()
            lidarDevice.activeFormat = format
            lidarDevice.activeDepthDataFormat = depthFormat
            lidarDevice.unlockForConfiguration()
        } catch {
            print("Error configuring the LiDAR camera")
        }
    }
    
    // Setup video and depth data outputs and synchronize them
    private static func setupDataOutputs(frameHandler: FrameHandler) {
        // Set up the video data output
        frameHandler.videoDataOutput = AVCaptureVideoDataOutput()
        frameHandler.videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        frameHandler.videoDataOutput.setSampleBufferDelegate(frameHandler, queue: DispatchQueue(label: "videoQueue"))
        if frameHandler.captureSession.canAddOutput(frameHandler.videoDataOutput) {
            frameHandler.captureSession.addOutput(frameHandler.videoDataOutput)
        }
        frameHandler.videoDataOutput.connection(with: .video)?.videoOrientation = .portrait
        
        // Set up the depth data output
        frameHandler.depthDataOutput = AVCaptureDepthDataOutput()
        frameHandler.depthDataOutput.isFilteringEnabled = true
        if frameHandler.captureSession.canAddOutput(frameHandler.depthDataOutput) {
            frameHandler.captureSession.addOutput(frameHandler.depthDataOutput)
        }
        
        // Synchronize video and depth outputs
        frameHandler.outputVideoSync = AVCaptureDataOutputSynchronizer(dataOutputs: [frameHandler.videoDataOutput, frameHandler.depthDataOutput])
        frameHandler.outputVideoSync.setDelegate(frameHandler, queue: DispatchQueue(label: "syncQueue"))
    }
}

