//
//  obstacleAvoidanceApp.swift
//  obstacleAvoidance
//
//  Main driver file to the Obstacle avoidance app.
//

import SwiftUI

@main
struct ObstacleAvoidanceApp: App {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    var body: some Scene {
        WindowGroup {
                    if isLoggedIn {
                        ContentView()  // Show main app if logged in
                    } else {
                        LoginView()  // Show login screen if not logged in
                    }
                }
    }
}
