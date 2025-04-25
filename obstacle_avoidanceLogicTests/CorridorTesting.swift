//
//  CorridorTesting.swift
//  obstacle_avoidance
//
//  Created by Carlos Breach on 4/25/25.
//

import Foundation
import Testing
@testable import obstacle_avoidance

struct CorridorTesting {
    @Test
    func testBoundingBoxInsideCorridor() {
        // Define a fake corridor
        let corridor = CorridorGeometry(
            bottomLeft: CGPoint(x: 50, y: 600),
            bottomRight: CGPoint(x: 350, y: 600),
            topRight: CGPoint(x: 250, y: 300),
            topLeft: CGPoint(x: 150, y: 300)
        )

        // Create bounding boxes
        let insideBox = CGRect(x: 200, y: 450, width: 20, height: 20)
        let outsideBox = CGRect(x: 10, y: 100, width: 20, height: 20)

            // Test inside box
        #expect(CorridorUtils.isBoundingBoxInCorridor(insideBox, corridor: corridor) == true)

            // Test outside box
        #expect(CorridorUtils.isBoundingBoxInCorridor(outsideBox, corridor: corridor) == false)
    }
}
