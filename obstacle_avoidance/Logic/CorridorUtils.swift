//
//  CorridorUtils.swift
//  obstacle_avoidance
//
//  Created by Carlos Breach on 4/13/25.
//

import Foundation

struct CorridorUtils {
    static func isPointInside(_ point: CGPoint, trapezoid: CorridorGeometry)->Bool{
        return false
    }
    static func isBoundingBoxInCorridor(_ bbox: CGRect, corridor: CorridorGeometry)->Bool{
        let point = CGPoint(x: bbox.midX, y: bbox.midY)
        return isPointInside(point, trapezoid: corridor)
    }
}
