//
//  YoloDecoder.swift
//  obstacle_avoidance
//
//  Created by Carlos Breach on 3/28/25.
//

import CoreImage
import Foundation
import Vision
import CoreML
import UIKit

struct YOLODecoder{
    /**Not entirelly if there is a better way of doing this, but since the model is outputing the raw tensors in the form of a multiArray we have to manually assign it a label**/
    static let labels: [String] = [
            "bench", "bicycle", "branch", "bus", "bushes", "car", "crosswalk", "door", "elevator",
            "fire_hydrant", "green_light", "gun", "motorcycle", "person", "pothole", "rat", "red_light",
            "scooter", "stairs", "stop_sign", "traffic_cone", "train", "tree", "truck", "umbrella"
        ]

   static func sigmoid(_ x: Float) -> Float {
        return 1 / (1 + exp(-x))
    }

    static func decodeOutput(multiArray: MLMultiArray, confidenceThreshold: Float = 0.5) -> [BoundingBox] {
        let shape = multiArray.shape
        guard shape.count == 3,
            let channels = shape[1] as? Int, let boxes = shape[2] as? Int else {
            print("Unexpected detection shape!! \(multiArray.shape)")
            return []
        }

        let classNum = channels - 5
        let pointer = multiArray.dataPointer.bindMemory(to: Float.self, capacity: multiArray.count)

        var boundingBoxes = [BoundingBox]()

        for i in 0..<boxes {
            let base = i * channels
            let x = pointer[base]
            let y = pointer[base + 1]
            let width = pointer[base + 2]
            let height = pointer[base + 3]
            let objectnessScore = sigmoid(pointer[base + 4]) // Apply sigmoid early

            var maxClassScore: Float = 0
            var classIndex = -1  // Instead of optional

            // Find the best class index and score
            for c in 0..<classNum {
                let score = sigmoid(pointer[base + 5 + c])  // Apply sigmoid
                if score > maxClassScore {
                    maxClassScore = score
                    classIndex = c
                }
            }

            // Skip processing if no valid class was found
            if classIndex == -1 { continue }

            let confidence = objectnessScore * maxClassScore
            if confidence < confidenceThreshold { continue } // Skip low-confidence detections

            // Compute bounding box coordinates efficiently
            let x1 = max(min(x - width / 2, 1), 0)
            let y1 = max(min(y - height / 2, 1), 0)
            let x2 = max(min(x + width / 2, 1), 0)
            let y2 = max(min(y + height / 2, 1), 0)

            let rect = CGRect(
                x: CGFloat(x1),
                y: CGFloat(y1),
                width: CGFloat(x2 - x1),
                height: CGFloat(y2 - y1)
            )
            let centerX = rect.midX
            //let direction = DetectionUtils.calculateDirection(centerX)

            boundingBoxes.append(BoundingBox(
                classIndex: classIndex,
                score: confidence,
                rect: rect,
                name: labels[classIndex],
                direction: "Unkown"
            ))
        }

        return boundingBoxes
    }

}
