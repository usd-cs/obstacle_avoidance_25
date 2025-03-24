//
//  Struct.swift
//  obstacle_avoidance
//
//  Created by Austin Lim on 3/7/25.
//

import Foundation

struct EmergencyContact: Codable{
    let name: String
    let phoneNumber: String
    
    static let empty = EmergencyContact(name: "", phoneNumber: "")
}

struct User: Codable{
    
    let id: Int?
    let username: String
    let phoneNumber: String
    let emergencyContact: EmergencyContact
    let createdAt: String?
}
