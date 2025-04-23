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

    var body: some View {

        ZStack {
            BasicTile(size: CGSize(width: size.width, height: size.height))
            
            VStack {
                VStack{
                    Text(question1)
                        .font(.title3)
                        .padding(.bottom, 1)
                        .fontWeight(.bold)
                    Text(question2)
                        .font(.title3)
                        .padding(.bottom, 1)
                        .fontWeight(.bold)
                    Text(question3)
                        .font(.title3)
                        .fontWeight(.bold)
                }
                .padding(.vertical)
                
                HStack {

                    Button(" Yes ") {
                        yesAction()
                    }
                    .foregroundColor(Color("PrimaryColor"))
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color("SecondaryColor"))
                    )
                    
                    Button(" No ") {
                        noAction()
                    }
                    .foregroundColor(Color("SecondaryColor"))
                    .fontWeight(.bold)
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
                }
                .padding()
            }
        }
        .frame(width: size.width, height: size.height)
        SegmentedProgressBar(
            totalSegments: totalQuestions,
            filledSegments: questionNumber,
            tileWidth: 300
        )

        Text("Progress")
            .font(.footnote)
            .padding(.top, 4)
            .fontWeight(.bold)

    } // end body
} // end struct


//struct InputTileMoreQuestions_Previews: PreviewProvider {
//
//    @State static var inputText = ""
//
//    static var previews: some View {
//        InputTileMoreQuestions(questionNumber: 5, totalQuestions: 5, question: "Would you like to answer additional questions?") {
//            // nothing
//        } skipAction: {
//            //
//        } yesAction: {
//            //
//        } noAction: {
//            //
//        }
//
//    }
//}


