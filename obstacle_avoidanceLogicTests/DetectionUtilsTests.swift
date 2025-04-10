//
//  DetectionUtilsTests.swift
//  obstacle_avoidance
//
//  Created by Carlos Breach on 4/6/25.
//

import Foundation
import Testing
@testable import obstacle_avoidance

struct DetectionUtilsTests{
    let polarTests: [Int: (Float, Float)] = [
        1 : (10.0, 0.0),
        2 : (7.1, 7.1),
        3 : (0.0, 10.0 ),
        4 : (-7.1, 7.1),
        5 : (-10.0, 0.0),
    ]
    @Test func polarToCartesian(){
        var angle = -45
        for count in 1 ... 5{
            angle += 45
            let testResult = DetectionUtils.polarToCartesian(distance: 10.0, angle: Float(angle))
            #expect(testResult == polarTests[count]!)
        }

    }
}
