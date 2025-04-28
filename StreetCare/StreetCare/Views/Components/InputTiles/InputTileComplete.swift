//
//  InputTileComplete.swift
//  StreetCare
//
//  Created by Michael on 4/24/23.
//

import SwiftUI

struct InputTileComplete: View {

    var size = CGSize(width: 300.0, height: 300.0)
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showConfirmationDialog = false // New state variable for confirmation
    @State private var navigateToVisitImpactView = false
    @State private var successMessage1 = ""
    @State private var successMessage2 = "four business days."
    @State private var hasShared = false
    var finishAction: () -> ()
    var shareAction: () -> () // Action to be triggered when sharing

    var body: some View {
        ZStack {
            BasicTile(size: CGSize(width: size.width, height: size.height))
            
            VStack {
                Text("Thank You! Your")
                    .font(.title2)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                Text("Interaction has")
                    .font(.title2)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                Text("been logged.")
                    .font(.title2)
                    .padding(.bottom, 8)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                if !successMessage1.isEmpty {
                    Text(successMessage1)
                        .font(.caption)
                        .foregroundColor(.black)
                        .padding(.top, 8)
                    Text(successMessage2)
                        .font(.caption)
                        .foregroundColor(.black)
                        .padding(.bottom, 8)
                }
                HStack {
                    Button("Add Another Interaction") {
                        VisitLogEntry()
                    }
                    .foregroundColor(Color("PrimaryColor"))
                    .frame(maxWidth: 180)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .font(.caption)
                    .fontWeight(.bold)
                    .background(
                        Capsule()
                            .fill(Color("SecondaryColor"))
                    )
                }
                .padding(.bottom, 12)
                
                HStack {
                    Button("Back to Interaction Log") {
                        finishAction()
                    }
                    .foregroundColor(Color("PrimaryColor"))
                    .frame(maxWidth: 180)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 12)
                    .font(.caption)
                    .fontWeight(.bold)
                    .background(
                        Capsule()
                            .fill(Color("SecondaryColor"))
                    )
                }
                .padding(.bottom, 12)
                
                if !hasShared {
                    HStack {
                        Button("Share with Community") {
                            showConfirmationDialog = true
                        }
                        .foregroundColor(Color.black)
                        .frame(maxWidth: 180)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 12)
                        .font(.caption)
                        .fontWeight(.bold)
                        .background(
                            Capsule()
                                .fill(Color.white)
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color("SecondaryColor"), lineWidth: 2)
                        )
                    }
                }
                
            }
        }
        .frame(width: size.width, height: size.height)
        .padding(.bottom, 12)
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
                        successMessage1 = "Approval can take typically within"
                        hasShared = true
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
        CapsuleProgressBar(progress: 1.0)
            .padding(.bottom, 20)
    } // end body
} // end struct

struct CapsuleProgressBar: View {
    var progress: CGFloat // between 0 and 1

    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                Capsule()
                    .stroke(Color.black, lineWidth: 2)
                    .frame(height: 12)

                Capsule()
                    .fill(Color("PrimaryColor"))
                    .frame(width: progress * 280, height: 12) // Adjust width based on need
            }
            .frame(width: 280, height: 12)

            Text("Completed")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.black)
                .padding(.top, 4)
        }
    }
}


