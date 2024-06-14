//
//  ContentView.swift
//  StreetCare
//
//  Created by Michael on 3/26/23.
//

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


struct LandingScreenView: View {
    
    var links: [LinkData] = [
        LinkData(icon: "startNow", title: "startNow", view: AnyView(StartNowView()), iden: 1),
        LinkData(icon: "IconSoap", title: "whatToGive", view: AnyView(WhatToBringView()), iden: 1),
        LinkData(icon: "IconVideo", title: "How-to Videos", view: AnyView(PlaylistsView()), iden: 1),
        LinkData(icon: "IconStreetcare", title: "Donate", view: AnyView(DonateView()), iden: 1)
    ]
    @State private var img = ImageEnum.img1
    @State private var fadeOut = false
    @State private var currentPage = 0

    let timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    Image(img.rawValue).frame(width: UIScreen.main.bounds.width - 30, height: 200.0)
                        .clipShape(RoundedRectangle(cornerRadius: 16.0)).aspectRatio(contentMode: .fit)
                        .opacity(fadeOut ? 0 : 1)
                        .animation(.easeOut(duration: 0.25), value: fadeOut)
                        .onReceive(timer) { input in
                            self.fadeOut.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                withAnimation {
                                    self.img = self.img.next()    // 2) change image
                                    if currentPage == 2{
                                        self.currentPage = 0
                                    }else{
                                        self.currentPage += 1
                                    }
                                    self.fadeOut.toggle()         // 3) fade in
                                }
                            }
                        }
                    Spacer().frame(height: 20)
                    PageControl(numberOfPages: 3, currentPage: $currentPage)
                    Spacer().frame(height: 30)
                    Text("Your toolkit to help homeless people")
                        .font(.headline).padding(EdgeInsets(top: 15.0, leading: 0.0, bottom: 10.0, trailing:0.0)) .fontWeight(.bold).foregroundColor(Color("TextColor"))
                    
                    Text("Street Care is brought to you by homelessness care experts to share tools that will enable you to provide transformative help to homeless families and individuals.").foregroundColor(Color("TextColor"))
                    
                    //ScrollView {
                    ForEach(links, id: \.id) { link in
                        NavigationLink {
                            link.view
                        } label: {
                            NavigationRowLinkView(link: link) .padding(EdgeInsets(top: 5.0, leading: 5.0, bottom: 5.0, trailing:5.0))
                        }
                    }
                    //}
                }
            }
            .padding()
        }
    } // end body
} // end struct

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LandingScreenView()
    }
}

struct PageControl: View {
    
    var numberOfPages: Int
    
    @Binding var currentPage: Int
    
    var body: some View {
        HStack {
            ForEach(0..<numberOfPages) { index in
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(index == self.currentPage ? .yellow : Color("TextColor"))
                    .onTapGesture(perform: { self.currentPage = index })
            }
        }
    }
}
