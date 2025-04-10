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
        // Reset the heap before testing
        obstacle_avoidance.AudioQueue.queue = Heap<AudioQueueVertex>()

        // Create an unordered list of mock objects
        let mockObjects = [
            ProcessedObject(objName: "person", distance: 0.284, angle: "12 o'clock", vert: "lower third", threatLevel: 10.568), // Medium threat
            ProcessedObject(objName: "stop sign", distance: 1.243, angle: "1 o'clock", vert: "lower third", threatLevel: 11.486), // High threat
            ProcessedObject(objName: "kite", distance: 0.568, angle: "2 o'clock", vert: "lower third", threatLevel: 17.136),  // Highest threat
            ProcessedObject(objName: "potted Pland", distance: 1.456, angle: "11 o'clock", vert: "lower third", threatLevel: 8.912) // Low threat
        ]

        // Adds objects to the heap
        for object in mockObjects {
            AudioQueue.addToHeap(object)
        }

        // Expected ordering: descending threat level
        let expectedOrder = ["kite", "stop sign", "person"]
        var actualOrder: [String] = []

        // Pop elements and verify they are in the correct order
        while let highestThreatObject = AudioQueue.popHighestPriorityObject(threshold: 10.511) {
            actualOrder.append(highestThreatObject.objName)
        }

        #expect(actualOrder == expectedOrder, "AudioQueue did not return objects in expected priority order.")
    }

    @Test
    func testPopHighestThreatLevel() {
        // Reset the heap before testing
        obstacle_avoidance.AudioQueue.queue = Heap<AudioQueueVertex>()

        // Insert mock objects
        let mockObjects = [
            ProcessedObject(objName: "person", distance: 0.284, angle: "12 o'clock", vert: "lower third", threatLevel: 10.568), // Medium threat
            ProcessedObject(objName: "stop sign", distance: 1.243, angle: "1 o'clock", vert: "lower third", threatLevel: 11.486), // High threat
            ProcessedObject(objName: "kite", distance: 0.568, angle: "2 o'clock", vert: "lower third", threatLevel: 17.136),  // Highest threat
            ProcessedObject(objName: "potted Pland", distance: 1.456, angle: "11 o'clock", vert: "lower third", threatLevel: 8.912) // Low threat
        ]

        for object in mockObjects {
            AudioQueue.addToHeap(object)
        }

        // Pop the highest-priority object and assert it's the one with highest threat level
        let highestThreatObject = AudioQueue.popHighestPriorityObject(threshold: 10.511)

        #expect(highestThreatObject?.objName == "kite", "Failed: Highest threat object was not popped first.")
        #expect(highestThreatObject?.threatLevel == 17.136, "Failed: Threat level does not match expected value.")
    }
}
