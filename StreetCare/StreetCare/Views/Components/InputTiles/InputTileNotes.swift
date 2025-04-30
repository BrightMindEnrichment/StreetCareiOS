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

    var body: some View {

        ZStack {
            BasicTile(size: CGSize(width: tileWidth, height: tileHeight))
            
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
                    .font(.footnote)
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
                        .font(.title2)
                        .padding(.bottom, 1)
                        .fontWeight(.bold)
                    Text(question2)
                        .font(.title2)
                        .padding(.bottom, 1)
                        .fontWeight(.bold)
                    Text(question3)
                        .font(.title2)
                        .padding(.bottom, 1)
                        .fontWeight(.bold)
                }
                .padding(.vertical)

                AutoGrowingTextEditor(text: $otherNotes, placeholder: placeholderText)
                
                HStack {
                    Button("Previous") {
                        previousAction()
                    }
                    .foregroundColor(Color("SecondaryColor"))
                    .font(.footnote)
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
                    .fontWeight(.bold)
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
        .frame(width: tileWidth, height: tileHeight)
        SegmentedProgressBar(
            totalSegments: totalQuestions,
            filledSegments: questionNumber,
            tileWidth: tileWidth
        )

        Text("Progress")
            .font(.footnote)
            .padding(.top, 4)
            .fontWeight(.bold)

    } // end body
} // end struct
