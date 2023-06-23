//
//  LoadingView.swift
//  StreetCare
//
//  Created by Michael Thornton on 6/14/23.
//

import SwiftUI

struct PulsingCircle: View {

    @State var isLoading = false
    @State var delay = 0.0
    @State var color1 = Color("PrimaryColor")
    @State var color2 = Color("SecondaryColor")
    
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(isLoading ? color1 : color2)
                .frame(width: 20.0, height: 20.0)
                .scaleEffect(isLoading ? 1.0 : 0.5)
                .onAppear {
                    isLoading.toggle()
                }
                .animation(.easeInOut.repeatForever().delay(delay), value: isLoading)
        }
    }
} // end struct


struct LoadingView: View {
    
    @State var isLoading = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16.0).foregroundColor(.gray.opacity(0.5))
            
            HStack {
                PulsingCircle().padding()
                PulsingCircle(delay: 0.05).padding()
                PulsingCircle(delay: 0.1).padding()
            }
        }
    }
} // end struct



struct LoadingAnimation: ViewModifier {

    var isLoading = false
    
    func body(content: Content) -> some View {
        
        if isLoading {
            ZStack {
                content
                LoadingView()
            }
        }
        else {
            content
        }
    }
}



extension View {
    func loadingAnimation(isLoading: Bool) -> some View {
        modifier(LoadingAnimation(isLoading: isLoading))
    }
}


struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
