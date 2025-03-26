/* 
An object class that takes the data surrounding an obstacle and determines 
if it should be announced to the user.

Data in:
    Object Name
    Distance
    Direction

Returns: ProcessedObject which is the detectedObject with a computed threat levelt o be passed to AudioQueue

Inital Author: Scott Schnieders
Current Author: Darien Aranda
Last modfiied: 3/26/2025
 */

import SwiftUI
import Foundation

//Create a struct holding parameters that pass through logic
struct  DetectedObject {
    let objName: String
    let distance: Float16
    let angle: String
}

struct  ProcessedObject {
    let objName: String
    let distance: Float16
    let angle: String
    let threatLevel: Float16
}

class DecisionBlock {
    var detectedObject: DetectedObject
    var processed: ProcessedObject!

    //Initializer
    init(detectedObject: DetectedObject){
        self.detectedObject = detectedObject
    }

    // Does the mathmatics to create a threat heuristic for the objects
    func computeThreatLevel(for object: DetectedObject) -> Float16 {
        let objectID = ThreatLevelConfigV3.objectName[object.objName] ?? 1
        let objThreat = ThreatLevelConfigV3.objectWeights[objectID] ?? 1
        let angleWeight = ThreatLevelConfigV3.angleWeights[object.angle] ?? 1
        let distanceFactor = object.distance * 2
        return Float16(objThreat) * Float16(angleWeight) + distanceFactor
    }

    // Given the provided information about the object, computes the threat level to create a processedObject
    func processDetectedObjects(processed: ProcessedObject) {
        let processed = ProcessedObject(
            objName: detectedObject.objName,
            distance: detectedObject.distance,
            angle: detectedObject.angle,
            threatLevel: computeThreatLevel(for: detectedObject)
            )

        // Passes each instance of a detected object into the Queue
        AudioQueue.addToHeap(processed)
    }
}
