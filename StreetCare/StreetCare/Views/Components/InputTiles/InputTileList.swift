//
//  InputTileList.swift
//  StreetCare
//
//  Created by Michael on 4/20/23.
//

import SwiftUI

enum SupportMode {
    case provided
    case needed
}

struct InputTileList: View {
    

    var questionNumber: Int
    var totalQuestions: Int
    var optionCount: Int
    var size: CGSize
    var question1: String
    var question2: String
    @ObservedObject var visitLog: VisitLog
    var nextAction: () -> ()
    var previousAction: () -> ()
    var skipAction: () -> ()
    var buttonMode: ButtonMode = .navigation
    var showProgressBar: Bool = true
    var supportMode: SupportMode = .provided

    @Environment(\.presentationMode) var presentationMode
    @State private var showSuccessAlert = false
    private func updateSupportArray() {
        var selected: [String] = []

        switch supportMode {
        case .provided:
            if visitLog.foodAndDrinks { selected.append("Food & Drinks") }
            if visitLog.clothes { selected.append("Clothes") }
            if visitLog.hygiene { selected.append("Hygiene Products") }
            if visitLog.wellness { selected.append("Wellness/Emotional Support") }
            if visitLog.medical { selected.append("Medical Help") }
            if visitLog.social { selected.append("Social Worker/Psychiatrist") }
            if visitLog.legal { selected.append("Legal/Lawyer") }
            if visitLog.other {
                selected.append(visitLog.otherNotes.isEmpty ? "Other" : visitLog.otherNotes)
            }
            visitLog.whatGiven = selected

        case .needed:
            if visitLog.furtherFoodAndDrinks { selected.append("Food & Drinks") }
            if visitLog.furtherClothes { selected.append("Clothes") }
            if visitLog.furtherHygiene { selected.append("Hygiene Products") }
            if visitLog.furtherWellness { selected.append("Wellness/Emotional Support") }
            if visitLog.furtherMedical { selected.append("Medical Help") }
            if visitLog.furtherSocial { selected.append("Social Worker/Psychiatrist") }
            if visitLog.furtherLegal { selected.append("Legal/Lawyer") }
            if visitLog.furtherOther {
                selected.append(visitLog.furtherOtherNotes.isEmpty ? "Other" : visitLog.furtherOtherNotes)
            }
            visitLog.whatGiven = selected // Reused for further support too
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if buttonMode == .update {
                Text("Edit Your Interaction")
                    .font(.title2)
                    .fontWeight(.bold)
                //.padding(.top, 16)
                    .padding(.bottom, 50)
            }
            
            ZStack {
                BasicTile(size: CGSize(width: size.width, height: size.height))
                
                VStack {
                    if buttonMode == .navigation {
                        HStack {
                            Text(NSLocalizedString("question", comment: "") + " \(questionNumber)/\(totalQuestions)")
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
                    }
                    
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
                            switch supportMode {
                            case .provided:
                                checkbox("Food & Drinks", isChecked: $visitLog.foodAndDrinks)
                                checkbox("Clothes", isChecked: $visitLog.clothes)
                                checkbox("Hygiene Products", isChecked: $visitLog.hygiene) // fix to $visitLog.hygiene if renamed
                                checkbox("Wellness/Emotional Support", isChecked: $visitLog.wellness)
                                checkbox("Medical Help", isChecked: $visitLog.medical)
                                checkbox("Social Worker/Psychiatrist", isChecked: $visitLog.social)
                                checkbox("Legal/Lawyer", isChecked: $visitLog.legal)
                                checkbox("Other", isChecked: $visitLog.other)
                                if visitLog.other {
                                    AutoGrowingTextEditor(text: $visitLog.otherNotes, placeholder: NSLocalizedString("otherNotes", comment: ""))
                                }
                                
                            case .needed:
                                checkbox("Food & Drinks", isChecked: $visitLog.furtherFoodAndDrinks)
                                checkbox("Clothes", isChecked: $visitLog.furtherClothes)
                                checkbox("Hygiene Products", isChecked: $visitLog.furtherHygiene) // fix to $visitLog.furtherHygiene if renamed
                                checkbox("Wellness/Emotional Support", isChecked: $visitLog.furtherWellness)
                                checkbox("Medical Help", isChecked: $visitLog.furtherMedical)
                                checkbox("Social Worker/Psychiatrist", isChecked: $visitLog.furtherSocial)
                                checkbox("Legal/Lawyer", isChecked: $visitLog.furtherLegal)
                                checkbox("Other", isChecked: $visitLog.furtherOther)
                                if visitLog.furtherOther {
                                    AutoGrowingTextEditor(text: $visitLog.furtherOtherNotes, placeholder: NSLocalizedString("furtherOtherNotes", comment: ""))
                                }
                            }
                        }
                        .padding()
                    }
                    //.padding()
                    
                    Spacer()
                    
                    if buttonMode == .navigation {
                        HStack {
                            Button(NSLocalizedString("previous", comment: "")) {
                                previousAction()
                            }
                            .foregroundColor(Color("SecondaryColor"))
                            .font(.footnote)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.white))
                            .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
                            
                            Spacer()
                            
                            Button(" " + NSLocalizedString("next", comment: "") + " ") {
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
                if supportMode == .provided {
                    SupportChangeObserverProvided(visitLog: visitLog, onUpdate: updateSupportArray)
                } else {
                    SupportChangeObserverNeeded(visitLog: visitLog, onUpdate: updateSupportArray)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Interaction Log")
        .frame(width: size.width, height: size.height)
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Updated"),
                message: Text("Interaction Log was successfully updated."),
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
            Text(NSLocalizedString("progress", comment: ""))
                .font(.footnote)
                .padding(.top, 4)
                .fontWeight(.bold)
        }

    } // end body
    
} // end struct
struct SupportChangeObserverProvided: View {
    @ObservedObject var visitLog: VisitLog
    var onUpdate: () -> Void

    var body: some View {
        EmptyView()
            .onChange(of: visitLog.foodAndDrinks) { onUpdate() }
            .onChange(of: visitLog.clothes) { onUpdate() }
            .onChange(of: visitLog.hygiene) { onUpdate() }
            .onChange(of: visitLog.wellness) { onUpdate() }
            .onChange(of: visitLog.medical) { onUpdate() }
            .onChange(of: visitLog.social) { onUpdate() }
            .onChange(of: visitLog.legal) { onUpdate() }
            .onChange(of: visitLog.other) { onUpdate() }
            .onChange(of: visitLog.otherNotes) { onUpdate() }
    }
}

struct SupportChangeObserverNeeded: View {
    @ObservedObject var visitLog: VisitLog
    var onUpdate: () -> Void

    var body: some View {
        EmptyView()
            .onChange(of: visitLog.furtherFoodAndDrinks) { onUpdate() }
            .onChange(of: visitLog.furtherClothes) { onUpdate() }
            .onChange(of: visitLog.furtherHygiene) { onUpdate() }
            .onChange(of: visitLog.furtherWellness) { onUpdate() }
            .onChange(of: visitLog.furtherMedical) { onUpdate() }
            .onChange(of: visitLog.furtherSocial) { onUpdate() }
            .onChange(of: visitLog.furtherLegal) { onUpdate() }
            .onChange(of: visitLog.furtherOther) { onUpdate() }
            .onChange(of: visitLog.furtherOtherNotes) { onUpdate() }
    }
}
struct InputTileList_Previews: PreviewProvider {
    static var previews: some View {
        InputTileList(
            questionNumber: 1,
            totalQuestions: 5,
            optionCount: 5,
            size: CGSize(width: 350, height: 450),
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
