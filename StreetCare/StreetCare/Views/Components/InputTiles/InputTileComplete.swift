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
    @State var log: VisitLog
    @State private var showConfirmationDialog = false
    @State private var navigateToVisitImpactView = false
    @State private var successMessage1 = ""
    @State private var successMessage2 = "four business days."
    @State private var hasShared = false
    
    // Environment property to dismiss the entire flow
    @Environment(\.presentationMode) var presentationMode
    
    var finishAction: () -> ()
    var shareAction: () -> ()

    var body: some View {
        VStack {
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
                        NavigationLink {
                            VisitLogEntry()
                        } label: {
                            ZStack {
                                NavLinkButton(
                                    title: "Add Another Interaction",
                                    width: 210,
                                    cornerRadius: 20,
                                    fontSize: 13,
                                    textColor: Color("SecondaryColor"),
                                    buttonColor: Color("PrimaryColor")
                                )
                                .frame(width: 210, height: 25)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color("SecondaryColor")))
                            }
                        }
                    }
                    .padding(.bottom, 12)

                    HStack {
                        Button(action: {
                            finishAction()
                            // Dismisses the entire flow to go home
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            ZStack {
                                NavLinkButton(
                                    title: "Back to Interaction Log",
                                    width: 210,
                                    cornerRadius: 20,
                                    fontSize: 13,
                                    textColor: Color("SecondaryColor"),
                                    buttonColor: Color("PrimaryColor")
                                )
                                .frame(width: 210, height: 25)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(Color("SecondaryColor")))
                            }
                        }
                    }
                }
            }
            .frame(width: size.width, height: size.height)
            .padding(.bottom, 12)
            
            CapsuleProgressBar(progress: 1.0)
                .padding(.bottom, 20)
        }
        // --- START OF NAVIGATION FIXES ---
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // Force hide the system button
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(Color("SecondaryColor"))
                }
            }
        }
        // --- END OF NAVIGATION FIXES ---
        .alert(isPresented: Binding(
            get: { showConfirmationDialog || showAlert },
            set: { _ in }
        )) {
            if showConfirmationDialog {
                return Alert(
                    title: Text("Confirm Sharing"),
                    message: Text("The following information will be shared when posted to the community:\n- Name & Profile Picture\n- Date & Time of Interaction\n- City, State\n- People Helped\n- Type of Help Offered\n- Items Donated\n- People Who Joined"),
                    primaryButton: .default(Text("Confirm")) {
                        let adapter = VisitLogDataAdapter()
                        adapter.updateVisitLogField(log.id, field: "isPublic", value: true) {
                            shareAction()
                            alertMessage = "Visit Log Shared Successfully!"
                            successMessage1 = "Approval can typically take"
                            hasShared = true
                            showAlert = true
                            showConfirmationDialog = false
                        }
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
    }
}

struct CapsuleProgressBar: View {
    var progress: CGFloat

    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                Capsule()
                    .stroke(Color.black, lineWidth: 2)
                    .frame(height: 12)

                Capsule()
                    .fill(Color("PrimaryColor"))
                    .frame(width: progress * 280, height: 12)
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
