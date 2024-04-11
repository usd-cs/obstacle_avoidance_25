//
//  FrameView.swift
//  obstacle_avoidance
//
//  Swift file that is used to startup the phone camera for viewing the frames.
//

import SwiftUI

//struct BoundingBox: Identifiable {
//    var id = UUID()
//    var rect: CGRect
//}

struct FrameView: View {
    var image: CGImage?
    var boundingBoxes: [BoundingBox]
    var name: String?
    
    //boundingBoxes.append(test)

    var body: some View {
        //let test = BoundingBox(rect: CGRect(origin: CGPoint(x: 50, y: 50), size: CGSize(width: 50, height: 50)))
        //let testList = [test]
        ZStack {
            if let image = image {
                Image(uiImage: UIImage(cgImage: image))
                    .resizable()
                    .scaledToFit()
            } else {
                Color.black
            }
            // get the biggest box
            let biggestIndex = boundingBoxes.indices.max(by: { boundingBoxes[$0].rect.width < boundingBoxes[$1].rect.width })
            
            // Overlay bounding boxes on the image
            ForEach(boundingBoxes) { box in
                ZStack {
                    Rectangle()
                        .stroke(Color.red, lineWidth: 2) // Adjust stroke color and width as needed
                        .frame(width: box.rect.width, height: box.rect.height)
                        .position(x: box.rect.midX, y: box.rect.midY)
                    if let name = name {
                        Text(name)
                            .foregroundColor(Color.white)
                            .font(.headline)
                            .offset(y: box.rect.midY - 20)
                            .accessibility(label: Text(name))
                            .accessibility(addTraits: .isStaticText)
                            .onAppear {
                                UIAccessibility.post(notification: .announcement, argument: name)
                            }
                    }
                }
            }
        }
    }
}

struct FrameView_Previews: PreviewProvider {
    static var previews: some View {
        FrameView(image: nil, boundingBoxes: [], name: "")
    }
}
