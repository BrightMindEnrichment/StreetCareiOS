//
//  SignUpView.swift
//  StreetCare
//
//  Created by Michael on 4/17/23.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var company = ""
    
    @State private var errorMessage: String?
    
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        
        VStack(spacing: 20.0) {
            if let errorMessage = self.errorMessage {
                Text(errorMessage)
            }
            VStack(spacing: 12.0) {

                TextField("email", text: $email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)
                
                TextField("password", text: $password)
                    .textFieldStyle(.roundedBorder)
                
                TextField("company", text: $company)
                    .textFieldStyle(.roundedBorder)
            }
            .padding()
            VStack {
                Button {
                    register()
                } label: {
                    Text("signUpButtonTitle")
                        .padding(EdgeInsets(top: 8.0, leading: 20.0, bottom: 8.0, trailing: 20.0))
                        .foregroundColor(Color("PrimaryColor"))
                }
                .frame(width: 300.0)
                .background(Color("SecondaryColor"))
                .clipShape(Capsule())

            }
        }
        .navigationTitle("signUpButtonTitle")
    } // end body
    
    

    
    
    func register() {

        if email.count == 0 {
            errorMessage = "Email required"
            return
        }
        
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters long."
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { result, error in

            if let error = error {
                errorMessage = error.localizedDescription
            }
            
            if let result = result {
                print("created user \(result.user.uid)")
                presentation.wrappedValue.dismiss()
            }
        }
    }
    
} // end struct

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
