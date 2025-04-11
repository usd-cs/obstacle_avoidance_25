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
        ZStack{
            FrameView(image: model.frame, boundingBoxes: model.boundingBoxes)
            CorridorOverlayView()
        }
            .ignoresSafeArea()
            .onAppear {
                model.startCamera()
            }
            .onDisappear {
                model.stopCamera()
            }
    }
}
