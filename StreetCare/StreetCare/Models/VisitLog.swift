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

    // 1. whenVisit (timestamp)
    @Published var whenVisit = Date()

    // 2. whereVisit (string)
    @Published var whereVisit = ""

    // 3. locationDescription (string)
    @Published var locationDescription = ""

    // 4. peopleHelped (number)
    @Published var peopleHelped = 0

    // 5. peopleHelpedDescription (string)
    @Published var peopleHelpedDescription = ""

    // 6–13. help types (bool)
    @Published var foodAndDrinks = false
    @Published var clothes = false
    @Published var hygiene = false
    @Published var wellness = false
    @Published var medical = false
    @Published var social = false
    @Published var legal = false
    @Published var other = false

    // 14. whatGiven (array of strings)
    @Published var whatGiven: [String] = []

    // 15. otherNotes (string)
    @Published var otherNotes = ""

    // 16. itemQty (number)
    @Published var itemQty = 0

    // 17. itemQtyDescription (string)
    @Published var itemQtyDescription = ""

    // 18. rating (0–5)
    @Published var rating = 0

    // 19. ratingNotes (string)
    @Published var ratingNotes = ""

    // 20–21. duration (number)
    @Published var durationHours = -1
    @Published var durationMinutes = -1

    // 22. numberOfHelpers (number)
    @Published var numberOfHelpers = 0

    // 23. numberOfHelpersComment (string)
    @Published var numberOfHelpersComment = ""

    // 24. peopleNeedFurtherHelp (number)
    @Published var peopleNeedFurtherHelp = 0

    // 25. peopleNeedFurtherHelpComment (string)
    @Published var peopleNeedFurtherHelpComment = ""

    // 26. peopleNeedFurtherHelpLocation (string)
    @Published var peopleNeedFurtherHelpLocation = ""

    // 27–34. further help types (bool)
    @Published var furtherFoodAndDrinks = false
    @Published var furtherClothes = false
    @Published var furtherHygiene = false
    @Published var furtherWellness = false
    @Published var furtherMedical = false
    @Published var furtherSocial = false
    @Published var furtherLegal = false
    @Published var furtherOther = false

    // 35. furtherOtherNotes (string)
    @Published var furtherOtherNotes = ""

    // 36. whatGivenFurther (array of strings)
    @Published var whatGivenFurther: [String] = []

    // 37. followUpWhenVisit (timestamp)
    @Published var followUpWhenVisit = Date()

    // 38. futureNotes (string)
    @Published var futureNotes = ""

    // 39. volunteerAgain (string)
    @Published var volunteerAgain = "" // "Yes", "No", "Maybe"

    // 40. lastEdited (timestamp)
    @Published var lastEdited = Date()

    // 41. timeStamp (initial log creation time, timestamp)
    @Published var timeStamp = Date()

    // 42. type (string)
    @Published var type = "iOS"

    // 43. uid (string)
    @Published var uid = ""

    // 44. isPublic (bool)
    @Published var isPublic = false

    // 45. isFlagged (bool)
    @Published var isFlagged = false

    // 46. flaggedByUser (string)
    @Published var flaggedByUser = ""

    // 47. location (CLLocationCoordinate2D)
    @Published var location = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)

    // (Optional Firestore-friendly components)
    @Published var street = ""
    @Published var city = ""
    @Published var state = ""
    @Published var stateAbbv = ""
    @Published var zipcode = ""
    @Published var status = ""

    init(id: String) {
        self.id = id
    }

    /*/// Optional: Convert legacy int values (1, 0, -1) to new string type
    func setVolunteerAgain(from intValue: Int) {
        switch intValue {
        case 1: self.volunteerAgain = "Yes"
        case 0: self.volunteerAgain = "No"
        default: self.volunteerAgain = "Maybe"
        }
    }*/

    // Optional: Reverse geocoding for debug/UI use only
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
