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
    var disclaimerText: String?
    var placeholderText: String?
    
    @Binding var number: Int
    //@State private var numberString = "0"
    @State private var numberString: String

    @Binding var generalDescription: String
    var showTextEditor: Bool = true
    @State private var showAlert = false
    @State private var showSuccessAlert = false
    @Environment(\.presentationMode) var presentationMode
    
    var nextAction: () -> ()
    var previousAction: () -> ()
    var skipAction: () -> ()
    var showProgressBar: Bool
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
        disclaimerText: String? = nil,
        placeholderText: String? = nil,
        number: Binding<Int>,
        generalDescription: Binding<String>,
        nextAction: @escaping () -> Void,
        previousAction: @escaping () -> Void,
        skipAction: @escaping () -> Void,
        showProgressBar: Bool = true,
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
        self.disclaimerText = disclaimerText
        self.placeholderText = placeholderText
        self._number = number
        self._numberString = State(initialValue: String(number.wrappedValue))
        self._generalDescription = generalDescription
        self.nextAction = nextAction
        self.previousAction = previousAction
        self.skipAction = skipAction
        self.showProgressBar = showProgressBar
        self.buttonMode = buttonMode
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
                BasicTile(size: CGSize(width: tileWidth, height: tileHeight))
                
                VStack {
                    if buttonMode == .navigation{
                        HStack {
                            Text("Question \(questionNumber)/\(totalQuestions)")
                                .foregroundColor(.black)
                            Spacer()
                            Button("Skip") {
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
                    
                    VStack {
                        Text(question1).font(.title2).fontWeight(.bold).padding(.bottom, 1)
                        Text(question2).font(.title2).fontWeight(.bold).padding(.bottom, 1)
                        Text(question3).font(.title2).fontWeight(.bold).padding(.bottom, 1)
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
                        .padding()
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Interaction Log")
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Updated"),
                message: Text("Interaction Log was successfully updated."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss() // 👈 Dismiss this view
                }
            )
        }
        .frame(width: tileWidth, height: tileHeight)
        .onAppear {
            numberString = String(number) // Sync when view appears
        }
        if showProgressBar {
            SegmentedProgressBar(
                totalSegments: totalQuestions,
                filledSegments: questionNumber,
                tileWidth: tileWidth
            )
            Text("Progress")
                .font(.footnote)
                .padding(.top, 4)
                .fontWeight(.bold)
        }
    }
}

// Preview
struct InputTileNumber_Previews: PreviewProvider {
    @State static var number = 3
    @State static var string = "Whats UP"

    static var previews: some View {
        InputTileNumber(
            questionNumber: 2,
            totalQuestions: 6,
            tileWidth: 320,
            tileHeight: 560,
            question1: "Describe who you",
            question2: "supported and how",
            question3: "many individuals",
            question4: "were involved.",
            descriptionLabel: "Description",
            disclaimerText: "Note: Avoid personal identifiers in your response.",
            placeholderText: "E.g., Two elderly individuals needing assistance",
            number: $number,
            generalDescription: $string,
            nextAction: {},
            previousAction: {},
            skipAction: {}
        )
    }
}
