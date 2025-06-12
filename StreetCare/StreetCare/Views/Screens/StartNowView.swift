//
//  StartNowView.swift
//  StreetCare
//
//  Created by Michael on 5/8/23.
//

import SwiftUI

struct StartNowView: View {
    
    var links: [LinkData] = [
        LinkData(icon: "", title: NSLocalizedString("beforeOutreach", comment: ""), view: AnyView(BeforeOutreachView()), iden: 1),
        LinkData(icon: "", title: NSLocalizedString("duringOutreach", comment: ""), view: AnyView(PlaylistsView()), iden: 1),
        LinkData(icon: "", title: NSLocalizedString("afterOutreach", comment: ""), view: AnyView(AfterOutreachView()), iden: 1),
    ]
    
    var body: some View {
        VStack {
            ScrollView {
                Spacer()
                
                // Image("HelpPhoto2").resizable().frame(width: 300.0, height: 200.0) .clipShape(RoundedRectangle(cornerRadius: 16.0))
                
                Spacer(minLength: 70.0)
                
                Text(NSLocalizedString("startNowViewText", comment: "")).padding(EdgeInsets(top: 5.0, leading: 20.0, bottom: 5.0, trailing: 20.0)).multilineTextAlignment(.center) .fontWeight(.bold).foregroundColor(.black)
                
                
                //ScrollView {
                ForEach(links, id: \.id) { link in
                    NavigationLink {
                        link.view
                    } label: {
                        NavigationRowLinkView(link: link).padding(EdgeInsets(top: 5.0, leading: 20.0, bottom: 5.0, trailing: 20.0))
                    }
                }
                // }
                
                // Spacer()
            }
        }
        //.navigationTitle("Start Now")
    } // end body
} // end struct

struct StartNowView_Previews: PreviewProvider {
    static var previews: some View {
        StartNowView()
    }
}
