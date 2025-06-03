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
    
    @Binding var volunteerAgain: Int
        
    var nextAction: () -> ()
    var previousAction: () -> ()
    var skipAction: () -> ()
    
    @Environment(\.presentationMode) var presentationMode
    var buttonMode: ButtonMode = .navigation
    @State private var showSuccessAlert = false
    
    var body: some View {

        ZStack {
            BasicTile(size: CGSize(width: size.width, height: size.height))
            
            VStack {
                if buttonMode == .navigation {
                    HStack {
                        Text("Question \(questionNumber)/\(totalQuestions)")
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
                        volunteerAgain = 1
                    }) {
                        Text("Yes")
                            .font(.footnote)
                            .foregroundColor(volunteerAgain == 1 ? .white : Color("SecondaryColor"))
                            //.foregroundColor(Color.black)
                            .frame(maxWidth: 120)
                            .padding(.vertical, 8)
                            .fontWeight(.bold)
                            .background(
                                Capsule()
                                    .fill(volunteerAgain == 1 ? Color("SecondaryColor") : Color.white)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color("SecondaryColor"), lineWidth: 2)
                            )
                    }

                    Button(action: {
                        volunteerAgain = 0
                    }) {
                        Text("No")
                            .font(.footnote)
                            .foregroundColor(volunteerAgain == 0 ? .white : Color("SecondaryColor"))
                            //.foregroundColor(Color.black)
                            .fontWeight(.bold)
                            .frame(maxWidth: 120)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(volunteerAgain == 0 ? Color("SecondaryColor") : Color.white)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color("SecondaryColor"), lineWidth: 2)
                            )
                    }

                    Button(action: {
                        volunteerAgain = 2
                    }) {
                        Text("Maybe")
                            .font(.footnote)
                            .foregroundColor(volunteerAgain == 2 ? .white : Color("SecondaryColor"))
                            //.foregroundColor(Color.black)
                            .fontWeight(.bold)
                            .frame(maxWidth: 120)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(volunteerAgain == 2 ? Color("SecondaryColor") : Color.white)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color("SecondaryColor"), lineWidth: 2)
                            )
                    }
                }
                //.padding(.horizontal)
                .padding()
                
                if buttonMode == .navigation {
                    HStack {
                        Button("Previous") {
                            previousAction()
                        }
                        .foregroundColor(Color("SecondaryColor"))
                        .font(.footnote)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.white))
                        .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))

                        Spacer()

                        Button("Finish") {
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

            Text("Progress")
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
