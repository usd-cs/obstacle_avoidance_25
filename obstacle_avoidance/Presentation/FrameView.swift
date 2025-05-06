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
    @State private var timer = Timer.publish(every:0.01, on: .main, in: .common).autoconnect()
    @State private var clearTimer = Timer.publish(every:3.0, on: .main, in: .common).autoconnect()
    @State private var isSpeaking: Bool = false
    private let speakDelay: Double = 2.0
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

//                    Text("\(biggestBox.name) at \(biggestBox.direction) ")
//                        .foregroundColor(Color.white)
//                        .font(.headline)
//                        .offset(y: biggestBox.rect.midY - 20)
//                        .accessibility(label: Text(biggestBox.name))
//                        .accessibility(addTraits: .isStaticText)
                }
                .onReceive(timer){ _ in
                    guard !isSpeaking else { return }
                    print(AudioQueue.queue)
                    if let audioOutput = AudioQueue.popHighestPriorityObject(threshold: 1) {
                        isSpeaking = true

                        let newDirection = audioOutput.corridorPosition
                        let message = "\(audioOutput.objName) \(newDirection) \(audioOutput.formattedDist)"
                        AudioQueue.clearQueue()
                        DispatchQueue.main.async {
                            if UIAccessibility.isVoiceOverRunning {
                                UIAccessibility.post(notification: .announcement, argument: message)
                                print("VoiceOver announcement posted: \(message)")
                            } else {
                                print("VoiceOver is not running. Announcement skipped.")
                            }
                        }
                        print("Object name: \(audioOutput.objName)")
                        print("Object direction: \(audioOutput.corridorPosition)")
                        print("Object distance: \(audioOutput.distance)")
                        print("Formatted distance: \(audioOutput.formattedDist)")
                        print("Threat level: \(audioOutput.threatLevel)")
                        print("Distance as a Float: \(Float(audioOutput.distance))")
                        print("Object Vertical: \(audioOutput.vert) \n")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + speakDelay){
                            isSpeaking = false
                        }
                    }
                    else{
                        print("Audio queue is false")
                    }
                }
                .onReceive(clearTimer){ _ in
                    print("Queue cleared")
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
