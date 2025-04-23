//
//  LoginView.swift
//  StreetCare
//
//  Created by Michael on 4/17/23.
//

import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift



struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @Binding var selection: Int
    @State private var errorMessage: String?
    
    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        
        VStack(spacing: 20.0) {
            if let errorMessage = self.errorMessage {
                Text(errorMessage)
            }
            VStack(spacing: 29.0) {

                TextField("Username/Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textFieldStyle(.roundedBorder)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(.roundedBorder)
            }
            .frame(width: 340, height: 43)
            .padding()
            VStack {

                NavigationLink {
                    ForgotPasswordView()
                } label: {
                    NavLinkButton(title: "Forgot your password?", width: 150.0, secondaryButton: true, noBorder: true,color: Color(
                        red:   0/255,
                        green: 122/255,
                        blue: 255/255
                    ))
                }
                .padding()

                Button {
                    login()
                } label: {
                    Text("login")
                        .padding(EdgeInsets(top: 8.0, leading: 20.0, bottom: 8.0, trailing: 20.0))
                        .foregroundColor(Color("PrimaryColor"))
                        .frame(width: 248.0)
                        
                }
                .background(Color("SecondaryColor"))
                .clipShape(Capsule())
                
                
//                Button(action: loginWithGoogle) {
//                    HStack {
//                        Image("Google")
//                        Text("Continue with Google")
//                            .padding(EdgeInsets(top: 8.0, leading: 20.0, bottom: 8.0, trailing: 20.0))
//                            .foregroundColor(Color("PrimaryColor"))
//                    }
//                }
//                .frame(width: 300.0)
//                .background(Color("SecondaryColor"))
//                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 50)
        .navigationTitle("loginButtonTitle").bold()
        .navigationBarTitleDisplayMode(.inline)
    } // end body
    
    
    func loginWithGoogle() {

        guard let vc = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {return}

        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        GIDSignIn.sharedInstance.signIn(withPresenting: vc) { result, error in
            guard error == nil else {
                print("error \(error!.localizedDescription)")
                return
            }
            
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                print("problem getting user ro token")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { result, error in
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    return
                }
                    
                if let result = result {
                    print("created user \(result.user.uid)")
                    presentation.wrappedValue.dismiss()
                }
            }
        }
    }
    
    
    func login() {

        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            if let error = error {
                errorMessage = error.localizedDescription
                return
            }
            selection = 3
            presentation.wrappedValue.dismiss()
        }
    }
    
} // end struct



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(selection: .constant(1))
    }
}

