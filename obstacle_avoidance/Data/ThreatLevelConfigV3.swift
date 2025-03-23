//
//  ThreatLevelConfigV3.swift
//  obstacle_avoidance
//
//  Created by Darien Aranda on 3/23/25.
//

import Foundation

struct ThreatLevelConfigV3{
    static let angleWeights: [Int: Int]=[
        12: 5,  //Directly Ahead
        11: 3,  //Slightly Off-Centered
        1: 3,
        10: 1,  //Closing in on Peripheral Vision
        2: 1
    ]

//Setting up semi-arbitrary values just to run through the tree
//15-12 consist of non-stationary obstacles. 10 represent stationary items of priority
//7 we may encounter along a path, 6 is items we may find helpful, 5, items we can identify more as testing, 0 is items we should disregard.
    static let objectWeights: [Int: Int]=[
        0: 15,  // Person
        1: 15,  // Bicycle
        2: 15,  // Car
        3: 15,  // Motorcycle
        4: 0,   // Aeroplane
        5: 15,  // Bus
        6: 15,  // Train
        7: 15,  // Truck
        8: 6,   // Boat
        9: 6,   // Traffic Light
        10: 6,  // Fire Hydrant
        11: 7,  // Stop Sign
        12: 10, // Parking Meter
        13: 10, // Bench
        14: 6,  // Bird
        15: 7,  // Cat
        16: 7,  // Dog
        17: 7,  // Horse
        18: 6,  // Sheep
        19: 6,  // Cow
        20: 0,  // Elephant
        21: 0,  // Bear
        22: 0,  // Zebra
        23: 0,  // Giraffe
        24: 7,  // Backpack
        25: 7,  // Umbrella
        26: 6,  // Handbag
        27: 0,  // Tie
        28: 6,  // Suitcase
        29: 6,  // Frisbee
        30: 5,  // Skis
        31: 5,  // Snowboard
        32: 6,  // Sports Ball
        33: 7,  // Kite
        34: 6,  // Baseball Bat
        35: 6,  // Baseball Glove
        36: 8,  // Skateboard
        37: 8,  // Surfboard
        38: 5,  // Tennis Racket
        39: 5,  // Bottle
        40: 5,  // Wine Glass
        41: 5,  // Cup
        42: 5,  // Fork
        43: 5,  // Knife
        44: 5,  // Spoon
        45: 5,  // Bowl
        46: 5,  // Banana
        47: 5,  // Apple
        48: 5,  // Sandwich
        49: 5,  // Orange
        50: 5,  // Broccoli
        51: 5,  // Carrot
        52: 5,  // Hot Dog
        53: 5,  // Pizza
        54: 5,  // Donut
        55: 5,  // Cake
        56: 7,  // Chair
        57: 7,  // Sofa
        58: 8,  // Potted Plant
        59: 7,  // Bed
        60: 7,  // Dining table
        61: 6,  // Toilet
        62: 6,  // TV Monitor
        63: 6,  // Laptop
        64: 5,  // Mouse
        65: 5,  // Remote
        66: 5,  // Keyboard
        67: 5,  // Cell Phone
        68: 5,  // Microwave
        69: 5,  // Oven
        70: 5,  // Toaster
        71: 5,  // Sink
        72: 5,  // Refrigerator
        73: 5,  // Book
        74: 5,  // Clock
        75: 5,  // Vase
        76: 5,  // Scissors
        77: 5,  // Teddy Bear
        78: 5,  // Hair Brush
        79: 5   // Toothbrush
    ]

    static let objectName: [Int: String]=[
        0: "person",
        1: "bicycle",
        2: "car",
        3: "motorcycle",
        4: "aeroplane",
        5: "bus",
        6: "train",
        7: "truck",
        8: "boat",
        9: "traffic light",
        10: "fire hydrant",
        11: "stop sign",
        12: "parking meter",
        13: "bench",
        14: "bird",
        15: "cat",
        16: "dog",
        17: "horse",
        18: "sheep",
        19: "cow",
        20: "elephant",
        21: "bear",
        22: "zebra",
        23: "giraffe",
        24: "backpack",
        25: "umbrella",
        26: "handbag",
        27: "tie",
        28: "suitcase",
        29: "frisbee",
        30: "skis",
        31: "snowboard",
        32: "sports ball",
        33: "kite",
        34: "baseball bat",
        35: "baseball glove",
        36: "skateboard",
        37: "surfboard",
        38: "tennis racket",
        39: "bottle",
        40: "wine glass",
        41: "cup",
        42: "fork",
        43: "knife",
        44: "spoon",
        45: "bowl",
        46: "banana",
        47: "apple",
        48: "sandwich",
        49: "orange",
        50: "broccoli",
        51: "carrot",
        52: "hot dog",
        53: "pizza",
        54: "donut",
        55: "cake",
        56: "chair",
        57: "sofa",
        58: "potted plant",
        59: "bed",
        60: "dining table",
        61: "toilet",
        62: "tv",  //Testing how naming conventions impact the DecBlock readings
        63: "laptop",
        64: "mouse",
        65: "remote",
        66: "keyboard",
        67: "cell phone",
        68: "microwave",
        69: "oven",
        70: "toaster",
        71: "sink",
        72: "refrigerator",
        73: "book",
        74: "clock",
        75: "vase",
        76: "scissors",
        77: "teddy bear",
        78: "hair drier",
        79: "toothbrush"
    ]
}
