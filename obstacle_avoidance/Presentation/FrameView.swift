//
//  FrameView.swift
//  obstacleAvoidance
//
//  Swift file that is used to startup the phone camera for viewing the frames.
//  Triggers audible notification for largest bounding box in view.
//

import SwiftUI

struct FrameView: View {
    
    //Keep track of when we last announced
    @State private var lastAnnounceTime: Date = .distantPast
    // How many seconds between announcements
    private let announceInterval: TimeInterval = 2.8
    @State private var timer = Timer.publish(every:0.00001, on: .main, in: .common).autoconnect()
    @State private var clearTimer = Timer.publish(every:3.0, on: .main, in: .common).autoconnect()

    @State private var isSpeaking: Bool = false
    private let speakDelay: Double = 2.0
    var image: CGImage?
    var boundingBoxes: [BoundingBox]
    // hate hte linter 
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

//                    Text("\(biggestBox.name) at \(biggestBox.direction) ")
//                        .foregroundColor(Color.white)
//                        .font(.headline)
//                        .offset(y: biggestBox.rect.midY - 20)
//                        .accessibility(label: Text(biggestBox.name))
//                        .accessibility(addTraits: .isStaticText)
                }
                .onReceive(timer){ _ in
                    guard !isSpeaking else { return }

                    if let audioOutput = AudioQueue.popHighestPriorityObject(threshold: 10) {
                        isSpeaking = true
                        let newAngle = DetectionUtils.calculateScreenSection(objectDirection: audioOutput.angle)
                        UIAccessibility.post(notification: .announcement, argument: "\(audioOutput.objName) \(newAngle) \(audioOutput.distance)")
                        print("Object name: \(audioOutput.objName)")
                        print("Object angle: \(audioOutput.angle)")
                        print("Object distance: \(audioOutput.distance)")
                        print("Threat level: \(audioOutput.threatLevel)")
                        print("Distance as a Float: \(Float(audioOutput.distance))")
                        print("Object Vertical: \(audioOutput.vert) \n")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + speakDelay){
                            isSpeaking = false
                        }
                    }
                }
                .onReceive(clearTimer){ _ in
                    AudioQueue.clearQueue()
                }




                }
//                .onAppear {
//                    let now = Date()
//                    if now.timeIntervalSince(lastAnnounceTime) > announceInterval {
//                        
//                        UIAccessibility.post(notification:
//                                .announcement, argument: "\(biggestBox.name) at \(biggestBox.direction)")
//                        lastAnnounceTime = now
//                    }
//                }
            }
        }
    }


struct FrameViewPreviews: PreviewProvider {
    static var previews: some View {
        FrameView(image: nil, boundingBoxes: [])
    }
}
