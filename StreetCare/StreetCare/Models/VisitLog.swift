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

    // Visit details
    @Published var whereVisit = ""
    @Published var locationDescription = ""
    @Published var whenVisit = Date()
    @Published var followUpWhenVisit = Date()
    @Published var timeStamp = Date() // initial log creation time
    @Published var lastEdited = Date() // most recent update time
    
    // Address components
    @Published var street = ""
    @Published var city = ""
    @Published var state = ""
    @Published var stateAbbv = ""
    @Published var zipcode = ""
    @Published var location = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    // People helped
    @Published var peopleHelped = 0
    @Published var peopleHelpedDescription = ""
    
    // Type of help provided
    @Published var foodAndDrinks = false
    @Published var clothes = false
    @Published var hygiene = false
    @Published var wellness = false
    @Published var medical = false
    @Published var social = false
    @Published var legal = false
    @Published var other = false
    @Published var otherNotes = ""

    // Items given
    @Published var itemQty = 0
    @Published var itemQtyDescription = ""

    var whatGiven: [String] {
        var given = [String]()
        if foodAndDrinks { given.append("Food and Drink") }
        if clothes { given.append("Clothes") }
        if hygiene { given.append("Hygiene Products") }
        if wellness { given.append("Wellness/ Emotional Support") }
        if medical { given.append("Medical Help") }
        if social { given.append("Social Worker /Psychiatrist") }
        if legal { given.append("Legal/Lawyer") }
        if other, !otherNotes.isEmpty { given.append(otherNotes) }
        return given
    }

    // Rating
    @Published var rating = 0
    @Published var ratingNotes = ""

    // Duration
    @Published var durationHours = -1
    @Published var durationMinutes = -1

    // Helpers
    @Published var numberOfHelpers = 0
    @Published var numberOfHelpersComment = ""

    // People still needing help
    @Published var peopleNeedFurtherHelp = 0
    @Published var peopleNeedFurtherHelpComment = ""
    @Published var peopleNeedFurtherHelpLocation = ""
    
    // Further help needed
    @Published var furtherFoodAndDrinks = false
    @Published var furtherClothes = false
    @Published var furtherHygiene = false
    @Published var furtherWellness = false
    @Published var furtherMedical = false
    @Published var furtherSocial = false
    @Published var furtherLegal = false
    @Published var furtherOther = false
    @Published var furtherOtherNotes = ""
    
    var whatGivenFurther: [String] {
        var further = [String]()
        if furtherFoodAndDrinks { further.append("Food and Drink") }
        if furtherClothes { further.append("Clothes") }
        if furtherHygiene { further.append("Hygiene Products") }
        if furtherWellness { further.append("Wellness/ Emotional Support") }
        if furtherMedical { further.append("Medical Help") }
        if furtherSocial { further.append("Social Worker /Psychiatrist") }
        if furtherLegal { further.append("Legal/Lawyer") }
        if furtherOther, !furtherOtherNotes.isEmpty { further.append(furtherOtherNotes) }
        return further
    }

    // Volunteer preference
    @Published var volunteerAgain = -1
    var volunteerAgainText: String {
        switch volunteerAgain {
        case 1: return "Yes"
        case 0: return "No"
        default: return "Maybe"
        }
    }

    // Misc
    @Published var type = "" // "Android" or "iOS"
    @Published var status = ""
    @Published var flaggedByUser = ""
    
    var didProvideSpecificHelp: Bool {
        return foodAndDrinks || clothes || hygiene || wellness || medical || social || legal || other
    }

    init(id: String) {
        self.id = id
    }
    
    
    func reverseGeocode(latitude: Double, longitude: Double) {
        // Create the URL with the API endpoint and parameters
        let baseUrl = "https://api.geoapify.com/v1/geocode/reverse"
        let latLonParams = "lat=\(latitude)&lon=\(longitude)&apiKey=fd35651164a04eac9266ccfb75aa125d"
        let urlString = "\(baseUrl)?\(latLonParams)"

        // Create the URLSession and URLRequest
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        // Send the request
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }

            // Check the response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }

            // Process the data
            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
                    // Handle the JSON response
                    print(json)
                } else {
                    print("Unable to parse JSON data")
                }
            } else {
                print("No data received")
            }
        }

        task.resume()
    }
} // end class

