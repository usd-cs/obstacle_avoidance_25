//
//  SignUpView.swift
//  obstacle_avoidance
//
//  Created by Austin Lim on 3/25/25.
//
import SwiftUI

struct SignUpView: View{
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("username") private var username = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var isPasswordVisible = false
    @State private var address = ""
    @State private var email = ""
    @State private var name = ""
    @State private var passwordAccepted = false
    @State private var usernameAccepted = false
    @State private var phoneNumberAccepted = false
    @State private var emailAccepted = false
    let minPasswordLength = 8
    @State private var nameFilled = false
    @State private var goToECView = false
    
    var body: some View{
        VStack(alignment: .leading, spacing: 4){
            
            Text("User Information")
                .font(.largeTitle)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
            
            VStack(alignment: .leading, spacing: 4) {
                            Text("Name: required")
                                .font(.caption)
                                .foregroundColor(.red)
                            
                            TextField("Enter name", text: $name)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 370)  // Set a fixed width
                                .padding(.bottom, 8)
                                .onChange(of: name) {
                                    nameFilled = !name.isEmpty
                                }
                        }
            .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(alignment: .leading, spacing: 4) {
                           Text("Username: required")
                               .font(.caption)
                               .foregroundColor(.red)
                           
                           TextField("Enter username", text: $username)
                               .textFieldStyle(RoundedBorderTextFieldStyle())
                               .frame(width: 370)  // Set a fixed width
                               .padding(.bottom, 8)
                       }
            .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(alignment: .leading, spacing: 4) {
                            Text("Password: required")
                                .font(.caption)
                                .foregroundColor(.red)
                            
                            ZStack(alignment: .trailing) {
                                if isPasswordVisible {
                                    TextField("Enter password", text: $password)
                                        .accessibilityLabel("Password field currently visible")
                                } else {
                                    SecureField("Enter password", text: $password)
                                        .accessibilityLabel("Password field currently hidden")
                                }

                                Button(action: { isPasswordVisible.toggle() }) {
                                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 10)
                                }
                            }
                            .onChange(of: password) {
                                passwordAccepted = password.count >= minPasswordLength
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 370)
                            .padding(.bottom, 8)
                        }
            .onChange(of: password) {
                passwordAccepted = password.count >= minPasswordLength
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            
            VStack(alignment: .leading, spacing: 4) {
                            Text("Phone Number: required")
                                .font(.caption)
                                .foregroundColor(.red)
                            
                            TextField("Enter phone number", text: $phoneNumber)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 370)
                                .padding(.bottom, 8)
                        }
            
            .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(alignment: .leading, spacing: 4) {
                            Text("Email: Optional")
                                .font(.caption)
                            
                            TextField("Enter email", text: $email)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 370)
                                .padding(.bottom, 8)
                        }
            .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(alignment: .leading, spacing: 4) {
                            Text("Address: Optional")
                                .font(.caption)
                            
                            TextField("Enter address", text: $address)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 370)
                                .padding(.bottom, 8)
                        }
            .frame(maxWidth: .infinity, alignment: .center)
            
        }
        Button("Next") {
            Task {
                await confirmUser(username: username, phoneNumber: phoneNumber, email: email)
            }
        }
        .buttonStyle(.borderedProminent)
        .padding()
        .navigationDestination(isPresented: $goToECView) {
            ECView(name:name, password: password, address: address, email: email, phoneNumber: phoneNumber)
        }

    }
    
    func confirmUser(username: String, phoneNumber: String, email: String) async{
        let users = await Database.shared.fetchUsers()
        
        if users.contains(where: { $0.username == username }) {
            usernameAccepted = false
            print("Username already taken")
        } else {
            usernameAccepted = true
        }
        if users.contains(where: { $0.phoneNumber == phoneNumber }) {
            phoneNumberAccepted = false
            print("Phone number already taken")
        } else {
            phoneNumberAccepted = true
        }
        if users.contains(where: { $0.email == email }) {
            emailAccepted = false
            print("Email already taken")
        } else if email.isEmpty {
            emailAccepted = true
        } else{
            emailAccepted = true
        }
        
        if (nameFilled == true && usernameAccepted == true && emailAccepted == true && phoneNumberAccepted == true && passwordAccepted == true){
            goToECView = true
        }
        
    }
    
}

#Preview {
    NavigationStack {
            SignUpView()
        }
}

