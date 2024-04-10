//
//  ContentView.swift
//  StreetCare
//
//  Created by Michael on 3/26/23.
//

import SwiftUI

struct LandingScreenView: View {
    
    var links: [LinkData] = [
        LinkData(icon: "startNow", title: "startNow", view: AnyView(StartNowView())),
        LinkData(icon: "IconSoap", title: "whatToGive", view: AnyView(WhatToBringView())),
        LinkData(icon: "IconVideo", title: "How-to Videos", view: AnyView(PlaylistsView())),
        LinkData(icon: "IconStreetcare", title: "Donate", view: AnyView(DonateView()))
    ]
    
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    Image("HelpPhoto2").resizable().frame(width: 300.0, height: 200.0)
                        .clipShape(RoundedRectangle(cornerRadius: 16.0))
                    Spacer()
                    Text("Your toolkit to help homeless people")
                        .font(.headline).padding(EdgeInsets(top: 15.0, leading: 0.0, bottom: 10.0, trailing:0.0)) .fontWeight(.bold).foregroundColor(.black)
                    
                    
                    
                    Text("Street Care is brought to you by homelessness care experts to share tools that will enable you to provide transformative help to homeless families and individuals.").foregroundColor(.black)
                    
                    
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
