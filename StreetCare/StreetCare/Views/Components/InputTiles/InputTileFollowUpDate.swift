//
//  InputTileFollowUpDate.swift
//  StreetCare
//
//  Created by Daivik Girish on 3/11/25.
//


import SwiftUI

struct InputTileFollowUpDate: View {

    var questionNumber: Int
    var totalQuestions: Int

    var size = CGSize(width: 360.0, height: 500.0)

    var question1: String
    var question2: String

    var showSkip: Bool = true
    var showProgressBar: Bool = true
    var buttonMode: ButtonMode = .navigation
    var isFollowUpDate: Bool = false
    var initialDateValue: Date = Date()

    @Binding var datetimeValue: Date
    @Binding var convertedDate: Date
    @Binding var additionalDetails: String

    var nextAction: () -> ()
    var skipAction: () -> ()
    var previousAction: () -> ()

    @Environment(\.presentationMode) var presentationMode
    @State private var showSuccessAlert = false
    let placeholderDate = Date(timeIntervalSince1970: 0) // Jan 1, 1970

    var body: some View {
        VStack(spacing: 0) {
            if buttonMode == .update {
                Text("Edit Your Interaction")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.bottom, 50)
            }

            ZStack {
                BasicTile(size: size)

                VStack {
                    if buttonMode == .navigation {
                        HStack {
                            Text(NSLocalizedString("question", comment: "") + " \(questionNumber)/\(totalQuestions)")
                                .foregroundColor(.black)

                            Spacer()

                            if showSkip {
                                Button(NSLocalizedString("skip", comment: "")) {
                                    convertedDate = placeholderDate
                                    skipAction()
                                }
                                .foregroundColor(Color("SecondaryColor"))
                                .font(.footnote)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(Color.white))
                                .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)

                        Divider()
                            .background(Color.gray.opacity(0.3))
                            .padding(.horizontal)
                    }

                    // Titles
                    VStack {
                        Text(question1).font(.title2).fontWeight(.bold).padding(.top, 6).padding(.bottom, 6)
                    }

                    // Date + Time row
                    HStack(spacing: 12) {
                        // Date
                        HStack(spacing: 8) {
                            Image(systemName: "calendar")
                                .foregroundColor(.black)

                            DatePicker(
                                "",
                                selection: $datetimeValue,
                                displayedComponents: [.date]
                            )
                            .labelsHidden()
                            .datePickerStyle(.compact)
                        }
                        .padding(.leading, 12)
                        .padding(.vertical, 10)
                        .frame(width: 175, alignment: .leading)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .cornerRadius(10)

                        // Time
                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .foregroundColor(.black)

                            DatePicker(
                                "",
                                selection: $datetimeValue,
                                displayedComponents: [.hourAndMinute]
                            )
                            .labelsHidden()
                            .datePickerStyle(.compact)
                        }
                        .padding(.leading, 12)
                        .padding(.vertical, 10)
                        .frame(width: 140, alignment: .leading)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .cornerRadius(10)
                    }
                    .frame(width: 335)
                    .padding(.horizontal)
                    
                    VStack {
                        Text(question2).font(.title2).fontWeight(.bold)
                    }
                    .padding(.bottom, 12).padding(.top, 10)
                    
                    // Text box: Any additional details
                    VStack(alignment: .leading, spacing: 8) {

                        TextEditor(text: $additionalDetails)
                            .frame(height: 120)
                            .padding(8)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                            .cornerRadius(10)
                    }
                    .frame(width: 335)
                    .padding(.horizontal)
                    .padding(.top, 12)

                    // Navigation buttons
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
                                // Persist the selected date/time as-is
                                if isFollowUpDate &&
                                   Calendar.current.isDate(datetimeValue, equalTo: initialDateValue, toGranularity: .minute) {
                                    convertedDate = datetimeValue
                                } else {
                                    convertedDate = datetimeValue
                                }
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
                                convertedDate = datetimeValue
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Interaction Log")
        .frame(width: size.width, height: size.height)
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Updated"),
                message: Text("Interaction log was successfully updated."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }

        if showProgressBar {
            SegmentedProgressBar(
                totalSegments: totalQuestions,
                filledSegments: questionNumber,
                tileWidth: 350
            )
            Text(NSLocalizedString("progress", comment: ""))
                .font(.footnote)
                .padding(.top, 4)
                .fontWeight(.bold)
        }
    }
}
