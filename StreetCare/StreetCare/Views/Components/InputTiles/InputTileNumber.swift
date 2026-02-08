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
    // Optional two-line header shown above the first notes editor.
    // When provided, this header is used instead of descriptionLabel.
    var editorHeaderLine1: String?
    var editorHeaderLine2: String?
    var disclaimerText: String?
    var placeholderText: String?
    var placeholderText2: String?
    
    @Binding var number: Int
    @State private var numberString: String
    // NEW: Optional second number binding for two-question screens
    @Binding var number2: Int?
    @State private var numberString2: String = ""
    // Mode flag: when true, show Question1 + stepper, then Question2 + stepper
    var dualNumberMode: Bool = false
    
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
        editorHeaderLine1: String? = nil,   // NEW
        editorHeaderLine2: String? = nil,    // NEW
        disclaimerText: String? = nil,
        placeholderText: String? = nil,
        placeholderText2: String? = nil,
        number: Binding<Int>,
        number2: Binding<Int?> = .constant(nil),      // NEW: optional binding (defaults to nil)
        dualNumberMode: Bool = false,                 // NEW: mode flag (defaults to false)
        showTextEditor: Bool = true,                    //New: added to set texteditor false in case 5
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
        self.editorHeaderLine1 = editorHeaderLine1
        self.editorHeaderLine2 = editorHeaderLine2
        self.disclaimerText = disclaimerText
        self.placeholderText = placeholderText
        self.placeholderText2 = placeholderText2
        self._number = number
        self._numberString = State(initialValue: String(number.wrappedValue))
        // NEW: Initialize second number binding and string
        self._number2 = number2
        self._numberString2 = State(initialValue: number2.wrappedValue != nil ? String(number2.wrappedValue!) : "0")
        self._generalDescription = generalDescription
        self._generalDescription2 = generalDescription2
        self.nextAction = nextAction
        self.previousAction = previousAction
        self.skipAction = skipAction
        self.showProgressBar = showProgressBar
        self.showTextEditor = showTextEditor
        self.showTextEditor2 = showTextEditor2
        self.buttonMode = buttonMode
        self.dualNumberMode = dualNumberMode // NEW: Set dual number mode
    }
    
    // MARK: - Reusable Number Stepper Component
    // This function creates a reusable +/- stepper UI for any number value
    private func numberStepper(value: Binding<String>) -> some View {
        HStack(spacing: 20) {
            // Minus button - decrements the number (minimum 0)
            Button(action: {
                if let current = Int(value.wrappedValue), current > 0 {
                    value.wrappedValue = "\(current - 1)"
                }
            }) {
                Image(systemName: "minus")
                    .foregroundColor(Color("PrimaryColor"))
                    .frame(width: 30, height: 30)
                    .background(Color("SecondaryColor"))
                    .clipShape(Circle())
            }

            // Number text field (center-aligned, number pad keyboard)
            TextField("", text: value)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.title2)
                .fontWeight(.bold)
                .frame(width: 60)
                .textFieldStyle(PlainTextFieldStyle())

            // Plus button - increments the number
            Button(action: {
                if let current = Int(value.wrappedValue) {
                    value.wrappedValue = "\(current + 1)"
                } else {
                    value.wrappedValue = "1"
                }
            }) {
                Image(systemName: "plus")
                    .foregroundColor(Color("PrimaryColor"))
                    .frame(width: 30, height: 30)
                    .background(Color("SecondaryColor"))
                    .clipShape(Circle())
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if buttonMode == .update {
                Text("Edit Your Interaction")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
            }
            if showProgressBar {
                SegmentedProgressBar(
                    totalSegments: totalQuestions,
                    filledSegments: questionNumber,
                    tileWidth: tileWidth
                )
                .padding(.top, 36)
                .padding(.bottom, 36)
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
                        // Check if we need TWO number pickers or ONE
                        if dualNumberMode {
                            VStack(spacing: 18) { // space between the two sections
                                // FIRST SECTION
                                VStack(spacing: 0) {
                                    // Header (one line)
                                    VStack(spacing: 4) {
                                        Text(question1)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                    }
                                    
                                    numberStepper(value: $numberString)
                                    .padding(.top, 18)   // space from header to stepper
                                    .padding(.bottom, 14) // slight breathing room after stepper
                                }

                                // SECOND SECTION
                                VStack(spacing: 0) {
                                    // Header (two lines)
                                    VStack(spacing: 4) {
                                        Text(question2)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                        if !question3.isEmpty {
                                            Text(question3)
                                                .font(.title2)
                                                .fontWeight(.bold)
                                        }
                                    }

                                    numberStepper(value: $numberString2)
                                    .padding(.top, 18)   // space from header to stepper
                                    .padding(.bottom, 0) // slight breathing room after stepper
                                }
                            }
                            .padding(.top, 17)
                            .padding(.bottom, 0)
                        } else{
                            VStack(spacing: 4) {
                                Text(question1).font(.title2).fontWeight(.bold)
                                if !question2.isEmpty {
                                    Text(question2).font(.title2).fontWeight(.bold)
                                }
                                if !question3.isEmpty {
                                    Text(question3).font(.title2).fontWeight(.bold)
                                }
                                if !question4.isEmpty {
                                    Text(question4).font(.title2).fontWeight(.bold)
                                }
                            }
                            .padding(.vertical)
                            // Single number stepper for default behavior
                            numberStepper(value: $numberString)
                        }
                        // Prefer the custom header if provided; otherwise keep the old descriptionLabel behavior.
                        if let line1 = editorHeaderLine1, !line1.isEmpty {
                            VStack(spacing: 4) {
                                Text(line1)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                if let line2 = editorHeaderLine2, !line2.isEmpty {
                                    Text(line2)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                            }
                            .padding(.vertical)
                        }else if let label = descriptionLabel, !label.isEmpty {
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
                                        // NEW: also handle the second number only when dual mode is on
                                        if dualNumberMode {
                                            if let validNumber2 = Int(numberString2), validNumber2 >= 0 {
                                                number2 = validNumber2
                                            } else {
                                                number2 = 0 // safe fallback when Binding<Int?> is used
                                            }
                                        }
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
                                        // NEW: also handle the second number only when dual mode is on
                                        if dualNumberMode {
                                            if let validNumber2 = Int(numberString2), validNumber2 >= 0 {
                                                number2 = validNumber2
                                            } else {
                                                number2 = 0
                                            }
                                        }
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
//                    .frame(maxHeight: .infinity, alignment: .top)
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
            if let val = number2 {
                numberString2 = String(val)
            }
        }
        Spacer()
    }
}
