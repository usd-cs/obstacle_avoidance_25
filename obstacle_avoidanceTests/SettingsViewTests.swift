//
//  SettingsView.swift
//  obstacle_avoidance
//
//  Created by Austin Lim on 2/21/25.
//

import XCTest
import Vision
import ViewInspector
@testable import obstacle_avoidance

final class SettingsViewTests: XCTestCase {
    
    func testSettingsViewShowsNavigationLinks() throws {
        
        let mockUser = User(
                    id: 1,
                    name: "Test User",
                    username: "testuser",
                    phoneNumber: "123-456-7890",
                    emergencyContacts: [],
                    createdAt: "2024-03-28T12:00:00Z",
                    hashedPassword: "hashed",
                    saltedPassword: "salt",
                    address: "123 Test St",
                    email: "test@example.com",
                    userUid: UUID(),
                    measurementType: "feet",
                    userHeight: 72,
                    hapticFeedback: false,
                    locationSharing: false
                )
        
        let set = SettingsView(user: mockUser)
        
        
        let inspect = try set.inspect()
        
        let ns = try inspect.find(ViewType.NavigationStack.self)
        
        let list = try ns.list(0)
        
        XCTAssertEqual(list.count, 4)

        let firstLinkLabel = try list.navigationLink(0)
            .labelView()
            .find(ViewType.Label.self)
        let firstLinkTitle = try firstLinkLabel.find(ViewType.Text.self)
        XCTAssertEqual(try firstLinkTitle.string(), "Account")
        
        let secondLinkLabel = try list.navigationLink(1)
            .labelView()
            .find(ViewType.Label.self)
        let secondLinkTitle = try secondLinkLabel.find(ViewType.Text.self)
        XCTAssertEqual(try secondLinkTitle.string(), "Emergency Contacts")
        
        let thirdLinkLabel = try list.navigationLink(2)
            .labelView()
            .find(ViewType.Label.self)
        let thirdLinkTitle = try thirdLinkLabel.find(ViewType.Text.self)
        XCTAssertEqual(try thirdLinkTitle.string(), "System Preferences")
    }
}
