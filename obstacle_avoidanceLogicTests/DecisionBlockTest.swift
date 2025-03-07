//
//  DecisionBlockTest.swift
//  obstacle_avoidanceTests
//
//  Created by Darien Aranda on 2/20/25.
//
import Testing
@testable import obstacle_avoidance

struct DecisionBlockTest {
    // Mocks `DecisionBlock` to test it's intended behavior
    class MockDecisionBlock: DecisionBlock {
        override init(detectedObject: DetectedObject) {
            super.init(detectedObject: detectedObject)
        }
    }

    // Test Case: Test that `DecisionBlock` initializes correctly
    @Test("testDecisionBlockInit")
    func testDecisionBlockInit() {
        // Creates an instance of detectedObject
        let detectedObject = DetectedObject(objID: 10, distance: 6, angle: 9)
        let block = DecisionBlock(detectedObject: detectedObject)

        // Verify the object is stored correctly
        #expect(block.detectedObject.objID == 10, "Object ID does not match")
        #expect(block.detectedObject.distance == 6, "Distance does not match")
        #expect(block.detectedObject.angle == 9, "Angle does not match")
    }

    // Test Case: Compute threat level for a single object
    @Test("testComputeThreatLevel")
    func testComputeThreatLevel() {
        let detectedObject = DetectedObject(objID: 5, distance: 3, angle: 11)
        let block = DecisionBlock(detectedObject: detectedObject)

        let computedThreat = block.computeThreatLevel(for: detectedObject)

        let expectedThreatLevel = (ThreatLevelConfig.objectWeights[5] ?? 1) * (ThreatLevelConfig.angleWeights[11] ?? 1) + (3 * 2)

        #expect(computedThreat == expectedThreatLevel, "Threat level computation is incorrect")
    }
}
