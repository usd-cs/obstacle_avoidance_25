//
//  DecisionBlockTest.swift
//  obstacle_avoidanceTests
//
//  Created by Darien Aranda on 2/20/25.
//

import Testing
@testable import obstacle_avoidance

class MockDecisionBlock: DecisionBlock {

    override init(detectedObject: [(objID: Int, distance: Int, angle: Int)] = []){
        super.init(detectedObject: detectedObject)
    }
    
    @Test
    func testDecisionBlockInit(){
        //Initializes an empty object list
        let block1 = MockDecisionBlock(detectedObject: [])
        #expect(block1.detectedObject.isEmpty)
        #expect(block1.popAudioQueue()==nil)
        
        //Initialized a populated object list and verifies we can access it
        let detectedObjects: [(objID: Int, distance: Int, angle: Int)] = [(22, 5, 11), (5, 3, 12)]
        let block2 = MockDecisionBlock(detectedObject: detectedObjects)
        #expect(block2.detectedObject.count==2)
        #expect(block2.detectedObject[0].objID == 22)
    }
    
    //Struggled through all of these tests just to remove the function after implementing it in a different way );
//    @Test("selectHighestPriorityObject_CompleteList")
//    func selectHighestPriorityObjComplete(){
//        let mockBlock = MockDecisionBlock(detectedObject: [
//            (22, 5, 11),
//            (5, 3, 12),
//            (13, 2, 12) //Target value
//        ])
//        let result = mockBlock.selectHighestPriorityObj()
//        #expect(result?.0 == 13)
//    }
//    
//    @Test("selectHighestPriorityObject_EmptyList")
//    func selectHighestPriorityObjEmpty(){
//        let mockBlock = MockDecisionBlock(detectedObject: [])
//        let result = mockBlock.selectHighestPriorityObj()
//        #expect(result == nil)
//    }
    
    @Test("computeThreatLevel_CarAt11")
    func testComputeThreatLevel(){
        //Create a mock instance of the detecedObject
        let mockBlock = MockDecisionBlock(detectedObject: [])
        //Runs the mocked object through computeThreatLevel & then compute the expected value
        let computeThreat = mockBlock.computeThreatLevel(objID: 5, distance: 3, angle: 11)
        let expectedThreatLevel = ((ThreatLevelConfig.objectWeights[5] ?? 1) * (ThreatLevelConfig.angleWeights[11] ?? 1) + (3*2))
        
        //Print statements to ensure we're retrieving the proper weights
        print("Car Weight:", ThreatLevelConfig.objectWeights[5] ?? 1)
        print("Angle Weight:", ThreatLevelConfig.angleWeights[11] ?? 1)
        print("Computed Threat Level:", computeThreat)
        print("Expected Threat Level:", expectedThreatLevel)
        
        //Assert statment to ensure our computed value is the same as our expectations
        #expect(computeThreat == expectedThreatLevel)
    }
    
    @Test("prioritizedObjectIntoQueue_CorrectOrder")
    func testPrioritizedObjectIntoQueue(){
        //Create mocked object list
        let mockBlock = MockDecisionBlock(detectedObject: [
            (22, 8, 12),
            (5, 3, 12),
            (13, 2, 11),
        ])
        //place the objects into a queue based on threat level
        mockBlock.prioritizeObjectIntoQueue()
        
        //Assign audioQueue for each instance of items popped off the stack
        let firstAudioQueue = mockBlock.popAudioQueue()
        let secondAudioQueue = mockBlock.popAudioQueue()
        let thirdAudioQueue = mockBlock.popAudioQueue()
        
        //Assert statment to ensure we're traversing the Queue and return nil when empty
        #expect(firstAudioQueue?.objectName == ThreatLevelConfig.objectName[22])
        #expect(secondAudioQueue?.objectName == ThreatLevelConfig.objectName[5])
        #expect(thirdAudioQueue?.objectName == ThreatLevelConfig.objectName[13])
        #expect(mockBlock.popAudioQueue() == nil)
    }
}
