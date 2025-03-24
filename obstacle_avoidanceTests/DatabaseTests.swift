//
//  DatabaseTests.swift
//  obstacle_avoidance
//
//  Created by Austin Lim on 3/7/25.
//

import XCTest
@testable import obstacle_avoidance

final class DatabaseTests: XCTestCase {
    var testUserId: Int?

    func testDatabase() async throws {
            print(" Starting Test")

            let testEC = EmergencyContact(name: "Mike", phoneNumber: "123-456-7890")
            await Database.shared.addUser(username: "Joe", phoneNumber: "555-666-7777", emergencyContact: testEC)

            
            let users = await Database.shared.fetchUsers()
            testUserId = users.first(where: { $0.username == "Joe" })?.id
            XCTAssertNotNil(testUserId, "Test user was not created!")
            print("User added successfully with ID:", testUserId ?? "nil")

            let updatedEC = EmergencyContact(name: "Joe", phoneNumber: "444-555-6666")
        
            guard let testUserId = testUserId else {
                XCTFail("ERROR: testUserId is nil! The user was not created properly.")
                return
            }
            await Database.shared.updateEmergencyContact(userId: testUserId, newEC: updatedEC)

       
            let updatedUser = await Database.shared.fetchUserById(userId: testUserId)
            XCTAssertEqual(updatedUser?.emergencyContact.name, "Mike", "Emergency contact update failed!")
            print("Emergency contact updated successfully.")

            await Database.shared.deleteUser(userId: testUserId)


            let deletedUser = await Database.shared.fetchUserById(userId: testUserId)
            XCTAssertNil(deletedUser, "User was NOT deleted!")
            print("User deleted successfully.")

        }
}
