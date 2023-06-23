//
//  VisitLog.swift
//  StreetCare
//
//  Created by Michael on 4/26/23.
//

import Foundation
import CoreLocation


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
    
    @Published var location = CLLocationCoordinate2D.init(latitude: 0.0, longitude: 0.0)
    

    var didProvideSpecificHelp: Bool {
        return foodAndDrinks || clothes || hygine || wellness || other
    }
    
    
    var volunteerAgainText: String {
        switch(volunteerAgain) {
        case 0:
            return "No"
        case 1:
            return "Yes"
        default:
            return "Maybe"
        }
    }

    init(id: String) {
        self.id = id
    }
    
} // end class
