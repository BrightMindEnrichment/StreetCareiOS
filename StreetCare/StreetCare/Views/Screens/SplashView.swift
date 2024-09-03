//
//  SplashView.swift
//  StreetCare
//
//  Created by Developer Dev on 4/18/24.
//

import Foundation
import SwiftUI

struct SplashView: View {
    
    @State var isActive: Bool = false
    
    var body: some View {
        ZStack {
            if self.isActive {
                MainTabBarView()
            } else {
                VStack(content: {
                    Image("Icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                    Spacer().frame(height: 15)
                    Text("Your toolkit to help homeless individuals")
                        .font(.headline).padding(EdgeInsets(top: 15.0, leading: 0.0, bottom: 10.0, trailing:0.0)) .fontWeight(.bold).foregroundColor(Color("TextColor"))
                })
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    self.isActive = true
                }
            }
        }
    }
        
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
