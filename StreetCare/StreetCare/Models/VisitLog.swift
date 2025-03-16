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
    @Published var street = ""
    @Published var city = ""
    @Published var state = ""
    @Published var stateAbbv = ""
    @Published var zipcode = ""
    
    @Published var whenVisit = Date()
    @Published var peopleHelped = 1
    
    @Published var foodAndDrinks = false
    @Published var clothes = false
    @Published var hygine = false
    @Published var wellness = false
    @Published var medical = false
    @Published var socialworker = false
    @Published var legal = false
    @Published var other = false
    @Published var otherNotes = ""

    @Published var furtherfoodAndDrinks = false
    @Published var furtherClothes = false
    @Published var furtherHygine = false
    @Published var furtherWellness = false
    @Published var furtherOther = false
    @Published var furtherOtherNotes = ""
    
    @Published var rating = 0
    @Published var ratingNotes = ""
    
    @Published var durationHours = 0
    @Published var durationMinutes = 30
    
    @Published var numberOfHelpers = 0
    
    @Published var volunteerAgain = 0
    
    @Published var location = CLLocationCoordinate2D.init(latitude: 0.0, longitude: 0.0)
    
    @Published var peopleNeedFurtherHelp = 0
    @Published var followUpWhenVisit = Date()
    @Published var itemQty = 0

    var whatGiven: [String] {
        var given = [String]()
        
        if foodAndDrinks { given.append("Food and Drink") }
        if clothes { given.append("Clothes") }
        if hygine { given.append("Hygiene Products") }
        if wellness { given.append("Wellness/ Emotional Support") }
        if medical { given.append("Medical Help") }
        if socialworker { given.append("Social Worker /Psychiatrist") }
        if legal { given.append("Legal/Lawyer") }
        if other, !otherNotes.isEmpty { given.append(otherNotes) }
        
        return given
    }
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
