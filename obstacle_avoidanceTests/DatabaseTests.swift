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
        print("Starting Test")

        let testEC = EmergencyContact(name: "Mike", phoneNumber: "123-456-7890", address: "100 That Lane")
        await Database.shared.addUser(
            name: "Joe",
            username: "Joe",
            password: "hellothere",
            phoneNumber: "555-666-7777",
            emergencyContacts: [testEC],
            email: "joe@email.com",
            address: "101 That Lane"
        )

        let users = await Database.shared.fetchUsers()
        testUserId = users.first(where: { $0.username == "Joe" })?.id
        XCTAssertNotNil(testUserId, "Test user was not created!")
        print("User added successfully with ID:", testUserId ?? "nil")

        // let updatedEC = EmergencyContact(name: "Tom", phoneNumber: "444-555-6666", address: "100 That Lane")

        guard let testUserId = testUserId else {
            XCTFail("ERROR: testUserId is nil! The user was not created properly.")
            return
        }

        // await Database.shared.updateEmergencyContact(userId: testUserId, newECs: [updatedEC])

        // let updatedUser = await Database.shared.fetchUserById(userId: testUserId)

        // print("Updated User Full Object:", updatedUser ?? "nil")
        

        await Database.shared.deleteUser(userId: testUserId)

        let deletedUser = await Database.shared.fetchUserById(userId: testUserId)
        XCTAssertNil(deletedUser, "User was NOT deleted!")
        print("User deleted successfully.")
    }

}

