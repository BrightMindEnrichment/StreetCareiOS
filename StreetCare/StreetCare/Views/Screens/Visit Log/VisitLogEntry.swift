//
//  VisitLogEntry.swift
//  StreetCare
//
//  Created by Saheer on 1/15/26.
//

import SwiftUI
import FirebaseAuth
import CoreLocation
import CoreLocationUI

struct VisitLogEntry: View {
    
    @Environment(\.presentationMode) var presentation
    @State private var questionNumber: Int = 1
    @State var totalQuestions = 7
    @State private var selectedLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)

    @StateObject var visitLog = VisitLog(id: UUID().uuidString)
    @State private var currentInteractionLog = VisitLog(id: UUID().uuidString)
    @StateObject private var adapter = VisitLogDataAdapter()

    var currentUser = Auth.auth().currentUser
    @State var isLoading = false
    @State var isComplete = false
    @State private var volunteerAgain: Int = -1

    @State var rawDate: Date = Date()
    @State private var rawEndDate: Date? = Date().addingTimeInterval(3600)
    @State private var selectedTimeZone: String = TimeZone.current.identifier

    @State private var initialRawDate: Date = Date()
    @State private var didSetInitialRawDate = false
    @State var adjustedDate: Date = Date()

    @StateObject private var keyboard = KeyboardHeightObserver()

    // Personal details
    @State private var personalDetails = PersonalDetails()
    @State private var individualInteractions: [IndividualInteractionItem] = []
    @State private var editingIndex: Int? = nil
    @State private var didCommitOnThisPass: Bool = false
    @State private var isCreatingNewInteraction: Bool = false
    
    //Store question number for back button from case 15 to 7 and case 15 to 12
    @State private var previousQuestion: Int? = nil
    private func goTo(_ next: Int) {
        previousQuestion = questionNumber
        questionNumber = next
    }
    
    private var headerTitle: String {
        switch questionNumber {
        // For the specific data entry steps
        case 8, 9, 10, 11:
            return "Individual Interaction \(individualInteractions.count + 1)"
            
        // For the summary and follow-up steps
        case 12, 13:
            return "Individual Interaction"
            
        // Default title for steps 1-7 and others
        default:
            return NSLocalizedString("logYourInteraction", comment: "")
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {

                if !isComplete && questionNumber != 100 {
                    Text(headerTitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                }
                switch questionNumber {

                case 1:
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
                            visitLog.whenVisit = rawDate
                            visitLog.whenVisitEnd = rawEndDate ?? rawDate

                            let cityName = selectedTimeZone.split(separator: "/").last?
                                .replacingOccurrences(of: "_", with: " ") ?? selectedTimeZone
                            visitLog.city = String(cityName)

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
                    InputTileDetails(
                        questionNumber: 2,
                        totalQuestions: totalQuestions,
                        cardTitle: "Personal details",
                        showSkip: true,
                        showPrevious: true,
                        rawDate: $rawDate,
                        rawEndDate: $rawEndDate,
                        timeZoneIdentifier: $selectedTimeZone,
                        personalDetails: $personalDetails,
                        nextAction: {
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
                    InputTileLocation(
                        questionNumber: 3,
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
                        nextAction: { questionNumber += 1 },
                        previousAction: { questionNumber -= 1 },
                        skipAction: { questionNumber += 1 },
                        buttonMode: .navigation
                    )
                    .padding(.bottom, keyboard.currentHeight == 0 ? 0 : keyboard.currentHeight - 270)
                    .animation(.easeOut(duration: 0.16), value: keyboard.currentHeight)

//                case 4:
//                    InputTileNumber(
//                        questionNumber: 4,
//                        totalQuestions: totalQuestions,
//                        tileWidth: 360,
//                        tileHeight: 520,
//                        question1: NSLocalizedString("questionThreePartOne", comment: ""),
//                        question2: NSLocalizedString("questionThreePartTwo", comment: ""),
//                        question3: NSLocalizedString("questionThreePartThree", comment: ""),
//                        question4: NSLocalizedString("questionThreePartFour", comment: ""),
//                        descriptionLabel: "Description",
//                        disclaimerText: NSLocalizedString("disclaimer", comment: ""),
//                        placeholderText: NSLocalizedString("peopledescription", comment: ""),
//                        number: $visitLog.peopleHelped,
//                        generalDescription: $visitLog.peopleHelpedDescription,
//                        generalDescription2: .constant(""),
//                        nextAction: { questionNumber += 1 },
//                        previousAction: { questionNumber -= 1 },
//                        skipAction: { questionNumber += 1 }
//                    )
//                    .padding(.bottom, keyboard.currentHeight == 0 ? 0 : 35)
//                    .animation(.easeOut(duration: 0.16), value: keyboard.currentHeight)
                case 4:
                    InputTileList(
                        questionNumber: 4,
                        totalQuestions: 7,
                        optionCount: 5,
                        size: CGSize(width: 360, height: 450),
                        question1: NSLocalizedString("questionFourPartOne", comment: ""),
                        question2: NSLocalizedString("questionFourPartTwo", comment: ""),
                        visitLog: visitLog,
                        nextAction: {
                            visitLog.listOfSupportsProvided = visitLog.whatGivenSupport
                            questionNumber += 1
                        },
                        previousAction: { questionNumber -= 1 },
                        skipAction: { questionNumber += 1 },
                        buttonMode: .navigation,
                        showProgressBar: false,
                        supportMode: .support
                    )
                    .padding(.bottom, keyboard.currentHeight == 0 ? 0 : keyboard.currentHeight - 250)
                    .animation(.easeOut(duration: 0.16), value: keyboard.currentHeight)

                case 5:
                    InputTileNumber(
                        questionNumber: 5,
                        totalQuestions: 7,
                        tileWidth: 360,
                        tileHeight: 415,
                        question1: NSLocalizedString("questionFivePartOne", comment: ""),
                        question2: NSLocalizedString("questionFivePartTwo", comment: ""),
                        question3: NSLocalizedString("questionFivePartThree", comment: ""),
                        question4: "",
                        descriptionLabel: "",
                        disclaimerText: "",
                        placeholderText: "",
                        number: $visitLog.numPeopleHelped,
                        number2: Binding<Int?>(
                            get: { visitLog.numPeopleJoined },
                            set: { visitLog.numPeopleJoined = $0 ?? 0 }
                        ),
                        dualNumberMode: true,
                        showTextEditor: false,
                        generalDescription: .constant(""),
                        generalDescription2: .constant(""),
                        nextAction: { questionNumber += 1 },
                        previousAction: { questionNumber -= 1 },
                        skipAction: { questionNumber += 1 },
                        showProgressBar: true
                    )
                    .padding(.bottom, keyboard.currentHeight == 0 ? 0 : 35)
                    .animation(.easeOut(duration: 0.16), value: keyboard.currentHeight)

                case 6:
                    InputTileNumber(
                        questionNumber: 6,
                        totalQuestions: 7,
                        tileWidth: 360,
                        tileHeight: 545,
                        question1: NSLocalizedString("questionSixPartOne", comment: ""),
                        question2: NSLocalizedString("questionSixPartTwo", comment: ""),
                        question3: "",
                        question4: "",
                        descriptionLabel: "",
                        editorHeaderLine1: NSLocalizedString("whatItemsIncludedLine1", comment: ""),
                        editorHeaderLine2: NSLocalizedString("whatItemsIncludedLine2", comment: ""),
                        disclaimerText: "",
                        placeholderText: "Enter notes here",
                        number: $visitLog.carePackagesDistributed,
                        generalDescription: $visitLog.carePackageContents,
                        generalDescription2: .constant(""),
                        nextAction: { questionNumber += 1 },
                        previousAction: { questionNumber -= 1 },
                        skipAction: { questionNumber += 1 },
                        showProgressBar: true
                    )
                    .padding(.bottom, keyboard.currentHeight == 0 ? 0 : 35)
                    .animation(.easeOut(duration: 0.16), value: keyboard.currentHeight)

                case 7:
                    InputTileMoreQuestions(
                        question1: NSLocalizedString("questionSevenPartOne", comment: ""),
                        question2: NSLocalizedString("questionSevenPartTwo", comment: ""),
                        question3: NSLocalizedString("questionSevenPartThree", comment: ""),
                        questionNumber: 6,
                        totalQuestions: 6,
                        nextAction: {
                            goTo(15)
                        },
                        skipAction: {
                            questionNumber -= 1
                        },
                        yesAction: {
                            isCreatingNewInteraction = true
                            editingIndex = nil
                            didCommitOnThisPass = false
                            questionNumber += 1
                        },
                        noAction: {
//                            saveVisitLog()
                            isComplete = true
                            goTo(15)
                        },
                        previousAction: {
                            questionNumber -= 1
                        }
                    )
                case 8:
                    InputTileIndividualInteraction(
//                        log: visitLog,
                        log: currentInteractionLog,
                        questionTitle: "",
                        questionNumber: 1,
                        totalQuestions: 4,
                        skipAction: { questionNumber += 1 },
                        previousAction: { questionNumber = 7 },
                        nextAction: { questionNumber += 1 }
                    )
                case 9:
                    InputTileList(
                        questionNumber: 2,
                        totalQuestions: 4,
                        optionCount: 5,
                        size: CGSize(width: 360, height: 450),
                        question1: NSLocalizedString("questionNinePartOne", comment: ""),
                        question2: NSLocalizedString("questionNinePartTwo", comment: ""),
                        visitLog: currentInteractionLog,
                        nextAction: {
                            currentInteractionLog.helpProvidedCategory = currentInteractionLog.whatGiven
                            questionNumber += 1
                        },
                        previousAction: { questionNumber -= 1 },
                        skipAction: { questionNumber += 1 },
                        buttonMode: .navigation,
                        showProgressBar: false,
                        supportMode: .provided
                    )
                    .padding(.bottom, keyboard.currentHeight == 0 ? 0 : keyboard.currentHeight - 250)
                    .animation(.easeOut(duration: 0.16), value: keyboard.currentHeight)

                case 10:
                    InputTileList(
                        questionNumber: 3,
                        totalQuestions: 4,
                        optionCount: 5,
                        size: CGSize(width: 360, height: 450),
                        question1: NSLocalizedString("questionTenPartOne", comment: ""),
                        question2: NSLocalizedString("questionTenPartTwo", comment: ""),
                        visitLog: currentInteractionLog,
                        nextAction: {
                            currentInteractionLog.furtherHelpCategory = currentInteractionLog.whatGivenFurther
                            questionNumber += 1
                        },
                        previousAction: { questionNumber -= 1 },
                        skipAction: { questionNumber += 1 },
                        buttonMode: .navigation,
                        showProgressBar: false,
                        supportMode: .needed

                    )
                    .padding(.bottom, keyboard.currentHeight == 0 ? 0 : keyboard.currentHeight - 250)
                    .animation(.easeOut(duration: 0.16), value: keyboard.currentHeight)
                case 11:
                    InputTileFollowUpDate(
                        questionNumber: 4,
                        totalQuestions: 4,
                        question1: NSLocalizedString("questionElevenPartOne", comment: ""),
                        question2: NSLocalizedString("questionElevenPartTwo", comment: ""),
                        showSkip: false,
                        showProgressBar: false,
                        initialDateValue: rawDate,
                        datetimeValue: $rawDate,
                        convertedDate: $currentInteractionLog.helpRequestFollowUpTimestamp,
                        additionalDetails: $currentInteractionLog.helpRequestAdditionalDetails,
                        nextAction: {
                            if didCommitOnThisPass {
                                questionNumber = 12
                                return
                            }

                            didCommitOnThisPass = true

                            let title: String
                            if let idx = editingIndex {
                                title = "Individual Interaction \(idx + 1)"
                            } else {
                                title = "Individual Interaction \(individualInteractions.count + 1)"
                            }

                            let newItem = IndividualInteractionItem(
                                title: title,
                                firstName: currentInteractionLog.recipientFirstName,
                                lastName: currentInteractionLog.recipientLastName,
                                helpProvidedCategory: currentInteractionLog.helpProvidedCategory,
                                furtherHelpCategory: currentInteractionLog.furtherHelpCategory,
                                additionalDetails: currentInteractionLog.helpRequestAdditionalDetails,
                                followUpTimestamp: currentInteractionLog.helpRequestFollowUpTimestamp
                            )
                            if isCreatingNewInteraction {
                                individualInteractions.append(newItem)
                            } else if let idx = editingIndex,
                                      idx >= 0,
                                      idx < individualInteractions.count {
                                individualInteractions[idx] = newItem
                            }
                            currentInteractionLog = VisitLog(id: UUID().uuidString)
                            questionNumber = 12
                        },
                        skipAction: { questionNumber += 1 },
                        previousAction: { questionNumber -= 1 },
                    )
                    .padding(.bottom, keyboard.currentHeight == 0 ? 0 : 24)
                case 12: //Individual Interactions Summary Page
                    InputTileIndividualInteractionsSummary(
                        questionNumber: 4,
                        totalQuestions: 4,
                        interactions: $individualInteractions,
                        previousAction: {
                            didCommitOnThisPass = false
                            isCreatingNewInteraction = false
                            questionNumber = 11
                        },
                        nextAction: {
                            isCreatingNewInteraction = false
                            editingIndex = nil
                            goTo(15)
                        },
                        addMoreAction: {
                            isCreatingNewInteraction = true
                            editingIndex = nil
                            didCommitOnThisPass = false
                            currentInteractionLog = VisitLog(id: UUID().uuidString)   //  RESET
                            questionNumber = 8
                        },
                        editAction: { _, index in
                            isCreatingNewInteraction = false
                            editingIndex = index
                            didCommitOnThisPass = false
                            questionNumber = 8
                        },
                        deleteAction: { _, index in
                            if index >= 0 && index < individualInteractions.count {
                                individualInteractions.remove(at: index)
                                renumberIndividualInteractionTitles()
                            }
                            // Keep editing index aligned with the mutated array.
                            if let currentEditingIndex = editingIndex {
                                if currentEditingIndex == index {
                                    editingIndex = nil
                                } else if currentEditingIndex > index {
                                    editingIndex = currentEditingIndex - 1
                                }
                            }
                        },
                        showProgressBar:false,
                    )
                case 13:
                    InputTileDate(
                        questionNumber: 5,
                        totalQuestions: totalQuestions,
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
                    InputTileNotes(
                        questionNumber: 6,
                        totalQuestions: totalQuestions,
                        tileWidth: 360,
                        tileHeight: 380,
                        question1: NSLocalizedString("questionThirteenPartOne", comment: ""),
                        question2: NSLocalizedString("questionThirteenPartTwo", comment: ""),
                        question3: NSLocalizedString("questionThirteenPartThree", comment: ""),
                        placeholderText: NSLocalizedString("aq6des", comment: ""),
                        otherNotes: $visitLog.furtherOtherNotes,
                        nextAction: { questionNumber += 1 },
                        previousAction: { questionNumber -= 1 },
                        skipAction: {
                            saveVisitLog()
                            questionNumber += 1
                        },
                        buttonMode: .navigation
                    )
                                
                case 15:
                    InputTileConsent(
                        size: CGSize(width: 360, height: 450),
                               submitAction: {
                                   saveVisitLog()
                                   // Move to next question after consent is given
                                   questionNumber = 100
                                  //navigateNext = true
                               }
                           )
                           .padding(.bottom, keyboard.currentHeight == 0 ? 0 : 50)
                           .animation(.easeOut(duration: 0.16), value: keyboard.currentHeight)

                   
                case 100:
                    InputTileComplete(log: visitLog) {
//                        saveVisitLog()
                        presentation.wrappedValue.dismiss()
                    } shareAction: {
                        // saveVisitLog_Community()
                    }

                default:
                    Text("An error has occured")
                }
            }
            .onAppear {
                questionNumber = 1

                if currentUser == nil {
                    self.isLoading = true
                    Auth.auth().signInAnonymously { _, _ in
                        print("signed in anon")
                        self.isLoading = false
                    }
                }
            }
            .onChange(of: questionNumber) { newValue in
                // keeping your existing logic exactly
                if newValue == 12 && !didSetInitialRawDate {
                    initialRawDate = rawDate
                    didSetInitialRawDate = true
                }
            }
        }
        .navigationTitle(NSLocalizedString("interactionLog", comment: ""))
        //hiding default back button on top navigation bar and adding new Back functionality
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    handleBack()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
    }
    private func handleBack() {
        if let prev = previousQuestion {
            questionNumber = prev
            previousQuestion = nil   // clear after use
        } else if questionNumber > 1 {
            questionNumber -= 1
        } else {
            presentation.wrappedValue.dismiss()
        }
    }
    func saveVisitLog() {
        adapter.addVisitLog(self.visitLog, interactions: individualInteractions)
    }
    
    // Rebuild titles to match the current list order.
    private func renumberIndividualInteractionTitles() {
        for idx in individualInteractions.indices {
            individualInteractions[idx].title = "Individual Interaction \(idx + 1)"
        }
    }
}
