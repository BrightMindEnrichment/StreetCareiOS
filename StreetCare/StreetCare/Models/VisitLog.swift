//
//  VisitLog.swift
//  StreetCare
//
//  Created by Michael on 4/26/23.
//

import Foundation


class VisitLog: ObservableObject, Identifiable {
    
    @Published var id: String
    
    @Published var whereVisit = ""
    @Published var whenVisit = Date()
    @Published var peopleHelped = 1
    
    @Published var foodAndDrinks = false
    @Published var clothes = false
    @Published var hygine = false
    @Published var wellness = false
    @Published var other = false
    @Published var otherNotes = ""
    
    @Published var rating = 0
    @Published var ratingNotes = ""
    
    @Published var durationHours = 0
    @Published var durationMinutes = 30
    
    @Published var numberOfHelpers = 0
    
    @Published var volunteerAgain = 0
    
    init(id: String) {
        self.id = id
    }
    
} // end class
