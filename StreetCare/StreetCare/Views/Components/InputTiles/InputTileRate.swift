//
//  InputTileRate.swift
//  StreetCare
//
//  Created by Michael on 4/19/23.
//
import SwiftUI

struct InputTileRate: View {

    var questionNumber: Int
    var totalQuestions: Int
    
    var size = CGSize(width: 300.0, height: 380.0)
    var question1: String
    var question2: String
        
    @Binding var textValue: String
    @Binding var rating: Int
        
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
                            //.font(.footnote)
                            
                            Spacer()
                            
                            /*Button("Skip") {
                             skipAction()
                             }
                             .foregroundColor(Color("SecondaryColor"))
                             .padding(.horizontal, 16)
                             .padding(.vertical, 8)
                             .background(
                             Capsule()
                             .fill(Color.white)
                             )
                             .overlay(
                             Capsule()
                             .stroke(Color("SecondaryColor"), lineWidth: 2)
                             )*/
                            
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                            .padding(.horizontal)
                    }
                    
                    VStack{
                        Text(question1)
                            .font(.title3)
                            .padding(.top, 12)
                            .fontWeight(.bold)
                        Text(question2)
                            .font(.title3)
                        //.padding(.bottom, 12)
                            .fontWeight(.bold)
                    }
                    RatingView(rating: $rating)
                    
                    
                    AutoGrowingTextEditor(text: $textValue, placeholder: NSLocalizedString("comments", comment: ""))
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
                            
                            Button(" " + NSLocalizedString("next", comment: "") + " ") {
                                nextAction()
                            }
                            .foregroundColor(Color("PrimaryColor"))
                            .fontWeight(.bold)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color("SecondaryColor")))
                        }
                        .padding()
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
                        .padding()
                    }
                }
                
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Interaction Log")
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Updated"),
                message: Text("Your rating was successfully updated."),
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
                .font(.footnote)
                .padding(.top, 4)
                .fontWeight(.bold)
        }

    } // end body
    
    
    private func starNameForStarNumber(_ starNumber: Int) -> String {
        if starNumber <= rating {
            return "star.fill"
        }
        else {
            return "star"
        }
    }
    
    private func starColorForStarNumber(_ starNumber: Int) -> Color {
        if starNumber <= rating {
            return .yellow
        }
        else {
            return .gray
        }
    }
}
// end struct

