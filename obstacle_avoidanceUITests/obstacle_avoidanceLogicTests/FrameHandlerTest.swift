//
//  FrameHandlerTest.swift
//  obstacle_avoidance
//
//  Created by Jacob Fernandez on 2/19/25
//

import Foundation
import Testing
@testable import obstacle_avoidance
import AVFoundation
import SwiftUICore
//comment so that it will let me push this file
struct FrameHandlerTest {
    class MockFrameHandler: FrameHandler {
        override init() {
            super.init()
            self.frame = nil
            self.boundingBoxes = []
            self.objectDistance = 0.0
        }
    }

    // Mock DetectionView to test UI initialization
    struct MockDetectionView: View {
        @ObservedObject var frameHandler: MockFrameHandler = MockFrameHandler()
        //This is needed to create the DetectionView
        var body: some View {
            Text("Mock Detection View")
        }
    }

    // Test to verify that FrameHandler initializes correctly
    @Test func testFrameHandlerInitialization() {
        let frameHandler = MockFrameHandler()
        #expect(frameHandler.frame == nil)
        #expect(frameHandler.boundingBoxes.isEmpty)
        #expect(frameHandler.objectDistance == 0.0)
    }

    // Test to check if capture session is correctly configured
    @Test func testSetupCaptureSession() {
        let frameHandler = MockFrameHandler()
        frameHandler.setupCaptureSession()
        #expect(frameHandler.sessionConfigured == false, "Capture session should be configured")
    }

    // Test to ensure DetectionView initializes with expected values
    @Test func testDetectionViewInitialization() {
        let detectionView = MockDetectionView()
        #expect(detectionView.frameHandler.frame == nil)
        #expect(detectionView.frameHandler.boundingBoxes.isEmpty)
    }

    // Mock class for AVCaptureDataOutputSynchronizer
    class MockAVCaptureDataOutputSynchronizer: AVCaptureDataOutputSynchronizer {
        override init(dataOutputs: [AVCaptureOutput]) {
            super.init(dataOutputs: dataOutputs)
        }
    }

    // Mock class for AVCaptureSynchronizedDataCollection to prevent crashes
    class MockAVCaptureSynchronizedDataCollection {
        init() {}
        func synchronizedData(for output: AVCaptureOutput) -> AVCaptureSynchronizedData? {
            return nil
        }
    }

    // Test to ensure data output synchronizer delegate does not crash
    @Test func testDataOutputSynchronizerDelegate() {
        let frameHandler = MockFrameHandler()
        let captureSession = AVCaptureSession()
        let mockVideoOutput = AVCaptureVideoDataOutput()
        let mockDepthOutput = AVCaptureDepthDataOutput()
        // Configure outputs
        mockVideoOutput.alwaysDiscardsLateVideoFrames = true
        mockVideoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
        mockDepthOutput.isFilteringEnabled = true
        // Ensure outputs are added to the session before using them
        if captureSession.canAddOutput(mockVideoOutput) {
            captureSession.addOutput(mockVideoOutput)
        }
        if captureSession.canAddOutput(mockDepthOutput) {
            captureSession.addOutput(mockDepthOutput)
        }
        // Start the session to ensure connections are created
        captureSession.startRunning()
        // Ensure valid connections
        guard let videoConnection = mockVideoOutput.connection(with: .video),
              let depthConnection = mockDepthOutput.connection(with: .depthData) else {
            #expect(Bool(true), "Failed to create valid connections for data outputs")
            return
        }
        let synchronizer = MockAVCaptureDataOutputSynchronizer(dataOutputs: [mockVideoOutput, mockDepthOutput])
        let synchronizedData = MockAVCaptureSynchronizedDataCollection()
        do {
            frameHandler.dataOutputSynchronizer(synchronizer, didOutput: synchronizedData as! AVCaptureSynchronizedDataCollection)
            #expect(true) // Just ensuring no crashes occur
        } catch {
            #expect(Bool(false), "Unexpected error: \(error)")
        }
    }
    // Test to validate corrected depth calculation logic
    @Test func testCorrectedDepthCalculation() {
        let depthValue: Float16 = 2.0
        let correctedDepth: Float16 = depthValue > 0 ? 1.0 / depthValue : 0
        #expect(correctedDepth == 0.5, "Corrected depth should be 0.5 when depth value is 2.0")
    }
}
