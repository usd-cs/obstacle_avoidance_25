//
//  Obstacle Avoidance App
//  ContentView.swift
//
//  Content View is a swift file that is used for triggering the Obstacle Avoidance application.
//
//  Previous Authors: Alexander Guerrero, Avery Lenninger, Olivia Nolan Shafer, Cassidy Spencer

//Current Authors: Jacob Fernandez
//  Last modified: 12/10/2024
//

import SwiftUI

// Structure for app viewing upon opening.
struct ContentView: View {
    // Tracks when an alert should be shown or when the start button has been pressed
    @State private var showAlert = false
    @State private var startPressed = false

    var body: some View {
        VStack {
            TabbedView()
        }
    }
}

// Main tab bar with navigation
struct TabbedView: View {
    init() {
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
                SettingsView()
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
    // Fake default info for testing
    @State private var username: String = "jacobtf"
    @State private var name: String = "Jacob"
    @State private var email: String = "Fakemail"
    @State private var phone: String = "111-111-1111"
    @State private var address: String = "FakeAddress"
    @State private var password: String = "fakepassword"
    @State private var isEditing: Bool = false // Controls editing mode

    var body: some View {
        Form {
            // This is the account screen, so it will hold all the information for each user.
            Section(header: Text("Account Information")) {
                editableRow(label: "Username", text: $username)
                editableRow(label: "Name", text: $name)
                editableRow(label: "Email", text: $email, keyboard: .emailAddress)
                editableRow(label: "Phone Number", text: $phone, keyboard: .phonePad)
                editableRow(label: "Address", text: $address)
                editableRow(label: "Password", text: $password, isSecure: true)
            }
            
            if isEditing {
                Button("Save Changes") {
                    saveChanges()
                }
                .foregroundColor(.blue)
            }
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
        print("Changes saved: Username=\(username), Name=\(name), Email=\(email), Phone Number=\(phone), Address=\(address), Password=\(password)")
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
}

struct EmergencyContactView: View {
    var body: some View {
        Text("Emergency Contact screen")
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
