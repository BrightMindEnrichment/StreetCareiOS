//
//  VisitLogEntry.swift
//  StreetCare
//
//  Created by Michael on 4/10/23.
//


import SwiftUI
import FirebaseAuth
import CoreLocation
import CoreLocationUI

// Make sure PersonalDetails struct is available (either defined in InputTileDetails
// or copied here if it's needed by other files in VisitLogEntry)

struct VisitLogEntry: View {
    
    @Environment(\.presentationMode) var presentation
    @State private var questionNumber: Int = 1
    @State var totalQuestions = 7 // UPDATED: Changed from 6 to 7 to include Personal Details (Q2)
    @State private var selectedLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    @StateObject var visitLog = VisitLog(id: UUID().uuidString)
    
    var currentUser = Auth.auth().currentUser
    @State var isLoading = false
    @State var isComplete = false
    @State private var volunteerAgain: Int = -1
    
    @State var rawDate: Date = Date()
    @State private var rawEndDate: Date? = Date().addingTimeInterval(3600) // NEW: For Q1 End time
    @State private var selectedTimeZone: String = TimeZone.current.identifier // NEW: For Q1 Time Zone
    
    @State private var initialRawDate: Date = Date()
    @State private var didSetInitialRawDate = false
    @State var adjustedDate: Date = Date()
    
    @StateObject private var keyboard = KeyboardHeightObserver()
    
    // NEW: State for Personal Details (Question 2)
    // NOTE: If PersonalDetails is defined in InputTileDetails.swift, ensure it is accessible here (e.g., public/internal).
    @State private var personalDetails = PersonalDetails()
    
    
    
    var body: some View {
        NavigationStack {
            VStack {
                
                if !isComplete{
                    Text(NSLocalizedString("logYourInteraction", comment: ""))
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                }
                
                switch questionNumber {
                case 1:
                    // REPLACEMENT for InputTileDate (Q1: When was your Interaction?)
                    InputTileDetails(
                        questionNumber: 1,
                        totalQuestions: totalQuestions,
                        cardTitle: NSLocalizedString("questionOne", comment: "") + " " + NSLocalizedString("interaction", comment: "") + "?",
                        showSkip: false,
                        showPrevious: false,
                        rawDate: $rawDate,
                        rawEndDate: $rawEndDate,
                        timeZoneIdentifier: $selectedTimeZone,
                        personalDetails: $personalDetails,
                        
                        nextAction: {
                            // Update visitLog.whenVisit based on rawDate and TimeZone here or in an extension/model method
                            questionNumber += 1
                        },
                        skipAction: {
                            questionNumber += 1
                        },
                        previousAction: {
                            questionNumber -= 1
                        },
                        currentQuestionType: .interactionTime
                    )
                    
                case 2:
                    // NEW QUESTION (Q2: Personal Details)
                    InputTileDetails(
                        questionNumber: 2,
                        totalQuestions: totalQuestions,
                        cardTitle: "Personal details", // Use NSLocalizedString for localization if available
                        showSkip: true,
                        showPrevious: true,
                        rawDate: $rawDate, // Required by component, even if not used for Q2
                        rawEndDate: $rawEndDate, // Required by component
                        timeZoneIdentifier: $selectedTimeZone, // Required by component
                        personalDetails: $personalDetails,
//                        firstname: $personalDetails.firstname,
//                        lastname: $personalDetails.lastname,
//                        contactemail: $personalDetails.contactemail,
//                        contactphone: $personalDetails.contactphone,
                        nextAction: {
                            // You might want to save personalDetails to a user profile or visitLog here
                            // ⭐️ ADD THESE LINES HERE ⭐️
                            visitLog.firstname = personalDetails.firstname
                            visitLog.lastname = personalDetails.lastname
                            visitLog.contactemail = personalDetails.contactemail
                            visitLog.contactphone = personalDetails.contactphone
                            questionNumber += 1
                        },
                        skipAction: {
                            questionNumber += 1
                        },
                        previousAction: {
                            questionNumber -= 1
                        },
                        currentQuestionType: .personalDetails
                    )
                    
                case 3:
                    // Original case 2 is now case 3 (Location)
                    InputTileLocation(
                        questionNumber: 3, // UPDATED: question number is now 3
                        totalQuestions: totalQuestions,
                        question1: NSLocalizedString("questionTwo", comment: ""),
                        question2: NSLocalizedString("interaction", comment: "") + "?",
                        
                        textValue: Binding(
                            get: { visitLog.whereVisit },
                            set: { newValue in
                                visitLog.whereVisit = newValue
                                print("📍 Updated visitLog.whereVisit: \(visitLog.whereVisit)")
                            }
                        ),
                        location: Binding(
                            get: { visitLog.location },
                            set: { newValue in
                                visitLog.location = newValue
                                print("📍 Updated visitLog.location: \(visitLog.location.latitude), \(visitLog.location.longitude)")
                            }
                        ),
                        locationDescription: Binding(
                            get: { visitLog.locationDescription },
                            set: { newValue in
                                visitLog.locationDescription = newValue
                                print("📝 Updated visitLog.locationDescription: \(visitLog.locationDescription)")
                            }
                        ),
                        nextAction: {
                            questionNumber += 1
                        },
                        previousAction: {
                            questionNumber -= 1
                        },
                        skipAction: {
                            questionNumber += 1
                        },
                        buttonMode: .navigation
                    )
                    .padding(.bottom, keyboard.currentHeight == 0 ? 0 : keyboard.currentHeight - 270)
                    .animation(.easeOut(duration: 0.16), value: keyboard.currentHeight)
                    
                case 4:
                    // Original case 3 is now case 4 (People Helped)
                    InputTileNumber(
                        questionNumber: 4, // UPDATED: was 3
                        totalQuestions: totalQuestions,
                        tileWidth: 360,
                        tileHeight: 520,
                        question1: NSLocalizedString("questionThreePartOne", comment: ""),
                        question2: NSLocalizedString("questionThreePartTwo", comment: ""),
                        question3: NSLocalizedString("questionThreePartThree", comment: ""),
                        question4: NSLocalizedString("questionThreePartFour", comment: ""),
                        descriptionLabel: "Description",
                        disclaimerText: NSLocalizedString("disclaimer", comment: ""),
                        placeholderText: NSLocalizedString("peopledescription", comment: ""),
                        number: $visitLog.peopleHelped,
                        generalDescription: $visitLog.peopleHelpedDescription,
                        generalDescription2: .constant(""),
                        nextAction: {
                            questionNumber += 1
                        },
                        previousAction: {
                            questionNumber -= 1
                        },
                        skipAction: {
                            questionNumber += 1
                        }
                    )
                    .padding(.bottom, keyboard.currentHeight == 0 ? 0 : 35)
                    .animation(.easeOut(duration: 0.16), value: keyboard.currentHeight)
                    
                case 5:
                    // Original case 4 is now case 5 (Support Provided)
                    InputTileList(
                        questionNumber: 5, // UPDATED: was 4
                        totalQuestions: totalQuestions,
                        optionCount: 5,
                        size: CGSize(width: 360, height: 450),
                        question1: NSLocalizedString("questionFourPartOne", comment: ""),
                        question2: NSLocalizedString("questionFourPartTwo", comment: ""),
                        visitLog: visitLog,
                        nextAction: { questionNumber += 1 },
                        previousAction: { questionNumber -= 1 },
                        skipAction: { questionNumber += 1 },
                        buttonMode: .navigation,
                        showProgressBar: true,
                        supportMode: .provided
                    )
                    .padding(.bottom, keyboard.currentHeight == 0 ? 0 : keyboard.currentHeight - 250)
                    .animation(.easeOut(duration: 0.16), value: keyboard.currentHeight)
                    
                case 6:
                    // Original case 5 is now case 6 (Items Given)
                    InputTileNumber(
                        questionNumber: 6, // UPDATED: was 5
                        totalQuestions: totalQuestions,
                        tileWidth: 360,
                        tileHeight: 500,
                        question1: NSLocalizedString("questionFivePartOne", comment: ""),
                        question2: NSLocalizedString("questionFivePartTwo", comment: ""),
                        question3: "",
                        question4: "",
                        descriptionLabel: "",
                        disclaimerText: "",
                        placeholderText: "Enter notes here",
                        number: $visitLog.itemQty,
                        generalDescription: $visitLog.itemQtyDescription,
                        generalDescription2: .constant(""),
                        nextAction: {
                            questionNumber += 1
                        },
                        previousAction: {
                            questionNumber -= 1
                        },
                        skipAction: {
                            questionNumber += 1
                        }
                    )
                    .padding(.bottom, keyboard.currentHeight == 0 ? 0 : 35)
                    .animation(.easeOut(duration: 0.16), value: keyboard.currentHeight)
                    
                case 7:
                    // Original case 6 is now case 7 (Rating)
                    InputTileRate(
                        questionNumber: 7, // UPDATED: was 6
                        totalQuestions: totalQuestions,
                        question1: NSLocalizedString("questionSixPartOne", comment: ""),
                        question2: NSLocalizedString("questionSixPartTwo", comment: ""),
                        textValue: $visitLog.ratingNotes,
                        rating: $visitLog.rating
                    ) {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        questionNumber += 1
                    }
                    .padding(.bottom, keyboard.currentHeight == 0 ? 0 : 4)
                    .animation(.easeOut(duration: 0.16), value: keyboard.currentHeight)
                    
                case 8:
                    // Original case 7 is now case 8 (More Questions Prompt)
                    InputTileMoreQuestions(
                        question1: NSLocalizedString("questionSevenPartOne", comment: "") ,
                        question2: NSLocalizedString("questionSevenPartTwo", comment: ""),
                        question3:NSLocalizedString("questionSevenPartThree", comment: ""),
                        questionNumber: totalQuestions,
                        totalQuestions: totalQuestions
                    ) {
                        // saveVisitLog()
                        questionNumber = 100
                    } skipAction: {
                        questionNumber -= 1
                    } yesAction: {
                        questionNumber += 1
                    } noAction: {
                        saveVisitLog()
                        isComplete = true
                        questionNumber = 100
                    }
                
                // Cases 9 through 14 must also be incremented by +1 and have totalQuestions updated.
                // Case 8 -> 9, Case 9 -> 10, Case 10 -> 11, Case 11 -> 12, Case 12 -> 13, Case 13 -> 14, Case 14 -> 15
                
                case 9:
                    // Original case 8 is now case 9 (Duration)
                    InputTileDuration(
                        questionNumber: 1,
                        totalQuestions: totalQuestions, // Total questions remains 7 for the follow-up flow
                        tileWidth: 360,
                        tileHeight: 361,
                        questionLine1: NSLocalizedString("questionEightPartOne", comment: ""),
                        questionLine2: NSLocalizedString("questionEightPartTwo", comment: ""),
                        questionLine3: NSLocalizedString("questionEightPartThree", comment: ""),
                        hours: $visitLog.durationHours, minutes: $visitLog.durationMinutes
                    ) {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        questionNumber += 1
                    }
                    
                case 10:
                    // Original case 9 is now case 10 (Number of Helpers)
                    InputTileNumber(
                        questionNumber: 2,
                        totalQuestions: totalQuestions, // Total questions remains 7 for the follow-up flow
                        tileWidth: 360,
                        tileHeight: 500,
                        question1: NSLocalizedString("questionNinePartOne", comment: ""),
                        question2: NSLocalizedString("questionNinePartTwo", comment: ""),
                        question3: "",
                        question4: "",
                        descriptionLabel: nil,
                        disclaimerText: nil,
                        placeholderText: NSLocalizedString("aq2des", comment: ""),
                        number: $visitLog.numberOfHelpers,
                        generalDescription: $visitLog.numberOfHelpersComment,
                        generalDescription2: .constant(""),
                        nextAction: {
                            questionNumber += 1
                        },
                        previousAction: {
                            questionNumber -= 1
                        },
                        skipAction: {
                            questionNumber += 1
                        }
                    )
                    .padding(.bottom, keyboard.currentHeight == 0 ? 0 : 24)
                    .animation(.easeOut(duration: 0.16), value: keyboard.currentHeight)
                    
                case 11:
                    // Original case 10 is now case 11 (Need Further Help)
                    InputTileNumber(
                        questionNumber: 3,
                        totalQuestions: totalQuestions, // Total questions remains 7 for the follow-up flow
                        tileWidth: 360,
                        tileHeight: 580,
                        question1: NSLocalizedString("questionTenPartOne", comment: ""),
                        question2: NSLocalizedString("questionTenPartTwo", comment: ""),
                        question3: "",
                        question4: "",
                        descriptionLabel: "Description",
                        descriptionLabel2: "Location Description",
                        disclaimerText: "",
                        placeholderText: NSLocalizedString("peopledescription", comment: ""),
                        placeholderText2: NSLocalizedString("questionTenPlaceholder", comment: ""),
                        number: $visitLog.peopleNeedFurtherHelp,
                        generalDescription: $visitLog.peopleNeedFurtherHelpComment,
                        generalDescription2: $visitLog.peopleNeedFurtherHelpLocation,
                        nextAction: {
                            questionNumber += 1
                        },
                        previousAction: {
                            questionNumber -= 1
                        },
                        skipAction: {
                            questionNumber += 1
                        },
                        showTextEditor2: true
                    )
                    .padding(.bottom, keyboard.currentHeight == 0 ? 0 : 50)
                    .animation(.easeOut(duration: 0.16), value: keyboard.currentHeight)
                    
                case 12:
                    // Original case 11 is now case 12 (Support Needed)
                    InputTileList(
                        questionNumber: 4,
                        totalQuestions: totalQuestions, // Total questions remains 7 for the follow-up flow
                        optionCount: 5,
                        size: CGSize(width: 360, height: 450),
                        question1: NSLocalizedString("questionElevenPartOne", comment: ""),
                        question2: NSLocalizedString("questionElevenPartTwo", comment: ""),
                        visitLog: visitLog,
                        nextAction: { questionNumber += 1 },
                        previousAction: { questionNumber -= 1 },
                        skipAction: { questionNumber += 1 },
                        buttonMode: .navigation,
                        showProgressBar: true,
                        supportMode: .needed
                    )
                    .padding(.bottom, keyboard.currentHeight == 0 ? 0 : 50)
                    .animation(.easeOut(duration: 0.16), value: keyboard.currentHeight)
                    
                case 13:
                    // Original case 12 is now case 13 (Follow-up Date)
                    InputTileDate(
                        questionNumber: 5,
                        totalQuestions: totalQuestions, // Total questions remains 7 for the follow-up flow
                        question1: NSLocalizedString("questionTwelevePartOne", comment: ""),
                        question2: NSLocalizedString("questionTwelevePartTwo", comment: ""),
                        question3: NSLocalizedString("questionTwelevePartThree", comment: ""),
                        showSkip: true,
                        isFollowUpDate: true,
                        initialDateValue: initialRawDate,
                        datetimeValue: $rawDate,
                        convertedDate: $visitLog.followUpWhenVisit
                    ) {
                        questionNumber += 1
                    } skipAction: {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    }
                    
                case 14:
                    // Original case 13 is now case 14 (Other Notes)
                    InputTileNotes(
                        questionNumber: 6,
                        totalQuestions: totalQuestions, // Total questions remains 7 for the follow-up flow
                        tileWidth: 360,
                        tileHeight: 380,
                        question1: NSLocalizedString("questionThirteenPartOne", comment: ""),
                        question2: NSLocalizedString("questionThirteenPartTwo", comment: ""),
                        question3: NSLocalizedString("questionThirteenPartThree", comment: ""),
                        placeholderText: NSLocalizedString("aq6des", comment: ""),
                        otherNotes: $visitLog.furtherOtherNotes,
                        nextAction: {
                            //saveVisitLog()
                            questionNumber += 1
                        },
                        previousAction: {
                            questionNumber -= 1
                        },
                        skipAction: {
                            saveVisitLog()
                            questionNumber += 1
                        },
                        buttonMode: .navigation
                    )
                    
                case 15:
                    // Original case 14 is now case 15 (Volunteer Again)
                    InputTileVolunteerAgain(
                        questionNumber: 7,
                        totalQuestions: totalQuestions, // Total questions remains 7 for the follow-up flow
                        question1: NSLocalizedString("questionFourteenPartOne", comment: ""),
                        question2: NSLocalizedString("questionFourteenPartTwo", comment: ""),
                        volunteerAgain: $visitLog.volunteerAgain
                    ) {
                        isComplete = true
                        questionNumber = 100
                        saveVisitLog()
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        saveVisitLog()
                        isComplete = true
                        questionNumber = 100
                    }
                    
                case 100:
                    InputTileComplete(log: visitLog) {
                        // Ensure placeholderDate is defined or use a valid default
                        // visitLog.followUpWhenVisit = placeholderDate
                        saveVisitLog() // Regular save
                        presentation.wrappedValue.dismiss()
                    } shareAction: {
                        // saveVisitLog_Community() // Save for community
                    }
                    
                default:
                    Text("An error has occured")
                }
            }
            .onAppear {
                questionNumber = 1
                
                
                if currentUser == nil {
                    self.isLoading = true
                    
                    Auth.auth().signInAnonymously { result, error in
                        print("signed in anon")
                        self.isLoading = false
                    }
                }
            }
            .onChange(of: questionNumber) { newValue in
                if newValue == 12 && !didSetInitialRawDate {
                    initialRawDate = rawDate
                    didSetInitialRawDate = true
                        }
                    }
        }.navigationTitle(NSLocalizedString("interactionLog", comment: ""))
    } // end body
    
    
    func saveVisitLog() {
        let adapter = VisitLogDataAdapter()
        adapter.addVisitLog(self.visitLog)
    }
    
    // Original SegmentedProgressBar definition should remain here.
    // If you removed it previously, you need to ensure it is defined here:
    /*
    struct SegmentedProgressBar: View { ... }
    */
}
