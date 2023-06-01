//
//  AchievementBadge.swift
//  StreetCare
//
//  Created by Michael on 5/1/23.
//

import SwiftUI

struct AchievementBadge: View {
    
    var count: Int
    var title: String
    var imageName: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8.0)
                .strokeBorder(lineWidth: 2.0)
                .foregroundColor(Color("SecondaryColor"))
                .frame(width: 116.0, height: 107.0)
            ZStack {
                Circle()
                    .fill(Color("BackgroundColor"))
                    .frame(width: 66.0)
                Circle()
                    .strokeBorder(lineWidth: 2.0)
                    .foregroundColor(Color("SecondaryColor"))
                    .frame(width: 66.0)
                Image(imageName)
            }
            .offset(CGSize(width: 0.0, height: -53.0))
            VStack {
                Text(count > 0 ? "\(count)" : "--")
                    .font(.title)
                Text(title)
                    .font(.footnote)
            }
            .offset(CGSize(width: 0.0, height: 10.0))
        }
        
    } // end body
} // end struct

struct AchievementBadge_Previews: PreviewProvider {
    static var previews: some View {
        AchievementBadge(count: 24, title: "People helped", imageName: "HelpingHands")
    }
}
