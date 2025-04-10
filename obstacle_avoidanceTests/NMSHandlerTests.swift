//
//  NMSHandlerTests.swift
//  obstacle_avoidance
//
//  Created by Austin Lim on 2/19/25.
//

import XCTest
@testable import obstacle_avoidance

class NMSHandlerTests: XCTestCase{
    

    
    func testSingleClassNMS() throws {
        
        NMSHandler.multiClass = false

        let boxes: [BoundingBox] = [
                
            BoundingBox(classIndex: 0, score: 0.05, rect: CGRect(x: 0.1, y: 0.1, width: 0.2, height: 0.2), name: "object1", direction: "N", vert: "lower third"),
                // Above threshold, box A
            BoundingBox(classIndex: 0, score: 0.8, rect: CGRect(x: 0.2, y: 0.2, width: 0.2, height: 0.2), name: "object2", direction: "N", vert: "lower third"),
                // Above threshold, box B overlapping with box A
            BoundingBox(classIndex: 0, score: 0.75, rect: CGRect(x: 0.22, y: 0.22, width: 0.2, height: 0.2), name: "object3", direction: "N", vert: "lower third"),
                // Below threshold -> should be filtered out
            BoundingBox(classIndex: 0, score: 0.09, rect: CGRect(x: 0.8, y: 0.8, width: 0.2, height: 0.2), name: "object4", direction: "N", vert: "lower third")
        ]

        let filteredBoxes = NMSHandler.performNMS(on: boxes)

        XCTAssertEqual(filteredBoxes.count, 1)

        
        XCTAssertEqual(filteredBoxes.first?.score, 0.8)
    }
    
    func testMultiClassNMS() throws {
        
        NMSHandler.multiClass = true

        let boxes: [BoundingBox] = [
            // Class 0
            BoundingBox(classIndex: 0, score: 0.9, rect: CGRect(x: 0.1, y: 0.1, width: 0.2, height: 0.2), name: "object1", direction: "N", vert: "lower third"),
            BoundingBox(classIndex: 0, score: 0.8, rect: CGRect(x: 0.15, y: 0.15, width: 0.2, height: 0.2), name: "object2", direction: "N", vert: "lower third"),
            BoundingBox(classIndex: 0, score: 0.05, rect: CGRect(x: 0.2, y: 0.2, width: 0.2, height: 0.2), name: "object3", direction: "N", vert: "lower third"),
            // Class 1
            BoundingBox(classIndex: 1, score: 0.7, rect: CGRect(x: 0.4, y: 0.4, width: 0.2, height: 0.2), name: "object4", direction: "E", vert: "lower third"),
            BoundingBox(classIndex: 1, score: 0.65, rect: CGRect(x: 0.45, y: 0.45, width: 0.2, height: 0.2), name: "object5", direction: "E", vert: "lower third"),
            BoundingBox(classIndex: 1, score: 0.6, rect: CGRect(x: 0.8, y: 0.8, width: 0.2, height: 0.2), name: "object6", direction: "E", vert: "lower third"),
            // Class 2
            BoundingBox(classIndex: 2, score: 0.3, rect: CGRect(x: 0.6, y: 0.1, width: 0.2, height: 0.2), name: "object7", direction: "S", vert: "lower third"),
            BoundingBox(classIndex: 2, score: 0.12, rect: CGRect(x: 0.65, y: 0.15, width: 0.2, height: 0.2), name: "object8", direction: "S", vert: "lower third"),
            // Class 3
            BoundingBox(classIndex: 3, score: 0.4, rect: CGRect(x: 0.7, y: 0.7, width: 0.2, height: 0.2), name: "object9", direction: "W", vert: "lower third"),
            BoundingBox(classIndex: 3, score: 0.02, rect: CGRect(x: 0.9, y: 0.9, width: 0.2, height: 0.2), name: "object10", direction: "W", vert: "lower third")
        ]

        
        let filteredBoxes = NMSHandler.performNMS(on: boxes)

        XCTAssertLessThanOrEqual(filteredBoxes.count, 6)
        
        for box in filteredBoxes {
            XCTAssertGreaterThanOrEqual(box.score, 0.1)
        }
    }

}
