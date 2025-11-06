//
//  InputTileDate.swift
//  StreetCare
//
//  Created by Michael on 4/19/23.
//

import SwiftUI

struct InputTileDate: View {

    var questionNumber: Int
    var totalQuestions: Int

    // compact tile to match Figma
    var size = CGSize(width: 360.0, height: 360.0)

    var question1: String
    var question2: String
    var question3: String
    var showSkip: Bool = true
    var showProgressBar: Bool = true
    var buttonMode: ButtonMode = .navigation
    var isFollowUpDate: Bool = false
    var initialDateValue: Date = Date()

    // START: existing start-date binding (keeps backwards compatibility)
    @Binding var datetimeValue: Date
    @Binding var convertedDate: Date

    // NEW: optional end-date binding with default constant so existing call-sites don't break.
    // If you want persistence for end time, pass a real binding (e.g. $visitLog.whenVisitEnd).
    var initialEndDate: Date = Date()
    @State private var endDateState: Date = Date()
    var convertedEndDate: Binding<Date> = .constant(Date(timeIntervalSince1970: 0))

    @State private var selectedTimeZone: String = TimeZone.current.identifier
    let usTimeZones = TimeZone.knownTimeZoneIdentifiers
        .filter { $0.starts(with: "America/") }
        .sorted()

    var nextAction: () -> ()
    var skipAction: () -> ()
    var previousAction: () -> ()

    @Environment(\.presentationMode) var presentationMode
    @State private var showSuccessAlert = false
    let placeholderDate = Date(timeIntervalSince1970: 0) // Jan 1, 1970

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter
    }

    // Custom init to support optional convertedEndDate default
    init(questionNumber: Int,
         totalQuestions: Int,
         size: CGSize = CGSize(width: 360.0, height: 360.0),
         question1: String,
         question2: String,
         question3: String = "",
         showSkip: Bool = true,
         showProgressBar: Bool = true,
         buttonMode: ButtonMode = .navigation,
         isFollowUpDate: Bool = false,
         initialDateValue: Date = Date(),
         datetimeValue: Binding<Date>,
         convertedDate: Binding<Date>,
         initialEndDate: Date = Date(),
         convertedEndDate: Binding<Date>? = nil,
         nextAction: @escaping () -> (),
         skipAction: @escaping () -> (),
         previousAction: @escaping () -> ()
    ) {
        self.questionNumber = questionNumber
        self.totalQuestions = totalQuestions
        self.size = size
        self.question1 = question1
        self.question2 = question2
        self.question3 = question3
        self.showSkip = showSkip
        self.showProgressBar = showProgressBar
        self.buttonMode = buttonMode
        self.isFollowUpDate = isFollowUpDate
        self.initialDateValue = initialDateValue

        self._datetimeValue = datetimeValue
        self._convertedDate = convertedDate

        self.initialEndDate = initialEndDate
        self._endDateState = State(initialValue: initialEndDate)

        // If caller provided a binding for convertedEndDate, use it; otherwise use a constant binding.
        if let providedEndBinding = convertedEndDate {
            self.convertedEndDate = providedEndBinding
        } else {
            self.convertedEndDate = .constant(Date(timeIntervalSince1970: 0))
        }

        self.nextAction = nextAction
        self.skipAction = skipAction
        self.previousAction = previousAction
    }

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar placed above the card (Figma)
            if showProgressBar {
                SegmentedProgressBar(
                    totalSegments: totalQuestions,
                    filledSegments: questionNumber,
                    tileWidth: size.width
                )
                .padding(.top, 8)
                .padding(.bottom, 6)

                Text(NSLocalizedString("progress", comment: ""))
                    .font(.footnote)
                    .fontWeight(.bold)
                    .padding(.bottom, 6)
            }

            ZStack {
                BasicTile(size: size, cornerRadius: 12)

                VStack(spacing: 0) {
                    // top small question row inside the card
                    HStack {
                        Text(NSLocalizedString("question", comment: "") + " \(questionNumber)/\(totalQuestions)")
                            .foregroundColor(.black)
                            .font(.subheadline)
                        Spacer()
                        if showSkip && buttonMode == .navigation {
                            Button(NSLocalizedString("skip", comment: "")) {
                                convertedDate = placeholderDate
                                // also clear end binding if writable
                                convertedEndDate.wrappedValue = Date(timeIntervalSince1970: 0)
                                skipAction()
                            }
                            .foregroundColor(Color("SecondaryColor"))
                            .font(.footnote)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.white))
                            .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 10)

                    Divider()
                        .background(Color.gray.opacity(0.25))
                        .padding(.horizontal, 8)
                        .padding(.top, 6)

                    // Big title (centered)
                    VStack(spacing: 6) {
                        Text(question1).font(.title2).fontWeight(.bold).multilineTextAlignment(.center)
                        Text(question2).font(.title2).fontWeight(.bold).multilineTextAlignment(.center)
                        if !question3.isEmpty { Text(question3).font(.title2).fontWeight(.bold).multilineTextAlignment(.center) }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 6)
                    .frame(maxWidth: .infinity)

                    Spacer()

                    // START: Start time row (label + date/time pickers)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start Time:")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 18)

                        HStack(spacing: 16) {
                            // Date box (start)
                            HStack(spacing: 10) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.black)
                                    .padding(.leading, 8)
                                DatePicker("", selection: $datetimeValue, displayedComponents: [.date])
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                    .padding(.vertical, 10)
                            }
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                            .cornerRadius(10)
                            .frame(width: 180)

                            // Time box (start)
                            HStack(spacing: 10) {
                                Image(systemName: "clock")
                                    .foregroundColor(.black)
                                    .padding(.leading, 8)
                                DatePicker("", selection: $datetimeValue, displayedComponents: [.hourAndMinute])
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                    .padding(.vertical, 10)
                            }
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                            .cornerRadius(10)
                            .frame(width: 140)
                        }
                        .padding(.horizontal, 18)
                    }

                    Spacer().frame(height: 12)

                    // END: End time row (label + date/time pickers)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("End Time:")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 18)

                        HStack(spacing: 16) {
                            // Date box (end)
                            HStack(spacing: 10) {
                                Image(systemName: "calendar")
                                    .foregroundColor(.black)
                                    .padding(.leading, 8)
                                DatePicker("", selection: $endDateState, displayedComponents: [.date])
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                    .padding(.vertical, 10)
                            }
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                            .cornerRadius(10)
                            .frame(width: 180)

                            // Time box (end)
                            HStack(spacing: 10) {
                                Image(systemName: "clock")
                                    .foregroundColor(.black)
                                    .padding(.leading, 8)
                                DatePicker("", selection: $endDateState, displayedComponents: [.hourAndMinute])
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                    .padding(.vertical, 10)
                            }
                            .background(Color.white)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                            .cornerRadius(10)
                            .frame(width: 140)
                        }
                        .padding(.horizontal, 18)
                    }

                    Spacer().frame(height: 12)

                    // Timezone dropdown (applies visually; we use selectedTimeZone for conversions)
                    Menu {
                        Picker("Time Zone", selection: $selectedTimeZone) {
                            ForEach(usTimeZones, id: \.self) { zone in
                                Text("\(zone.replacingOccurrences(of: "America/", with: "").replacingOccurrences(of: "_", with: " ")) (\(TimeZone(identifier: zone)?.abbreviation() ?? ""))")
                                    .tag(zone)
                            }
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "globe")
                                .foregroundColor(.black)
                            Text("\(selectedTimeZone.replacingOccurrences(of: "America/", with: "").replacingOccurrences(of: "_", with: " ")) (\(TimeZone(identifier: selectedTimeZone)?.abbreviation() ?? ""))")
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            Spacer()
                            Image(systemName: "triangle.fill")
                                .resizable()
                                .frame(width: 8, height: 6)
                                .rotationEffect(.degrees(180))
                                .foregroundColor(.black)
                        }
                        .padding()
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.5), lineWidth: 1))
                        .cornerRadius(10)
                        .padding(.horizontal, 20)
                    }

                    Spacer()

                    // Buttons: show only Next centered for question 1; otherwise Prev + Next
                    if buttonMode == .navigation {
                        if questionNumber == 1 {
                            // Centered Next only
                            HStack {
                                Spacer()
                                Button(" " + NSLocalizedString("next", comment: "") + " ") {
                                    // Update converted start date
                                    if let converted = convertToCurrentTimeZone(from: datetimeValue, selectedTimeZoneID: selectedTimeZone) {
                                        if isFollowUpDate &&
                                           selectedTimeZone == TimeZone.current.identifier &&
                                           Calendar.current.isDate(datetimeValue, equalTo: initialDateValue, toGranularity: .minute) {
                                            convertedDate = placeholderDate
                                        } else {
                                            convertedDate = converted
                                        }
                                    } else {
                                        convertedDate = datetimeValue
                                    }

                                    // Update converted end date if binding writable
                                    if let convertedEnd = convertToCurrentTimeZone(from: endDateState, selectedTimeZoneID: selectedTimeZone) {
                                        convertedEndDate.wrappedValue = convertedEnd
                                    } else {
                                        convertedEndDate.wrappedValue = endDateState
                                    }

                                    nextAction()
                                }
                                .foregroundColor(Color("PrimaryColor"))
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Capsule().fill(Color("SecondaryColor")))
                                .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 2)
                                Spacer()
                            }
                            .padding([.horizontal, .bottom], 18)
                        } else {
                            // Prev + Next
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
                                    if let converted = convertToCurrentTimeZone(from: datetimeValue, selectedTimeZoneID: selectedTimeZone) {
                                        if isFollowUpDate &&
                                           selectedTimeZone == TimeZone.current.identifier &&
                                           Calendar.current.isDate(datetimeValue, equalTo: initialDateValue, toGranularity: .minute) {
                                            convertedDate = placeholderDate
                                        } else {
                                            convertedDate = converted
                                        }
                                    } else {
                                        convertedDate = datetimeValue
                                    }

                                    if let convertedEnd = convertToCurrentTimeZone(from: endDateState, selectedTimeZoneID: selectedTimeZone) {
                                        convertedEndDate.wrappedValue = convertedEnd
                                    } else {
                                        convertedEndDate.wrappedValue = endDateState
                                    }

                                    nextAction()
                                }
                                .foregroundColor(Color("PrimaryColor"))
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(Capsule().fill(Color("SecondaryColor")))
                                .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 2)
                            }
                            .padding([.horizontal, .bottom], 18)
                        }
                    }

                } // VStack inside card
                .frame(width: size.width - 18, height: size.height - 18)
            } // ZStack (card)
            .frame(width: size.width, height: size.height)
            .padding(.bottom, 8)
        } // outer VStack
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Interaction Log")
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Updated"),
                message: Text("Interaction log was successfully updated."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        // Keep pickers in sync with model and convert on change
        .onAppear {
            if convertedDate.timeIntervalSince1970 > 0 {
                datetimeValue = convertedDate
            }
            // prefill end date if user passed a meaningful convertedEndDate
            if convertedEndDate.wrappedValue.timeIntervalSince1970 > 0 {
                endDateState = convertedEndDate.wrappedValue
            }
        }
        .onChange(of: datetimeValue) { newValue in
            if let converted = convertToCurrentTimeZone(from: newValue, selectedTimeZoneID: selectedTimeZone) {
                convertedDate = converted
            } else {
                convertedDate = newValue
            }
        }
        .onChange(of: endDateState) { newValue in
            if let converted = convertToCurrentTimeZone(from: newValue, selectedTimeZoneID: selectedTimeZone) {
                convertedEndDate.wrappedValue = converted
            } else {
                convertedEndDate.wrappedValue = newValue
            }
        }
    } // body
} // struct

// reuse convert function unchanged
func convertToCurrentTimeZone(from date: Date, selectedTimeZoneID: String) -> Date? {
    guard let selectedTimeZone = TimeZone(identifier: selectedTimeZoneID) else {
        print("❌ Invalid Time Zone Identifier")
        return nil
    }
    let currentTimeZone = TimeZone.current
    let selectedOffset = TimeInterval(selectedTimeZone.secondsFromGMT(for: date))
    let currentOffset = TimeInterval(currentTimeZone.secondsFromGMT(for: date))
    let timeDifference = currentOffset - selectedOffset
    return date.addingTimeInterval(timeDifference)
}

struct InputTileDate_Previews: PreviewProvider {
    @State static var input = Date()
    static var previews: some View {
        InputTileDate(
            questionNumber: 1,
            totalQuestions: 6,
            question1: "When was your",
            question2: "Interaction?",
            question3: "",
            showSkip: false,
            datetimeValue: $input,
            convertedDate: $input,
            nextAction: {},
            skipAction: {},
            previousAction: {}
        )
    }
}
