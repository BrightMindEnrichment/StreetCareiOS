//
//  InputTileMoreQuestions.swift
//  StreetCare
//
//  Created by Michael on 4/24/23.
//

import SwiftUI

struct InputTileMoreQuestions: View {

    var size = CGSize(width: 300.0, height: 250.0)
    var question1: String
    var question2: String
    var question3: String
    
    var questionNumber: Int
    var totalQuestions: Int
        
    var nextAction: () -> ()
    var skipAction: () -> ()
    var yesAction: () -> ()
    var noAction: () -> ()
    var previousAction: () -> () // ✅ Added new action

    var body: some View {

        VStack(spacing: 0) {
            // ✅ Progress bar below tile
            SegmentedProgressBar(
                totalSegments: totalQuestions,
                filledSegments: questionNumber,
                tileWidth: 300
            )

            Text(NSLocalizedString("", comment: ""))
                .font(.footnote)
                .padding(.top, 4)
                .fontWeight(.bold)
            ZStack {
                BasicTile(size: CGSize(width: size.width, height: size.height))
                
                VStack {
                    Spacer() // Pushes content from top to center

                    VStack(spacing: 1) { // Grouped questions
                        Text(question1)
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(question2)
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(question3)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .multilineTextAlignment(.center)

                    Spacer() // Balances space between text and buttons

                    // Yes / No Buttons
                    HStack(spacing: 20) {
                        Button(" Yes ") {
                            yesAction()
                        }
                        .foregroundColor(Color("PrimaryColor"))
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color("SecondaryColor")))
                        
                        Button(" No ") {
                            noAction()
                        }
                        .foregroundColor(Color("SecondaryColor"))
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.white))
                        .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
                    }

                    // Previous button
                    Button(NSLocalizedString("previous", comment: "")) {
                        previousAction()
                    }
                    .foregroundColor(Color("SecondaryColor"))
                    .font(.footnote)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.white))
                    .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
                    .padding(.top, 16)

                    Spacer() // Pushes content from bottom to center
                }
                .padding()
                .frame(width: size.width, height: size.height) // Added to allow Spacers to expand
            }
            .frame(width: size.width, height: size.height)
            
          Spacer()
           
        }
    }
}
