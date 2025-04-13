//
//  CameraView.swift
//  obstacleAvoidance
//
//  Created by Carlos Breach on 12/9/24.
//
import SwiftUI

struct CameraView: View {
    @StateObject private var model = FrameHandler()
    /**
     apparently we can bind the corridor directly to the model...
     lets hope this doesn't cause any problems 
     **/
    //@State private var corridorGeometry: CorridorGeometry? = nil


    var body: some View {
        ZStack{
            FrameView(image: model.frame, boundingBoxes: model.boundingBoxes)
            CorridorOverlay(corridor: $model.corridorGeometry)
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
