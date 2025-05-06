//
//  CorridorGeometry.swift
//  obstacle_avoidance
//
//  Created by Carlos Breach on 4/13/25.
//

import SwiftUI

struct CorridorGeometry{
    let bottomLeft: CGPoint
    let bottomRight: CGPoint
    let topRight: CGPoint
    let topLeft: CGPoint

    var shape : [CGPoint]{
        [bottomLeft,bottomRight,topRight,topLeft]
    }
}

func calculateCorridor(size: CGSize) -> CorridorGeometry{
    let screenWidth = size.width
    let screenHeight = size.height

    let baseY = screenHeight
    let baseWidth = screenWidth * 0.95

    // Top of the corridor (farthest point)
    let topY = screenHeight * 0.4 // ~60% up the screen
    let topWidth = screenWidth * 0.30 // tapers to this width

    return CorridorGeometry(
            bottomLeft: CGPoint(x: (screenWidth - baseWidth) / 2, y: baseY),
            bottomRight: CGPoint(x: (screenWidth + baseWidth) / 2, y: baseY),
            topRight: CGPoint(x: (screenWidth + topWidth) / 2, y: topY),
            topLeft: CGPoint(x: (screenWidth - topWidth) / 2, y: topY)
        )
}

