/* 
An object class that takes the data surrounding an obstacle and determines 
if it should be announced to the user.

Data in:
    Object Name
    Distance
    Direction

Returns: ProcessedObject which is the detectedObject with a computed threat levelt o be passed to AudioQueue

Testing something

Inital Author: Scott Schnieders
Current Author: Darien Aranda
Last modfiied: 2/21/2025
 */

import SwiftUI
import Foundation

//Create a struct holding parameters that pass through logic
struct  DetectedObject {
    let objID: Int
    let distance: Int
    let angle: Int
}

struct  ProcessedObject {
    let objID: Int
    let distance: Int
    let angle: Int
    let threatLevel: Int
}

class DecisionBlock {
    var detectedObject: DetectedObject
    var processed: ProcessedObject!

    //Initializer
    init(detectedObject: DetectedObject){
        self.detectedObject = detectedObject
    }

    // Does the mathmatics to create a threat heuristic for the objects
    func computeThreatLevel(for object: DetectedObject) -> Int {
        let objThreat = ThreatLevelConfig.objectWeights[object.objID] ?? 1
        let angleWeight = ThreatLevelConfig.angleWeights[object.angle] ?? 1
        let distanceFactor = object.distance * 2
        return objThreat * angleWeight + distanceFactor
    }

    // Given the provided information about the object, computes the threat level to create a processedObject
    func processDetectedObjects() {
        processed = ProcessedObject(
            objID: detectedObject.objID,
            distance: detectedObject.distance,
            angle: detectedObject.angle,
            threatLevel: computeThreatLevel(for: detectedObject)
            )

        // Passes each instance of a detected object into the Queue
        AudioQueue.addToHeap(processed)
    }
}
