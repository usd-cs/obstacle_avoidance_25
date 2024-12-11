//
//  FrameView.swift
//  obstacleAvoidance
//
//  Swift file that is used to startup the phone camera for viewing the frames.
//  Triggers audible notification for largest bounding box in view.
//

import SwiftUI

struct FrameView: View {
    var image: CGImage?
    var boundingBoxes: [BoundingBox]
    

    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: UIImage(cgImage: image))
                    .resizable()
                    .scaledToFit()
            } else {
                Color.black
            }
            
            
            // Overlay bounding boxes on the image
            // Notify user of object with the biggest bounding box
            if let biggestBox = boundingBoxes.max(by: { $0.rect.width < $1.rect.width }) {
                ZStack {
                    Rectangle()
                        .stroke(Color.red, lineWidth: 2) // Adjust stroke color and width as needed
                        .frame(width: biggestBox.rect.width, height: biggestBox.rect.height)
                        .position(x: biggestBox.rect.midX, y: biggestBox.rect.midY)
                    
                    Text("\(biggestBox.name) at \(biggestBox.direction)")
                        .foregroundColor(Color.white)
                        .font(.headline)
                        .offset(y: biggestBox.rect.midY - 20)
                        .accessibility(label: Text(biggestBox.name))
                        .accessibility(addTraits: .isStaticText)
                }
                .onAppear {
                    UIAccessibility.post(notification: .announcement, argument: "\(biggestBox.name) at \(biggestBox.direction)")
                }
            }
        }
    }
}


struct FrameViewPreviews: PreviewProvider {
    static var previews: some View {
        FrameView(image: nil, boundingBoxes: [])
    }
}

