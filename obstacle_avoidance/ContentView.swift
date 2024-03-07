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
    
    var body: some View {
       
        // Text alert on screen.
        Text("Obstacle Avoidance")
            .onAppear{
                showAlert = true
            }
        
        //Trigger the alert with the message
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Obstacle Avoidance"),
                message: Text("To optimize your experience, we recommend using open-air earbuds or bone conduction headphones. For the best visuals, ensure your phone’s back camera is facing away from your body. Press start to begin."),
                dismissButton:
                        .default(Text("Start"))
            )
        }
        TabbedView()
        
    }
}

struct TabbedView: View {
    init() {
        UITabBar.appearance().backgroundColor = UIColor.lightGray
        UITabBar.appearance().isTranslucent = true
        //let font = UIFont(name: "Helvetica", size: 22)
        //UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font:font]
        //UIFont.systemFont(ofSize: 50, weight: .bold)
    }
    var body: some View {
        //let boundingBoxes: [BoundingBox] = []
        
        return TabView {
            CameraView() //boundingBoxes: boundingBoxe
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home").font(.system(size: 50))
                }
            
            Text("The content of the second view")
                .tabItem {
                    Image(systemName: "gear")
                    Text("Second Tab")
                }
        }
    }
}


struct CameraView: View {
    @StateObject private var model = FrameHandler()
    @State private var db = DecisionBlock() // No need to pass initial values here

    var body: some View {
        FrameView(image: model.frame, boundingBoxes: model.boundingBoxes)
            .ignoresSafeArea()
            .onReceive(model.$frame) { newFrame in
                if let objectNameUnwrap = model.objectName {
                    //db.processInput(objectName: objectNameUnwrap)
                    let utterance = AVSpeechUtterance(string: objectNameUnwrap)
                    let voice = AVSpeechSynthesisVoice(language: "en-GB")
                    utterance.voice = voice
                    
                    let synthesizer = AVSpeechSynthesizer()
                    synthesizer.speak(utterance)
                }
//                // Update DecisionBlock when the frame changes
//                db.processInput(image: model.frame, model.objectName, boundingBoxes: model.boundingBoxes)
            }
            .onReceive(model.$boundingBoxes) { newBoundingBoxes in
//                // Update DecisionBlock when bounding boxes change
//                db.processInput(image: model.frame, model.objectName, boundingBoxes: newBoundingBoxes)
            }
    }
}



// For Preview in Xcode
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
