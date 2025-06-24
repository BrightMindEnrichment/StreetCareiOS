//
//  InputTileVolunteerAgain.swift
//  StreetCare
//
//  Created by Michael on 4/30/23.
//

import SwiftUI

struct InputTileVolunteerAgain: View {

    var questionNumber: Int
    var totalQuestions: Int
        
    var size = CGSize(width: 300.0, height: 350.0)
    var question1: String
    var question2: String
    
    @Binding var volunteerAgain: String
        
    var nextAction: () -> ()
    var previousAction: () -> ()
    var skipAction: () -> ()
    
    @Environment(\.presentationMode) var presentationMode
    var buttonMode: ButtonMode = .navigation
    @State private var showSuccessAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            if buttonMode == .update {
                Text("Edit Your Interaction")
                    .font(.title2)
                    .fontWeight(.bold)
                //.padding(.top, 16)
                    .padding(.bottom, 50)
            }
            
            ZStack {
                BasicTile(size: CGSize(width: size.width, height: size.height))
                
                VStack {
                    if buttonMode == .navigation {
                        HStack {
                            Text(NSLocalizedString("question", comment: "") + " \(questionNumber)/\(totalQuestions)")
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                    }
                    
                    Divider()
                        .background(Color.gray.opacity(0.3))
                        .padding(.horizontal)
                    
                    VStack{
                        Text(question1)
                            .font(.title2)
                            .padding(.top, 12)
                            .fontWeight(.bold)
                        Text(question2)
                            .font(.title2)
                            .padding(.bottom, 6)
                            .fontWeight(.bold)
                    }
                    
                    VStack(spacing: 12) {
                        Button(action: {
                            volunteerAgain = "Yes"
                        }) {
                            Text(NSLocalizedString("yes", comment: ""))
                                .font(.footnote)
                                .foregroundColor(volunteerAgain == "Yes" ? .white : Color("SecondaryColor"))
                                .fontWeight(.bold)
                                .frame(maxWidth: 120)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(volunteerAgain == "Yes" ? Color("SecondaryColor") : Color.white)
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color("SecondaryColor"), lineWidth: 2)
                                )
                        }

                        Button(action: {
                            volunteerAgain = "No"
                        }) {
                            Text("No")
                                .font(.footnote)
                                .foregroundColor(volunteerAgain == "No" ? .white : Color("SecondaryColor"))
                                .fontWeight(.bold)
                                .frame(maxWidth: 120)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(volunteerAgain == "No" ? Color("SecondaryColor") : Color.white)
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color("SecondaryColor"), lineWidth: 2)
                                )
                        }

                        Button(action: {
                            volunteerAgain = "Maybe"
                        }) {
                            Text("Maybe")
                                .font(.footnote)
                                .foregroundColor(volunteerAgain == "Maybe" ? .white : Color("SecondaryColor"))
                                .fontWeight(.bold)
                                .frame(maxWidth: 120)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(volunteerAgain == "Maybe" ? Color("SecondaryColor") : Color.white)
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(Color("SecondaryColor"), lineWidth: 2)
                                )
                        }
                    }
                    .padding()
                    if buttonMode == .navigation {
                        HStack {
                            Button(NSLocalizedString("previous", comment: "")) {
                                previousAction()
                            }
                            .foregroundColor(Color("SecondaryColor"))
                            .font(.footnote)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.white))
                            .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
                            
                            Spacer()
                            
                            Button(" " + NSLocalizedString("finish", comment: "") + " ") {
                                nextAction()
                            }
                            .foregroundColor(Color("PrimaryColor"))
                            .fontWeight(.bold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color("SecondaryColor")))
                        }
                        .padding(.horizontal)
                    } else if buttonMode == .update {
                        HStack {
                            Button("Cancel") {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .foregroundColor(Color("SecondaryColor"))
                            .font(.footnote)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.white))
                            .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
                            
                            Spacer()
                            
                            Button("Update") {
                                showSuccessAlert = true
                                nextAction()
                            }
                            .foregroundColor(Color("PrimaryColor"))
                            .fontWeight(.bold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color("SecondaryColor")))
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Interaction Log")
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Updated"),
                message: Text("Interaction Log was successfully updated."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .frame(width: size.width, height: size.height)
        if buttonMode == .navigation {
            SegmentedProgressBar(
                totalSegments: totalQuestions,
                filledSegments: questionNumber,
                tileWidth: 300
            )

            Text(NSLocalizedString("progress", comment: ""))
                .font(.caption)
                .padding(.top, 4)
        }

    } // end body
} // end struct


/*struct InputTileVolunteerAgain_Previews: PreviewProvider {

    @State static var input = 0

    static var previews: some View {

        InputTileVolunteerAgain(questionNumber: 1, totalQuestions: 3, question: "Sleep in?", volunteerAgain: $input) {
            //
        } previousAction: {
            //
        } skipAction: {
            //
        }

    }
}
*/
