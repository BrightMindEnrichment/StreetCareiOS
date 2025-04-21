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
    
    var body: some View {

        ZStack {
            BasicTile(size: CGSize(width: size.width, height: size.height))
            
            VStack {
                
                HStack {
                    Text("Question \(questionNumber)/\(totalQuestions)")
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
            .fontWeight(.bold)

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
} // end struct



