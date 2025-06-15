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

struct VisitLogEntry: View {
    
    @Environment(\.presentationMode) var presentation
    
    @State var questionNumber = 1
    @State var totalQuestions = 6
    @State private var selectedLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    @StateObject var visitLog = VisitLog(id: UUID().uuidString)
    
    var currentUser = Auth.auth().currentUser
    @State var isLoading = false
    @State var isComplete = false
    @State private var volunteerAgain: Int = -1
    
    
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
                    InputTileDate(questionNumber: 1, totalQuestions: 6, question1: NSLocalizedString("questionOne", comment: ""),question2: NSLocalizedString("interaction", comment: "") + "?" ,question3: "", showSkip: false,  datetimeValue: $visitLog.whenVisit) {
                        questionNumber += 1
                    } skipAction: {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    }
                    
                case 2:
                    InputTileLocation(
                        questionNumber: 2,
                        totalQuestions: 6,
                        question1: NSLocalizedString("questionTwo", comment: ""),question2: NSLocalizedString("interaction", comment: "") + "?",
                        textValue: Binding(
                            get: { visitLog.whereVisit },
                            set: { newValue in
                                visitLog.whereVisit = newValue // ✅ Updates whereVisit
                                print("📍 Updated visitLog.whereVisit: \(visitLog.whereVisit)")
                            }
                        ),
                        location: Binding(
                            get: { visitLog.location }, // ✅ Ensure visitLog.location updates
                            set: { newValue in
                                visitLog.location = newValue
                                print("📍 Updated visitLog.location: \(visitLog.location.latitude), \(visitLog.location.longitude)")
                            }
                        )
                    ) {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        questionNumber += 1
                    }
                    
                case 3:
                    InputTileNumber(questionNumber: 3, totalQuestions: 6, tileWidth: 360, tileHeight: 560, question1: NSLocalizedString("questionThreePartOne", comment: "") , question2: NSLocalizedString("questionThreePartTwo", comment: "") ,question3: NSLocalizedString("questionThreePartThree", comment: ""), question4: NSLocalizedString("questionThreePartFour", comment: ""), descriptionLabel: "Description", disclaimerText: NSLocalizedString("disclaimer", comment: ""), placeholderText: NSLocalizedString("peopledescription", comment: ""), number: $visitLog.peopleHelped) {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        questionNumber += 1
                    }
                    
                case 4:
                    InputTileList(
                        questionNumber: 4,
                        totalQuestions: 6,
                        question1: NSLocalizedString("questionFourPartOne", comment: ""),
                        question2: NSLocalizedString("questionFourPartTwo", comment: ""),
                        foodAndDrinks: $visitLog.foodAndDrinks,
                        clothes: $visitLog.clothes,
                        hygine: $visitLog.hygine,
                        wellness: $visitLog.wellness,
                        medical: $visitLog.medical,
                        socialworker: $visitLog.socialworker,
                        legal: $visitLog.legal,
                        other: $visitLog.other,
                        otherNotes: $visitLog.otherNotes
                    ) {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        questionNumber += 1
                    }
                    
                case 5:
                    InputTileNumber(questionNumber: 5, totalQuestions: 6, tileWidth: 300, tileHeight: 460, question1: NSLocalizedString("questionFivePartOne", comment: "") , question2: NSLocalizedString("questionFivePartTwo", comment: ""), question3:"", question4:"", descriptionLabel: "", disclaimerText: "", placeholderText: NSLocalizedString("questionFivePlaceholder", comment: ""), number: $visitLog.itemQty) {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        questionNumber += 1
                    }
                case 6:
                    InputTileRate(questionNumber: 6, totalQuestions: 6, question1: NSLocalizedString("questionSixPartOne", comment: ""), question2: NSLocalizedString("questionSixPartTwo", comment: ""), textValue: $visitLog.ratingNotes, rating: $visitLog.rating) {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        questionNumber += 1
                    }
                    
                case 7:
                    
                    InputTileMoreQuestions(question1: NSLocalizedString("questionSevenPartOne", comment: "") , question2: NSLocalizedString("questionSevenPartTwo", comment: ""), question3:NSLocalizedString("questionSevenPartThree", comment: ""), questionNumber: 6, totalQuestions: 6) {
                        saveVisitLog()
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
                case 8:
                    InputTileDuration(
                        questionNumber: 1,
                        totalQuestions: 7,
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
                    
                case 9:
                    InputTileNumber(questionNumber: 2, totalQuestions: 7, tileWidth: 360, tileHeight: 467, question1: NSLocalizedString("questionNinePartOne", comment: "") , question2: NSLocalizedString("questionNinePartTwo", comment: "") ,question3: "",question4: "",placeholderText: NSLocalizedString("aq2des", comment: ""), number: $visitLog.numberOfHelpers) {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        questionNumber += 1
                    }
                    
                case 10:
                    InputTileNumber(questionNumber: 3, totalQuestions: 7, tileWidth: 360, tileHeight: 600, question1: NSLocalizedString("questionTenPartOne", comment: "") , question2: NSLocalizedString("questionTenPartTwo", comment: ""), question3: "", question4: "", descriptionLabel: "Description", disclaimerText: "", placeholderText: NSLocalizedString("aq3des", comment: ""), descriptionLabel2: "Location Description",placeholderText2: NSLocalizedString("questionTenPlaceholder", comment: ""), number: $visitLog.peopleNeedFurtherHelp, peopleLocationDescription: $visitLog.peopleNeedFurtherHelpLocation) {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        questionNumber += 1
                    }
                case 11:
                    InputTileList(
                        questionNumber: 4,
                        totalQuestions: 7,
                        question1: NSLocalizedString("questionElevenPartOne", comment: ""),
                        question2: NSLocalizedString("questionElevenPartTwo", comment: ""),
                        foodAndDrinks: $visitLog.furtherfoodAndDrinks,
                        clothes: $visitLog.furtherClothes,
                        hygine: $visitLog.furtherHygine,
                        wellness: $visitLog.furtherWellness,
                        medical: $visitLog.medical,
                        socialworker: $visitLog.socialworker,
                        legal: $visitLog.legal,
                        other: $visitLog.furtherOther,
                        otherNotes: $visitLog.furtherOtherNotes
                    ) {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        questionNumber += 1
                    }
                case 14:
                    InputTileVolunteerAgain(questionNumber: 7, totalQuestions: 7, question1: NSLocalizedString("questionFourteenPartOne", comment: ""), question2: NSLocalizedString("questionFourteenPartTwo", comment: ""), volunteerAgain: $visitLog.volunteerAgain) {
                        saveVisitLog()
                        isComplete = true
                        questionNumber = 100
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        saveVisitLog()
                        isComplete = true
                        questionNumber = 100
                    }
                case 12:
                    InputTileDate(questionNumber: 5, totalQuestions: 7, question1: NSLocalizedString("questionTwelevePartOne", comment: ""), question2: NSLocalizedString("questionTwelevePartTwo", comment: ""), question3:NSLocalizedString("questionTwelevePartThree", comment: ""), showSkip: true, datetimeValue: $visitLog.followUpWhenVisit) {
                        questionNumber += 1
                    } skipAction: {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    }
                    
                case 13:
                    InputTileNotes(questionNumber: 6, totalQuestions: 7,tileWidth: 360, tileHeight: 380, question1: NSLocalizedString("questionThirteenPartOne", comment: ""), question2: NSLocalizedString("questionThirteenPartTwo", comment: ""), question3:NSLocalizedString("questionThirteenPartThree", comment: ""), placeholderText: NSLocalizedString("aq6des", comment: ""), otherNotes: $visitLog.furtherOtherNotes) {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        saveVisitLog()
                        questionNumber += 1
                    }
                    
                case 100:
                    InputTileComplete() {
                        //saveVisitLog() // Regular save
                        presentation.wrappedValue.dismiss()
                    } shareAction: {
                        //saveVisitLog()
                        saveVisitLog_Community() // Save for community
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
        }.navigationTitle(NSLocalizedString("interactionLog", comment: ""))
    } // end body
    
    
    func saveVisitLog() {
        let adapter = VisitLogDataAdapter()
        adapter.addVisitLog(self.visitLog)
    }
    
    func saveVisitLog_Community() {
        let adapter = VisitLogDataAdapter()
        //adapter.addVisitLog(self.visitLog)
        adapter.addVisitLog_Community(self.visitLog)
    }
    
} // end struct

struct VisitLogEntry_Previews: PreviewProvider {
    static var previews: some View {
        VisitLogEntry()
    }
}

struct SegmentedProgressBar: View {
    var totalSegments: Int
    var filledSegments: Int
    var tileWidth: CGFloat
    let segmentHeight: CGFloat = 12
    let spacing: CGFloat = 8
    
    var body: some View {
        let totalSpacing = spacing * CGFloat(totalSegments - 1)
        let segmentWidth = (tileWidth - totalSpacing - 20) / CGFloat(totalSegments)
        
        HStack(spacing: spacing) {
            ForEach(0..<totalSegments, id: \.self) { index in
                Capsule()
                    .fill(index < filledSegments ? Color("PrimaryColor") : Color("SecondaryColor"))
                    .frame(width: segmentWidth, height: segmentHeight)
                    .overlay(
                        Group {
                            if index == filledSegments - 1 {
                                Capsule()
                                    .stroke(Color("SecondaryColor"), lineWidth: 1)
                            } else if index >= filledSegments {
                                Capsule()
                                    .stroke(Color("SecondaryColor"), lineWidth: 1)
                            } else {
                                EmptyView()
                            }
                        }
                    )
            }
        }
        .frame(width: tileWidth - 20)
        .padding(.top, 4)
    }
}
