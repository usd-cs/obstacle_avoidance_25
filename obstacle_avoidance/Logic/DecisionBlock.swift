/* 
An object class that takes the data surrounding an obstacle and determines 
if it should be announced to the user.

Data in:
    Object Name
    Distance
    Direction

Returns: An optional AudioQueue object (will be empty if no need to announce)

Inital Author: Scott Schnieders
Current Author: Darien Aranda
Last modfiied: 2/21/2025
 */

import SwiftUI
import AVFoundation
import Foundation

//Create a struct holding parameters that pass through logic
struct  DetectedObject {
    let objID: Int
    let distance: Int
    let angle: Int
}

struct  PrioritizedObject {
    let objID: Int
    let distance: Int
    let angle: Int
    let urgencyLevel: Int
}

class DecisionBlock {
    //What would this be reffered to as?
    var audio: AudioQueue?
    var urgencyLevel: Int = 0
    private var audioQueueQueue: [AudioQueue] = []
    var detectedObject: [DetectedObject]

    
    //Initializer
    init(detectedObject: [DetectedObject]){
        self.detectedObject = detectedObject
        self.audioQueueQueue = []
    }
    
    func computeThreatLevel(for object: DetectedObject) -> Int {
        let objThreat = ThreatLevelConfig.objectWeights[object.objID] ?? 1
        let angleWeight = ThreatLevelConfig.angleWeights[object.angle] ?? 1
        let distanceFactor = object.distance * 2
        return objThreat * angleWeight + distanceFactor
    }
    
    func prioritizeObjectIntoQueue() {
        let prioritizedObject = detectedObject.map { obj in
            PrioritizedObject(
                objID: obj.objID,
                distance: obj.distance,
                angle: obj.angle,
                urgencyLevel: computeThreatLevel(for: obj)
            )
        }
        
        let sortedObjects = prioritizedObject.sorted { (obj1, obj2) in obj1.urgencyLevel > obj2.urgencyLevel }
        
        audioQueueQueue = sortedObjects.compactMap{ obj in
            //"Unkown Object" works to infer different types, and avoids crashing if objID is missing
            let objectName = ThreatLevelConfig.objectName[obj.objID] ?? "Unkown Object"
            return try? AudioQueue(
                threatLevel: obj.urgencyLevel,
                objectName: objectName,
                angle: obj.angle,
                distance: obj.distance
            )
        }
    }

    // Function to return and pop an AudioQueue object from the queue
    func popAudioQueue() -> AudioQueue? {
        guard !audioQueueQueue.isEmpty else {return nil}
        return audioQueueQueue.removeFirst()
    }
}
