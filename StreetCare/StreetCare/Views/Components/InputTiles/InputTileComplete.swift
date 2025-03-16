//
//  InputTileComplete.swift
//  StreetCare
//
//  Created by Michael on 4/24/23.
//

import SwiftUI

struct InputTileComplete: View {

    var size = CGSize(width: 300.0, height: 450.0)
    var question: String
    @State private var showAlert = false
    @State private var alertMessage = ""
                
    var finishAction: () -> ()
    
    var body: some View {

        ZStack {
            
            BasicTile(size: CGSize(width: size.width, height: size.height))
            
            VStack {
                Spacer()

                Text("Thank You")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text(question)
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                HStack {
                    Button("Share with Community") {
                        finishAction()
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(Color("TextButtonColor"))
                }
                .padding()
                
                HStack {
                    Button("Back to Visit Log") {
                        alertMessage = "Visit Log Shared Successfully!"
                        showAlert = true
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(Color("TextButtonColor"))
                }
                .padding()
                
                Spacer()
            }
        }
        .frame(width: size.width, height: size.height)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Form Submission"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertMessage == "Visit Log Shared Successfully!" {
                        
                    }
                }
            )
        }
    } // end body
} // end struct


struct InputTileComplete_Previews: PreviewProvider {

    @State static var inputText = ""

    static var previews: some View {

        InputTileComplete(question: "Complete!") {
            //
        }
    }
}


