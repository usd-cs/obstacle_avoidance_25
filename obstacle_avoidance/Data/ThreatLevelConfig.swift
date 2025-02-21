//
//  ThreatLevelConfig.swift
//  obstacle_avoidance
//
//  Created by Darien Aranda on 2/20/25.
//

import Foundation

struct ThreatLevelConfig{
    static let angleWeights: [Int: Int]=[
        12: 5,  //Directly Ahead
        11: 3,  //Slightly Off-Centered
        1: 3,
        10: 1,  //Closing in on Peripheral Vision
        2: 1
    ]
    
    //Setting up semi-arbitrary values just to run through the tree
    //15-12 consist of non-stationary obstacles. 10 represent stationary items of priority
    //7 we may encounter along a path, 6 is items we may find helpful, 0 is items we should disregard.
    static let objectWeights: [Int: Int]=[
        0: 7,                   //Bench
        1: 15,                  //Bicycle
        2: 7,                   //Branch
        3: 12,                  //Bus
        4: 6,                   //Bushes
        5: 12,                  //Car
        6: 7,                   //Crosswalk
        7: 7,                   //Door
        8: 5,                   //Elevator
        9: 6,                   //Fire Hydrant
        10: 6,                  //Green Light
        11: 0,                  //Gun
        12: 12,                 //Motorcycle
        13: 15,                 //Person
        14: 7,                  //Pothole
        15: 0,                  //Rat
        16: 6,                  //Red Light
        17: 15,                 //Scooter
        18: 15,                 //Stairs
        19: 10,                 //Stop Sign
        20: 7,                  //Traffic Cone
        21: 12,                 //Train
        22: 10,                 //Tree
        23: 12,                 //Truck
        24: 0,                  //Umbrella
        25: 6                   //Yellow Light
    ]
    
    static let objectName: [Int: String]=[
        0: "Bench",
        1: "Bicycle",
        2: "Branch",
        3: "Bus",
        4: "Bushes",
        5: "Car",
        6: "Crosswalk",
        7: "Door",
        8: "Elevator",
        9: "Fire Hydrant",
        10: "Green Light",
        11: "Gun",
        12: "Motorcycle",
        13: "Person",
        14: "Pothole",
        15: "Rat",
        16: "Red Light",
        17: "Scooter",
        18: "Stairs",
        19: "Stop Sign",
        20: "Traffic Cone",
        21: "Train",
        22: "Tree",
        23: "Truck",
        24: "Umbrella",
        25: "Yellow Light"
    ]
}
