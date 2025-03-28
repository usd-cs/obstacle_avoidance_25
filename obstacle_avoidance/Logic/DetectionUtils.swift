//
//  DetectionUtils.swift
//  obstacle_avoidance
//
//  Created by Carlos Breach on 3/28/25.
//

import Foundation

struct DetectionUtils {
    static func calculateDirection(_ percentage: CGFloat) -> String {
        // what about if you somehow get a value greater or less than expected?
        guard percentage >= 0, percentage <= 100 else { return "Unknown" }

        let directions = [
            "9 o'clock", "10 o'clock", "11 o'clock",
            "12 o'clock", "1 o'clock", "2 o'clock"
        ]
        let index = min(Int(percentage / 16.67), directions.count - 1)
        return directions[index]
    }
}
