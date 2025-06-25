//
//  InputTileString.swift
//  StreetCare
//
//  Created by Michael on 4/19/23.
//
import SwiftUI

enum ButtonMode {
    case navigation  // Shows Previous & Next
    case update      // Shows Update & Cancel
}

struct InputTileNumber: View {
    
    var questionNumber: Int
    var totalQuestions: Int
    
    var tileWidth: CGFloat
    var tileHeight: CGFloat
    
    var question1: String
    var question2: String
    var question3: String
    var question4: String
    
    var descriptionLabel: String?
    var descriptionLabel2: String?
    var disclaimerText: String?
    var placeholderText: String?
    var placeholderText2: String?
    
    @Binding var number: Int
    @State private var numberString: String

    @Binding var generalDescription: String
    @Binding var generalDescription2: String
    var showTextEditor: Bool = true
    @State private var showAlert = false
    @State private var showSuccessAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    var nextAction: () -> ()
    var previousAction: () -> ()
    var skipAction: () -> ()
    var showProgressBar: Bool
    var showTextEditor2: Bool
    var buttonMode: ButtonMode
    
    init(
        questionNumber: Int,
        totalQuestions: Int,
        tileWidth: CGFloat,
        tileHeight: CGFloat,
        question1: String,
        question2: String,
        question3: String,
        question4: String,
        descriptionLabel: String? = nil,
        descriptionLabel2: String? = nil,
        disclaimerText: String? = nil,
        placeholderText: String? = nil,
        placeholderText2: String? = nil,
        number: Binding<Int>,
        generalDescription: Binding<String>,
        generalDescription2: Binding<String>,
        nextAction: @escaping () -> Void,
        previousAction: @escaping () -> Void,
        skipAction: @escaping () -> Void,
        showProgressBar: Bool = true,
        showTextEditor2: Bool = false,
        buttonMode: ButtonMode = .navigation
    ) {
        self.questionNumber = questionNumber
        self.totalQuestions = totalQuestions
        self.tileWidth = tileWidth
        self.tileHeight = tileHeight
        self.question1 = question1
        self.question2 = question2
        self.question3 = question3
        self.question4 = question4
        self.descriptionLabel = descriptionLabel
        self.descriptionLabel2 = descriptionLabel2
        self.disclaimerText = disclaimerText
        self.placeholderText = placeholderText
        self.placeholderText2 = placeholderText2
        self._number = number
        self._numberString = State(initialValue: String(number.wrappedValue))
        self._generalDescription = generalDescription
        self._generalDescription2 = generalDescription2
        self.nextAction = nextAction
        self.previousAction = previousAction
        self.skipAction = skipAction
        self.showProgressBar = showProgressBar
        self.showTextEditor2 = showTextEditor2
        self.buttonMode = buttonMode
    }

    var body: some View {
        VStack(spacing: 0) {
            if buttonMode == .update {
                Text("Edit Your Interaction")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
            }

            ZStack {
                BasicTile(size: CGSize(width: tileWidth, height: tileHeight))

                ScrollView {
                    VStack(spacing: 16) {
                        if buttonMode == .navigation {
                            HStack {
                                Text(NSLocalizedString("question", comment: "") + " \(questionNumber)/\(totalQuestions)")
                                    .foregroundColor(.black)
                                Spacer()
                                Button(NSLocalizedString("skip", comment: "")) {
                                    skipAction()
                                }
                                .foregroundColor(Color("SecondaryColor"))
                                .font(.footnote)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color.white))
                                .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
                            }
                            .padding(.horizontal)
                            .padding(.top, 12)

                            Divider()
                                .background(Color.gray.opacity(0.3))
                                .padding(.horizontal)
                        }

                        VStack(spacing: 4) {
                            Text(question1).font(.title2).fontWeight(.bold)
                            Text(question2).font(.title2).fontWeight(.bold)
                            Text(question3).font(.title2).fontWeight(.bold)
                            Text(question4).font(.title2).fontWeight(.bold)
                        }
                        .padding(.vertical)

                        HStack(spacing: 20) {
                            Button(action: {
                                if let current = Int(numberString), current > 0 {
                                    numberString = "\(current - 1)"
                                }
                            }) {
                                Image(systemName: "minus")
                                    .foregroundColor(Color("PrimaryColor"))
                                    .frame(width: 30, height: 30)
                                    .background(Color("SecondaryColor"))
                                    .clipShape(Circle())
                            }

                            TextField("", text: $numberString)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .font(.title2)
                                .fontWeight(.bold)
                                .frame(width: 60)
                                .textFieldStyle(PlainTextFieldStyle())

                            Button(action: {
                                if let current = Int(numberString) {
                                    numberString = "\(current + 1)"
                                } else {
                                    numberString = "1"
                                }
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(Color("PrimaryColor"))
                                    .frame(width: 30, height: 30)
                                    .background(Color("SecondaryColor"))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.bottom)

                        if let label = descriptionLabel, !label.isEmpty {
                            Text(label)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .foregroundColor(Color("SecondaryColor"))
                        }

                        if showTextEditor {
                            AutoGrowingTextEditor(text: $generalDescription, placeholder: placeholderText ?? "")
                        }

                        if let label = descriptionLabel2, !label.isEmpty {
                            Text(label)
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal)
                                .foregroundColor(Color("SecondaryColor"))
                        }

                        if showTextEditor2 {
                            AutoGrowingTextEditor(text: $generalDescription2, placeholder: placeholderText2 ?? "")
                        }

                        if let disclaimer = disclaimerText, !disclaimer.isEmpty {
                            Text(disclaimer)
                                .font(.footnote)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal)
                                .padding(.top, 8)
                        }

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
                                    if let validNumber = Int(numberString), validNumber >= 0 {
                                        number = validNumber
                                        nextAction()
                                    } else {
                                        showAlert = true
                                    }
                                }
                                .foregroundColor(Color("PrimaryColor"))
                                .fontWeight(.bold)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color("SecondaryColor")))
                                .alert(isPresented: $showAlert) {
                                    Alert(title: Text("Invalid Input"), message: Text("Please enter a valid number."), dismissButton: .default(Text("OK")))
                                }
                            }
                            .padding(.top)
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
                                    if let validNumber = Int(numberString), validNumber >= 0 {
                                        number = validNumber
                                        showSuccessAlert = true
                                        nextAction()
                                    } else {
                                        showAlert = true
                                    }
                                }
                                .foregroundColor(Color("PrimaryColor"))
                                .fontWeight(.bold)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color("SecondaryColor")))
                            }
                            .padding(.top)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Interaction Log")
        .frame(width: tileWidth, height: tileHeight)
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Updated"),
                message: Text("Interaction Log was successfully updated."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .onAppear {
            numberString = String(number) // Sync on load
        }

        if showProgressBar {
            SegmentedProgressBar(
                totalSegments: totalQuestions,
                filledSegments: questionNumber,
                tileWidth: tileWidth
            )
            Text(NSLocalizedString("progress", comment: ""))
                .font(.footnote)
                .padding(.top, 4)
                .fontWeight(.bold)
        }
    }
}
