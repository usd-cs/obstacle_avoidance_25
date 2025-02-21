/* 
An object class that takes the data surrounding an obstacle and determines 
if it should be announced to the user.

Data in:
    Object Name
    Distance
    Direction

Returns: An optional AudioQueue object (will be empty if no need to announce)

Author: Scott Schnieders
Last modfiied: 2/28/2024
 */

import SwiftUI
import AVFoundation
import Foundation

class DecisionBlock {
    // Properties
    var audio: AudioQueue?
    var urgencyLevel: Int = 0
    //Initialize an array of tuples to pass through logic
    var detectedObject: [(objID: Int, distance: Int, angle: Int)]
    // Queue to store AudioQueue objects
    private var audioQueueQueue: [AudioQueue] = []
    
    //Initializer
    init(detectedObject: [(objID: Int, distance: Int, angle: Int)]){
        self.detectedObject = detectedObject
        self.audioQueueQueue = []
    }
    
    func computeThreatLevel(objID: Int, distance: Int, angle: Int)->Int{
        let objThreat = ThreatLevelConfig.objectWeights[objID] ?? 1
        let angleWeight = ThreatLevelConfig.angleWeights[angle] ?? 1
        let distanceFactor = distance * 2
        return objThreat * angleWeight + distanceFactor
    }
    
    func prioritizeObjectIntoQueue(){
        let prioritizedObject = detectedObject.map{obj in
            return (
                objID: obj.objID,
                distance: obj.distance,
                angle: obj.angle,
                urgencyLevel: computeThreatLevel(objID: obj.objID, distance: obj.distance, angle: obj.angle)
            )
        }
        
        let sortedObject = prioritizedObject.sorted { (a, b) in a.urgencyLevel > b.urgencyLevel }
        
        audioQueueQueue = sortedObject.compactMap{ obj in
            let objectName = ThreatLevelConfig.objectName[obj.objID] ?? "Unkown Object"
            return try? AudioQueue(threatLevel: obj.urgencyLevel, objectName: objectName, angle: obj.angle, distance: obj.distance)
        }
    }

    // Function to return and pop an AudioQueue object from the queue
    func popAudioQueue() -> AudioQueue? {
        guard !audioQueueQueue.isEmpty else {return nil}
        return audioQueueQueue.removeFirst()
    }
}
