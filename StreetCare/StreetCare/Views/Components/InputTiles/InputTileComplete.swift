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
    @State private var showConfirmationDialog = false // New state variable for confirmation
    
    var finishAction: () -> ()
    var shareAction: () -> () // Action to be triggered when sharing

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
                    Button("Back to Visit Log") {
                        finishAction()
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(Color("TextButtonColor"))
                }
                .padding()
                
                HStack {
                    Button("Share with Community") {
                        showConfirmationDialog = true // Show confirmation before sharing
                    }
                    .buttonStyle(.borderedProminent)
                    .foregroundColor(Color("TextButtonColor"))
                }
                .padding()
                
                Spacer()
            }
        }
        .frame(width: size.width, height: size.height)
        // Unified Alert to Handle Both Confirmation and Success
        .alert(isPresented: Binding(
            get: { showConfirmationDialog || showAlert },
            set: { _ in }
        )) {
            if showConfirmationDialog {
                return Alert(
                    title: Text("Confirm Sharing"),
                    message: Text("""
                    The following information will be shared when posted to the community:
                    - Your Name
                    - Your Profile Picture
                    - Your Location
                    - Type of Help Provided
                    """),
                    primaryButton: .default(Text("Confirm")) {
                        shareAction() // Call the actual share action
                        alertMessage = "Visit Log Shared Successfully!"
                        showAlert = true
                        showConfirmationDialog = false
                    },
                    secondaryButton: .cancel {
                        showConfirmationDialog = false
                    }
                )
            } else {
                return Alert(
                    title: Text("Form Submission"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK")) {
                        showAlert = false
                    }
                )
            }
        }
    } // end body
} // end struct




