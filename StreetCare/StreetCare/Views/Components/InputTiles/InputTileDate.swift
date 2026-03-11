//
////
////  InputTileDate.swift
////  StreetCare
////
////  Created by Michael on 4/19/23.
////
//
//import SwiftUI
//
//
//struct InputTileDate: View {
//
//    var questionNumber: Int
//    var totalQuestions: Int
//    
//    var size = CGSize(width: 360.0, height: 360.0)
//    var question1: String
//    var question2: String
//    var question3: String
//    var showSkip: Bool = true
//    var showProgressBar: Bool = true
//    var buttonMode: ButtonMode = .navigation
//    var isFollowUpDate: Bool = false
//    var initialDateValue: Date = Date()
//
//
//    @Binding var datetimeValue: Date
//    @Binding var convertedDate: Date
//    @State private var selectedTimeZone: String = TimeZone.current.identifier
//    let timeZones = TimeZone.knownTimeZoneIdentifiers.sorted()
//    let usTimeZones = TimeZone.knownTimeZoneIdentifiers
//        .filter { $0.starts(with: "America/") }
//        .sorted()
//    
//    var nextAction: () -> ()
//    var skipAction: () -> ()
//    var previousAction: () -> ()
//    
//    
//    @Environment(\.presentationMode) var presentationMode
//    @State private var showSuccessAlert = false
//    let placeholderDate = Date(timeIntervalSince1970: 0) // Jan 1, 1970
//
//
//    private var dateFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "MM/dd/yyyy"
//        return formatter
//    }
//
//    private var timeFormatter: DateFormatter {
//        let formatter = DateFormatter()
//        formatter.dateFormat = "hh:mm a"
//        return formatter
//    }
//    
//    private func getCalendar(for identifier: String) -> Calendar {
//        var calendar = Calendar.current
//        if let tz = TimeZone(identifier: identifier) {
//            calendar.timeZone = tz
//        }
//        return calendar
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            if buttonMode == .update {
//                Text("Edit Your Interaction")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                //.padding(.top, 16)
//                    .padding(.bottom, 50)
//            }
//            ZStack {
//                BasicTile(size: size)
//                
//                VStack {
//                    if buttonMode == .navigation {
//                        HStack {
//                            Text(NSLocalizedString("question", comment: "") + " \(questionNumber)/\(totalQuestions)")
//                                .foregroundColor(.black)
//                            
//                            Spacer()
//                            
//                            if showSkip {
//                                Button(NSLocalizedString("skip", comment: "")) {
//                                    convertedDate = placeholderDate
//                                    skipAction()
//                                }
//                                .foregroundColor(Color("SecondaryColor"))
//                                .font(.footnote)
//                                .padding(.horizontal, 16)
//                                .padding(.vertical, 8)
//                                .background(Capsule().fill(Color.white))
//                                .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
//                            }
//                        }
//                        .padding(.horizontal)
//                        .padding(.top, 12)
//                        
//                        Divider()
//                            .background(Color.gray.opacity(0.3))
//                            .padding(.horizontal)
//                    }
//                    
//                    VStack {
//                        Text(question1).font(.title2).fontWeight(.bold)
//                        Text(question2).font(.title2).fontWeight(.bold)
//                        Text(question3).font(.title2).fontWeight(.bold)
//                    }
//                    .padding(.bottom, 12)
//                    
//                    if buttonMode == .navigation{
//                        Spacer()
//                    }
//                    
//                    HStack(spacing: 12) {
//                        // Date Picker Box
//                        HStack(spacing: 8) {
//                            Image(systemName: "calendar")
//                                .foregroundColor(.black)
//                            
//                            // Replace this:
//                            DatePicker(
//                                "",
//                                selection: $datetimeValue,
//                                displayedComponents: [.date]
//                            )
//                            .labelsHidden()
//                            .datePickerStyle(.compact)
//                            .environment(\.calendar, getCalendar(for: selectedTimeZone)) // This fixes the visual shift
//                            
//                        }
//                        .padding(.leading, 12)
//                        .padding(.vertical, 10)
//                        .frame(width: 175, alignment: .leading)
//                        .background(Color.white)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.black, lineWidth: 1)
//                        )
//                        .cornerRadius(10)
//                        
//                        // Time Picker Box
//                        HStack(spacing: 8) {
//                            Image(systemName: "clock")
//                                .foregroundColor(.black)
//                            
//                            DatePicker(
//                                "",
//                                selection: $datetimeValue,
//                                displayedComponents: [.hourAndMinute]
//                            )
//                            .labelsHidden()
//                            .datePickerStyle(.compact)
//                            .environment(\.calendar, getCalendar(for: selectedTimeZone)) // This fixes the visual shift
//                            
//                        }
//                        .padding(.leading, 12)
//                        .padding(.vertical, 10)
//                        .frame(width: 140, alignment: .leading)
//                        .background(Color.white)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.black, lineWidth: 1)
//                        )
//                        .cornerRadius(10)
//                    }
//                    .frame(width: 335)
//                    .padding(.horizontal)
//                    
//                    if buttonMode == .navigation{
//                        Spacer()
//                    }
//                    Menu {
//                        Picker("Time Zone", selection: $selectedTimeZone) {
//                            ForEach(usTimeZones, id: \.self) { zone in
//                                Text("\(zone.replacingOccurrences(of: "America/", with: "").replacingOccurrences(of: "_", with: " ")) (\(TimeZone(identifier: zone)?.abbreviation() ?? ""))")
//                                    .tag(zone)
//                            }
//                        }
//                    } label: {
//                        HStack(spacing: 8) {
//                            Image(systemName: "globe")
//                                .foregroundColor(.black)
//                            
//                            Text("\(selectedTimeZone.replacingOccurrences(of: "America/", with: "").replacingOccurrences(of: "_", with: " ")) (\(TimeZone(identifier: selectedTimeZone)?.abbreviation() ?? ""))")
//                                .foregroundColor(.black)
//                                .font(.body)
//                                .lineLimit(1)
//                            
//                            Spacer()
//                            
//                            Image(systemName: "triangle.fill")
//                                .resizable()
//                                .frame(width: 8, height: 6)
//                                .rotationEffect(.degrees(180))
//                                .foregroundColor(.black)
//                        }
//                        //.padding(.horizontal)
//                        //.padding(.vertical, 6)
//                        .padding()
//                        .background(Color.white)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.black, lineWidth: 1)
//                        )
//                        .cornerRadius(10)
//                        .frame(width: 335, alignment: .leading)
//                        .padding(.horizontal)
//                    }
//                    
//                    if buttonMode == .navigation {
//                        HStack {
//                            Button(NSLocalizedString("previous", comment: "")) {
//                                previousAction()
//                            }
//                            .foregroundColor(Color("SecondaryColor"))
//                            .font(.footnote)
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 8)
//                            .background(Capsule().fill(Color.white))
//                            .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
//                            
//                            Spacer()
//                            
//                            Button(" " + NSLocalizedString("next", comment: "") + " ") {
//                                if let converted = convertToCurrentTimeZone(from: datetimeValue, selectedTimeZoneID: selectedTimeZone) {
//                                    convertedDate = converted
//                                    
//                                    // This will print the raw UTC value to your Xcode console
//                                    print("---------- TIMEZONE DEBUG ----------")
//                                    print("Selected Timezone: \(selectedTimeZone)")
//                                    print("Local Input Time:  \(datetimeValue)")
//                                    print("Final UTC to Save: \(converted)")
//                                    print("------------------------------------")
//                                    
//                                } else {
//                                    convertedDate = datetimeValue
//                                }
//                                nextAction()
//                            }
//                            
//                            .foregroundColor(Color("PrimaryColor"))
//                            .fontWeight(.bold)
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 8)
//                            .background(Capsule().fill(Color("SecondaryColor")))
//                        }
//                        .padding()
//                    } else if buttonMode == .update {
//                        HStack {
//                            Button("Cancel") {
//                                presentationMode.wrappedValue.dismiss()
//                            }
//                            .foregroundColor(Color("SecondaryColor"))
//                            .font(.footnote)
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 8)
//                            .background(Capsule().fill(Color.white))
//                            .overlay(Capsule().stroke(Color("SecondaryColor"), lineWidth: 2))
//                            
//                            Spacer()
//                            
//                            Button("Update") {
//                                // Single source of truth for conversion
//                                if let converted = convertToCurrentTimeZone(from: datetimeValue, selectedTimeZoneID: selectedTimeZone) {
//                                    convertedDate = converted
//                                } else {
//                                    convertedDate = datetimeValue
//                                }
//                                showSuccessAlert = true
//                                // We call nextAction here because in the Edit flow it handles the save trigger
//                                nextAction()
//                            }
//                            .foregroundColor(Color("PrimaryColor"))
//                            .fontWeight(.bold)
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 8)
//                            .background(Capsule().fill(Color("SecondaryColor")))
//                        }
//                        .padding()
//                    }
//                }
//            }
//        }
//        .navigationBarTitleDisplayMode(.inline)
//        .navigationTitle("Interaction Log")
//        .onChange(of: selectedTimeZone) { newValue in
//            
//            if let converted = convertToCurrentTimeZone(from: datetimeValue, selectedTimeZoneID: newValue) {
//                let formatter = DateFormatter()
//                formatter.dateStyle = .medium
//                formatter.timeStyle = .medium
//                formatter.timeZone = TimeZone.current
//            }
//        }
//        .frame(width: size.width, height: size.height)
//        .alert(isPresented: $showSuccessAlert) {
//            Alert(
//                title: Text("Updated"),
//                message: Text("Interaction log was successfully updated."),
//                dismissButton: .default(Text("OK")) {
//                    presentationMode.wrappedValue.dismiss()
//                }
//            )
//        }
//        .frame(width: size.width, height: size.height)
//        
//        if showProgressBar {
//            SegmentedProgressBar(
//                totalSegments: totalQuestions,
//                filledSegments: questionNumber,
//                tileWidth: 350
//            )
//            
//            Text(NSLocalizedString("progress", comment: ""))
//                .font(.footnote)
//                .padding(.top, 4)
//                .fontWeight(.bold)
//        }
//    }
//              // Function to get the current time zone abbreviation (e.g., CST, EST, PST)
//        func getTimeZoneAbbreviation() -> String {
//            return TimeZone.current.abbreviation() ?? "UTC"
//        }
//}
//
//func convertToCurrentTimeZone(from date: Date, selectedTimeZoneID: String) -> Date? {
//    guard let selectedTimeZone = TimeZone(identifier: selectedTimeZoneID) else {
//        print("❌ Invalid Time Zone Identifier")
//        return nil
//    }
//
//    let currentTimeZone = TimeZone.current
//
//    let selectedOffset = TimeInterval(selectedTimeZone.secondsFromGMT(for: date))
//    let currentOffset = TimeInterval(currentTimeZone.secondsFromGMT(for: date))
//
//    // Adjust the date by the difference in offsets
//    // Corrected logic:
//    let timeDifference = selectedOffset - currentOffset
//    return date.addingTimeInterval(-timeDifference)
//}
//struct InputTileDate_Previews: PreviewProvider {
//
//    @State static var input = Date()
//
//    static var previews: some View {
//        InputTileDate(
//            questionNumber: 3,
//            totalQuestions: 4,
//            question1: "Is there a planned date to",
//            question2: "interact with them again?",
//            question3: "",
//            showSkip: true,
//            datetimeValue: $input,
//            convertedDate: $input,
//            nextAction: {},
//            skipAction: {},
//            previousAction: {}
//        )
//    }
//}
//

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
    
    var size = CGSize(width: 360.0, height: 360.0)
    var question1: String
    var question2: String
    var question3: String
    var showSkip: Bool = true
    var showProgressBar: Bool = true
    var buttonMode: ButtonMode = .navigation
    var isFollowUpDate: Bool = false
    var initialDateValue: Date = Date()

    @Binding var datetimeValue: Date
    @Binding var convertedDate: Date
    
    // CHANGED: Added default value so it doesn't break other files
    @State private var selectedTimeZone: String = TimeZone.current.identifier
    
    let timeZones = TimeZone.knownTimeZoneIdentifiers.sorted()
    let usTimeZones = TimeZone.knownTimeZoneIdentifiers
        .filter { $0.starts(with: "America/") }
        .sorted()
    
    var nextAction: () -> ()
    var skipAction: () -> ()
    var previousAction: () -> ()
    
    @Environment(\.presentationMode) var presentationMode
    @State private var showSuccessAlert = false
    let placeholderDate = Date(timeIntervalSince1970: 0) // Jan 1, 1970

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter
    }
    
    private func getCalendar(for identifier: String) -> Calendar {
        var calendar = Calendar.current
        if let tz = TimeZone(identifier: identifier) {
            calendar.timeZone = tz
        }
        return calendar
    }
    
    private func getGMTOffset(for identifier: String) -> String {
        guard let tz = TimeZone(identifier: identifier) else { return "GMT" }
        let seconds = tz.secondsFromGMT()
        let hours = seconds / 3600
        let sign = hours >= 0 ? "+" : "-"
        return "GMT \(sign)\(abs(hours))"
    }

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
                        .padding(.top, 12)
                        
                        Divider()
                            .background(Color.gray.opacity(0.3))
                            .padding(.horizontal)
                    }
                    
                    VStack {
                        Text(question1).font(.title2).fontWeight(.bold)
                        Text(question2).font(.title2).fontWeight(.bold)
                        Text(question3).font(.title2).fontWeight(.bold)
                    }
                    .padding(.bottom, 12)
                    
                    if buttonMode == .navigation {
                        Spacer()
                    }
                    
                    HStack(spacing: 12) {
                        // Date Picker Box
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
                            .environment(\.calendar, getCalendar(for: selectedTimeZone))
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
                        
                        // Time Picker Box - Revised for Static Timezone
                        // Time Picker Box with GMT Offset
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .foregroundColor(.black)

                                DatePicker(
                                    "",
                                    selection: $datetimeValue,
                                    displayedComponents: [.hourAndMinute]
                                )
                                .labelsHidden()
                                .datePickerStyle(.compact)
                                .environment(\.calendar, getCalendar(for: selectedTimeZone))
                            }
                            
                            // THE GMT OFFSET LABEL - Black color for visibility
                            Text(getGMTOffset(for: selectedTimeZone))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.black)
                                .padding(.leading, 24)
                        }
                        .padding(.leading, 12)
                        .padding(.vertical, 8)
                        .frame(width: 160, alignment: .leading)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .cornerRadius(10)                    }
                    .frame(width: 335)
                    .padding(.horizontal)
                    
                    if buttonMode == .navigation {
                        Spacer()
                    }
                    
                    // REMOVED: The old Interactive Timezone Menu is gone from here.

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
                                processDateConversion()
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
                                processDateConversion()
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
    
    private func processDateConversion() {
        if let converted = convertToCurrentTimeZone(from: datetimeValue, selectedTimeZoneID: selectedTimeZone) {
            convertedDate = converted
        } else {
            convertedDate = datetimeValue
        }
    }
}

func convertToCurrentTimeZone(from date: Date, selectedTimeZoneID: String) -> Date? {
    guard let selectedTimeZone = TimeZone(identifier: selectedTimeZoneID) else {
        return nil
    }
    let currentTimeZone = TimeZone.current
    let selectedOffset = TimeInterval(selectedTimeZone.secondsFromGMT(for: date))
    let currentOffset = TimeInterval(currentTimeZone.secondsFromGMT(for: date))
    let timeDifference = selectedOffset - currentOffset
    return date.addingTimeInterval(-timeDifference)
}

struct InputTileDate_Previews: PreviewProvider {
    @State static var input = Date()
    static var previews: some View {
        InputTileDate(
            questionNumber: 3,
            totalQuestions: 4,
            question1: "Is there a planned date to",
            question2: "interact with them again?",
            question3: "",
            showSkip: true,
            datetimeValue: $input,
            convertedDate: $input,
            nextAction: {},
            skipAction: {},
            previousAction: {}
        )
    }
}
