//
//  DetectionUtils.swift
//  obstacle_avoidance
//
//  Created by Carlos Breach on 3/28/25.
//

import Foundation

struct DetectionUtils {
    /*
     calculateDirection sections the screen into 5 equal segments along the X axis and determines at what possition is the object.
     */
    static func calculateDirection(_ percentage: CGFloat) -> String {
        // what about if you somehow get a value greater or less than expected?
        guard percentage >= 0, percentage <= 100 else { return "Unknown" }

        let directions = [
            "10 o'clock", "11 o'clock",
            "12 o'clock", "1 o'clock", "2 o'clock"
        ]
        let index = min(Int(percentage / 20.0), directions.count - 1)
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
     similar to how @calculateDirection works, verticalCorridor segments the screen in 3
     sections of equal size, and uses the object's centerYpercentage to determine its
     position relative to the screen.

        PS: combining these two functions should be enough to acomplish our corridor
     calculation....
     basically we can determine an object's X and Y possition and determine if its on a
     significant treat zone. distance from LiDar will be crutial for this as we don't want
     to compute something as being in the in the upper hald of the screen if the object
     is far away...
     */
    static func verticalCorridor(_ percentage: CGFloat) -> String{
        //we might need to switch the upper and lower values, as i'm not too sure whether
        // a low percentage indicates top of the screen or vice versa
        let sections = [
            "upper half",
            "middle half",
            "lower half"
        ]
        let index = min(Int(percentage/33.33), sections.count-1)
        return sections[index]
    }
    static func directionToDegrees(direction: String) -> Float {

        let degrees = [
            "10 o'clock" : 0,
            "11 o'clock" : 20,
            "12 o'clock" : 40,
            "1 o'clock" : 60,
            "2 o'clock" : 80
        ]

        return Float(degrees[direction]!)
    }
    /*
     this functio is what handles the conversion from polar chords to Cardinal cords.
     - this will be specially useful for our corridor idea.
     - we take in the distance (from LiDar sensor) as well as the angle of the detected obstacle
        - ps: they are not necesarilly floats the types will be adjusted accordingly this is just the skeleton of the function
     */
    static func polarToCartesian(distance: Float, direction: String) -> (Float, Float){

        let angle = directionToDegrees(direction: direction)
        if distance <= 0 || angle <= 0 {return (-1,-1)} //this shoudl only happen in case of an error in either distance or angle calculation.
        //we need to first convert the angle to radians
        let angleRadians = (angle * .pi) / 180
        var xCord = distance * cos(angleRadians)
        var yCord = distance * sin(angleRadians)

        //swift is dumb and does not have a built in round func to a given decimal so we'll have ot
        //work around it
        xCord = Float(round(100 * xCord) / 100)
        yCord = Float(round(100 * yCord) / 100)
        return (x: xCord,y: yCord)
    }
}
