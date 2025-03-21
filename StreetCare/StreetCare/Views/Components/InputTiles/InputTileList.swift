//
//  InputTileList.swift
//  StreetCare
//
//  Created by Michael on 4/20/23.
//

import SwiftUI



struct InputTileList: View {
    
    var questionNumber: Int
    var totalQuestions: Int
    
    var optionCount = 5
    
    var size = CGSize(width: 300.0, height: 450.0)
    var question: String
    
    @Binding var foodAndDrinks: Bool
    @Binding var clothes: Bool
    @Binding var hygine: Bool
    @Binding var wellness: Bool
    @Binding var medical: Bool
    @Binding var socialworker: Bool
    @Binding var legal: Bool
    @Binding var other: Bool
    @Binding var otherNotes: String

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
                    .padding(EdgeInsets(top: 10.0, leading: 0.0, bottom: 0.0, trailing: 16.0))
                }

                Spacer()

                Text("Question \(questionNumber)/\(totalQuestions)")
                    .foregroundColor(.gray)
                    .font(.footnote)
    
                Text(question)
                    .font(.headline)
                    //.padding()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) { // Add spacing between toggles
                        Toggle("Food & Drinks", isOn: $foodAndDrinks)
                        Toggle("Clothes", isOn: $clothes)
                        Toggle("Hygiene Products", isOn: $hygine)
                        Toggle("Wellness/Emotional Support", isOn: $wellness)
                        Toggle("Medical Help", isOn: $medical)
                        Toggle("Social Worker/Psychiatrist", isOn: $socialworker)
                        Toggle("Legal/Lawyer", isOn: $legal)
                        Toggle("Other", isOn: $other)
                        
                        if other {
                            TextField("Other", text: $otherNotes)
                                .textFieldStyle(RoundedBorderTextFieldStyle()) // Optional: Improve appearance
                                .padding(.top, 5)
                        }
                    }
                    .padding() // Apply padding to the entire VStack
                }
                .padding()
                
                Spacer()
                
                ProgressView(value: Double(questionNumber) / Double(totalQuestions))
                    .tint(.yellow)
                    .background(.black)
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
            }
        }
        .frame(width: size.width, height: size.height)

    } // end body
} // end struct


struct InputTileList_Previews: PreviewProvider {
    
    @State static var foodAndDrinks = false
    @State static var clothes = false
    @State static var hygine = false
    @State static var wellness = false
    @State static var medical = false
    @State static var socialworker = false
    @State static var legal = false
    @State static var other = false
    @State static var otherNotes = ""

    static var previews: some View {
        InputTileList(
            questionNumber: 1,
            totalQuestions: 5,
            question: "What kind of help did you provide?",
            foodAndDrinks: $foodAndDrinks,
            clothes: $clothes,
            hygine: $hygine,
            wellness: $wellness,
            medical: $medical,
            socialworker: $socialworker,
            legal: $legal,
            other: $other,
            otherNotes: $otherNotes,
            nextAction: {},
            previousAction: {},
            skipAction: {}
        )
    }
}
