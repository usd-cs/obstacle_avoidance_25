//
//  ECView.swift
//  obstacle_avoidance
//
//  Created by Austin Lim on 3/26/25.
//

import SwiftUI

struct ECView: View {
    @State private var ecName = ""
    @State private var ecPhoneNumber = ""
    @State private var ecAddress = ""
    @State private var goToApp = false
    let name: String
    @AppStorage("username") private var username = ""
    let password: String
    let address: String
    let email: String
    let phoneNumber: String
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    var body: some View {
        NavigationStack {
            VStack {
                Text("Emergency Contact Information")
                    .padding()
                    .font(.title2)
                Text("Not required, but fill out all fields if you add one")
                    .padding()
                    .font(.footnote)
                TextField("Name", text: $ecName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                TextField("Phone Number", text: $ecPhoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                TextField("Address", text: $ecAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                let emergencyContacts = EmergencyContact(
                    name: ecName,
                    phoneNumber: ecPhoneNumber,
                    address: ecAddress
                )
                Button("Submit") {
                    Task {
                        await addUserDatabase(name: name, username: username, password: password, phoneNumber: phoneNumber, emergencyContact: emergencyContacts, address:address, email: email)
                        goToApp = true
                        isLoggedIn = true
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .navigationDestination(isPresented: $goToApp) {
                    ContentView()
                }
            }
        }
    }
    func addUserDatabase(name: String,
                         username: String,
                         password: String,
                         phoneNumber: String,
                         emergencyContact: EmergencyContact,
                         address: String,
                         email: String) async {
        await Database.shared.addUser(name: name,
                                      username: username,
                                      password: password,
                                      phoneNumber: phoneNumber,
                                      emergencyContacts: [emergencyContact],
                                      email: email,
                                      address: address)
    }
}

#Preview{
    ECView(name: "Joe", password: "12345678", address: "address", email: "email", phoneNumber: "phoneNumber")
}
