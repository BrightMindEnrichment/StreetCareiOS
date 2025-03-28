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
        
    var size = CGSize(width: 300.0, height: 450.0)
    var question: String
    
    @Binding var volunteerAgain: Int
        
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
                
                Picker("\(question)", selection: $volunteerAgain) {
                    Text("Yes").tag(1)
                    Text("No").tag(0)
                    Text("Maybe").tag(2)
                }
                .pickerStyle(.segmented)
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


struct InputTileVolunteerAgain_Previews: PreviewProvider {

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

