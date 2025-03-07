//
//  audioQueueTests.swift
//  obstacle_avoidanceTests
//
//  Created by Jacob Fernandez on 12/12/24.
//  Altered by Darien Aranda on 03/05/2025
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
            ProcessedObject(objID: 1, distance: 5, angle: 12, threatLevel: 90), // High threat
            ProcessedObject(objID: 2, distance: 10, angle: 1, threatLevel: 30), // Low threat
            ProcessedObject(objID: 4, distance: 3, angle: 2, threatLevel: 95),  // Highest threat
            ProcessedObject(objID: 3, distance: 7, angle: 9, threatLevel: 70) // Medium threat
        ]

        // Adds objects to the heap
        for object in mockObjects {
            AudioQueue.addToHeap(object)
        }

        // Expected ordering: descending threat level
        let expectedOrder = [4, 1, 3, 2]
        var actualOrder: [Int] = []

        // Pop elements and verify they are in the correct order
        while let highestThreatObject = AudioQueue.popHighestPriorityObject() {
            actualOrder.append(highestThreatObject.objID)
        }

        #expect(actualOrder == expectedOrder, "AudioQueue did not return objects in expected priority order.")
    }

    @Test
    func testPopHighestThreatLevel() {
        // Reset the heap before testing
        obstacle_avoidance.AudioQueue.queue = Heap<AudioQueueVertex>()

        // Insert mock objects
        let mockObjects = [
            ProcessedObject(objID: 6, distance: 6, angle: 3, threatLevel: 60),   // Lower threat
            ProcessedObject(objID: 7, distance: 4, angle: 9, threatLevel: 80)  ,  // Medium threat
            ProcessedObject(objID: 5, distance: 2, angle: 12, threatLevel: 100) // Max threat
        ]

        for object in mockObjects {
            AudioQueue.addToHeap(object)
        }

        // Pop the highest-priority object and assert it's the one with highest threat level
        let highestThreatObject = AudioQueue.popHighestPriorityObject()

        #expect(highestThreatObject?.objID == 5, "Failed: Highest threat object was not popped first.")
        #expect(highestThreatObject?.threatLevel == 100, "Failed: Threat level does not match expected value.")
    }
}
