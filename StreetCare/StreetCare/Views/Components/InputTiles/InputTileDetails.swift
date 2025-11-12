//
//  InputTileDetails.swift
//  StreetCare
//
//  Created by Sahana Hemraj on 11/10/25.
//

import SwiftUI

// Struct to hold the input fields for Question 2
struct PersonalDetails {
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var phoneNumber: String = ""
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
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1. PROGRESS BAR: Moved to the very top (outside the card)
            SegmentedProgressBar(totalSegments: totalQuestions, filledSegments: questionNumber, tileWidth: 360)
                .padding(.top, 20)
                .padding(.bottom, 10)
            
            
            // 2. Question Card
            VStack(alignment: .leading, spacing: 20) {
                
                // ➡️ RE-ADD Question/Step Number
                Text("Question \(questionNumber)/\(totalQuestions)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .foregroundColor(.gray)
                
                // Horizontal Separator (Line) as seen in Figma
                Divider()
                    .padding(.top, -10) // Pull it closer to the question number

                // Card Title (When was your Interaction? - keep two-line formatting)
                Text(cardTitle.replacingOccurrences(of: " Interaction?", with: "\nInteraction?"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 5)
                    .padding(.bottom, 10)
                
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
                HStack {
                    if showPrevious {
                        Button(action: previousAction) {
                            Text("Previous")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(Color("PrimaryColor"))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color("PrimaryColor"), lineWidth: 1)
                                )
                        }
                    }
                    
                    if showSkip {
                        Button(action: skipAction) {
                            Text("Skip")
                                .fontWeight(.semibold)
                                .padding(.vertical, 16)
                                .foregroundColor(Color("PrimaryColor"))
                        }
                        .padding(.leading, 10)
                    }

                    Button(action: nextAction) {
                            Text("Next")
                                .padding(.horizontal, 40) // Make it compact but wide enough
                                .padding(.vertical, 12)  // Adjust vertical height
                                .background(Color("SecondaryColor"))
                                // ➡️ CHANGE FONT COLOR HERE
                                .foregroundColor(Color("PrimaryColor"))
                                .cornerRadius(8)
                        }
                        .disabled(isNextButtonDisabled)
                    }
                    // ➡️ ADD THIS TO THE OUTER HSTACK TO CENTER COMPACT BUTTONS:
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 10)
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding(.horizontal)
            
            Spacer()
        }
    }
    
    // MARK: - Q1 Content: Interaction Time
    var interactionTimeContent: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            // Start Time Label
            Text("Start Time:")
                .font(.footnote)
                .foregroundColor(.gray)
                .fontWeight(.bold)
            
            // Start Time PICKERS
            HStack(spacing: 10) {
                
                // ⭐️ Start Time - Date Picker (Custom Style)
                ZStack {
                    DatePicker("", selection: $rawDate, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .opacity(0.01)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        // ➡️ FIXED DATE FORMATTING: MM/DD/YYYY
                        Text(rawDate, format: .dateTime.month(.twoDigits).day(.twoDigits).year())
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                    // ➡️ ADD HIGHLIGHT (BORDER):
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                }
                .frame(maxWidth: .infinity)
                
                // ⭐️ Start Time - Time Picker (Custom Style)
                ZStack {
                    DatePicker("", selection: $rawDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .opacity(0.01)

                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .foregroundColor(.gray)
                        Text(rawDate, style: .time)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                    // ➡️ ADD HIGHLIGHT (BORDER):
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                }
                .frame(maxWidth: .infinity)
            }
            
            // End Time Label
            Text("End Time:")
                .font(.footnote)
                .foregroundColor(.black)
                
            
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

                    HStack(spacing: 8) {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        // ➡️ FIXED DATE FORMATTING: MM/DD/YYYY
                        Text(rawEndDate ?? rawDate, format: .dateTime.month(.twoDigits).day(.twoDigits).year())
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                }
                .frame(maxWidth: .infinity)

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

                    HStack(spacing: 8) {
                        Image(systemName: "clock")
                            .foregroundColor(.gray)
                        Text(rawEndDate ?? rawDate, style: .time)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                }
                .frame(maxWidth: .infinity)
            }

            // TIME ZONE PICKER (Styling is complete)
            HStack {
                // ➡️ CHANGE THIS LINE:
                Image(systemName: "globe")
                    // .foregroundColor(Color("PrimaryColor"))
                    .foregroundColor(.gray)
                    .padding(.leading, 8)
                
                Picker("", selection: $timeZoneIdentifier) {
                    ForEach(timezones, id: \.self) { identifier in
                        Text(identifier.replacingOccurrences(of: "_", with: " ").components(separatedBy: "/").last ?? identifier)
                            .tag(identifier)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
        }
    }
    
    
    // MARK: - Q2 Content: Personal Details
    var personalDetailsContent: some View {
        VStack(spacing: 15) {
            InputTextField(placeholder: "First Name *", text: $personalDetails.firstName)
            InputTextField(placeholder: "Last Name", text: $personalDetails.lastName)
            InputTextField(placeholder: "Email", text: $personalDetails.email, keyboardType: .emailAddress)
            InputTextField(placeholder: "Phone Number", text: $personalDetails.phoneNumber, keyboardType: .phonePad)
        }
    }
    
    // Helper to determine if the Next button should be disabled
    var isNextButtonDisabled: Bool {
        if currentQuestionType == .personalDetails {
            return personalDetails.firstName.isEmpty
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
            .padding()
            // ➡️ Change to white background and add shadow
            .background(Color.white)
            .cornerRadius(5)
            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
            .overlay(
                // Add a very subtle light gray stroke to define the box
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
            )
    }
}

// This struct must be defined once as a top-level struct (Outside InputTileDetails)
struct SegmentedProgressBar: View {
    var totalSegments: Int
    var filledSegments: Int
    var tileWidth: CGFloat
    var segmentHeight: CGFloat = 8
    var spacing: CGFloat = 8
    
    var body: some View {
        let totalSpacing = spacing * CGFloat(totalSegments - 1)
        let segmentWidth = (tileWidth - totalSpacing - 40) / CGFloat(totalSegments)
        
        HStack(spacing: spacing) {
            ForEach(0..<totalSegments, id: \.self) { index in
                Capsule()
                    .fill(index < filledSegments ? Color("PrimaryColor") : Color("SecondaryColor"))
                    .frame(width: segmentWidth, height: segmentHeight)
            }
        }
        .frame(width: tileWidth)
        .padding(.horizontal, 20)
    }
}
