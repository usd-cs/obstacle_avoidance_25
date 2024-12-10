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

//Structure for app viewing upon opening.
struct ContentView: View {
    //tracks when an alert should ne shown or  when the start button has been pressed
    @State private var showAlert = false
    @State private var startPressed = false
    
    var body: some View {
        VStack {
            TabbedView()
        }
    }
}
        
// Main tab bar with nativation
struct TabbedView: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor.lightGray
        UITabBar.appearance().isTranslucent = true
    }
    var body: some View {
        return TabView {
            //home tab
            InstructionView()
                .tabItem {
                    Image(systemName: "house.fill")
                        .accessibility(label: Text("Home Tab"))
                    Text("Home").font(.system(size: 50))
                }
            //camera tab
            CameraView()
                .tabItem {
                    Image(systemName: "camera.fill")
                        .accessibility(label: Text("Camera Tab"))
                    Text("Camera").font(.system(size: 50))
                }
            //setting view, in a navigation stack so we can have proper back button
            NavigationStack{
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


struct AccountScreen: View{
    //fake default info for testing
    @State private var username: String = "jacobtf"
    @State private var name: String = "Jacob"
    @State private var email: String = "Fakemail"
    @State private var phone: String = "111-111-1111"
    @State private var address: String = "FakeAddress"
    @State private var password: String = "fakepassword"
    @State private var isEditing: Bool = false // Controls editing mode

    

    var body: some View {
        Form {
            //This is the account screen so it is going to hold all the informatin for each user.
            Section(header: Text("Account Information")) {
                HStack {
                    Text("Username:")
                        .fontWeight(.bold)
                    Spacer()
                    if isEditing {
                        TextField("Enter Username", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(username)
                            .foregroundColor(.gray)
                    }
                }
                HStack {
                    Text("Name:")
                        .fontWeight(.bold)
                    Spacer()
                    if isEditing {
                        TextField("Enter Name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        Text(name)
                            .foregroundColor(.gray)
                    }
                }
                HStack {
                    Text("Email:")
                        .fontWeight(.bold)
                    Spacer()
                    if isEditing {
                        TextField("Enter Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                    } else {
                        Text(email)
                            .foregroundColor(.gray)
                    }
                }
                HStack {
                    Text("Phone Number:")
                        .fontWeight(.bold)
                    Spacer()
                    if isEditing {
                        TextField("Enter Phone Number", text: $phone)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                    } else {
                        Text(phone)
                            .foregroundColor(.gray)
                    }
                }
                HStack {
                    Text("Address:")
                        .fontWeight(.bold)
                    Spacer()
                    if isEditing {
                        TextField("Enter Address", text: $address)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                    } else {
                        Text(address)
                            .foregroundColor(.gray)
                    }
                }
                HStack {
                    Text("Password:")
                        .fontWeight(.bold)
                    Spacer()
                    if isEditing {
                        TextField("Enter Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                    } else {
                        Text(password)
                            .foregroundColor(.gray)
                    }
                }
            }
            //if they want to edit they can see the save changes button. Will need more
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
}
struct EmergencyContactView: View{
    var body: some View {
        Text("Emergency Contact screen")
    }
}

enum MeasurementType: String, CaseIterable, Identifiable
{
    //Allows for our picker to easily work, still debating if we want to do it like this or with the arrays.
    case feet = "feet"
    case meters = "meters"
    var id: String { self.rawValue }
}

struct PrefrencesView: View{
    //All variabels for the user prefrences
    @State private var hapticFeedback = false
    @State private var spacialAudio = false
    @State private var locationSharing = false
    @State private var measurementSelection: MeasurementType = .feet
    @State private var userHeight: String = ""
    @State private var selectedHeight: Int = 60
    @State private var selectedFOV: Int = 70
    //the range that teh FOV cand height can be between
    let FOVRange = Array(50...110)
    let heightRange = Array(20...80)
//    @Binding var selection: MeasurementType
    var body: some View {
        NavigationStack{
            List{
                //uses a picker as it is clean and easy.
                Picker("Measurement Type", selection: $measurementSelection)
                {
                   ForEach(MeasurementType.allCases){ measurement in
                       Text(measurement.rawValue.capitalized).tag(measurement)
    
                   }
                    
                }
                Picker("User Height", selection: $selectedHeight)
                {
                    ForEach(heightRange, id: \.self) { height in
                        Text("\(height) inches").tag(height)
                        
                    }
                    
                }
                Picker("Field of View", selection: $selectedFOV)
                {
                    ForEach(heightRange, id: \.self) { FOV in
                        Text("\(FOV) inches").tag(FOV)
                        
                    }
                    
                }
                //Toggles for haptic, spacialized audio, and location sharing
                Toggle(isOn: $hapticFeedback) {
                                    Text("Recieve haptic feedback")
                                        .font(.headline) // Larger font size
                
                                }
                                .toggleStyle(SettingsToggleStyle())
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                                .accessibilityLabel("Use meters instead of feet")
                                .accessibilityHint("Double tap to enable")
                

                
                Toggle(isOn: $spacialAudio) {
                                    Text("Use spacialized audio")
                                        .font(.headline) // Larger font size
                                }
                                .toggleStyle(SettingsToggleStyle())
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                                .accessibilityLabel("Use angle instead of clock")
                                .accessibilityHint("Double tap to enable")
                

                
                Toggle(isOn: $locationSharing) {
                    //Will need more persmission access and things
                                    Text("Share your location")
                                        .font(.headline) // Larger font size
                                }
                                .toggleStyle(SettingsToggleStyle())
                                .background(Color(UIColor.systemGray6))
                                .cornerRadius(8)
                                .accessibilityLabel("Use angle instead of clock")
                                .accessibilityHint("Double tap to enable")
                
                            Spacer()
                        }

            }
        .pickerStyle(.navigationLink)
        .navigationTitle("Prefrences")

    }
}

struct SettingsToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .font(.headline) // Larger font size
            Spacer()
            Toggle("", isOn: configuration.$isOn)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle())
                .frame(width: 80, height: 40)
        }
    }
}
    

    
    // For Preview in Xcode
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }

