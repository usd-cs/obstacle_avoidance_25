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
    static func calculateScreenSection(_ percentage:CGFloat) -> String{
        // checks for unknown or nill values
        guard percentage >= 0, percentage <= 100 else { return "Unknown" }
        //sets devides the screen into 3 sections
        let section = ["Left", "Center", "Right"]
        let index = min(Int(percentage/33.33), section.count-1)
        return section[index]
    }
    /*
     this functio is what handles the conversion from polar chords to Cardinal cords.
     - this will be specially useful for our corridor idea.
     - we take in the distance (from LiDar sensor) as well as the angle of the detected obstacle
        - ps: they are not necesarilly floats the types will be adjusted accordingly this is just the skeleton of the function
     */
    static func polarToCartesian(distance: Float, angle: Float) -> (Float, Float){
        if distance <= 0 || angle <= 0 {return (-1,-1)} //this shoudl only happen in case of an error in either distance or angle calculation.
        //we need to first convert the angle to radians
        let angleRadians = (angle * .pi) / 180
        var xCord = distance * cos(angleRadians)
        var yCord = distance * sin(angleRadians)

        //swift is dumb and does not have a built in round func to a given decimal so we'll have ot
        //work around it
        xCord = Float(round(10 * xCord) / 10)
        yCord = Float(round(10 * yCord) / 10)
        return (x: xCord,y: yCord)
    }
}
