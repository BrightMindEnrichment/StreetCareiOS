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

    var tileWidth: CGFloat
    var tileHeight: CGFloat

    var question1: String
    var question2: String
    var question3: String
    var question4: String


    var descriptionLabel: String
    var disclaimerText: String
    var placeholderText: String

    @Binding var number: Int
    @State private var peopledescription = ""

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
                        .font(.title3)
                        .padding(.bottom, 1)
                        .fontWeight(.bold)
                    Text(question2)
                        .font(.title3)
                        .padding(.bottom, 1)
                        .fontWeight(.bold)
                    Text(question3)
                        .font(.title3)
                        .padding(.bottom, 1)
                        .fontWeight(.bold)
                    Text(question4)
                        .font(.title3)
                        .fontWeight(.bold)
                }
                .padding(.vertical)

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

                    /*TextField("", value: $number, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 60)
                        .padding(6)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("SecondaryColor"), lineWidth: 1)
                        )*/
                    TextField("", value: $number, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(width: 60)
                        .textFieldStyle(PlainTextFieldStyle()) // removes any border or background
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
    
                Text(descriptionLabel)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .foregroundColor(Color("SecondaryColor"))

                AutoGrowingTextEditor(text: $peopledescription, placeholder: placeholderText)

                Text(disclaimerText)
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
