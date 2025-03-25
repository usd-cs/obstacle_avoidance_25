//
//  DetectionUtils.swift
//  obstacle_avoidance
//
//  Created by Carlos Breach on 3/25/25.
//
import Foundation

struct DetectionUtils{
    static func calculateDirection(_ percentage: CGFloat) -> String{
        switch percentage {
        case 0..<16.67:
            return "9 o'clock"
        case 16.67..<33.33:
            return "10 o'clock"
        case 33.33..<50:
            return "11 o'clock"
        case 50..<66.67:
            return "12 o'clock"
        case 66.67..<83.33:
            return "1 o'clock"
        case 83.33..<100:
            return "2 o'clock"
        default:
            return "Unknown"
        }
    }
}
