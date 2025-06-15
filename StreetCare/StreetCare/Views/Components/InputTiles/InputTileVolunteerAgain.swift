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
    
    var body: some View {

        ZStack {
            BasicTile(size: CGSize(width: size.width, height: size.height))
            
            VStack {
                HStack {
                    Text(NSLocalizedString("question", comment: "") + " \(questionNumber)/\(totalQuestions)")
                        .foregroundColor(.black)
                        //.font(.footnote)
                    
                    Spacer()
                    
                    /*Button("Skip") {
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
                    )*/
                    
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
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
                        Text(NSLocalizedString("yes", comment: ""))
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
                
                HStack {
                    Button(NSLocalizedString("previous", comment: ""))  {
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
                    
                    Button(" " + NSLocalizedString("finish", comment: "") + " ") {
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
                //.padding()
                .padding(.horizontal)
            }
        }
        .frame(width: size.width, height: size.height)
        SegmentedProgressBar(
            totalSegments: totalQuestions,
            filledSegments: questionNumber,
            tileWidth: 300
        )
        
        Text(NSLocalizedString("progress", comment: ""))
            .font(.caption)
            .padding(.top, 4)

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
