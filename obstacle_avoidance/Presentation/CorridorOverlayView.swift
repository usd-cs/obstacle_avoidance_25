//
//  CorridorOverlayView.swift
//  obstacle_avoidance
//
//  Created by Carlos Breach on 4/11/25.
//
import SwiftUI

struct CorridorOverlayView: View {
    var body: some View {
        GeometryReader { geo in
            let screenWidth = geo.size.width
            let screenHeight = geo.size.height

            // Bottom of the screen (nearest point to user)
            let baseY = screenHeight
            let baseWidth = screenWidth * 0.95

            // Top of the corridor (farthest point)
            let topY = screenHeight * 0.4 // ~60% up the screen
            let topWidth = screenWidth * 0.30 // tapers to this width

            Path { path in
                path.move(to: CGPoint(x: (screenWidth - baseWidth) / 2, y: baseY))
                path.addLine(to: CGPoint(x: (screenWidth + baseWidth) / 2, y: baseY))
                path.addLine(to: CGPoint(x: (screenWidth + topWidth) / 2, y: topY))
                path.addLine(to: CGPoint(x: (screenWidth - topWidth) / 2, y: topY))
                path.closeSubpath()
            }
            .fill(Color.red.opacity(0.3))
            Text("middle")
                .font(.headline)
                .foregroundColor(.white)
                .bold()
                .position(
                    x: screenWidth / 2,
                    y: (baseY + topY) / 2  // halfway between top and bottom
                )


        }
        .allowsHitTesting(false)
    }
}

