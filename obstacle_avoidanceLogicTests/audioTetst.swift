//
//  audioQueueTests.swift
//  obstacle_avoidanceTests
//
//  Created by Jacob Fernandez on 12/12/24.
//  Altered by Darien Aranda on 03/26/2025
//

import Foundation
import HeapModule
import Testing
@testable import obstacle_avoidance

struct AudioQueueTests {

    @Test
    func testAudioQueueOrdering() {
        // Create an unordered list of mock objects
        let mockObjects = [
            ProcessedObject(objName: "person", distance: 0.284, angle: "12 o'clock", vert: "lower third", threatLevel: 528.165), // Highest threat
            ProcessedObject(objName: "stop sign", distance: 1.243, angle: "1 o'clock", vert: "lower third", threatLevel: 16.88), // Low threat
            ProcessedObject(objName: "kite", distance: 0.568, angle: "2 o'clock", vert: "lower third", threatLevel: 12.32),  // Lower threat
            ProcessedObject(objName: "potted plant", distance: 1.456, angle: "11 o'clock", vert: "lower third", threatLevel: 16.48) // Low threat
        ]

        // Adds objects to the heap
        for object in mockObjects {
            AudioQueue.addToHeap(object)
        }

        // Expected ordering: descending threat level
        let expectedOrder = ["person", "stop sign", "potted plant"]
        var actualOrder: [String] = []

        // Pop elements and verify they are in the correct order
        while let highestThreatObject = AudioQueue.popHighestPriorityObject(threshold: 15) {
            actualOrder.append(highestThreatObject.objName)
        }

        #expect(actualOrder == expectedOrder, "AudioQueue did not return objects in expected priority order.")
        // Reset the heap before testing
        actualOrder.removeAll()
        AudioQueue.clearQueue()
    }

    @Test
    func testPopHighestThreatLevel() {
        // Insert mock objects
        let mockObjects2 = [
            ProcessedObject(objName: "stop sign", distance: 0.284, angle: "12 o'clock", vert: "lower third", threatLevel: 36.225), // Highest threat
            ProcessedObject(objName: "person", distance: 1.243, angle: "1 o'clock", vert: "lower third", threatLevel: 246.478), // Low threat
            ProcessedObject(objName: "kite", distance: 0.568, angle: "2 o'clock", vert: "lower third", threatLevel: 12.32),  // Lower threat
            ProcessedObject(objName: "potted plant", distance: 1.456, angle: "11 o'clock", vert: "lower third", threatLevel: 16.48) // Low threat
        ]

        for object in mockObjects2 {
            AudioQueue.addToHeap(object)
        }

        // Pop the highest-priority object and assert it's the one with highest threat level
        let highestThreatObject = AudioQueue.popHighestPriorityObject(threshold: 15)

        #expect(highestThreatObject?.objName == "person", "Failed: Highest threat object was not popped first.")
        #expect(highestThreatObject?.threatLevel == 246.478, "Failed: Threat level does not match expected value.")

        // Reset the heap before testing
        AudioQueue.clearQueue()
    }
}
