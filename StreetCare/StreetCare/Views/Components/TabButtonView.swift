//
//  TabButtonView.swift
//  StreetCare
//
//  Created by Michael on 5/5/23.
//

import SwiftUI

struct TabButtonView: View {

    var imageName: String
    var title: String
    var isActive = true

    
    var body: some View {
        VStack {
            if isActive {
                Rectangle().frame(height: 10.0)
                    .foregroundColor(Color("SecondaryColor"))
            }
            isActive ? Image("\(imageName)") : Image("\(imageName)-Inactive")
            Text(title)
        }

    }
}

struct TabButtonView_Previews: PreviewProvider {
    static var previews: some View {
        TabButtonView(imageName: "Tab-HowToHelp", title: "How to Help")
    }
}
