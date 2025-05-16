
//
//  InputTileDate.swift
//  StreetCare
//
//  Created by Michael on 4/19/23.
//

import SwiftUI

/*enum ButtonMode {
    case navigation  // Shows Previous & Next
    case update      // Shows Update & Cancel
}*/

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
    
    @Binding var datetimeValue: Date
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

    var body: some View {
        ZStack {
            BasicTile(size: size)

            VStack {
                /*HStack {
                    Text("Question \(questionNumber)/\(totalQuestions)")
                        .foregroundColor(.black)
                        .screenLeft()
                }*/
                    
                if buttonMode == .navigation {
                    HStack {
                        Text("Question \(questionNumber)/\(totalQuestions)")
                            .foregroundColor(.black)
                        
                        Spacer()

                        if showSkip {
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
                
                if buttonMode == .navigation{
                    Spacer()
                }

                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "calendar")
                        Text(dateFormatter.string(from: datetimeValue))
                    }
                    .padding()
                    .frame(width: 160)
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))

                    HStack {
                        Image(systemName: "clock")
                        Text(timeFormatter.string(from: datetimeValue))
                    }
                    .padding()
                    .frame(width: 140)
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                }
                .cornerRadius(10)
                .frame(width: 320)
                
                if buttonMode == .navigation{
                    Spacer()
                }
                Menu {
                    Picker("Time Zone", selection: $selectedTimeZone) {
                        ForEach(usTimeZones, id: \.self) { zone in
                            Text("\(zone.replacingOccurrences(of: "America/", with: "").replacingOccurrences(of: "_", with: " ")) (\(TimeZone(identifier: zone)?.abbreviation() ?? ""))")
                                .tag(zone)
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "globe")
                        Text("\(selectedTimeZone.replacingOccurrences(of: "America/", with: "").replacingOccurrences(of: "_", with: " ")) (\(TimeZone(identifier: selectedTimeZone)?.abbreviation() ?? ""))")
                        Spacer()
                        Image(systemName: "triangle.fill")
                            .resizable()
                            .frame(width: 8, height: 6)
                            .rotationEffect(.degrees(180))
                    }
                    .padding()
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 1))
                    .cornerRadius(10)
                    .frame(width: 310)
                }
                .padding(.horizontal)

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

                        Button(" Next  ") {
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
        .alert(isPresented: $showSuccessAlert) {
            Alert(
                title: Text("Updated"),
                message: Text("Date was successfully updated."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .frame(width: size.width, height: size.height)

        if showProgressBar {
            SegmentedProgressBar(
                totalSegments: totalQuestions,
                filledSegments: questionNumber,
                tileWidth: 350
            )

            Text("Progress")
                .font(.footnote)
                .padding(.top, 4)
                .fontWeight(.bold)
        }
    }
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
            nextAction: {},
            skipAction: {},
            previousAction: {}
        )
    }
}
