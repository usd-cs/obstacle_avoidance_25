//
//  ContentView.swift
//  obstacle_avoidance
//
//  Created by Alexander on 2/13/24.
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
    }

}


#Preview {
    ContentView()
}
