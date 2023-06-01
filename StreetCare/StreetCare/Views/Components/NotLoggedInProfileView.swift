//
//  NotLoggedInProfileView.swift
//  StreetCare
//
//  Created by Michael on 4/18/23.
//

import SwiftUI

struct NotLoggedInProfileView: View {
    var body: some View {
            VStack {
                Spacer()
                
                Text("welcome")
                    .font(.largeTitle)
                
                Spacer()
                
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 170.0, height: 170.0)
                
                Spacer()
                
                NavigationLink {
                    LoginView()
                } label: {
                    NavLinkButton(title: NSLocalizedString("loginButtonTitle", comment: ""), width: 120.0)
                }
                
                NavigationLink {
                    SignUpView()
                } label: {
                    NavLinkButton(title: NSLocalizedString("signUpButtonTitle", comment: ""), width: 120.0, secondaryButton: true)
                }
                
                Spacer()
            }
        
    } // end body
    
} // end struct

struct NotLoggedInProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NotLoggedInProfileView()
    }
}
