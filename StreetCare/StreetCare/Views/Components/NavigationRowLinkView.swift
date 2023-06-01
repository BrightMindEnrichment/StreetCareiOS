//
//  NavigationRowLinkView.swift
//  StreetCare
//
//  Created by Michael on 4/3/23.
//

import SwiftUI

struct NavigationRowLinkView: View {
    
    var link: LinkData
    
    var body: some View {

        ZStack {
            HStack {
                Image("\(link.icon)")
                Spacer()
                Text(NSLocalizedString(link.title, comment: ""))
                    .font(.headline)
                    .foregroundColor(Color("TextColor"))
                Spacer()
                Image(systemName: "greaterthan")
                    .imageScale(.large)
                    .foregroundColor(Color("TextColor"))
            }
            .padding(EdgeInsets(top: 4.0, leading: 20.0, bottom: 4.0, trailing: 20.0))
        }
        .frame(height: 60.0)
        .overlay(RoundedRectangle(cornerRadius: 30.0).stroke(Color("SecondaryColor"), lineWidth: 2))
        .padding(EdgeInsets(top: 2.0, leading: 2.0, bottom: 4.0, trailing: 4.0))
        
    }
}

//struct NavigationRowLinkView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationRowLinkView()
//    }
//}
