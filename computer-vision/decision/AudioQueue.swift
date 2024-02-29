/* 
An object class to store the audio queue information sent from the DecisionBlock to the UI.

Author: Scott Schnieders
Last modfiied: 2/28/2024

 */
enum AudioQueueError: Error {
    case invalidThreatLevel
    case invalidAngle
}

class AudioQueue {
    var threatLevel: Int // Threat level of the obstacle between 0-100, with 100 being the greatest threat.
    var objectName: String // Name of the obstacle
    var angle: Int // Angle of the obstacle in clock terms. Ex. 12 O'clock would be straight forward.
    var distance: Int // Distance calculated from the person holding phone to the obstacle (in feet).
    
    init(threatLevel: Int, objectName: String, angle: Int, distance: Int) throws {
        guard threatLevel >= 0 && threatLevel <= 100 else {
            throw AudioQueueError.invalidThreatLevel
        }
        guard [9,10,11,12,1,2,3].contains(angle) else {
            throw AudioQueueError.invalidAngle
        }
        
        self.threatLevel = threatLevel
        self.objectName = objectName
        self.angle = angle
        self.distance = distance
    }
}