//
//  ForgotPasswordView.swift
//  StreetCare
//
//  Created by Michael on 5/3/23.
//

import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    
    @Environment(\.presentationMode) var presentation

    @State var email = ""
    
    var body: some View {
        
        VStack {
            Text("Trouble logging in?")
                .font(.title)
                .padding()
            
            Text("Enter your email and we'll send you a link to get back into your account.")
                .padding()
            
            TextField("email", text: $email)
                .keyboardType(.emailAddress)
                .textFieldStyle(.roundedBorder)
                .padding()
                    
            Button {
                recoverPassword()
            } label: {
                Text("Reset Password")
                    .padding(EdgeInsets(top: 8.0, leading: 20.0, bottom: 8.0, trailing: 20.0))
                    .foregroundColor(Color("PrimaryColor"))
            }
            .frame(width: 100.0)
            .background(Color("SecondaryColor"))
            .clipShape(Capsule())
            .padding()
        }
    } // end body
    
    
    private func recoverPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) {_ in
            presentation.wrappedValue.dismiss()
        }
    }
    
} // end struct

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView()
    }
}
