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
    @State var totalQuestions = 5
    @State private var selectedLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    @StateObject var visitLog = VisitLog(id: "")
    
    var currentUser = Auth.auth().currentUser
    @State var isLoading = false
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Log Your Interaction")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                                
                switch questionNumber {
                case 1:
                    InputTileDate(questionNumber: 1, totalQuestions: 6, question1: "When was your",question2: "Interaction?", datetimeValue: $visitLog.whenVisit) {
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
                        question: "Where was your visit?",
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
                    InputTileNumber(questionNumber: 3, totalQuestions: 6, question1: "How many people" , question2: "did you help?", number: $visitLog.peopleHelped) {
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
                        question1: "What kind of help",
                        question2: "did you provide?",
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
                    InputTileNumber(questionNumber: 5, totalQuestions: 6, question1: "How many items" , question2: "did you donate?", number: $visitLog.peopleHelped) {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        questionNumber += 1
                    }
                case 6:
                    InputTileRate(questionNumber: 6, totalQuestions: 6, question1: "How would you rate your", question2: "outreach experience?", textValue: $visitLog.ratingNotes, rating: $visitLog.rating) {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        questionNumber += 1
                    }

                case 7:
                    
                    InputTileMoreQuestions(question: "Do they need further help?") {
                        saveVisitLog()
                        questionNumber = 100
                    } skipAction: {
                        questionNumber -= 1
                    } yesAction: {
                        questionNumber += 1
                    } noAction: {
                        saveVisitLog()
                        questionNumber = 100
                    }

                    
                case 8:
                    InputTileList(
                        questionNumber: 1,
                        totalQuestions: 4,
                        question1: "What kind of help do",
                        question2: "they still need?",
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
                    
                case 9:
                    InputTileNumber(questionNumber: 3, totalQuestions: 5, question1: "How many people" , question2: "still need help?", number: $visitLog.peopleHelped) {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        questionNumber += 1
                    }
//                case 8:
//                    InputTileDuration(questionNumber: 2, totalQuestions: 5, question: "Approximate time spent on outreach?", hours: $visitLog.durationHours, minutes: $visitLog.durationMinutes) {
//                        questionNumber += 1
//                    } previousAction: {
//                        questionNumber -= 1
//                    } skipAction: {
//                        questionNumber += 1
//                    }
                    

                    
//                case 8:
//                    InputTileNumber(questionNumber: 2, totalQuestions: 3, question: "How many people joined or helped you prepare?", number: $visitLog.numberOfHelpers) {
//                        questionNumber += 1
//                        saveVisitLog()
//                    } previousAction: {
//                        questionNumber -= 1
//                    } skipAction: {
//                        questionNumber += 1
//                        saveVisitLog()
//                    }
                case 10:
                    InputTileDate(questionNumber: 3, totalQuestions: 4, question1: "Is there a planned date to",question2: "interact with them again?", datetimeValue: $visitLog.followUpWhenVisit) {
                        questionNumber += 1
                    } skipAction: {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    }
                    
                case 11:
                    InputTileVolunteerAgain(questionNumber: 4, totalQuestions: 4, question: "Would you like to volunteer again?", volunteerAgain: $visitLog.volunteerAgain) {
                        saveVisitLog()
                        questionNumber = 100
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        saveVisitLog()
                        questionNumber = 100
                    }
                    
                case 100:
                    InputTileComplete(question: "Complete!") {
                        presentation.wrappedValue.dismiss()
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
        }.navigationTitle("Interaction Log")
    } // end body
    
    
    func saveVisitLog() {
        let adapter = VisitLogDataAdapter()
        adapter.addVisitLog(self.visitLog)
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

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSegments, id: \.self) { index in
                Capsule()
                    .fill(index < filledSegments ? Color.yellow : Color("SecondaryColor"))
                    .frame(width: 35, height: 12)
                    .overlay(
                        Capsule()
                            .stroke(Color("SecondaryColor"), lineWidth: 1)
                    )
            }
        }
        .padding(.top, 4)
    }
}
