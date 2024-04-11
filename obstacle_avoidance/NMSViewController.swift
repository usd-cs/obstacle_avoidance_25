//
//  NMSVievController.swift
//  obstacle_avoidance
//
//  Created by Kenny Collins on 4/11/24.
//

import Foundation
import UIKit

class NMSViewController: UIViewController {
    let numClasses = 4
    let selectHowMany = 6
    let selectPerClass = 2
    let scoreThreshold: Float = 0.1
    let iouThreshold: Float = 0.5
    
    var boundingBoxViews: [BoundingBoxView] = []
    var multiClass = false
    
    // TODO: add the bounding boxes into the list above
    func something() {
        // Perform non-maximum suppression to find the best bounding boxes.
        let selected: [Int]
        if multiClass {
            selected = nonMaxSuppressionMultiClass(numClasses: numClasses,
                                                   boundingBoxes: predictions,
                                                   scoreThreshold: scoreThreshold,
                                                   iouThreshold: iouThreshold,
                                                   maxPerClass: selectPerClass,
                                                   maxTotal: selectHowMany)
        } else {
            // First remove bounding boxes whose score is too low.
            let filteredIndices = predictions.indices.filter { predictions[$0].score > scoreThreshold }
            
            selected = nonMaxSuppression(boundingBoxes: predictions,
                                         indices: filteredIndices,
                                         iouThreshold: iouThreshold,
                                         maxBoxes: selectHowMany)
        }
        
        boundingBoxViews[i].show(frame: prediction.rect,
                                 label: String(format: "%.2f", prediction.score),
                                 color: color, textColor: textColor)
    }
