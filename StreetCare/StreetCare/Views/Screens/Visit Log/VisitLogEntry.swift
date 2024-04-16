//
//  VisitLogEntry.swift
//  StreetCare
//
//  Created by Michael on 4/10/23.
//

import SwiftUI
import FirebaseAuth


struct VisitLogEntry: View {
    
    @Environment(\.presentationMode) var presentation
    
    @State var questionNumber = 1
    @State var totalQuestions = 5
    
    @StateObject var visitLog = VisitLog(id: "")
    
    var currentUser = Auth.auth().currentUser
    @State var isLoading = false
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Visit Log")
                    .font(.largeTitle)
                    .padding()
                                
                switch questionNumber {
                case 1:
                    InputTileDate(questionNumber: 1, totalQuestions: 5, question: "When was your visit?", datetimeValue: $visitLog.whenVisit) {
                        questionNumber += 1
                    } skipAction: {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    }
                    
                case 2:
                    InputTileLocation(questionNumber: 2, totalQuestions: 5, question: "Where was your visit?", textValue: $visitLog.whereVisit, location: $visitLog.location) {
                        questionNumber += 1
                    } previousAction: {
                        //
                    } skipAction: {
                        questionNumber += 1
                    }
                    
                case 3:
                    InputTileNumber(questionNumber: 3, totalQuestions: 5, question: "How many people did you help?", number: $visitLog.peopleHelped) {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        questionNumber += 1
                    }
                    
                case 4:
                    
                    InputTileList(questionNumber: 4, totalQuestions: 5, question: "What kind of help did you provide?", foodAndDrinks: $visitLog.foodAndDrinks, clothes: $visitLog.clothes, hygine: $visitLog.hygine, wellness: $visitLog.wellness, other: $visitLog.other, otherNotes: $visitLog.otherNotes) {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        questionNumber += 1
                    }
                    
                    
                case 5:
                    InputTileRate(questionNumber: 5, totalQuestions: 5, question: "Rate your outreach experience.", textValue: $visitLog.ratingNotes, rating: $visitLog.rating) {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        questionNumber += 1
                    }

                case 6:
                    
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

                case 7:
                    InputTileList(questionNumber: 1, totalQuestions: 4, question: "What further help is needed?", foodAndDrinks: $visitLog.furtherfoodAndDrinks, clothes: $visitLog.furtherClothes, hygine: $visitLog.furtherHygine, wellness: $visitLog.furtherWellness, other: $visitLog.furtherOther, otherNotes: $visitLog.furtherOtherNotes) {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    } skipAction: {
                        questionNumber += 1
                    }
                    
                case 8:
                    InputTileNumber(questionNumber: 2, totalQuestions: 4, question: "How many people need further help?", number: $visitLog.peopleNeedFurtherHelp) {
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
                    
                    
                case 9:
                    InputTileDate(questionNumber: 3, totalQuestions: 4, question: "Is there a day for the follow-up visit?", datetimeValue: $visitLog.followUpWhenVisit) {
                        questionNumber += 1
                    } skipAction: {
                        questionNumber += 1
                    } previousAction: {
                        questionNumber -= 1
                    }
                    
                case 10:
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
        }.navigationTitle("Visit Log")
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
