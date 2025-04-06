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
    
    var size = CGSize(width: 350.0, height: 320.0)
    var question: String
        
    @Binding var datetimeValue: Date
    @State private var selectedTimeZone: String = TimeZone.current.identifier
    let timeZones = TimeZone.knownTimeZoneIdentifiers.sorted()
    let usTimeZones = TimeZone.knownTimeZoneIdentifiers
        .filter { $0.starts(with: "America/") }
        .sorted()
        
    var nextAction: () -> ()
    var skipAction: () -> ()
    var previousAction: () -> ()
    
    var body: some View {
        
        ZStack {
            BasicTile(size: CGSize(width: size.width, height: size.height))
            
            VStack {
                
                HStack {
                    Text("Question \(questionNumber)/\(totalQuestions)")
                        .foregroundColor(.black)
                        //.font(.footnote)
                    
                    Spacer()
                    
                    /*Button("Skip") {
                        skipAction()
                    }
                    .foregroundColor(.gray)
                    .padding()*/
                    
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                    .padding(.horizontal)
                
                HStack{
                    Text(question)
                        .font(.title3)
                        .padding(.top, 12)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 12) {
                    // Date Picker Row
                    HStack {
                        Image(systemName: "calendar")
                        DatePicker(
                            "",
                            selection: $datetimeValue,
                            displayedComponents: [.date]
                        )
                        .labelsHidden()
                        .font(.footnote)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white) // Background white
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1) // Border black
                    )
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)

                    // Time Picker Row
                    HStack {
                        Image(systemName: "clock")
                        DatePicker(
                            "",
                            selection: $datetimeValue,
                            displayedComponents: [.hourAndMinute]
                        )
                        .labelsHidden()
                        .datePickerStyle(CompactDatePickerStyle())
                        .font(.footnote)
                        .colorMultiply(.black) // Keeps time text dark on white

                        Picker("Time Zone", selection: $selectedTimeZone) {
                            ForEach(usTimeZones, id: \.self) { zone in
                                Text("\(zone.replacingOccurrences(of: "America/", with: "").replacingOccurrences(of: "_", with: " ")) (\(TimeZone(identifier: zone)?.abbreviation() ?? ""))")
                                    .tag(zone)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white) // Background white
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 1) // Border black
                    )
                    .cornerRadius(10)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                HStack {
                    Button("Previous") {
                        previousAction()
                    }
                    .foregroundColor(Color("SecondaryColor"))
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
                        nextAction()
                    }
                    .foregroundColor(Color("PrimaryColor"))
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
        .frame(width: size.width, height: size.height)
        SegmentedProgressBar(
            totalSegments: totalQuestions,
            filledSegments: questionNumber
        )

        Text("Progress")
            .font(.caption)
            .padding(.top, 4)
    }
        
        
        // Function to get the current time zone abbreviation (e.g., CST, EST, PST)
        func getTimeZoneAbbreviation() -> String {
            return TimeZone.current.abbreviation() ?? "UTC"
        }
}


struct InputTileDate_Previews: PreviewProvider {

    @State static var input = Date()

    static var previews: some View {

        InputTileDate(questionNumber: 1, totalQuestions: 4, question: "Enter a date to remember.", datetimeValue: $input) {
            //
        } skipAction: {
            //
        } previousAction: {
            //
        }

    }
}

