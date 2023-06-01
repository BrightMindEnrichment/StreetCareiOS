//
//  ListConnectorDecorationView.swift
//  StreetCare
//
//  Created by Michael on 5/1/23.
//

import SwiftUI

struct ListConnectorDecorationView: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle().frame(width: 2).padding(0)
            ZStack {
                Circle()
                    .fill(.yellow)
                    .frame(width: 15.0, height: 15.0)
                Circle()
                    .strokeBorder(lineWidth: 2.0)
                    .foregroundColor(Color("SecondaryColor"))
                    .frame(width: 15.0, height: 15.0)
            }.padding(0)
            Rectangle().frame(width: 2).padding(0)
        }
    }
}

struct ListConnectorDecorationView_Previews: PreviewProvider {
    static var previews: some View {
        ListConnectorDecorationView()
    }
}
