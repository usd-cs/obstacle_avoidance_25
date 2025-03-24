//
//  YOLODecoder.swift
//  obstacle_avoidance
//
//  Created by Carlos Breach on 3/24/25.
//
import CoreImage
import Foundation
import Vision
import CoreML
import UIKit
struct YOLODecoder{
    static let labels: [String] = [
            "bench", "bicycle", "branch", "bus", "bushes", "car", "crosswalk", "door", "elevator",
            "fire_hydrant", "green_light", "gun", "motorcycle", "person", "pothole", "rat", "red_light",
            "scooter", "stairs", "stop_sign", "traffic_cone", "train", "tree", "truck", "umbrella"
        ]
    //removed "yellow_light" since there seems to be a difference between the channels and the labels
    static func decodeOutput(multiArray: MLMultiArray, confidenceTreshold: Float = 0.3) -> [BoundingBox]{
        let shape = multiArray.shape
        guard shape.count == 3,
              let channels = shape[1] as? Int, let boxes = shape[2] as? Int else {
            print("Unexpected detection shape!! \(multiArray.shape)")
            return []
        }
        //channel number test
        /**print("Chanels: ", channels)
        let classNum = channels - 5 // we substract the x,y,w,h as well as the objectness confidence from the tensor
        print("Class Count detected: ", classNum)
        print("Number of labels: ", labels.count)
         */
        let pointer = UnsafeMutablePointer<Float>(OpaquePointer(multiArray.dataPointer))
        var boundingBoxes: [BoundingBox] = []
        for i in 0..<boxes {
            //i am aware this syntax is kind of weird but it basically means
            // count from range (0 to but not including x)

        }

        return []
    }
}
