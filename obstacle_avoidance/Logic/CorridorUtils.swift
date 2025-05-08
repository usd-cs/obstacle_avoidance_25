//
//  CorridorUtils.swift
//  obstacle_avoidance
//
//  Created by Carlos Breach on 4/13/25.
//

import Foundation

struct CorridorUtils {
    enum CorridorPoition {
        case inside
        case left
        case right
        case ahead
    }
    static func corridorPosition(_ point: CGPoint, trapezoid: CorridorGeometry) -> CorridorPoition {

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

    /**
    I feel like we could subdivide the corridor in 3 equally and determine where in space is the object exactly
     */
    static func positionInCorridor(_ percentage: CGFloat) -> String{
        let sections = [
            "Left",
            "Center",
            "Right"
        ]
        let index = min(Int(percentage/33.33), sections.count-1)
        return sections[index]
    }
    static func isBoundingBoxInCorridor(_ bbox: CGRect, corridor: CorridorGeometry)->Bool{
        let point = CGPoint(x: bbox.midX, y: bbox.midY)
        return isPointInside(point, trapezoid: corridor)
    }
    static func horizontalPercentage(bbox: CGRect, corridor: CorridorGeometry) -> CGFloat{
        let verticalFactor = (bbox.midY - corridor.bottomLeft.y)/(corridor.topLeft.y-corridor.bottomLeft.y)
        let corridorLeftX = corridor.bottomLeft.x + (corridor.topLeft.x - corridor.bottomLeft.x) * verticalFactor
        let corridorRightX = corridor.bottomRight.x + (corridor.topRight.x - corridor.bottomRight.x) * verticalFactor
        let widthAtY = corridorRightX - corridorLeftX

        let percentageInsideCorridor = ((bbox.midX - corridorLeftX) / widthAtY) * 100
        return max(0, min(percentageInsideCorridor,100))
    }

    static func determinePosition(_ bbox: CGRect, corridor: CorridorGeometry)->String{
        let point = CGPoint(x: bbox.midX, y: bbox.midY)
        //we can just avoid the extra computations if the object is not inside our corridor
        if isPointInside(point, trapezoid: corridor){
            let horizontalPos = horizontalPercentage(bbox: bbox, corridor: corridor)
            return positionInCorridor(horizontalPos)
        }

        return "Outside"
    }
}
