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
    
    var size = CGSize(width: 350.0, height: 450.0)
    var question1: String
    var question2: String
    
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
                        .padding(.top, 12)
                        .fontWeight(.bold)
                    Text(question2)
                        .font(.title2)
                        .padding(.bottom, 12)
                        .fontWeight(.bold)
                }
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        checkbox("Food & Drinks", isChecked: $foodAndDrinks)
                        checkbox("Clothes", isChecked: $clothes)
                        checkbox("Hygiene Products", isChecked: $hygine)
                        checkbox("Wellness/Emotional Support", isChecked: $wellness)
                        checkbox("Medical Help", isChecked: $medical)
                        checkbox("Social Worker/Psychological support", isChecked: $socialworker)
                        checkbox("Legal/Lawyer", isChecked: $legal)
                        checkbox("Other", isChecked: $other)

                        if other {
                            AutoGrowingTextEditor(text: $otherNotes, placeholder: NSLocalizedString("otherNotes", comment: ""))
                        }
                        (
                            Text("Note: ").bold() +
                            Text("You may check more than one box.")
                        )
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.top, 10)

                    }
                    .padding()
                }
                //.padding()
                
                Spacer()
                
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
            question1: "What kind of help did you provide?",
            question2: "",
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

@ViewBuilder
func checkbox(_ label: String, isChecked: Binding<Bool>) -> some View {
    Button(action: {
        isChecked.wrappedValue.toggle()
    }) {
        HStack {
            ZStack {
                // Background box
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color("SecondaryColor"), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(isChecked.wrappedValue ? Color("SecondaryColor") : Color.clear)
                    )
                    .frame(width: 20, height: 20)
                
                // Checkmark
                if isChecked.wrappedValue {
                    Image(systemName: "checkmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundColor(Color("PrimaryColor"))
                }
            }

            Text(label)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
    .buttonStyle(PlainButtonStyle())
}
