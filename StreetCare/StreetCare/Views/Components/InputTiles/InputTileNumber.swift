//
//  InputTileNumber.swift
//  StreetCare
//
//  Created by Michael on 4/19/23.
//


import SwiftUI

struct InputTileNumber: View {

    var questionNumber: Int
    var totalQuestions: Int
    
    var size = CGSize(width: 300.0, height: 490.0)
    var question1: String
    var question2: String
    @State private var peopledescription = ""
        
    @Binding var number: Int
        
    var nextAction: () -> ()
    var previousAction: () -> ()
    var skipAction: () -> ()

    var body: some View {

        ZStack {
            BasicTile(size: CGSize(width: size.width, height: size.height))
            
            VStack {
                
                HStack {
                    Text("Question \(questionNumber)/\(totalQuestions)")
                        .foregroundColor(.black)
                        //.font(.footnote)
                    
                    Spacer()
                    
                    Button("Skip") {
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
                    )
                    
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.horizontal)
    
                VStack{
                    Text(question1)
                        .font(.title3)
                        .padding(.top, 12)
                        .fontWeight(.bold)
                    Text(question2)
                        .font(.title3)
                        .padding(.bottom, 12)
                        .fontWeight(.bold)
                }

                HStack(spacing: 20) {
                    Button(action: {
                        if number > 0 {
                            number -= 1
                        }
                    }) {
                        Image(systemName: "minus")
                            .foregroundColor(Color("PrimaryColor"))
                            .frame(width: 30, height: 30)
                            .background(Color("SecondaryColor"))
                            .clipShape(Circle())
                    }

                    Text("\(number)")
                        .font(.title2)
                        .fontWeight(.bold)

                    Button(action: {
                        number += 1
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color("PrimaryColor"))
                            .frame(width: 30, height: 30)
                            .background(Color("SecondaryColor"))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom)
                
                Text("Description")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .foregroundColor(Color("SecondaryColor"))
                
                AutoGrowingTextEditor(text: $peopledescription, placeholder: NSLocalizedString("peopledescription", comment: ""))
                
                Text(NSLocalizedString("disclaimer", comment: ""))
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                HStack {
                    Button("Previous") {
                        previousAction()
                    }
                    .foregroundColor(Color("SecondaryColor"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.white) // Fill with white
                    )
                    .overlay(
                        Capsule()
                            .stroke(Color("SecondaryColor"), lineWidth: 2) // Stroke with dark green
                    )

                    Spacer()

                    Button(" Next  ") {
                        nextAction()
                    }
                    .foregroundColor(Color("PrimaryColor"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color("SecondaryColor"))
                    )
                }
                .padding()
            }
        }
        .frame(width: size.width, height: size.height)
        SegmentedProgressBar(
            totalSegments: totalQuestions,
            filledSegments: questionNumber
        )

        Text("Progress")
            .font(.caption)
            .padding(.top, 4)

    } // end body
} // end struct




