//
//  InputTileDetails.swift
//  StreetCare
//
//  Created by Sahana Hemraj on 11/10/25.
//

import SwiftUI



// Struct to hold the input fields for Question 2
struct PersonalDetails {
    var firstname: String = ""
    var lastname: String = ""
    var contactemail: String = ""
    var contactphone: String = ""
}



// The main component for displaying question tiles
struct InputTileDetails: View {
    
    // MARK: - Properties
    
    var questionNumber: Int
    var totalQuestions: Int
    var cardTitle: String
    var showSkip: Bool
    var showPrevious: Bool
    
    // Bindings for Question 1: Date/Time
    @Binding var rawDate: Date
    @Binding var rawEndDate: Date?
    @Binding var timeZoneIdentifier: String

    // Bindings for Question 2: Personal Details
    @Binding var personalDetails: PersonalDetails
    
    // MARK: - Actions
    var nextAction: () -> Void
    var skipAction: () -> Void
    var previousAction: () -> Void
    
    // MARK: - Local State
    
    enum QuestionType {
        case interactionTime
        case personalDetails
    }
    
    var currentQuestionType: QuestionType
    
    // Timezone data
    private let timezones: [String] = {
        let identifiers = TimeZone.knownTimeZoneIdentifiers
        return identifiers.filter { $0.contains("/") && $0.split(separator: "/").count > 1 }
            .sorted()
    }()
    
    // 1. Get the current TimeZone object
    private var selectedTimeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? .current
    }

    // 2. Helper to format the Date (MM/DD/YYYY)
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.timeZone = selectedTimeZone
        return formatter.string(from: date)
    }

    // 3. Helper to format the Time (6:30 PM)
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.timeZone = selectedTimeZone
        return formatter.string(from: date)
    }
    
    // ➡️ START MODIFICATION 1: Add custom formatter
        // Custom formatter for time with timezone abbreviation (e.g., "6:30 PM CST")
        private var timeWithAbbreviationFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma"   // <-- KEEP THIS, DO NOT ADD z
        formatter.timeZone = TimeZone(identifier: timeZoneIdentifier)
        return formatter
    }
    private var tzAbbreviation: String {
        TimeZone(identifier: timeZoneIdentifier)?.abbreviation() ?? ""
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1. PROGRESS BAR: Moved to the very top (outside the card)
            SegmentedProgressBar(totalSegments: totalQuestions, filledSegments: questionNumber, tileWidth: 360)
                .padding(.top, 20)
                .padding(.bottom, 20)
            
            
            // 2. Question Card
            VStack(alignment: .leading, spacing: currentQuestionType == .personalDetails ? 2 : 20) {
                
                // InputTileDetails.swift - Around Line 100

                // ➡️ RE-ADD Question/Step Number
                HStack { // <--- Wrap Question number and Skip button in an HStack
                    Text("Question \(questionNumber)/\(totalQuestions)")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    
                    Spacer() // Pushes the Skip button to the right

                    // SKIP Button (Top Right Badge Style)
                    if showSkip {
                        Button(action: skipAction) {
                            Text("Skip")
                                .font(.subheadline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.black.opacity(0.4), lineWidth: 1) // Subtle border
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 0) // Creates space before the divider

                // Horizontal Separator (Line) as seen in Figma
                                if currentQuestionType != .personalDetails { // ⬅️ ADD THIS CONDITIONAL CHECK
                                    Divider()
                                        .padding(.top, -10) // Pulls the divider up
                                }

                // Card Title (When was your Interaction? - keep two-line formatting)
                if currentQuestionType == .interactionTime {
                    Text(cardTitle.replacingOccurrences(of: " Interaction?", with: "\nInteraction?"))
                        .font(.title)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.top, 0)     // reduce top space
                        .padding(.bottom, 5)  // keep bottom spacing
                        .padding(.bottom, 0)
                }
                
                // Content Switch
                Group {
                    switch currentQuestionType {
                    case .interactionTime:
                        interactionTimeContent
                    case .personalDetails:
                        personalDetailsContent
                    }
                }
                
                // Navigation/Action Buttons
                // ---------- NAVIGATION / ACTION BUTTONS ----------
                // ---------- NAVIGATION / ACTION BUTTONS ----------
                HStack {
                    if currentQuestionType == .interactionTime {
                        // Q1: center the Next button only
                        Spacer()
                        Button(action: nextAction) {
                            Text("Next")
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color("SecondaryColor"))
                                .foregroundColor(Color("PrimaryColor"))
                                .cornerRadius(30)
                                .fontWeight(.bold)
                        }
                        Spacer()
                    } else {
                        // Q2+ : previous on left, next on right (unchanged)
                        if showPrevious {
                            Button(action: previousAction) {
                                Text("Previous")
                                    .font(.body)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(Color.white)
                                    .foregroundColor(.black)
                                    .cornerRadius(25)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 25)
                                            .stroke(Color("SecondaryColor"), lineWidth: 1.5)
                                    )
                            }
                            .buttonStyle(.plain)
                        }

                        Spacer()

                        Button(action: nextAction) {
                            Text("Next")
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background(Color("SecondaryColor"))
                                .foregroundColor(Color("PrimaryColor"))
                                .cornerRadius(30)
                                .fontWeight(.bold)
                        }
                        .disabled(isNextButtonDisabled)
                    }
                }
                .padding(.top, 8)



                    // ➡️ ADD THIS TO THE OUTER HSTACK TO CENTER COMPACT BUTTONS:
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding(.horizontal, 30)
            
            Spacer()
        }
    }
    
    // MARK: - Q1 Content: Interaction Time
    var interactionTimeContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            
            
            // Start Time Label
            Text("Start Time:")
                .font(.subheadline)
                .foregroundColor(.black)
                .padding(.leading, 20)
            
            // Start Time PICKERS
            HStack(spacing: 10) {
                //Spacer()
                
               
                // ⭐️ Start Date - Date Picker
//                ZStack {
//                    DatePicker("", selection: $rawDate, displayedComponents: .date)
//                        .labelsHidden()
//                        .datePickerStyle(.compact)
//                        .opacity(0.01)
//                        .allowsHitTesting(true)
//                        // ➡️ This makes the calendar/picker wheels sync to the location:
//                        .environment(\.timeZone, selectedTimeZone)
//
//                    HStack(spacing: 8) {
//                        Image(systemName: "calendar")
//                            .foregroundColor(.black)
//
//                        // Fixed the formatting logic and removed the typo
//                        Text(rawDate.formatted(.dateTime.month(.twoDigits).day(.twoDigits).year().timeZone(selectedTimeZone)))
//                            .font(.subheadline)
//                            .foregroundColor(.black)
//                    }
                ZStack {
                    DatePicker("", selection: $rawDate, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .opacity(0.01)
                        .allowsHitTesting(true)
                        // ➡️ This line makes the "Calendar" sync to the location
                        .environment(\.timeZone, selectedTimeZone)

                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                        // ➡️ Use the helper function here
                        Text(formatDate(rawDate))
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.4), lineWidth: 1)
                    )
                    .allowsHitTesting(false)
                }
                .frame(width: 145)

            
                //.frame(maxWidth: .infinity, alignment: .leading)

                
                // ⭐️ Start Time - Time Picker (Custom Style)
                ZStack {
                    DatePicker("", selection: $rawDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .opacity(0.01)
                        .allowsHitTesting(true)
                        // ➡️ This line makes the "Clock Wheels" sync to the location
                        .environment(\.timeZone, selectedTimeZone)

                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                        // ➡️ Use the helper function here + the abbreviation
                        Text("\(formatTime(rawDate)) \(selectedTimeZone.abbreviation() ?? "")")
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.4), lineWidth: 1)
                    )
                    .allowsHitTesting(false)
                }
                .frame(width: 145)

            }
            .frame(width: 300)
            .padding(.horizontal, 12)
            
            // End Time Label
            Text("End Time:")
                .font(.subheadline)
                .foregroundColor(.black)
                .padding(.leading, 20)
            
                
            
            // End Time PICKERS
            HStack(spacing: 10) {
                
                // ⭐️ End Time - Date Picker (Custom Style)
                ZStack {
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { rawEndDate ?? rawDate },
                            set: { rawEndDate = $0 }
                        ),
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .opacity(0.01)
                    .allowsHitTesting(true)

                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.black)

                        Text(
                            rawEndDate ?? rawDate,
                            format: .dateTime.month(.twoDigits).day(.twoDigits).year()
                        )
                        .font(.subheadline)
                        .foregroundColor(.black)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.4), lineWidth: 1)
                    )
                    .allowsHitTesting(false)
                }
                .frame(width: 145)


                // ⭐️ End Time - Time Picker (Custom Style)
                ZStack {
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { rawEndDate ?? rawDate },
                            set: { rawEndDate = $0 }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .opacity(0.01)
                    .allowsHitTesting(true)

                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .foregroundColor(.black)

                        Text("\(timeWithAbbreviationFormatter.string(from: (rawEndDate ?? rawDate))) \(tzAbbreviation)")
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.4), lineWidth: 1)
                    )
                    .allowsHitTesting(false)
                }
                .frame(width: 145)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 15)

            
            // MARK: - TIMEZONE PICKER (Figma style: city (ABBR) + black chevron)
            Menu {
                ForEach(timezones, id: \.self) { identifier in
                    let city = identifier.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ") ?? identifier
                    let abbr = TimeZone(identifier: identifier)?.abbreviation() ?? ""
                    Button(action: {
                        timeZoneIdentifier = identifier
                    }) {
                        Text("\(city) (\(abbr))")
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "globe")
                        .foregroundColor(.black)

                    // selected city text
                    let selCity = timeZoneIdentifier.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ") ?? timeZoneIdentifier
                    let selAbbr = TimeZone(identifier: timeZoneIdentifier)?.abbreviation() ?? ""
                    Text("\(selCity) (\(selAbbr))")
                        .foregroundColor(.black)
                        .font(.system(size: 18))

                    Spacer()

                    Image(systemName: "arrowtriangle.down.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 8)   // tweak sizes to match Figma
                        .foregroundColor(.black)

                }
                .padding(.leading, 16)
                .padding(.trailing, 18)   // important for chevron spacing
                .padding(.vertical, 12)
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.6), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.10), radius: 4, x: 0, y: 2)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 16)
        }
    }
    
    
    // MARK: - Q2 Content: Personal Details
    var personalDetailsContent: some View {
        VStack(spacing: 15) {
            InputTextField(placeholder: "First Name *", text: $personalDetails.firstname)
            InputTextField(placeholder: "Last Name", text: $personalDetails.lastname)
            InputTextField(placeholder: "Email", text: $personalDetails.contactemail, keyboardType: .emailAddress)
            InputTextField(placeholder: "Phone Number", text: $personalDetails.contactphone, keyboardType: .phonePad)
        }
        .padding(.top, 10)
        .padding(.bottom, 0)
        .padding(.horizontal, 10)
    }
    
    // Helper to determine if the Next button should be disabled
    var isNextButtonDisabled: Bool {
        if currentQuestionType == .personalDetails {
            return personalDetails.firstname.isEmpty
        } else if currentQuestionType == .interactionTime {
            if let endDate = rawEndDate, endDate < rawDate {
                return true
            }
        }
        return false
    }
}

// Custom text field component for Question 2 (also needs white background/shadow)
struct InputTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .padding(.vertical, 8)
            .padding(.leading, 12)
            // ➡️ Change to white background and add shadow
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
            .overlay(
                // Add a very subtle light gray stroke to define the box
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black.opacity(0.4), lineWidth: 1)
            )
    }
}

        
        

// This struct must be defined once as a top-level struct (Outside InputTileDetails)
struct SegmentedProgressBar: View {
    var totalSegments: Int
    var filledSegments: Int
    var tileWidth: CGFloat
    var segmentHeight: CGFloat = 12
    var spacing: CGFloat = 8
    
    var body: some View {
        let totalSpacing = spacing * CGFloat(totalSegments - 1)
        let segmentWidth = (tileWidth - totalSpacing - 40) / CGFloat(totalSegments)
        
        HStack(spacing: spacing) {
            ForEach(0..<totalSegments, id: \.self) { index in
                Capsule()
                    // Fill logic: segments before 'filledSegments' are primary color
                    .fill(index < filledSegments ? Color("PrimaryColor") : Color("SecondaryColor"))
                    .frame(width: segmentWidth, height: segmentHeight)
                    
                    .overlay(
                        RoundedRectangle(cornerRadius: 100) // Use high corner radius for capsule
                            // ⭐️ MODIFIED LOGIC: Apply stroke only when index matches the current, active segment (filledSegments - 1)
                            .stroke(index == filledSegments - 1 ? Color.black : Color.clear, lineWidth: 1.5)
                    )
            }
        }
        .frame(width: tileWidth)
        .padding(.horizontal, 20)
    }
}
