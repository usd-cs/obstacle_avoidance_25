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
        let distanceFactor = distance*2
        return objThreat * angleWeight + distanceFactor
    }
    
    func selectHighestPriorityObj() -> (Int, Int, Int)?{
        return detectedObject.min(by:{ $0.distance < $1.distance})
    }

//    func processInput(objectName: String) {
//         Process image and bounding boxes here...         //What does this even mean?
//         Audio processing.work
//        do {
//            try audio = AudioQueue(threatLevel: 0, objectName: objectName, angle: 0, distance: 0)
//        } catch {
//            // there should be something here
//        }
//    }

    // Function to return and pop an AudioQueue object from the queue
    func popAudioQueue() -> AudioQueue? {
        guard !audioQueueQueue.isEmpty else {return nil}
        return audioQueueQueue.removeFirst()
    }
}
