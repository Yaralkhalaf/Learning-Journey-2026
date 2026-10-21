//
//  present me.swift
//  P1
//
//  Created by razan alawadh on 09/05/1448 AH.
//

import SwiftUI

struct present_me: View {
    var body: some View {
        List{
            VStack{
                Image(.profile)
                    .resizable()
                    .frame(width: 120, height:120)
                    .clipShape(.circle)
                
                Text(" Razan, \(23) ")
                    .font(.title)
                    .fontWeight(.semibold)
            }
            
            .frame(maxWidth:.infinity,alignment:.center)
            .listRowBackground(Color.clear)
            
            Section{
                Text("I am a Digital Product Designer and Computer Science Specialist with expertise in UI/UX design, software engineering, and generative AI applications. Holding First Class Honors and certifications in Scrum and Project Management, I specialize in translating complex ideas into elegant, user-centered digital products. Driven by innovation, I bridge the gap between aesthetics, technology, and user strategy to build impactful web and mobile experiences.")
            }
             header: {
                Text("About")
            }
        }
    }
}

#Preview {
    present_me()
}
