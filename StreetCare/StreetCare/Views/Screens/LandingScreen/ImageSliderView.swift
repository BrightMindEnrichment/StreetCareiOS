//
//  ImageSliderView.swift
//  StreetCare
//
//  Created by Kevin Phillips on 2/19/25.
//

import Foundation
import SwiftUI

enum ImageEnum: String {
    case img1 = "HelpPhoto1"
    case img2 = "HelpPhoto2"
    case img3 = "HelpPhoto3"
    
    func next() -> ImageEnum {
        switch self {
        case .img1: return .img2
        case .img2: return .img3
        case .img3: return .img1
        }
    }
}

struct ImageSliderView: View {
    @State private var img: ImageEnum = .img1
    @State private var fadeOut = false
    @State private var currentPage = 0
    
    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Image(img.rawValue)
                .resizable()
                .frame(width: UIScreen.main.bounds.width - 30, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .aspectRatio(contentMode: .fit)
                .opacity(fadeOut ? 0 : 1)
                .animation(.easeOut(duration: 0.25), value: fadeOut)
                .onReceive(timer) { _ in
                    fadeOut.toggle()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        withAnimation {
                            img = img.next()
                            currentPage = (currentPage + 1) % 3
                            fadeOut.toggle()
                        }
                    }
                }
            
            Spacer().frame(height: 20)
            
            PageControl(numberOfPages: 3, currentPage: $currentPage)
        }
    }
}

struct PageControl: View {
    var numberOfPages: Int
    @Binding var currentPage: Int
    
    var body: some View {
        HStack {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(index == self.currentPage ? .yellow : Color("TextColor"))
                    .onTapGesture {
                        self.currentPage = index
                    }
            }
        }
    }
}

struct ImageSliderView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSliderView()
    }
}
