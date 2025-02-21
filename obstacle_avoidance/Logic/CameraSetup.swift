//
//  CameraSetup.swift
//  obstacle_avoidance
//
//  Created by Jacob Fernandez on 2/21/25.
//

import Foundation
import AVFoundation
class CameraSetup{
    static func setupCaptureSession(frameHandler: FrameHandler) {
        // old yolo code using that camera
        let videoOutput = AVCaptureVideoDataOutput()
        // sets the Yolo camera
//        guard frameHandler.permissionGranted else { return }
        guard let videoDevice = AVCaptureDevice.default(.builtInDualWideCamera,
            for: .video, position: .back) else { return }
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else { return }
        guard frameHandler.captureSession.canAddInput(videoDeviceInput) else { return }
        frameHandler.captureSession.addInput(videoDeviceInput)
        videoOutput.setSampleBufferDelegate(frameHandler,
            queue: DispatchQueue(label: "sampleBufferQueue"))
        frameHandler.captureSession.addOutput(videoOutput)
        videoOutput.connection(with: .video)?.videoOrientation = .portrait
        // NOTE: .videoOrientation was depreciated in iOS 17 but
        // still works as of the current version.
        if frameHandler.sessionConfigured {
            return
        }
        // setup the lidar device and if there is input add that to the capture session
        guard let lidarDevice = AVCaptureDevice.default(.builtInLiDARDepthCamera,
            for: .video, position: .back) else {
            print("Error: LiDar device is not available")
            return
        }
        guard let lidarInput = try? AVCaptureDeviceInput(device: lidarDevice) else { return }
        if frameHandler.captureSession.canAddInput(lidarInput) {
            frameHandler.captureSession.addInput(lidarInput)
        }
        // find a good video format with good depth support
        guard let format = (lidarDevice.formats.last { format in
            format.formatDescription.dimensions.width == frameHandler.preferredWidthResolution &&
            format.formatDescription.mediaSubType.rawValue ==
                kCVPixelFormatType_420YpCbCr8BiPlanarFullRange &&
            !format.isVideoBinned &&
            !format.supportedDepthDataFormats.isEmpty
        }) else {
            print("Error: Required format is unavailable")
            return
        }
        guard let depthFormat = (format.supportedDepthDataFormats.last { depthFormat in
            depthFormat.formatDescription.mediaSubType.rawValue ==
                kCVPixelFormatType_DepthFloat16
        }) else {
            print("Error: Required format for depth is unavailable")
            return
        }
        // Begin the device configuration.
        do {
            try lidarDevice.lockForConfiguration()
            // Configure the device and depth formats.
            lidarDevice.activeFormat = format
            lidarDevice.activeDepthDataFormat = depthFormat
            // Finish the device configuration.
            lidarDevice.unlockForConfiguration()
        } catch {
            print("Error configuring the lidar camera")
            return
        }
        // set up the video data output
        frameHandler.videoDataOutput = AVCaptureVideoDataOutput()
        frameHandler.videoDataOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String:
                kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
        ]
        // Delegate for yolo detection if needed. Do not know if this will work
        frameHandler.videoDataOutput.setSampleBufferDelegate(frameHandler,
            queue: DispatchQueue(label: "videoQueue"))
        if frameHandler.captureSession.canAddOutput(frameHandler.videoDataOutput) {
            frameHandler.captureSession.addOutput(frameHandler.videoDataOutput)
        }
        frameHandler.videoDataOutput.connection(with: .video)?.videoOrientation = .portrait
        // set up the depth data output and add data if we can
        frameHandler.depthDataOutput = AVCaptureDepthDataOutput()
        frameHandler.depthDataOutput.isFilteringEnabled = true
        if frameHandler.captureSession.canAddOutput(frameHandler.depthDataOutput) {
            frameHandler.captureSession.addOutput(frameHandler.depthDataOutput)
        }
        // synchronize the video and depth outputs
        frameHandler.outputVideoSync = AVCaptureDataOutputSynchronizer(
            dataOutputs: [frameHandler.videoDataOutput, frameHandler.depthDataOutput])
        frameHandler.outputVideoSync.setDelegate(frameHandler,
            queue: DispatchQueue(label: "syncQueue"))
        frameHandler.sessionConfigured = true
    }

}
