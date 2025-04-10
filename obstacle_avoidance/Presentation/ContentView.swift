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
    @State private var user: User?
    @AppStorage("username") private var username = ""
    
    var body: some View {
        VStack {
            TabbedView(user: user)
        }
        .onAppear {
            Task {
                await getUserInfo()
            }
        }
    }
    
    private func getUserInfo() async {
        let users = await Database.shared.fetchUsers()
        user = users.first(where: { $0.username == username })
    }
}

// Main tab bar with navigation
struct TabbedView: View {
    let user: User?
    
    init(user: User?) {
        self.user = user
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
                SettingsView(user: user)
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
    let user: User?
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
                
                if isEditing {
                    Button("Save Changes") {
                        saveChanges()
                    }
                    .foregroundColor(.blue)
                }
            }
            .onAppear {
                if let user = user {
                    updatedUsername = user.username
                    updatedName = user.name
                    updatedEmail = user.email
                    updatedPhoneNumber = user.phoneNumber
                    updatedAddress = user.address
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
                    isEditing.toggle()
                }
            }
        }
        
    }
        
    private func saveChanges() {
        // Logic to save changes to a database or user preferences
        guard let user = user, let userId = user.id else { return }  // Ensure user exists
            
            Task {
                await Database.shared.updateUser(
                    userId: userId,
                    newName: updatedName,
                    newUsername: updatedUsername,
                    newPhoneNumber: updatedPhoneNumber,
                    newEmail: updatedEmail,
                    newAddress: updatedAddress
                )
            }
        isEditing = false
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
    //@State private var newContact = EmergencyContact.empty
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
                                        let updated = EmergencyContact(name: editName, phoneNumber: editPhone, address: editAddress)
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
        /*.sheet(isPresented: $isEditing) {
            if let contactToEdit = editingContact {
                EditEmergencyContactView(
                    contact: contactToEdit,
                    onSave: { updatedContact in
                        Task {
                            await editEC(updatedContact)
                            isEditing = false
                            editingContact = nil
                        }
                    },
                    onCancel: {
                        isEditing = false
                        editingContact = nil
                    }
                )
            }
        }*/

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
/*struct EditEmergencyContactView: View {
    @State var contact: EmergencyContact
    var onSave: (EmergencyContact) -> Void
    var onCancel: () -> Void
    @State private var nameEC: String = ""
    @State private var phoneNumberEC: String = ""
    @State private var addressEC: String = ""

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $nameEC)
                TextField("Phone Number", text: $phoneNumberEC)
                TextField("Address", text: $addressEC)
            }
            .navigationTitle("Edit Contact")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updatedContact = EmergencyContact(name: nameEC, phoneNumber: phoneNumberEC, address: addressEC)
                        onSave(updatedContact)
                    }
                }
            }
        }
        .onAppear {
            nameEC = contact.name
            phoneNumberEC = contact.phoneNumber
            addressEC = contact.address
        }
    }
}*/

// Allows for our picker to easily work. Still debating if we want to do it like this or with arrays.
enum MeasurementType: String, CaseIterable, Identifiable {
    case feet = "feet"
    case meters = "meters"
    var id: String { self.rawValue }
}

struct PreferencesView: View {
    // All variables for user preferences
    @State private var hapticFeedback = false
    @State private var spatialAudio = false
    @State private var locationSharing = false
    @State private var measurementSelection: MeasurementType = .feet
    @State private var selectedHeight: Int = 60
    @State private var selectedFOV: Int = 70
    // The range that the FOV and height can be between
    let FOVRange = Array(50...110)
    let heightRange = Array(20...80)

    var body: some View {
        NavigationStack {
            List {
                Picker("Measurement Type", selection: $measurementSelection) {
                    ForEach(MeasurementType.allCases) { measurement in
                        Text(measurement.rawValue.capitalized).tag(measurement)
                    }
                }
                Picker("User Height", selection: $selectedHeight) {
                    ForEach(heightRange, id: \ .self) { height in
                        Text("\(height) inches").tag(height)
                    }
                }
                Picker("Field of View", selection: $selectedFOV) {
                    ForEach(FOVRange, id: \ .self) { FOV in
                        Text("\(FOV) inches").tag(FOV)
                    }
                }
                // Toggles for haptic, spatialized audio, and location sharing
                toggleOption(title: "Receive haptic feedback", isOn: $hapticFeedback)
                toggleOption(title: "Use spatialized audio", isOn: $spatialAudio)
                toggleOption(title: "Share your location", isOn: $locationSharing)
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

// For Preview in Xcode
struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
