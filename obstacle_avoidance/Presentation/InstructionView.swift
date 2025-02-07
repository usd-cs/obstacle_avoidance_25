//
//  InstructionView.swift
//  obstacleAvoidance
//
//  Created by Carlos Breach on 12/9/24.
//

import SwiftUI

struct InstructionView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Obstacle Avoidance")
                .font(.title)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                .accessibilityLabel("Obstacle Avoidance")
                .accessibility(addTraits: .isStaticText)

            Text("To optimize your experience, we recommend using open-air earbuds or bone conduction headphones." +
                 "For the best visuals, ensure your phone’s back camera is facing away from your body")
                .font(.body)
                .foregroundColor(.secondary)
                .accessibility(addTraits: .isStaticText) // Specify that the text is static
                .accessibilityLabel("To optimize your experience, we recommend using open-air"
                    + "earbuds or bone conduction headphones." +
                    "For the best visuals, ensure your phone’s" +
                    "back camera is facing away from your body")
        }

        .padding()
    }
}
