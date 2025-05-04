//
//  CorridorUtils.swift
//  obstacle_avoidance
//
//  Created by Carlos Breach on 4/13/25.
//

import Foundation

struct CorridorUtils {
    enum corridorPos {
        case inside
        case left
        case right
        case ahead
    }
    static func corridorPosition(_ point: CGPoint, trapezoid: CorridorGeometry) -> corridorPos {

        let polygon = [trapezoid.bottomLeft, trapezoid.bottomRight, trapezoid.topRight, trapezoid.topLeft]
        var isInside = false
        var edgeJ = polygon.count - 1
        var crossingXPoints : [CGFloat] = []

        for edgeI in 0 ..< polygon.count {
            let pI = polygon[edgeI]
            let pJ = polygon[edgeJ]

            if (pI.y > point.y) != (pJ.y > point.y){

                let intersectX = (pJ.x - pI.x) * (point.y - pI.y) / (pJ.y - pI.y) + pI.x
                crossingXPoints.append(intersectX)

                if(point.x < intersectX){
                    isInside.toggle()
                }
            }
            edgeJ = edgeI
        }
        if isInside{
            return .inside
        }
        if let minX = crossingXPoints.min(), point.x < minX {
                return .left
            } else if let maxX = crossingXPoints.max(), point.x > maxX {
                return .right
            }
        return .ahead // default value in case no position is found (we should technically never reach this point)
    }
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
    static func determinePosition(_ bbox: CGRect, corridor: CorridorGeometry)->String{
        let point = CGPoint(x: bbox.midX, y: bbox.midY)

        let position = corridorPosition(point, trapezoid: corridor)

        if position == .left{
            return "left"
        }
        else if position == .inside{
            return "inside"
        }
        else if position == .right{
            return "right"
        }
        else{
            return "ahead"
        }
    }
}
