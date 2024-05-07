//
//  Obstacle Avoidance App
//  ContentView.swift
//
//  Content View is a swift file that is used for triggering the Obstacle avoidance application.
//

import SwiftUI
import AVFoundation
import Foundation
//Structure for app viewing upon opening.

struct ContentView: View {
    //@StateObject private var model = FrameHandler()
    @State private var showAlert = false
    @State private var startPressed = false
    
    var body: some View {
        VStack {
            TabbedView()
        }
    }
}
        

struct TabbedView: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor.lightGray
        UITabBar.appearance().isTranslucent = true
    }
    var body: some View {
        return TabView {
            InstructionView()
                .tabItem {
                    Image(systemName: "house.fill")
                        .accessibility(label: Text("Home Tab"))
                    Text("Home").font(.system(size: 50))
                }
            CameraView()
                .tabItem {
                    Image(systemName: "camera.fill")
                        .accessibility(label: Text("Camera Tab"))
                    Text("Camera").font(.system(size: 50))
                }
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                        .accessibility(label: Text("Settings Tab"))
                    Text("Settings")
                }
        }
    }
}

struct InstructionView: View{
    var body: some View{
        VStack(alignment: .leading, spacing: 10){
            Text("Obstacle Avoidance")
                .font(.title)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .accessibilityLabel("Obstacle Avoidance")
                .accessibility(addTraits: .isStaticText)
            
           
            Text("To optimize your experience, we recommend using open-air earbuds or bone conduction headphones. For the best visuals, ensure your phone’s back camera is facing away from your body")
                .font(.body)
                .foregroundColor(.secondary)
                //.accessibility(label: Text("Home Page")) // Provide a label for VoiceOver
                .accessibility(addTraits: .isStaticText) // Specify that the text is static
                .accessibilityLabel("To optimize your experience, we recommend using open-air earbuds or bone conduction headphones. For the best visuals, ensure your phone’s back camera is facing away from your body")
        }
        
        .padding()
    }
}



struct SettingsView: View {
    @State private var meters = false
    @State private var clock = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top, 50)
                .padding(.bottom, 30)
                .accessibility(addTraits: .isStaticText)
            
            VStack(alignment: .leading, spacing: 10) {
                Toggle(isOn: $meters) {
                    Text("Use meters instead of feet")
                        .font(.headline) // Larger font size

                }
                .toggleStyle(SettingsToggleStyle())
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
                .accessibilityLabel("Use meters instead of feet")
                .accessibilityHint("Double tap to enable")
                
                Text("Switch to use meters for distance. Example: Object in 2 meters.")
                    .font(.subheadline) // Larger font size
                    .foregroundColor(.gray)
                    .accessibilityLabel("Switch to use meters for distance. Example: Object in 2 meters.")
                    .accessibility(addTraits: .isStaticText)
                                    
                Toggle(isOn: $clock) {
                    Text("Use angle instead of clock")
                        .font(.headline) // Larger font size
                }
                .toggleStyle(SettingsToggleStyle())
                .background(Color(UIColor.systemGray6))
                .cornerRadius(8)
                .accessibilityLabel("Use angle instead of clock")
                .accessibilityHint("Double tap to enable")
                
                Text("Switch to angles for direction instead of clock positioning. Example: Object at 90 degrees.")
                    .font(.subheadline) // Larger font size
                    .foregroundColor(.gray)
                    .accessibilityLabel("Switch to angles for direction instead of clock positioning. Example: Object at 90 degrees.")
                    .accessibility(addTraits: .isStaticText)
                    
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .edgesIgnoringSafeArea(.all)
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
    func speak(word: String){
        let utterance = AVSpeechUtterance(string: word)
        utterance.rate = 0.57
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
        
    }
    
    struct CameraView: View {
        @StateObject private var model = FrameHandler()
        //@State private var spokenText: String = ""
        //@State private var db = DecisionBlock() // No need to pass initial values here
        
        var body: some View {
            FrameView(image: model.frame, boundingBoxes: model.boundingBoxes)
                .ignoresSafeArea()
                .onAppear {
                    model.startCamera()
                }
                .onDisappear {
                    model.stopCamera()
                }
                
            /*.onReceive(model.$boundingBoxes) { newBoundingBoxes in
             if let objectNameUnwrap = model.objectName {
             DispatchQueue.global().async {
             speak(word: objectNameUnwrap)
             //spokenText = objectNameUnwrap
             //db.processInput(objectName: objectNameUnwrap)
             }
             }*/
            
            //                // Update DecisionBlock when bounding boxes change
            //                db.processInput(image: model.frame, model.objectName, boundingBoxes: newBoundingBoxes)
            
            /*.onReceive(model.$frame) { newFrame in
             if let objectNameUnwrap = model.objectName {
             //db.processInput(objectName: objectNameUnwrap)
             }
             //                // Update DecisionBlock when the frame changes
             //                db.processInput(image: model.frame, model.objectName, boundingBoxes: model.boundingBoxes)
             }*/
            
        }
        // Text(spokenText)
    }
    
    
    
    
    // For Preview in Xcode
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }

