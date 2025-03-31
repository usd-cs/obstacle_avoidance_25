//
//  PasswordHandler.swift
//  obstacle_avoidance
//
//  Created by Austin Lim on 3/25/25.
//  Author: Jacob Fernandez

import SwiftUI
import SwiftData
import Foundation
import CryptoKit
func createSalt()->String {
    let characters = "abcdefghijklmnopqrtsuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()?<>."
    var salt = ""
    var identify = 0
    while identify <= 20 {
        let index = Int(arc4random_uniform(UInt32(characters.count)))
        let randomCharacter = characters[characters.index(characters.startIndex, offsetBy: index)]
        salt.append(randomCharacter)
        identify+=1
    }
    return salt
}

func hashSaltPassword(password: String, salt: String) ->String {
    // Converts the password to Data to store it in bytes
    let passwordData = Data(password.utf8)
    let saltData = Data(salt.utf8)
    var saltPassword = passwordData
    saltPassword.append(saltData)
    // hashes password
    let hash = SHA256.hash(data: saltPassword)
    // takes bytes and converts them to strings
    let byteConverter = hash.compactMap {
        String(format: "%02x", $0)}
    // Combines all invidual strings to a single string
    let hashedPassword = byteConverter.joined()
    return hashedPassword
}
func verifyPassword(input: String, storedHash: String, salt: String)-> Bool {
    let hashSaltPassword = hashSaltPassword(password: input, salt: salt)
    return hashSaltPassword == storedHash
}
