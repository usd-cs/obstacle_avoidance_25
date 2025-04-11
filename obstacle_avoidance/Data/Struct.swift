//
//  Struct.swift
//  obstacle_avoidance
//
//  Created by Austin Lim on 3/7/25.
//

import Foundation

struct EmergencyContact: Codable {
    let name: String
    let phoneNumber: String
    let address: String
    static let empty = EmergencyContact(name: "", phoneNumber: "", address: "")
}

struct User: Codable {
    let id: Int?
    let name: String
    let username: String
    let phoneNumber: String
    var emergencyContacts: [EmergencyContact]? // Should be a jsonb type in database
    let createdAt: String?
    let hashedPassword: String // Should be varchar type in database
    let saltedPassword: String // Should be varchar type in database
    let address: String
    let email: String
    let userUid: UUID?
}
