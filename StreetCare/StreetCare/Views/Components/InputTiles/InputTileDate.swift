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
    var showSkip: Bool
    
        
    @Binding var datetimeValue: Date
    @Binding var convertedDate: Date
    @State private var selectedTimeZone: String = TimeZone.current.identifier
    let timeZones = TimeZone.knownTimeZoneIdentifiers.sorted()
    let usTimeZones = TimeZone.knownTimeZoneIdentifiers
        .filter { $0.starts(with: "America/") }
        .sorted()
        
    var nextAction: () -> ()
    var skipAction: () -> ()
    var previousAction: () -> ()
    
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
            BasicTile(size: CGSize(width: size.width, height: size.height))
            
            VStack {
                
                HStack {
                    Text("Question \(questionNumber)/\(totalQuestions)")
                        .foregroundColor(.black)
                        //.font(.footnote)
                    
                    Spacer()
                    
                    if showSkip{
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
                    
                }
                .padding(.horizontal)
                .padding(.top, 12)
                //.padding()
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.horizontal)
                
                VStack{
                    Text(question1)
                        .font(.title2)
                        .padding(.top, 6)
                        .fontWeight(.bold)
                    Text(question2)
                        .font(.title2)
                        .fontWeight(.bold)
                        .fontWeight(.bold)
                    Text(question3)
                        .font(.title2)
                        .padding(.bottom, 12)
                        .fontWeight(.bold)
                }
                
                //Spacer()
                
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

                    // Time Picker Box
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
                            .foregroundColor(.black)

                        Text("\(selectedTimeZone.replacingOccurrences(of: "America/", with: "").replacingOccurrences(of: "_", with: " ")) (\(TimeZone(identifier: selectedTimeZone)?.abbreviation() ?? ""))")
                            .foregroundColor(.black)
                            .font(.body)
                            .lineLimit(1)

                        Spacer()

                        Image(systemName: "triangle.fill")
                            .resizable()
                            .frame(width: 8, height: 6)
                            .rotationEffect(.degrees(180))
                            .foregroundColor(.black)
                    }
                    //.padding(.horizontal)
                    //.padding(.vertical, 6)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .cornerRadius(10)
                    .frame(width: 335, alignment: .leading)
                    .padding(.horizontal)
                }
                
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
                        if let converted = convertToCurrentTimeZone(from: datetimeValue, selectedTimeZoneID: selectedTimeZone) {
                            convertedDate = converted  // ✅ Save to parent state
                        } else {
                            convertedDate = datetimeValue  // fallback
                        }
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
        .onChange(of: selectedTimeZone) { newValue in
            if let converted = convertToCurrentTimeZone(from: datetimeValue, selectedTimeZoneID: newValue) {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .medium
                formatter.timeZone = TimeZone.current
            }
        }
        .frame(width: size.width, height: size.height)
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
        
        
        // Function to get the current time zone abbreviation (e.g., CST, EST, PST)
        func getTimeZoneAbbreviation() -> String {
            return TimeZone.current.abbreviation() ?? "UTC"
        }
}


func convertToCurrentTimeZone(from date: Date, selectedTimeZoneID: String) -> Date? {
    guard let selectedTimeZone = TimeZone(identifier: selectedTimeZoneID) else {
        print("❌ Invalid Time Zone Identifier")
        return nil
    }

    let currentTimeZone = TimeZone.current

    let selectedOffset = TimeInterval(selectedTimeZone.secondsFromGMT(for: date))
    let currentOffset = TimeInterval(currentTimeZone.secondsFromGMT(for: date))

    // Adjust the date by the difference in offsets
    let timeDifference = currentOffset - selectedOffset
    return date.addingTimeInterval(timeDifference)
}



struct InputTileDate_Previews: PreviewProvider {

    @State static var input = Date()

    static var previews: some View {

        InputTileDate(questionNumber: 3, totalQuestions: 4, question1: "Is there a planned date to",question2: "interact with them again?",question3: "", showSkip: true, datetimeValue: $input, convertedDate: $input ) { 
            //
        } skipAction: {
            //
        } previousAction: {
            //
        }

    }
}


