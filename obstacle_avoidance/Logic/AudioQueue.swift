/* 
An object class to store the audio queue information sent from the DecisionBlock to the UI.

Current Author: Darien Aranda
Previous Author: Scott Schnieders
Last modfiied: 2/28/2025
 */
import Foundation
import HeapModule

struct AudioQueueVertex: Comparable {
    let threatLevel: Float16  // Threat level of the obstacle between 0-100, with 100 being the greatest threat.
    let objName: String // Name of the obstacle
    let corridorPosition: String // Angle of the obstacle in left/right/center.
    let vert: String // Vertical postionality of an object
    let distance: Float16 // Distance calculated from the person holding phone to the obstacle (in feet).

    // Auto Generate by Swift; Appears to reverse the order of the Queue since it's min-head by default
    static func < (lhs: AudioQueueVertex, rhs: AudioQueueVertex) -> Bool {
        return lhs.threatLevel > rhs.threatLevel
    }
}

extension AudioQueueVertex{
    func roundingDistance(distance: Double) -> Double{
        let decimalVal = distance - floor(distance)
        if  decimalVal > 0.7{
            return ceil(distance)
        }
        else{
            return floor(distance)
        }
    }
    var formattedDist: String{
        let unitPref = UserDefaults.standard.string(forKey: "measurementType") ?? "feet"
        if unitPref == "meters"{
            var meters = Double(self.distance)
            if meters > 1{
                meters = roundingDistance(distance: meters)
            }
            return String(format: "%.1f meters", meters)
        } else {
            var feet = Double(self.distance) * 3.28084
            if feet > 1{
                feet = roundingDistance(distance: feet)
            }
            return String(format: "%.1f feet", feet)
        }
    }
}

class AudioQueue {
    public static var queue = Heap<AudioQueueVertex>()

    static func addToHeap(_ processedObject: ProcessedObject) {
        let newVertex = AudioQueueVertex(
            threatLevel: processedObject.threatLevel,
            objName: processedObject.objName,
            corridorPosition: processedObject.corridorPosition,
            vert: processedObject.vert,
            distance: processedObject.distance
        );

        queue.insert(newVertex)
    }
    static func clearQueue(){
        return queue = Heap<AudioQueueVertex>()
    }

    static func popHighestPriorityObject(threshold: Float16) -> AudioQueueVertex? {
        guard let candidate = queue.popMin() else{
            return nil
        }
        if candidate.threatLevel >= threshold{
            return candidate
        } else {
            return nil
        }
    }
}
