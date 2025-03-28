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
    
    var size = CGSize(width: 300.0, height: 450.0)
    var question: String
    var cosentence: String
        
    @Binding var number: Int
        
    var nextAction: () -> ()
    var previousAction: () -> ()
    var skipAction: () -> ()

    var body: some View {

        ZStack {
            BasicTile(size: CGSize(width: size.width, height: size.height))
            
            VStack {
                
                HStack {
                    Spacer()
                    Button("Skip") {
                        skipAction()
                    }
                    .foregroundColor(.gray)
                    .padding()
                }
                
                Spacer()
                
                Text("Question \(questionNumber)/\(totalQuestions)")
                    .foregroundColor(.gray)
                    .font(.footnote)
    
                Text(question)
                    .font(.headline)
                    .padding()
                
                Stepper("\(number) \(cosentence)", value: $number)
                    .padding()
                
                Spacer()
                
                HStack {
                    Button("Previous") {
                        previousAction()
                    }
                    .foregroundColor(Color("TextColor"))
                    Spacer()
                    Button("Next") {
                        nextAction()
                    }
                    .foregroundColor(Color("TextColor"))
                }
                .padding()
                
                SegmentedProgressBar(
                    totalSegments: totalQuestions,
                    filledSegments: questionNumber
                )
                
                Text("Progress")
                    .font(.caption)
                    .padding(.top, 4)
            }
        }
        .frame(width: size.width, height: size.height)

    } // end body
} // end struct


