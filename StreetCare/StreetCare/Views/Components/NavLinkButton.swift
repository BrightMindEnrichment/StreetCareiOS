//
//  NavLinkButton.swift
//  StreetCare
//
//  Created by Michael on 5/2/23.
//

import SwiftUI

/**
 Looks like a button, but is not.  Used inside Navigation links because I don't know how ot have a button act as a link.
 */

struct NavLinkButton: View {

    var title: String
    var width: CGFloat
    var height: CGFloat = 35.0
    var secondaryButton = false
    var noBorder = false
    var rightArrowNeeded = false
    var color = Color("SecondaryColor")
    var textColor = Color("TextColor")
    var body: some View {

        ZStack {
            if secondaryButton {
                RoundedRectangle(cornerRadius: 16.0)
                    .strokeBorder(lineWidth: noBorder ? 0.0 : 2.0)
                    .frame(width: width, height: height)
                    .foregroundColor(color)
            }
            else {
                RoundedRectangle(cornerRadius: 16.0)
                    .frame(width: width, height: height)
                    .foregroundColor(color)
            }
            if rightArrowNeeded{
                HStack {
                    Spacer()
                    Text(NSLocalizedString(title, comment: ""))
                        .fontWeight(.bold).foregroundColor(.black)
                        .foregroundColor(Color("TextColor"))
                    Spacer()
                    Image(systemName: "greaterthan").aspectRatio(contentMode: .fit)
                        .imageScale(.medium)
                        .foregroundColor(Color("TextColor"))
                }
                .padding(EdgeInsets(top: 4.0, leading: 20.0, bottom: 4.0, trailing: 20.0))
            }else{
                HStack{
                    Text(title)
                        .padding(EdgeInsets(top: 8.0, leading: 20.0, bottom: 8.0, trailing: 20.0))
                        .foregroundColor(secondaryButton ? color : Color("PrimaryColor"))
                    if rightArrowNeeded{
                        //Spacer()
                        Image(systemName: "greaterthan").aspectRatio(contentMode: .fit)
                            .imageScale(.medium)
                            .foregroundColor(Color("TextColor")).multilineTextAlignment(.trailing)
                    }
                }
            }

        }

    } // end body
} // end struct

struct NavLinkButton_Previews: PreviewProvider {
    static var previews: some View {
        NavLinkButton(title: "Navigate now!", width: 150.0)
    }
}
