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
    
    var size = CGSize(width: 300.0, height: 450.0)
    var question: String
        
    @Binding var datetimeValue: Date
        
    var nextAction: () -> ()
    var skipAction: () -> ()
    var previousAction: () -> ()
    
    var body: some View {
        
        ZStack {
            BasicTile(size: CGSize(width: size.width, height: size.height))
            
            VStack {
                
                HStack {
                    Spacer()
                    Button("Skip") {
                        skipAction()
                    }
                    .foregroundColor(.gray)
                    .padding()
                }
                
                Spacer()
                
                Text("Question \(questionNumber)/\(totalQuestions)")
                    .foregroundColor(.gray)
                    .font(.footnote)
                
                Text(question)
                    .font(.headline)
                    .padding()
                
                // Date Picker with Time Zone Abbreviation Inline
                HStack {
                    DatePicker(
                        "",
                        selection: $datetimeValue,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .labelsHidden()
                    .datePickerStyle(CompactDatePickerStyle())
                    .padding()
                    
                    // Show Time Zone Abbreviation Inline
                    Text(getTimeZoneAbbreviation())
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Button("Previous") {
                        previousAction()
                    }
                    .foregroundColor(Color("TextColor"))
                    Spacer()
                    Button("Next") {
                        nextAction()
                    }
                    .foregroundColor(Color("TextColor"))
                }
                .padding()
                
                SegmentedProgressBar(
                    totalSegments: totalQuestions,
                    filledSegments: questionNumber
                )
                
                Text("Progress")
                    .font(.caption)
                    .padding(.top, 4)
                
            }
        }
        .frame(width: size.width, height: size.height)
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

