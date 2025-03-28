//
//  LoginView.swift
//  obstacle_avoidance
//
//  Created by Austin Lim on 3/25/25.
//

import SwiftUI
import SwiftData

struct LoginView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("username") private var username = ""
    @State private var goToApp = false
    @State private var goToSignUp = false
    @State private var password = ""
    @State private var isPasswordVisible = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Navig-Aid")
                    .font(.largeTitle)
                    .padding()
                
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                ZStack(alignment: .trailing) {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                            .accessibilityLabel("Password field, currently visible")
                    } else {
                        SecureField("Password", text: $password)
                            .accessibilityLabel("Password field, currently hidden")
                    }
                    
                    Button(action: { isPasswordVisible.toggle() }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 10)
                    }
                    .accessibilityLabel(isPasswordVisible ? "Hide password" : "Show password")
                    .accessibilityHint("Double-tap to toggle password visibility.")
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                Button("Login") {
                    Task {
                        await authenticateUser(username: username)
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding()
                .navigationDestination(isPresented: $goToApp) {
                    ContentView()
                }
                
                Button("Sign Up") {
                    goToSignUp = true
                }
                .foregroundColor(.blue)
                .navigationDestination(isPresented: $goToSignUp) {
                    SignUpView()
                }
            }
        }
    }
    
    func authenticateUser(username: String) async {
        let users = await Database.shared.fetchUsers()
        
        if let user = users.first(where: { $0.username == username }) {
            if verifyPassword(input: password, storedHash: user.hashedPassword, salt: user.saltedPassword) {
                isLoggedIn = true
                self.username = user.username
                goToApp = true
            } else {
                print("Incorrect password")
            }
        } else {
            print("User not found")
        }
    }
}

#Preview {
    LoginView()
}
