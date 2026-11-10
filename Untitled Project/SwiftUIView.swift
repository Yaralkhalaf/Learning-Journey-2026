//
//  SwiftUIView.swift
//  MyApp
//
//  Created by YARA ALKHALAF on 09/05/1448 AH.
//

import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        
        List{
            VStack{
                Image("Image 1")
                    .resizable()
                    .scaledToFit()
                    .frame(width:120, height:120)
                    .clipShape(.circle)
                
                Text("Yara, 22")
                    .font(.title)
                    .fontWeight(.light)
            }
            
            
            
            
            
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowBackground(Color.clear)

            
            Section{
                Text("i am Yara Alkhalaf, and i am a software engineering graduate expanding your technical mastery through the Apple Developer Academy at Princess Nourah University in Riyadh, actively building iOS applications with Swift, SwiftUI, and Xcode while sharpening your UI/UX skills in Figma and Sketch.")
                
                
                
            }header: {
                
                Text("about")
            }
            
        }
    }
}

#Preview {
    SwiftUIView()
}
