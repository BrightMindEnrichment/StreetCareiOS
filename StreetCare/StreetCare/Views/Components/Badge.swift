//
//  AchievementBadge.swift
//  StreetCare
//
//  Created by Michael on 5/1/23.
//

import SwiftUI


struct Badge: View {
    
    var description: String
    var title: String
    var imageName: String
    var objectId : Int
    
    var peopleHelped : Int
    var outreaches  : Int
    var itemsDonated  : Int
    
    var body: some View {
            HStack(alignment: .top) {
                let state = objectId == 1 ? outreaches > 3 : objectId == 2 ? itemsDonated > 10 : (outreaches > 15 || peopleHelped > 60)

                ZStack(alignment: .center) {
//                    RoundedRectangle(cornerRadius: 8.0)
//                        .strokeBorder(lineWidth: 0.0)
//                        .foregroundColor(Color("TextColor")).background(.gray)
                        //.frame(width: 60.0, height: 60.0)
                    Image(imageName).resizable().aspectRatio(contentMode: .fit).frame(width: 60.0,height: 60.0).grayscale(state ? 0.0 : 0.9)
                }
                VStack{
                    Text(title + "\n" + description)
                        .foregroundColor(state ? .black : .gray)  .multilineTextAlignment(.leading).listRowSeparator(.hidden)

                }
                Spacer()
            }.padding(.horizontal, 10).padding(.vertical, 10)
        }
    } // end body

struct Badge_Previews: PreviewProvider {
    static var previews: some View {
        Badge(description: "24", title: "People helped", imageName: "HelpingHands", objectId: 1,peopleHelped: 0,outreaches: 0,itemsDonated: 0)
    }
}
