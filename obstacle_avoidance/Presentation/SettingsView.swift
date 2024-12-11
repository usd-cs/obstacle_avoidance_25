//
//  SettingsView.swift
//  obstacleAvoidance
//
//  Created by Carlos Breach on 12/9/24.
//

import SwiftUI

struct SettingsView: View {
    @State private var meters = false
    @State private var clock = false
    @State private var username = "JacobTF"
    @State private var name = "Jacob"
    @State private var phone = "111-111-1111"
    @State private var email = "fakeemail.com"
    @State private var Address = "fakeaddress"
    
    var body: some View {
            NavigationStack
            {
                List{
                    NavigationLink(destination: AccountScreen()){
                        Label("Account", systemImage: "arrow.right.circle")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top, 50)
                            .padding(.bottom, 30)
                            .accessibility(addTraits: .isStaticText)
                    }
                    NavigationLink(destination: EmergencyContactView()){
                        Label("Emergency Contacts", systemImage: "arrow.right.circle")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top, 50)
                            .padding(.bottom, 30)
                            .accessibility(addTraits: .isStaticText)
                    }
                    NavigationLink(destination: PrefrencesView()){
                        Label("System Prefrences", systemImage: "arrow.right.circle")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                            .padding(.top, 50)
                            .padding(.bottom, 30)
                            .accessibility(addTraits: .isStaticText)
                    }
                }
            }
            .navigationTitle("Settings")
            
    }
}

