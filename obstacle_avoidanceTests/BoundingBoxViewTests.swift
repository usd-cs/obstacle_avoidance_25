//
//  PresentationTests.swift
//  obstacle_avoidance
//
//  Created by Austin Lim on 2/20/25.
//

import XCTest
import Vision
@testable import obstacle_avoidance


final class BoundingBoxViewTests: XCTestCase{
    
    func testInit() {
            let boundingBoxView = BoundingBoxView()

            XCTAssertTrue(boundingBoxView.shapeLayer.isHidden)
            XCTAssertTrue(boundingBoxView.textLayer.isHidden)
            XCTAssertEqual(boundingBoxView.shapeLayer.fillColor, UIColor.clear.cgColor)
            XCTAssertEqual(boundingBoxView.shapeLayer.lineWidth, 4)
            XCTAssertEqual(boundingBoxView.textLayer.contentsScale, UIScreen.main.scale)
            XCTAssertEqual(boundingBoxView.textLayer.fontSize, 14)
            XCTAssertEqual(boundingBoxView.textLayer.alignmentMode, .center)
        }
    
    func testHide() throws{
        let bbv = BoundingBoxView()
        
        bbv.shapeLayer.isHidden = false
        bbv.textLayer.isHidden = false
        
        bbv.hide()
        
        XCTAssertTrue(bbv.shapeLayer.isHidden)
        XCTAssertTrue(bbv.textLayer.isHidden)
    }
    
    func testAddLayers() throws{
        let bbv = BoundingBoxView()
        
        let parent = CALayer()
        
        bbv.addToLayer(parent)
        
        XCTAssertTrue(parent.sublayers?.contains(bbv.shapeLayer) ?? false)
               XCTAssertTrue(parent.sublayers?.contains(bbv.textLayer) ?? false)
        
    }
    
    func testShow() {
        
            let boundingBoxView = BoundingBoxView()
            let testFrame = CGRect(x: 10, y: 20, width: 100, height: 50)
            let label = "Test Label"
            let color = UIColor.red
            let textColor = UIColor.blue

            boundingBoxView.show(frame: testFrame, label: label, color: color, textColor: textColor)

            XCTAssertFalse(boundingBoxView.shapeLayer.isHidden)
            XCTAssertEqual(boundingBoxView.shapeLayer.strokeColor, color.cgColor)

            XCTAssertFalse(boundingBoxView.textLayer.isHidden)
            XCTAssertEqual(boundingBoxView.textLayer.string as? String, label)
            XCTAssertEqual(boundingBoxView.textLayer.foregroundColor, textColor.cgColor)
            XCTAssertEqual(boundingBoxView.textLayer.backgroundColor, color.cgColor)

            let attributes = [NSAttributedString.Key.font: boundingBoxView.textLayer.font as Any]
            let expectedRect = label.boundingRect(with: CGSize(width: 400, height: 100),
                                                  options: .truncatesLastVisibleLine,
                                                  attributes: attributes,
                                                  context: nil)
            let expectedSize = CGSize(width: expectedRect.width + 12, height: expectedRect.height)
            let expectedOrigin = CGPoint(x: testFrame.origin.x - 2, y: testFrame.origin.y - expectedSize.height)
            let expectedFrame = CGRect(origin: expectedOrigin, size: expectedSize)

            XCTAssertEqual(boundingBoxView.textLayer.frame, expectedFrame)
        }
    
    
}
