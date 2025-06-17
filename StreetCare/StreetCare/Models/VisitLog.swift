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
    @Published var whenVisit = Date()
    @Published var whereVisit = ""
    @Published var locationDescription = ""
    @Published var peopleHelped = 0
    @Published var peopleHelpedDescription = ""
    @Published var foodAndDrinks = false
    @Published var clothes = false
    @Published var hygiene = false
    @Published var wellness = false
    @Published var medical = false
    @Published var social = false
    @Published var legal = false
    @Published var other = false
    @Published var whatGiven: [String] = []
    @Published var otherNotes = ""
    @Published var itemQty = 0
    @Published var itemQtyDescription = ""
    @Published var rating = 0
    @Published var ratingNotes = ""
    @Published var durationHours = -1
    @Published var durationMinutes = -1
    @Published var numberOfHelpers = 0
    @Published var numberOfHelpersComment = ""
    @Published var peopleNeedFurtherHelp = 0
    @Published var peopleNeedFurtherHelpComment = ""
    @Published var peopleNeedFurtherHelpLocation = ""
    @Published var furtherFoodAndDrinks = false
    @Published var furtherClothes = false
    @Published var furtherHygiene = false
    @Published var furtherWellness = false
    @Published var furtherMedical = false
    @Published var furtherSocial = false
    @Published var furtherLegal = false
    @Published var furtherOther = false
    @Published var furtherOtherNotes = ""
    @Published var whatGivenFurther: [String] = []
    @Published var followUpWhenVisit = Date()
    @Published var futureNotes = ""
    @Published var volunteerAgain = ""
    @Published var lastEdited = Date()
    @Published var timeStamp = Date()
    @Published var type = "iOS"
    @Published var uid = ""
    @Published var isPublic = false
    @Published var isFlagged = false
    @Published var flaggedByUser = ""
    @Published var location = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    @Published var street = ""
    @Published var city = ""
    @Published var state = ""
    @Published var stateAbbv = ""
    @Published var zipcode = ""
    @Published var status = ""
    var isFromOldCollection: Bool = true
    init(id: String) {
        self.id = id
    }

    func reverseGeocode(latitude: Double, longitude: Double) {
        let baseUrl = "https://api.geoapify.com/v1/geocode/reverse"
        let latLonParams = "lat=\(latitude)&lon=\(longitude)&apiKey=fd35651164a04eac9266ccfb75aa125d"
        let urlString = "\(baseUrl)?\(latLonParams)"

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }

            if let data = data {
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
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
}
