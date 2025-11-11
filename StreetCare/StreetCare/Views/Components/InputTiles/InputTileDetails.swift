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
    var cardTitle: String // e.g., "When was your Interaction?" or "Personal details"
    var showSkip: Bool
    var showPrevious: Bool
    
    // Bindings for Question 1: Date/Time
    @Binding var rawDate: Date // Start Date/Time
    @Binding var rawEndDate: Date? // End Date/Time (Optional)
    @Binding var timeZoneIdentifier: String // Timezone selection

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
            // Header: "Log Your Interaction"
            Text("Log Your Interaction")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            // Progress Bar (It will use the SegmentedProgressBar defined in VisitLogEntry.swift)
            SegmentedProgressBar(totalSegments: totalQuestions, filledSegments: questionNumber, tileWidth: 360)
                .padding(.vertical, 10)
            
            // Question Card
            VStack(alignment: .leading, spacing: 20) {
                // Question/Step Number
                Text("Question \(questionNumber)/\(totalQuestions)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Card Title
                Text(cardTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                
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
                                .padding(10)
                                .foregroundColor(Color("PrimaryColor"))
                        }
                        .padding(.leading, 10)
                    }

                    Button(action: nextAction) {
                        Text("Next")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("PrimaryColor"))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(isNextButtonDisabled)
                }
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
            
            // Start Time
            VStack(alignment: .leading) {
                Text("Start Time:")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                HStack {
                    // Start Time - Date Picker
                    DatePicker(
                        "",
                        selection: $rawDate,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact) // CORRECTED
                    .frame(maxWidth: .infinity)
                    
                    // Start Time - Time Picker
                    DatePicker(
                        "",
                        selection: $rawDate,
                        displayedComponents: .hourAndMinute
                    )
                    .labelsHidden()
                    .datePickerStyle(.compact) // CORRECTED
                    .frame(maxWidth: .infinity)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(5)
            }
            
            // End Time
            VStack(alignment: .leading) {
                Text("End Time:")
                    .font(.footnote)
                    .foregroundColor(.gray)
                
                HStack {
                    // Date Picker (Binding to rawEndDate, defaulting to rawDate if nil)
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
                    .frame(maxWidth: .infinity)
                    
                    // Time Picker (Binding to rawEndDate, defaulting to rawDate if nil)
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
                    .frame(maxWidth: .infinity)
                }
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(5)
            }
            
            // Time Zone
            Picker("Time Zone", selection: $timeZoneIdentifier) {
                ForEach(timezones, id: \.self) { identifier in
                    Text(identifier.replacingOccurrences(of: "_", with: " ").components(separatedBy: "/").last ?? identifier)
                        .tag(identifier)
                }
            }
            .pickerStyle(.menu)
            .frame(maxWidth: .infinity)
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(5)
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
            return personalDetails.firstName.isEmpty // Assuming First Name is required
        } else if currentQuestionType == .interactionTime {
            // Check if end date is after start date if present
            if let endDate = rawEndDate, endDate < rawDate {
                return true
            }
        }
        return false
    }
}

// Custom text field component for Question 2
struct InputTextField: View {
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(5)
    }
}


struct SegmentedProgressBar: View {
    var totalSegments: Int
    var filledSegments: Int
    var tileWidth: CGFloat
    var segmentHeight: CGFloat = 8
    var spacing: CGFloat = 8
    
    var body: some View {
        let totalSpacing = spacing * CGFloat(totalSegments - 1)
        let segmentWidth = (tileWidth - totalSpacing) / CGFloat(totalSegments)
        
        HStack(spacing: spacing) {
            ForEach(0..<totalSegments, id: \.self) { index in
                Capsule()
                    .fill(index < filledSegments ? Color("PrimaryColor") : Color("SecondaryColor"))
                    .frame(width: segmentWidth, height: segmentHeight)
            }
        }
        .frame(width: tileWidth)
    }
}




