//
//  ThreatLevelConfigV3.swift
//  obstacle_avoidance
//
//  Created by Darien Aranda on 3/23/25.
//

import Foundation

struct ThreatLevelConfigV3{
    static let CorridorPosition: [String: Int]=[
        "Center": 10,  //Directly Ahead
        "Left": 3,     // Left of the Corridor
        "Right": 3,    // Right of the Corridor
        "Above": 2,    // Front of the Corridor
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

    static let objectName: [String: Int] = [
        "person": 0,
        "bicycle": 1,
        "car": 2,
        "motorcycle": 3,
        "aeroplane": 4,
        "bus": 5,
        "train": 6,
        "truck": 7,
        "boat": 8,
        "traffic light": 9,
        "fire hydrant": 10,
        "stop sign": 11,
        "parking meter": 12,
        "bench": 13,
        "bird": 14,
        "cat": 15,
        "dog": 16,
        "horse": 17,
        "sheep": 18,
        "cow": 19,
        "elephant": 20,
        "bear": 21,
        "zebra": 22,
        "giraffe": 23,
        "backpack": 24,
        "umbrella": 25,
        "handbag": 26,
        "tie": 27,
        "suitcase": 28,
        "frisbee": 29,
        "skis": 30,
        "snowboard": 31,
        "sports ball": 32,
        "kite": 33,
        "baseball bat": 34,
        "baseball glove": 35,
        "skateboard": 36,
        "surfboard": 37,
        "tennis racket": 38,
        "bottle": 39,
        "wine glass": 40,
        "cup": 41,
        "fork": 42,
        "knife": 43,
        "spoon": 44,
        "bowl": 45,
        "banana": 46,
        "apple": 47,
        "sandwich": 48,
        "orange": 49,
        "broccoli": 50,
        "carrot": 51,
        "hot dog": 52,
        "pizza": 53,
        "donut": 54,
        "cake": 55,
        "chair": 56,
        "sofa": 57,
        "potted plant": 58,
        "bed": 59,
        "dining table": 60,
        "toilet": 61,
        "tv": 62,
        "laptop": 63,
        "mouse": 64,
        "remote": 65,
        "keyboard": 66,
        "cell phone": 67,
        "microwave": 68,
        "oven": 69,
        "toaster": 70,
        "sink": 71,
        "refrigerator": 72,
        "book": 73,
        "clock": 74,
        "vase": 75,
        "scissors": 76,
        "teddy bear": 77,
        "hair drier": 78,
        "toothbrush": 79,
    ]
}
