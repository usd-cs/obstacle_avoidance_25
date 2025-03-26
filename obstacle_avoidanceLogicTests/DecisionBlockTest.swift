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
        let detectedObject = DetectedObject(objName: "truck", distance: 6, angle: "12 o'clock")
        let block = DecisionBlock(detectedObject: detectedObject)

        // Verify the object is stored correctly
        #expect(block.detectedObject.objName == "truck", "Object ID does not match")
        #expect(block.detectedObject.distance == 6, "Distance does not match")
        #expect(block.detectedObject.angle == "12 o'clock", "Angle does not match")
    }

    // Test Case: Compute threat level for a single object
    @Test("testComputeThreatLevel")
    func testComputeThreatLevel() {
        let detectedObject = DetectedObject(objName: "person", distance: 0.284, angle: "12 o'clock")
        let block = DecisionBlock(detectedObject: detectedObject)

        let computedThreat = block.computeThreatLevel(for: detectedObject)

        let expectedThreatLevel = (ThreatLevelConfigV3.objectWeights[ThreatLevelConfigV3.objectName[detectedObject.objName]!]!) * (ThreatLevelConfigV3.angleWeights[detectedObject.angle]!) + (Int(detectedObject.distance) * 2)

        print("Expected Threat level\(expectedThreatLevel)")
        print("Computed Threat Level\(computedThreat)")

        #expect(Int(computedThreat) == expectedThreatLevel, "Threat level computation is incorrect")
    }
}
