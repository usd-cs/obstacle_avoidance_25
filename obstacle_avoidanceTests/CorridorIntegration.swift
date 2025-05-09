//
//  CorridorIntegration.swift
//  obstacle_avoidance
//
//  Created by Carlos Breach on 5/9/25.
//

import Foundation
import Testing
@testable import obstacle_avoidance

struct CorridorIntegration{
    class DecisionBlockMock: DecisionBlock { 
        override init(detectedObject: DetectedObject) {
            super.init(detectedObject: detectedObject)
        }
    }

    @Test
    func blockCorridorIntegration(){
        let corridor = CorridorGeometry(
            bottomLeft: CGPoint(x: 50, y: 600),
            bottomRight: CGPoint(x: 350, y: 600),
            topRight: CGPoint(x: 250, y: 300),
            topLeft: CGPoint(x: 150, y: 300)
        )

        let midY = (corridor.bottomLeft.y + corridor.topLeft.y) / 2
        let centerBox = CGRect(x: 200, y: midY, width: 10, height: 10)
        let objectPos = CorridorUtils.determinePosition(centerBox, corridor: corridor)

        let mockObstacle = DetectedObject(
            objName: "Person",
            distance: 2.4,
            corridorPosition: objectPos,
            vert: "lower third"
        )

        let block = DecisionBlock(detectedObject: mockObstacle)

        let computedThreat = block.computeThreatLevel(for: mockObstacle)
        let distanceClamped = max(0.1, Float16(mockObstacle.distance))
        let inverseDistance = 1.0 / distanceClamped
        let expectedThreatLevel = Float16((
            ThreatLevelConfigV3.objectWeights[
            ThreatLevelConfigV3.objectName[mockObstacle.objName]!]!)) * Float16((ThreatLevelConfigV3.corridorPosition[mockObstacle.corridorPosition] ?? 1))
        * ((inverseDistance))
        print("Expected Threat level\(expectedThreatLevel)")
        print("Computed Threat Level\(computedThreat)")

        #expect(computedThreat == expectedThreatLevel, "Threat level computation is incorrect")
    }

    
}
