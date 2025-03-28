//
//  SettingsView.swift
//  obstacleAvoidance
//
//  Created by Carlos Breach on 12/9/24.
//

import SwiftUI

struct SettingsView: View {
    let user: User?
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("username") private var username = ""

    var body: some View {
        NavigationStack {
            List {
                NavigationLink(destination: AccountScreen(user: user)) {
                    Label("Account", systemImage: "arrow.right.circle")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 50)
                        .padding(.bottom, 30)
                        .accessibility(addTraits: .isStaticText)
                }
                NavigationLink(destination: EmergencyContactView(user: user)) {
                    Label("Emergency Contacts", systemImage: "arrow.right.circle")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 50)
                        .padding(.bottom, 30)
                        .accessibility(addTraits: .isStaticText)
                }
                NavigationLink(destination: PreferencesView()) {
                    Label("System Preferences", systemImage: "arrow.right.circle")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 50)
                        .padding(.bottom, 30)
                        .accessibility(addTraits: .isStaticText)
                }
                
                Button(action: logout) {
                    Label("Logout", systemImage: "arrow.backward.circle")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding(.top, 50)
                        .padding(.bottom, 30)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .accessibility(label: Text("Logout"))
                }
            }
        }
        .navigationTitle("Settings")
    }
    
    private func logout() {
        isLoggedIn = false
        username = ""  // Reset stored username
    }
}

