//
//  CameraView.swift
//  obstacleAvoidance
//
//  Created by Carlos Breach on 12/9/24.
//
import SwiftUI

struct CameraView: View {
    @StateObject private var model = FrameHandler()

    var body: some View {
        FrameView(image: model.frame, boundingBoxes: model.boundingBoxes)
            .ignoresSafeArea()
            .onAppear {
                model.startCamera()
            }
            .onDisappear {
                model.stopCamera()
            }
    }
}
