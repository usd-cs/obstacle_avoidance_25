//
//  DecisionBlockTest.swift
//  obstacle_avoidanceTests
//
//  Created by Darien Aranda on 2/20/25.
//

import Testing
@testable import obstacle_avoidance

class MockDecisionBlock: DecisionBlock {

    override init(detectedObject: [(name: String, distance: Int, angle: Int)] = []){
        super.init(detectedObject: detectedObject)
    }
    
    @Test
    func testDecisionBlockInit(){
        let block1 = MockDecisionBlock(detectedObject: [])
        #expect(block1.detectedObject.isEmpty)
        #expect(block1.popAudioQueue()==nil)
        
        let detectedObjects: [(name: String, distance: Int, angle: Int)] = [("Tree", 5, 11), ("Car", 3, 12)]
        let block2 = MockDecisionBlock(detectedObject: detectedObjects)
        #expect(block2.detectedObject.count==2)
        #expect(block2.detectedObject[0].name == "Tree")
    }
    
    @Test("selectHighestPriorityObject_CompleteList")
    func selectHighestPriorityObjComplete(){
        let mockBlock = MockDecisionBlock(detectedObject: [
            ("Tree", 5, 11),
            ("Car", 3, 12),
            ("Person", 2, 12) //Target value
        ])
        let result = mockBlock.selectHighestPriorityObj()
        #expect(result?.0 == "Person")
    }
    
    @Test("selectHighestPriorityObject_EmptyList")
    func selectHighestPriorityObjEmpty(){
        let mockBlock = MockDecisionBlock(detectedObject: [])
        let result = mockBlock.selectHighestPriorityObj()
        #expect(result == nil)
    }
}
