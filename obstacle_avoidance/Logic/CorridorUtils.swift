//
//  CorridorUtils.swift
//  obstacle_avoidance
//
//  Created by Carlos Breach on 4/13/25.
//

import Foundation

struct CorridorUtils {
    static func isPointInside(_ point: CGPoint, trapezoid: CorridorGeometry)->Bool{
        //assigns the gemotry of the corridor to an array so we can easily acces it
        let polygon = [trapezoid.bottomLeft, trapezoid.bottomRight, trapezoid.topRight, trapezoid.topLeft]
        var isInside = false
        var edgeJ = polygon.count - 1

        for edgeI in 0 ..< polygon.count {
            let pI = polygon[edgeI]
            let pJ = polygon[edgeJ]
            /**
             the for loop bellow is kind of hard to follow but basically edgeI and edgeJ represent two endpoints of on edge in the polygon
             pI begins at the start of the current selected edge and pJ at the end of said edge, since our corridor is a closed shape, we check all
             4 shapes to check if the center point of an object has crossed any of the given edges
             */
            if (pI.y > point.y) != (pJ.y > point.y) &&
                (point.x < (pJ.x - pI.x) * (point.y - pI.y) / (pJ.y - pI.y) + pI.x){
                isInside.toggle()
            }
            edgeJ = edgeI
        }
        return isInside
    }
    static func isBoundingBoxInCorridor(_ bbox: CGRect, corridor: CorridorGeometry)->Bool{
        let point = CGPoint(x: bbox.midX, y: bbox.midY)
        return isPointInside(point, trapezoid: corridor)
    }
}
