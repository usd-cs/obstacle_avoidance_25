//
//  NMSVievController.swift
//  obstacleAvoidance
//
//  Created by Kenny Collins on 4/11/24.
//

import Foundation
import UIKit

struct NMSHandler {
    static func performNMS(on boundingBoxes: [BoundingBox]) -> [BoundingBox] {
        let numClasses = 4
        let selectHowMany = 6
        let selectPerClass = 2
        let scoreThreshold: Float = 0.1
        let iouThreshold: Float = 0.5
        //    var boundingBoxViews: [BoundingBoxView] = []
        let multiClass = true
        // Perform non-maximum suppression to find the best bounding boxes.
        let selected: [Int]
        if multiClass {
            selected = nonMaxSuppressionMultiClass(numClasses: numClasses,
                                                   boundingBoxes: boundingBoxes,
                                                   scoreThreshold: scoreThreshold,
                                                   iouThreshold: iouThreshold,
                                                   maxPerClass: selectPerClass,
                                                   maxTotal: selectHowMany)
        } else {
            // First remove bounding boxes whose score is too low.
            let filteredIndices = boundingBoxes.indices.filter { boundingBoxes[$0].score > scoreThreshold }
            selected = nonMaxSuppression(boundingBoxes: boundingBoxes,
                                         indices: filteredIndices,
                                         iouThreshold: iouThreshold,
                                         maxBoxes: selectHowMany)
        }
        var result: [BoundingBox] = []
        for sbox in selected {
            result.append(boundingBoxes[sbox])
        }
        return result
    }
}
