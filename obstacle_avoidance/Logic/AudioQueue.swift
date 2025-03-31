/* 
An object class to store the audio queue information sent from the DecisionBlock to the UI.

Current Author: Darien Aranda
Previous Author: Scott Schnieders
Last modfiied: 2/28/2025
 */
import Foundation
import HeapModule

struct AudioQueueVertex: Comparable {
    let threatLevel: Int  // Threat level of the obstacle between 0-100, with 100 being the greatest threat.
    let objID: Int // Name of the obstacle
    let angle: Int // Angle of the obstacle in clock terms. Ex. 12 O'clock would be straight forward.
    let distance: Int // Distance calculated from the person holding phone to the obstacle (in feet).

    // Auto Generate by Swift; Appears to reverse the order of the Queue since it's min-head by default
    static func < (lhs: AudioQueueVertex, rhs: AudioQueueVertex) -> Bool {
        return lhs.threatLevel > rhs.threatLevel
    }
}

class AudioQueue {
    public static var queue = Heap<AudioQueueVertex>()

    static func addToHeap(_ processedObject: ProcessedObject) {
        let newVertex = AudioQueueVertex(
            threatLevel: processedObject.threatLevel,
            objID: processedObject.objID,
            angle: processedObject.angle,
            distance: processedObject.distance);
        queue.insert(newVertex)
    }

    static func popHighestPriorityObject() -> AudioQueueVertex? {
        return queue.popMin()
    }
}
