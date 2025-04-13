//
//  CorridorOverlayView.swift
//  obstacle_avoidance
//
//  Created by Carlos Breach on 4/11/25.
//
import SwiftUI

struct CorridorOverlay: View {
    @Binding var corridor: CorridorGeometry?

    var body: some View {
        GeometryReader { geo in
            let size = geo.size
            let geometry = calculateCorridor(size: size)

            ZStack {
                Path { path in
                    path.move(to: geometry.bottomLeft)
                    path.addLine(to: geometry.bottomRight)
                    path.addLine(to: geometry.topRight)
                    path.addLine(to: geometry.topLeft)
                    path.closeSubpath()
                }
                .fill(Color.red.opacity(0.3))

                Text("middle")
                    .font(.headline)
                    .foregroundColor(.white)
                    .bold()
                    .position(x: size.width / 2, y: (geometry.topLeft.y + geometry.bottomLeft.y) / 2)
            }
            .onAppear {
                DispatchQueue.main.async {
                    self.corridor = geometry
                }
            }
        }
        .allowsHitTesting(false)
    }
}

