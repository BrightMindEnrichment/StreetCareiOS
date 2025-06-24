//
//  InputTileNotes.swift
//  StreetCare
//
//  Created by Marian John on 4/24/25.
//

import SwiftUI

struct InputTileNotes: View {

    var questionNumber: Int
    var totalQuestions: Int

    var tileWidth: CGFloat
    var tileHeight: CGFloat

    var question1: String
    var question2: String
    var question3: String

    var placeholderText: String
    @Binding var otherNotes: String

    var nextAction: () -> ()
    var previousAction: () -> ()
    var skipAction: () -> ()

    var buttonMode: ButtonMode

    @Environment(\.presentationMode) var presentationMode
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
                BasicTile(size: CGSize(width: tileWidth, height: tileHeight))
                
                VStack {
                    if buttonMode == .navigation{
                        HStack {
                            Text(NSLocalizedString("question", comment: "") + " \(questionNumber)/\(totalQuestions)")
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Button(NSLocalizedString("skip", comment: "")) {
                                skipAction()
                            }
                            .foregroundColor(Color("SecondaryColor"))
                            .font(.footnote)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.white))
                            .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                            .padding(.horizontal)
                    }
                    
                    VStack {
                        Text(question1).font(.title2).fontWeight(.bold).padding(.bottom, 1)
                        Text(question2).font(.title2).fontWeight(.bold).padding(.bottom, 1)
                        Text(question3).font(.title2).fontWeight(.bold).padding(.bottom, 1)
                    }
                    .padding(.vertical)
                    
                    AutoGrowingTextEditor(text: $otherNotes, placeholder: placeholderText)
                    
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
                            
                            Button("Next") {
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
        .frame(width: tileWidth, height: tileHeight)
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Updated"),
                message: Text("Interaction Log was successfully updated."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }

        if buttonMode == .navigation {
            SegmentedProgressBar(
                totalSegments: totalQuestions,
                filledSegments: questionNumber,
                tileWidth: tileWidth
            )
            Text(NSLocalizedString("progress", comment: ""))
                .font(.footnote)
                .padding(.top, 4)
                .fontWeight(.bold)
        }
    }
}
