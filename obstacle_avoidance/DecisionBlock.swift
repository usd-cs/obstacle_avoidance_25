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
class DecisionBlock {
    // Properties
    var objectName: String?
    var distance: Int?
    var direction: Int?

    // Queue to store AudioQueue objects
    private var audioQueueQueue: [AudioQueue] = []
    
    func processInput(image: Image, boundingBoxes: [BoundingBox]) {
        // Process image and bounding boxes here...
    }

    // Method to process input and determine if announcement is needed
    func processInput(objectName: String, distance: Int, direction: Int) -> AudioQueue? {
        self.objectName = objectName
        self.distance = distance
        self.direction = direction
        
        // Logic to determine if announcement is needed based on object data
        // For demonstration purposes, let's assume we always announce if the object is closer than 10 feet
        if let distance = distance, distance < 10 {
            // Create an AudioQueue object to announce
            return AudioQueue(threatLevel: 50, objectName: objectName, angle: direction, distance: distance)
        } else {
            // No need to announce, return nil
            return nil
        }
    }

    // Function to return and pop an AudioQueue object from the queue
    func popAudioQueue() -> AudioQueue? {
        guard !audioQueueQueue.isEmpty else {
            return nil
        }
        return audioQueueQueue.removeFirst()
    }
}