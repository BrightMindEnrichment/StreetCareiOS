//
//  ImpactView.swift
//  StreetCare
//
//  Created by Michael on 5/3/23.
//

import SwiftUI

struct ImpactView: View {
    
    let adapter = VisitLogDataAdapter()

    var peopleHelped: Int
    var outreaches: Int
    var itemsDonated: Int
    
    var body: some View {
        VStack {
            Text("YOUR IMPACT").font(.system(size: 18)).bold()
            HStack {
                AchievementBadge(count: peopleHelped, title: "People helped", imageName: "Tab-Profile")
                AchievementBadge(count: outreaches, title: "Outreaches", imageName: "HelpingHands")
                AchievementBadge(count: itemsDonated, title: "Items donated", imageName: "Clothes")
            }.frame(height: 170)
        }
    }
}



struct ImpactView_Previews: PreviewProvider {
    static var previews: some View {
        ImpactView(peopleHelped: 3, outreaches: 4, itemsDonated: 5)
    }
}
