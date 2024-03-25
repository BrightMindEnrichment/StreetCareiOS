//
//  SignUpView.swift
//  StreetCare
//
//  Created by Michael on 4/17/23.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn

struct SignUpView: View {
    
    @State private var email = ""
    @State private var password = ""
    @State private var company = ""
    @State private var name = ""
    @State private var errorMessage: String?
    @EnvironmentObject var googleSignIn: UserAuthModel
    private var adapter = ProfileDetailsAdapter()
    @StateObject var profileDetails = ProfileDetail()

    @Environment(\.presentationMode) var presentation
    
    var body: some View {
        
        VStack(spacing: 20.0) {
            if let errorMessage = self.errorMessage {
                Text(errorMessage)
            }
            VStack(spacing: 12.0) {
                
                TextField("Name", text: self.$name)
                    .textFieldStyle(MyTextFieldStyle()).padding([.leading, .trailing], 10)
                Spacer().frame(height: 5)

                TextField("Email", text: self.$email)
                    .textFieldStyle(MyTextFieldStyle()).padding([.leading, .trailing], 10)
                Spacer().frame(height: 5)

                SecureField("password", text: self.$password)
                    .textFieldStyle(MyTextFieldStyle()).padding([.leading, .trailing], 10)
                Spacer().frame(height: 5)

                TextField("company", text: self.$company)
                    .textFieldStyle(MyTextFieldStyle()).padding([.leading, .trailing], 10)
                Spacer().frame(height: 5)

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
                .frame(width: 250.0,height: 50.0)
                .background(Color("SecondaryColor"))
                .clipShape(Capsule())
                
                Spacer().frame(height: 25)
//                LabelledDivider(label: "or")
//                Spacer().frame(height: 25)
                
//                Button(action: {
//                    continueWithGoogle()
//                }) {
//                    HStack {
//                        Image("HelpingHands")
//                        Text("Continue with Google")
//                    }
//                    .padding().frame(width: 300.0,height: 50.0)
//                    .accentColor(Color(.black))
//                    .background(Color(.clear))
//                    .cornerRadius(4.0)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 20).stroke(Color(.black.withAlphaComponent(0.5)), lineWidth: 2)
//                    )
//                }
//                

            }
        }
        .navigationTitle("signUpButtonTitle")

    } // end body
    
    
    func continueWithGoogle(){
        googleSignIn.signIn()
    }
    
    func register() {
        if name.count == 0{
            errorMessage = "Name required"
            return
        }
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
                profileDetails.displayName = name
                profileDetails.organization = company
                profileDetails.email = email
                adapter.addProfile(profileDetails)
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

struct MyTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(1)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.clear, lineWidth: 0).foregroundColor(Color(.black.withAlphaComponent(0.5)))
        ).padding(15).cornerRadius(4.0)
            .overlay(
                RoundedRectangle(cornerRadius: 10).stroke(Color(.black.withAlphaComponent(0.5)), lineWidth: 2)
            )
    }
}


struct LabelledDivider: View {

    let label: String
    let horizontalPadding: CGFloat
    let color: Color

    init(label: String, horizontalPadding: CGFloat = 20, color: Color = .black) {
        self.label = label
        self.horizontalPadding = horizontalPadding
        self.color = color
    }

    var body: some View {
        HStack {
            line
            Text(label).foregroundColor(color)
            line
        }
    }

    var line: some View {
        VStack { Divider().background(color) }.padding(horizontalPadding)
    }
}
