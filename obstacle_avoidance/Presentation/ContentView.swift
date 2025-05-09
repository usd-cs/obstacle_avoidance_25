//
//  Obstacle Avoidance App
//  ContentView.swift
//
//  Content View is a swift file that is used for triggering the Obstacle Avoidance application.
//
//  Previous Authors: Alexander Guerrero, Avery Lenninger, Olivia Nolan Shafer, Cassidy Spencer

// Current Authors: Jacob Fernandez, Austin Lim
//  Last modified: 3/27/2025
//

import SwiftUI

// Structure for app viewing upon opening.
struct ContentView: View {
    // Tracks when an alert should be shown or when the start button has been pressed
    @State private var showAlert = false
    @State private var startPressed = false
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @State private var currentUser: User?
    @AppStorage("username") private var username = ""
    var body: some View {
        VStack {
            TabbedView(user: $currentUser)
        }
        .onAppear {
            Task {
                await getUserInfo()
            }
        }
    }
    private func getUserInfo() async {
        let users = await Database.shared.fetchUsers()
        currentUser = users.first(where: { $0.username == username })
    }
}

// Main tab bar with navigation
struct TabbedView: View {
    @Binding var user: User?
    init(user: Binding<User?>) {
        self._user = user
        UITabBar.appearance().backgroundColor = UIColor.lightGray
        UITabBar.appearance().isTranslucent = true
    }
    var body: some View {
        TabView {
            // Home tab
            InstructionView()
                .tabItem {
                    Image(systemName: "house.fill")
                        .accessibility(label: Text("Home Tab"))
                    Text("Home").font(.system(size: 50))
                }
            // Camera tab
            CameraView()
                .tabItem {
                    Image(systemName: "camera.fill")
                        .accessibility(label: Text("Camera Tab"))
                    Text("Camera").font(.system(size: 50))
                }
            // Settings view, in a navigation stack so we can have a proper back button
            NavigationStack {
                SettingsView(user: $user)
            }
                .tabItem {
                    Image(systemName: "gear")
                        .accessibility(label: Text("Settings Tab"))
                    Text("Settings")
                }
        }
    }
}

struct AccountScreen: View {
    @State private var isEditing: Bool = false // Controls editing mode
    @AppStorage("username") private var username = ""
    @Binding var user: User?
    @State private var updatedUsername = ""
    @State private var updatedName = ""
    @State private var updatedEmail = ""
    @State private var updatedPhoneNumber = ""
    @State private var updatedAddress = ""
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    var body: some View {
        Form {
            // This is the account screen, so it will hold all the information for each user.
            Section(header: Text("Account Information")) {
                if let user = user {
                    editableRow(label: "Username", text: $updatedUsername)
                    editableRow(label: "Name", text: $updatedName)
                    editableRow(label: "Email", text: $updatedEmail, keyboard: .emailAddress)
                    editableRow(label: "Phone Number", text: $updatedPhoneNumber, keyboard: .phonePad)
                    editableRow(label: "Address", text: $updatedAddress)
                    // editableRow(label: "Password", text: "********", isSecure: true)
                    HStack {
                        Text("Password:").fontWeight(.bold)
                        Spacer()
                        Text("********") // Always shows `********` instead of the actual password
                            .foregroundColor(.gray)
                    }
                }
            }
            .onAppear {
                Task {
                    if let userId = user?.id {
                        if let refreshedUser = await Database.shared.fetchUserById(userId: userId) {
                            self.user = refreshedUser
                            updatedUsername = refreshedUser.username
                            updatedName = refreshedUser.name
                            updatedEmail = refreshedUser.email
                            updatedPhoneNumber = refreshedUser.phoneNumber
                            updatedAddress = refreshedUser.address
                        }
                    }
                }
            }
            Button(action: {
                Task {
                    if let user = user, let userId = user.id {
                        await deleteAccount(userId: userId)
                    } else {
                        print("Error: No valid user ID found.")
                    }
                }
            }) {
                Text("Delete Account")
                    .foregroundColor(.red)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .navigationTitle("Account")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        print("Done tapped — saving changes")
                        saveChanges()
                    } else {
                        isEditing = true
                    }
                }
            }
        }
    }
    private func saveChanges() {
        // Logic to save changes to a database or user preferences
        print("saveChanges triggered")
        guard let user = user, let userId = user.id else { return }
        Task{
            print("Entering Task")
            await Database.shared.updateUser(
                userId: userId,
                newName: updatedName,
                newUsername: updatedUsername,
                newPhoneNumber: updatedPhoneNumber,
                newEmail: updatedEmail,
                newAddress: updatedAddress
            )
            print("Task complete")
            /*if updatedEmail != user.email && !updatedEmail.isEmpty {
             do {
             try await Database.shared.updateAuthEmail(updatedEmail)
             } catch {
             print("Failed to update email: \(error.localizedDescription)")
             }
             }
             
             if updatedPhoneNumber != user.phoneNumber && !updatedPhoneNumber.isEmpty {
             do {
             try await Database.shared.updateAuthPhone(updatedPhoneNumber)
             } catch {
             print("Failed to update phone number: \(error.localizedDescription)")
             }
             }*/
            DispatchQueue.main.async {
                updatedUsername = updatedUsername
                updatedName = updatedName
                updatedEmail = updatedEmail
                updatedPhoneNumber = updatedPhoneNumber
                updatedAddress = updatedAddress
                
                isEditing = false
            }
        }
    }
    private func editableRow(label: String, text: Binding<String>, keyboard: UIKeyboardType = .default, isSecure: Bool = false) -> some View {
        HStack {
            Text("\(label):").fontWeight(.bold)
            Spacer()
            if isEditing {
                if isSecure {
                    SecureField("Enter \(label)", text: text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    TextField("Enter \(label)", text: text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(keyboard)
                }
            } else {
                Text(text.wrappedValue)
                    .foregroundColor(.gray)
            }
        }
    }
    private func deleteAccount(userId: Int) async {
        await Database.shared.deleteUser(userId: userId)
        isLoggedIn = false
    }
}

struct EmergencyContactView: View {
    let user: User?
    @State private var contacts: [EmergencyContact] = []
    @State private var nameEC = ""
    @State private var phoneNumberEC = ""
    @State private var addressEC = ""
    @State private var addingEC = false
    @State private var isEditing = false
    @State private var editingContact: EmergencyContact? = nil
    @State private var editingIndex: Int? = nil
    @State private var editName = ""
    @State private var editPhone = ""
    @State private var editAddress = ""
    var body: some View {
        VStack {
            Section(header: Text("Emergency Contacts")) {
                if contacts.isEmpty {
                    Text("No emergency contacts available.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(Array(contacts.enumerated()), id: \.element.name) { index, contact in
                        if editingIndex == index {
                            VStack(alignment: .leading, spacing: 10) {
                                TextField("Name", text: $editName)
                                TextField("Address", text: $editAddress)
                                TextField("Phone Number", text: $editPhone)
                                HStack {
                                    Button("Cancel") {
                                        editingIndex = nil
                                    }
                                    Spacer()
                                    Button("Save") {
                                        let updated = EmergencyContact(name: editName,
                                                                       phoneNumber: editPhone,
                                                                       address: editAddress)
                                        Task {
                                            await editEC(originalName: contact.name, updated: updated)
                                            editingIndex = nil
                                        }
                                    }
                                }
                                .padding(.top, 5)
                            }
                            .padding()
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(10)
                        } else {
                            EmergencyContactCard(
                                contact: contact,
                                onDelete: {
                                    Task { await deleteEmergencyContact(contact) }
                                },
                                onEdit: {
                                    editingIndex = index
                                    editName = contact.name
                                    editPhone = contact.phoneNumber
                                    editAddress = contact.address
                                }
                            )
                        }
                    }
                }
            }
            if addingEC {
                newBoxView()
            }
            Button("Add Contact") {
                addingEC = true
            }
        }
        .onAppear {
            if let userContacts = user?.emergencyContacts {
                contacts = userContacts
            }
        }
    }
    private func deleteEmergencyContact(_ contact: EmergencyContact) async {
        guard let userId = user?.id else { return }

        DispatchQueue.main.async {
            contacts.removeAll { $0.name == contact.name }
        }
        await Database.shared.deleteEmergencyContact(userId: userId, contactName: contact.name)
    }
    private func newBoxView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Name", text: $nameEC)
            TextField("Phone Number", text: $phoneNumberEC)
            TextField("Address", text: $addressEC)
            Button("Save Contact") {
                let newContact = EmergencyContact(name: nameEC, phoneNumber: phoneNumberEC, address: addressEC)
                Task {
                    await addEC(newContact)
                }
            }
            .padding(.top)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding()
    }
    private func addEC(_ newContact: EmergencyContact) async {
        guard let userId = user?.id else { return }
        await Database.shared.addEmergencyContact(userId: userId, newEC: newContact)
        DispatchQueue.main.async {
            contacts.append(newContact)
            //self.newContact = .empty
            self.nameEC = ""
            self.phoneNumberEC = ""
            self.addressEC = ""
            self.addingEC = false
        }
    }
    private func editEC(originalName: String, updated: EmergencyContact) async {
        guard let userId = user?.id else { return }
        if let index = contacts.firstIndex(where: { $0.name == originalName }) {
            contacts[index] = updated
        }
        await Database.shared.updateEmergencyContact(userId: userId, originalName: originalName, updatedContact: updated)
    }
}
struct EmergencyContactCard: View {
    let contact: EmergencyContact
    let onDelete: () -> Void
    let onEdit: () -> Void
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(contact.name)
                    .font(.title2)
                    .bold()
                Text("Phone: \(contact.phoneNumber)")
                    .font(.headline)
                    .foregroundColor(.blue)
                Text("Address: \(contact.address)")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack(spacing: 10) {
                Button("Edit", action: onEdit)
                    .foregroundColor(.blue)
                Button("Delete", action: onDelete)
                    .foregroundColor(.red)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}
// Allows for our picker to easily work. Still debating if we want to do it like this or with arrays.
enum MeasurementType: String, CaseIterable, Identifiable {
    case feet = "feet"
    case meters = "meters"
    var id: String { self.rawValue }
}
struct PreferencesView: View {
    // All variables for user preferences
    let user: User?
    
    @State private var hapticFeedback: Bool = false
    @State private var locationSharing: Bool = false
    @AppStorage("measurementType") private var measurementType: String = "feet"
    @AppStorage("userHeight") private var userHeight: Int = 60
    // The range that the FOV and height can be between
    let heightRange = Array(20...80)

    var body: some View {
        NavigationStack {
            List {
                Picker("Measurement Type", selection: $measurementType) {
                    ForEach(MeasurementType.allCases) { measurement in
                        Text(measurement.rawValue.capitalized).tag(measurement)
                    }
                }
                .onChange(of: measurementType) {
                    updatePreference(measurementType: measurementType.rawValue)
                }
                Picker("User Height", selection: $userHeight) {
                    ForEach(heightRange, id: \ .self) { height in
                        Text("\(height) inches").tag(height)
                    }
                }
                .onChange(of: userHeight) {
                    updatePreference(userHeight: userHeight)
                }
                // Toggles for haptic, spatialized audio, and location sharing
                toggleOption(title: "Receive haptic feedback", isOn: $hapticFeedback)
                    .onChange(of: hapticFeedback) {
                        updatePreference(hapticFeedback: hapticFeedback)
                    }
                toggleOption(title: "Share your location", isOn: $locationSharing)
                    .onChange(of: locationSharing) {
                        updatePreference(locationSharing: locationSharing)
                    }
            }
            .onAppear {
                Task {
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    guard let userId = user?.id else { return }
                    if let updatedUser = await Database.shared.fetchUserById(userId: userId) {
                        self.locationSharing = updatedUser.locationSharing
                        self.userHeight = updatedUser.userHeight
                        self.measurementType = MeasurementType(rawValue: updatedUser.measurementType)?.rawValue ?? "feet"
                        self.hapticFeedback = updatedUser.hapticFeedback
                    }
                }
            }
            .pickerStyle(.navigationLink)
            .navigationTitle("Preferences")
        }
    }
    private func toggleOption(title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.headline)
        }
        .toggleStyle(SettingsToggleStyle())
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
    private func updatePreference(
            userHeight: Int? = nil,
            locationSharing: Bool? = nil,
            measurementType: String? = nil,
            hapticFeedback: Bool? = nil
        ) {
            Task {
                guard let userId = user?.id else { return }
                await Database.shared.updateUserPreferences(
                    userId: userId,
                    userHeight: userHeight,
                    locationSharing: locationSharing,
                    measurementType: measurementType,
                    hapticFeedback: hapticFeedback
                )
            }
        }
}
struct SettingsToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .font(.headline)
            Spacer()
            Toggle("", isOn: configuration.$isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle())
                .frame(width: 80, height: 40)
        }
    }
}
