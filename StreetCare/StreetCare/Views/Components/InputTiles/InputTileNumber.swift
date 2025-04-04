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
    
    var size = CGSize(width: 300.0, height: 300.0)
    var question: String
        
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
    
                Text(question)
                    .font(.headline)
                    .padding()

                HStack(spacing: 20) {
                    Button(action: {
                        if number > 0 {
                            number -= 1
                        }
                    }) {
                        Image(systemName: "minus")
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
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
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(Color("SecondaryColor"))
                            .clipShape(Circle())
                    }
                }
                .padding(.bottom)
                
                
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

                    Button("Next") {
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


struct InputTileNumber_Previews: PreviewProvider {

    @State static var input = 5

    static var previews: some View {
        InputTileNumber(questionNumber: 1, totalQuestions: 2, question: "Luck number?", number: $input) {
            //
        } previousAction: {
            //
        } skipAction: {
            //
        }

    }
}
