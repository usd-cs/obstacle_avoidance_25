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
            address: "101 That Lane",
            email: "joe@email.com")

        let users: [User]
        do {
            users = try await Database.shared.fetchUsers()
        } catch {
            XCTFail("Failed to fetch users: \(error)")
            return
        }

        guard let joe = users.first(where: { $0.username == "Joe" }) else {
            XCTFail("Test user not found in fetched results")
            return
        }

        print("User found: \(joe)")
        testUserId = joe.id
        XCTAssertNotNil(testUserId, "User ID is nil!")

        // Delete user
        await Database.shared.deleteUser(userId: joe.id!)

        let deleted = await Database.shared.fetchUserById(userId: joe.id!)
        XCTAssertNil(deleted, "User was not deleted!")
        print("User deleted successfully.")
    }


}

