//
//  NotLoggedInProfileView.swift
//  StreetCare
//
//  Created by Michael on 4/18/23.
//

import SwiftUI

struct NotLoggedInProfileView: View {
    @Binding var selection: Int
    var body: some View {
            VStack {
                Spacer().frame(height: 70)

                Text("welcome").font(.system(size: 36).bold())
                Spacer().frame(height: 70)



                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160.0, height: 160.0)
               
                Spacer().frame(height: 70)

                NavigationLink {
                    LoginView(selection: $selection)
                } label: {
                    NavLinkButton(title: NSLocalizedString("loginButtonTitle", comment: ""), width: 160.0,height: 40.0)
                }
                Spacer().frame(height: 30)

                NavigationLink {
                    SignUpView()
                } label: {
                    NavLinkButton(title: NSLocalizedString("signUpButtonTitle", comment: ""), width: 160.0, height: 40.0,secondaryButton: true)
                }
                Spacer()
            }
        
    } // end body
    
} // end struct

struct NotLoggedInProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NotLoggedInProfileView(selection: .constant(1))
    }
}
