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
            /*
             if startPressed {
             TabbedView()
             } else {
             Text("Obstacle Avoidance")
             .onAppear{
             showAlert = true
             }
             .alert(isPresented: $showAlert) {
             Alert(
             title: Text("Obstacle Avoidance"),
             message: Text("To optimize your experience, we recommend using open-air earbuds or bone conduction headphones. For the best visuals, ensure your phone’s back camera is facing away from your body."),
             dismissButton: .default(Text("Start")) {
             startPressed = true
             }
             )
             }
             }
             */
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
                .accessibilityLabel("Home")
                .accessibilityHint("This is the first tab")
            CameraView()
                .tabItem {
                    Image(systemName: "camera.fill")
                        .accessibility(label: Text("Camera Tab"))
                    Text("Camera").font(.system(size: 50))
                }
                .accessibilityLabel("Camera")
                .accessibilityHint("This is the second tab")
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                        .accessibility(label: Text("Settings Tab"))
                    Text("Settings")
                }
                .accessibilityLabel("Settings")
                .accessibilityHint("This is the third tab")
        }
    }
}

struct InstructionView: View{
    var body: some View{
        VStack(alignment: .leading, spacing: 10){
            Text("Obstacle Avoidance")
                .font(.title)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .accessibilityLabel("Title")
                .accessibility(addTraits: .isStaticText)
           
            Text("To optimize your experience, we recommend using open-air earbuds or bone conduction headphones. For the best visuals, ensure your phone’s back camera is facing away from your body")
                .font(.body)
                .foregroundColor(.secondary)
                .accessibility(label: Text("Home Page")) // Provide a label for VoiceOver
                .accessibility(addTraits: .isStaticText) // Specify that the text is static
        }
        
        .padding()
        
    }
}



struct SettingsView: View {
    var body: some View {
        Text("This page will have settings")
            .accessibility(label: Text("Settings Page")) // Provide a label for VoiceOver
            .accessibility(addTraits: .isStaticText) // Specify that the text is static
            .onAppear {
                UIAccessibility.post(notification: .announcement, argument: "This page will have settings")
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
            FrameView(image: model.frame, boundingBoxes: model.boundingBoxes, name: model.objectName)
                .ignoresSafeArea()
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

