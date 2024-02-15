//
//  Obstacle Avoidance App
//  ContentView.swift
//

import SwiftUI


struct ContentView: View {
    @State private var showAlert = false
    var body: some View {

        Text("Obstacle Avoidance")
            .onAppear{
                showAlert = true
            }
        
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Obstacle Avoidance"),
                message: Text("To optimize your experience, we recommend using open-air earbuds or bone conduction headphones. For the best visuals, ensure your phone’s back camera is facing away from your body. Press start to begin."),
                dismissButton:
                        .default(Text("Start"))
            )
        }
        
        CameraView() //Calling the Camera
    }
}

struct CameraView: View {
    var body: some View {
        ZStack {
            //Going to be Camera preview
            Color.black
                .ignoresSafeArea(.all,edges: .all)
            
            VStack {
                Spacer()
                
                HStack{
                    //The Traditional camera button to be replaced
                    Button(action: {}, label: {
                        
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 65, height: 65)
                        }
                    })
                    
                }
            }
            
            
        }
    }
}


//Put the AI inplementation here
//
//Will get threat level
//
//




// Loads the iphone preview
#Preview {
    ContentView()
}
