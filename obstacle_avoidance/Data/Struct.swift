//
//  Struct.swift
//  obstacle_avoidance
//
//  Created by Austin Lim on 3/7/25.
//

import Foundation

struct EmergencyContact: Codable{
    let name: String
    let phone_number: String
    
    static let empty = EmergencyContact(name: "", phone_number: "")
}

struct User: Codable{
    
    let id: Int?
    let username: String
    let phone_number: String
    let emergency_contact: EmergencyContact
    let created_at: String?
    
}
