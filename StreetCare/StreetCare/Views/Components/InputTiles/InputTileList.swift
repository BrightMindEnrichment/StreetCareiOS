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
    @ObservedObject var visitLog: VisitLog

    var nextAction: () -> ()
    var previousAction: () -> ()
    var skipAction: () -> ()
    var buttonMode: ButtonMode = .navigation
    var showProgressBar: Bool = true
    @Environment(\.presentationMode) var presentationMode
    @State private var showSuccessAlert = false
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
                        checkbox("Food & Drinks", isChecked: $visitLog.foodAndDrinks)
                        checkbox("Clothes", isChecked: $visitLog.clothes)
                        checkbox("Hygiene Products", isChecked: $visitLog.hygine)
                        checkbox("Wellness/Emotional Support", isChecked: $visitLog.wellness)
                        checkbox("Medical Help", isChecked: $visitLog.medical)
                        checkbox("Social Worker/Psychiatrist", isChecked: $visitLog.socialworker)
                        checkbox("Legal/Lawyer", isChecked: $visitLog.legal)
                        checkbox("Other", isChecked: $visitLog.other)

                        if visitLog.other {
                            AutoGrowingTextEditor(text: $visitLog.otherNotes, placeholder: NSLocalizedString("otherNotes", comment: ""))
                        }
                    }
                    .padding()
                }
                //.padding()
                
                Spacer()
                
                if buttonMode == .navigation {
                    HStack {
                        Button("Previous") {
                            previousAction()
                        }
                        .foregroundColor(Color("SecondaryColor"))
                        .font(.footnote)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.white))
                        .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
                        
                        Spacer()
                        
                        Button("Next") {
                            nextAction()
                        }
                        .foregroundColor(Color("PrimaryColor"))
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color("SecondaryColor")))
                    }
                    .padding()
                } else if buttonMode == .update {
                    HStack {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(Color("SecondaryColor"))
                        .font(.footnote)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color.white))
                        .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
                        
                        Spacer()
                        
                        Button("Update") {
                            showSuccessAlert = true
                            nextAction()
                        }
                        .foregroundColor(Color("PrimaryColor"))
                        .fontWeight(.bold)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(Color("SecondaryColor")))
                    }
                    .padding()
                }
                
            }
        }
        .frame(width: size.width, height: size.height)
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Updated"),
                message: Text("The information was successfully updated."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        
        if showProgressBar {
            SegmentedProgressBar(
                totalSegments: totalQuestions,
                filledSegments: questionNumber,
                tileWidth: 300
            )
            Text("Progress")
                .font(.footnote)
                .padding(.top, 4)
                .fontWeight(.bold)
        }

    } // end body
    
} // end struct
struct InputTileList_Previews: PreviewProvider {
    static var previews: some View {
        InputTileList(
            questionNumber: 1,
            totalQuestions: 5,
            question1: "What kind of help did you provide?",
            question2: "",
            visitLog: VisitLog(id: UUID().uuidString),
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
