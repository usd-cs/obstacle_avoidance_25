//
//  CorridorUtilsTests.swift
//  obstacle_avoidance
//
//  Created by Carlos Breach on 5/9/25.
//

import Foundation
import Testing
@testable import obstacle_avoidance

struct CorridorUtilsTests {
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

    @Test
    func testHorizontalPercentage() {
        let corridor = CorridorGeometry(
            bottomLeft: CGPoint(x: 50, y: 600),
            bottomRight: CGPoint(x: 350, y: 600),
            topRight: CGPoint(x: 250, y: 300),
            topLeft: CGPoint(x: 150, y: 300)
        )

        // Midway vertically
        let midY = (corridor.bottomLeft.y + corridor.topLeft.y) / 2

        // Box in center → expect ~50%
        let centerBox = CGRect(x: 200, y: midY, width: 20, height: 20)
        let centerPct = CorridorUtils.horizontalPercentage(bbox: centerBox, corridor: corridor)
        #expect(centerPct == 50.0)

        // Box at left edge → expect ~0%
        let leftEdgeBox = CGRect(x: 50, y: midY, width: 10, height: 10)
        let leftPct = CorridorUtils.horizontalPercentage(bbox: leftEdgeBox, corridor: corridor)
        #expect(centerPct == 0.0)

        // Box at right edge → expect ~100%
        let rightEdgeBox = CGRect(x: 350, y: midY, width: 10, height: 10)
        let rightPct = CorridorUtils.horizontalPercentage(bbox: rightEdgeBox, corridor: corridor)
        #expect(centerPct == 100.0)

        // Box far left (outside corridor) → should clamp to 0%
        let farLeftBox = CGRect(x: 0, y: midY, width: 10, height: 10)
        let farLeftPct = CorridorUtils.horizontalPercentage(bbox: farLeftBox, corridor: corridor)
        #expect(centerPct == 0.0)

        // Box far right (outside corridor) → should clamp to 100%
        let farRightBox = CGRect(x: 500, y: midY, width: 10, height: 10)
        let farRightPct = CorridorUtils.horizontalPercentage(bbox: farRightBox, corridor: corridor)
        #expect(centerPct == 100.0)
    }
    @Test
    func testPositionInCorridor() {
        // Test LEFT
        #expect(CorridorUtils.positionInCorridor(0) == "Left")
        #expect(CorridorUtils.positionInCorridor(20) == "Left")
        #expect(CorridorUtils.positionInCorridor(33.32) == "Left")

        // Test CENTER
        #expect(CorridorUtils.positionInCorridor(33.34) == "Center")
        #expect(CorridorUtils.positionInCorridor(50) == "Center")
        #expect(CorridorUtils.positionInCorridor(66.65) == "Center")

        // Test RIGHT
        #expect(CorridorUtils.positionInCorridor(66.66) == "Right")
        #expect(CorridorUtils.positionInCorridor(90) == "Right")
        #expect(CorridorUtils.positionInCorridor(100) == "Right")

    }

    @Test
    func testDeterminePosition() {
        let corridor = CorridorGeometry(
            bottomLeft: CGPoint(x: 50, y: 600),
            bottomRight: CGPoint(x: 350, y: 600),
            topRight: CGPoint(x: 250, y: 300),
            topLeft: CGPoint(x: 150, y: 300)
        )

        let midY = (corridor.bottomLeft.y + corridor.topLeft.y) / 2

        // Inside - Left
        let leftBox = CGRect(x: 75, y: midY, width: 10, height: 10)
        #expect(CorridorUtils.determinePosition(leftBox, corridor: corridor) == "Left")

        // Inside - Center
        let centerBox = CGRect(x: 200, y: midY, width: 10, height: 10)
        #expect(CorridorUtils.determinePosition(centerBox, corridor: corridor) == "Center")
        // Inside - Right
        let rightBox = CGRect(x: 325, y: midY, width: 10, height: 10)
        #expect(CorridorUtils.determinePosition(rightBox, corridor: corridor) == "Right")
        // Outside - Left
        let farLeftBox = CGRect(x: 0, y: midY, width: 10, height: 10)
        #expect(CorridorUtils.determinePosition(farLeftBox, corridor: corridor) == "Outside")
        // Outside - Above
        let aboveBox = CGRect(x: 200, y: 100, width: 10, height: 10)
        #expect(CorridorUtils.determinePosition(aboveBox, corridor: corridor) == "Outside")
    }
}
