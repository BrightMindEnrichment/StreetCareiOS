//
//  EventDataAdapter.swift
//  StreetCare
//
//  Created by Michael on 5/5/23.
//


import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import Foundation
import Combine
import CoreLocation




protocol EventDataAdapterProtocol {
    func eventDataRefreshed(_ events: [Event])
    func helpRequestDataRefreshed(_ events: [HelpRequest])
}


class EventDataAdapter {
    
    var events = [Event]()
    var helpRequests = [HelpRequest]()
    var outreachEvents: [Event] = []
    var delegate: EventDataAdapterProtocol?
    var geocoder = CLGeocoder()
    var mapOutreachEvents: [(location: CLLocationCoordinate2D, title: String, description: String?)] = []
    var mapHelpRequests: [(location: CLLocationCoordinate2D, helpType: String, description: String?)] = []
    var mapVisitLogs: [(CLLocationCoordinate2D, String, String?)] = []

    
    
    func addEvent(title: String, description: String, date: Date) {
        
        guard let user = Auth.auth().currentUser else { return }
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        let db = Firestore.firestore()
        
        var eventData = [String: Any]()
        eventData["title"] = title
        eventData["description"] = description
        eventData["date"] = date
        eventData["interest"] = 1
        eventData["uid"] = user.uid
        
        db.collection("events").document().setData(eventData) { error in
            
            if let error = error  {
                print(error.localizedDescription)
            }
            else {
                print("saved")
                self.refresh()
            }
        }
    }
    
    
    
    func setLikeEvent(_ event: Event, setTo doesLike: Bool) {
        print(event.interest)
        if let user = Auth.auth().currentUser {
            
            let settings = FirestoreSettings()
            Firestore.firestore().settings = settings
            let db = Firestore.firestore()
            
            var likedData = [String: Any]()
            likedData["uid"] = user.uid
            likedData["eventId"] = event.eventId
            //            likedData["title"] = event.title
            //            likedData["description"] = event.description
            //            likedData["interests"] = event.interest
            //            likedData["createdAt"] = event.createdAt
            //            likedData["helpType"] = event.helpType
            //            likedData["approved"] = event.approved
            //            likedData["totalSlots"] = event.totalSlots
            //            likedData["helpRequest"] = event.helpRequest
            //            likedData["participants"] = event.participants
            //            likedData["skills"] = event.skills
            //            likedData["location"] = event.skills
            //            let dict = ["city" : event.city, "state" : event.state, "street": event.street, "zipcode" : event.zipcode]
            //            likedData["location"] = dict
            //            likedData["eventDate"] = event.eventDateStamp
            //            likedData["eventStartTime"] = event.eventStartTimeStamp
            //            likedData["eventEndTime"] = event.eventEndTimeStamp
            
            
            if doesLike {
                db.collection("outreachEventsDev").document().setData(likedData) { error in
                    if let error = error  {
                        print(error.localizedDescription)
                    }
                    else {
                        print("saved")
                        self.refresh()
                    }
                }
            }
            else {
                let _ = db.collection("outreachEventsDev").whereField("uid", isEqualTo: user.uid).whereField("eventId", isEqualTo: event.eventId!).getDocuments { querySnapshot, error in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    if let querySnapshot = querySnapshot {
                        for document in querySnapshot.documents {
                            db.collection("outreachEventsDev").document(document.documentID).delete()
                        }
                    }
                    
                    self.refresh()
                }
            }
        }
    }
    
    
    func refreshLiked() {
        if let user = Auth.auth().currentUser {
            let settings = FirestoreSettings()
            Firestore.firestore().settings = settings
            let db = Firestore.firestore()
            
            let _ = db.collection("likedEvents").whereField("uid", isEqualTo: user.uid).getDocuments { querySnapshot, error in
                
                if let error = error {
                    print(error.localizedDescription)
                    return
                    //TODO : what to do on db fail
                }
                
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        
                        if let eventId = document["eventId"] as? String {
                            for e in self.events {
                                if e.eventId == eventId {
                                    e.liked = true
                                }
                            }
                        }
                    }
                }
                self.delegate?.eventDataRefreshed(self.events)
            }
        }
        else {
            self.delegate?.eventDataRefreshed(self.events)
        }
    }
    
    func refresh() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        let db = Firestore.firestore()
        db.collection("outreachEventsDev")
            .order(by: "eventDate", descending: true) // Fetch all events first
            .getDocuments { querySnapshot, error in
                
                // clear out all the old data
                self.events.removeAll()
                
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        let data = document.data()
                        
                        // ✅ Filter only approved events in Swift
                        if let status = data["status"] as? String, status == "approved" {
                            let event = Event()
                            event.eventId = document.documentID
                            
                            event.title = data["title"] as? String ?? ""
                            event.description = data["description"] as? String
                            event.isFlagged = data["isFlagged"] as? Bool ?? false
                            event.flaggedByUser = data["flaggedByUser"] as? String
                            event.emailAddress = data["emailAddress"] as? String
                            event.contactNumber = data["contactNumber"] as? String
                            event.consentStatus = data["consentStatus"] as? Bool ?? false
                            
                            if let location = data["location"] as? [String: Any] {
                                var field = ""
                                if let street = location["street"] as? String {
                                    event.street = street
                                    field += street
                                }
                                if let city = location["city"] as? String {
                                    event.city = city
                                    field +=  ", " + city
                                }
                                if let state = location["state"] as? String {
                                    event.state = state
                                    field +=  ", " + state
                                }
                                if let stateAbbv = location["stateAbbv"] as? String {
                                    event.stateAbbv  = stateAbbv
                                    field +=  ", " + stateAbbv
                                }
                                if let zipcode = location["zipcode"] as? String {
                                    event.zipcode = zipcode
                                    field +=  " " + zipcode
                                }
                                event.location = field
                            } else {
                                event.location = "Unknown"
                            }
                            
                            event.interest = data["interests"] as? Int ?? 0
                            event.eventDateStamp = data["eventDate"] as? Timestamp
                            event.eventDate = event.eventDateStamp?.dateValue()
                            event.eventStartTimeStamp = data["eventStartTime"] as? Timestamp
                            event.eventStartTime = event.eventStartTimeStamp?.dateValue()
                            event.eventEndTimeStamp = data["eventEndTime"] as? Timestamp
                            event.eventEndTime = event.eventEndTimeStamp?.dateValue()
                            print("📍 TimeZone from Firestore: \(data["timeZone"] ?? "nil")")
                            event.timeZone = data["timeZone"] as? String
                            
                            
                            event.uid = data["uid"] as? String
                            
                            // Fetch the username from the `users` collection
                            if let uid = event.uid {
                                db.collection("users").document(uid).getDocument { userDoc, error in
                                    if let error = error {
                                        print("Error fetching user data: \(error.localizedDescription)")
                                    } else if let userDoc = userDoc, let userData = userDoc.data() {
                                        event.userType = userData["Type"] as? String
                                    }
                                }
                            }
                            
                            event.createdAt = data["createdAt"] as? String
                            event.helpType = data["helpType"] as? String
                            event.approved = data["approved"] as? Bool ?? false
                            event.totalSlots = Int(data["totalSlots"] as? String ?? "0")
                            event.helpRequest = data["helpRequest"] as? [String]
                            event.participants = data["participants"] as? [String]
                            event.skills = data["skills"] as? [String]
                            
                            self.events.append(event)
                        }
                    }
                }
                
                self.refreshLiked()
            }
    }
    
    
    //    GEDryQS4B9iq95ha11gF
    //    Printing description of user._userID:
    //    3wHp4nrtTlMv3ArzjmYW3vMAlUH2
    func getHelpRequest() {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        let db = Firestore.firestore()
        let _ = db.collection("helpRequests").order(by: "createdAt") .getDocuments { querySnapshot, error in
            
            // clear out all the old data
            self.helpRequests.removeAll()
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let querySnapshot = querySnapshot {
                for document in querySnapshot.documents {
                    print(document.data())
                    
                    let helpRequest = HelpRequest()
                    helpRequest.id = document.documentID
                    
                    if let title = document["title"] as? String {
                        helpRequest.title = title
                    }
                    if let description = document["description"] as? String {
                        helpRequest.description = description
                    }
                    if let identification = document["identification"] as? String {
                        helpRequest.identification = identification
                    }
                    if let location = document["location"] as? NSDictionary {
                        var field = ""
                        if let street = location["street"] as? String{
                            if street != ""{
                                field += street
                            }
                        }
                        if let ciity = location["city"] as? String{
                            if ciity != ""{
                                field +=  ", " + ciity
                            }
                        }
                        if let state = location["state"] as? String{
                            if state != ""{
                                field +=  ", " + state
                            }
                        }
                        if let zipcode = location["zipcode"] as? String{
                            if zipcode != ""{
                                field +=  " " + zipcode
                            }
                        }
                        helpRequest.location = field == "" ? "UnKnown" : field
                    }else{
                        helpRequest.location = "UnKnown"
                    }
                    if let status = document["status"] as? String {
                        helpRequest.status = status
                    }
                    
                    if let uid = document["uid"] as? String {
                        helpRequest.uid = uid
                        
                        // Fetch the user type for this uid
                        db.collection("users").document(uid).getDocument { userDoc, error in
                            if let error = error {
                                print("Error fetching user type: \(error)")
                            } else if let userDoc = userDoc, let userType = userDoc["Type"] as? String {
                                helpRequest.userType = userType // Assign the user type
                                self.delegate?.helpRequestDataRefreshed(self.helpRequests) // Refresh the UI
                            }
                        }
                    }
                    
                    if let createdAt = document["createdAt"] as? String {
                        helpRequest.createdAt = createdAt
                    }
                    if let skills = document["skills"] as? Array<String> {
                        helpRequest.skills = skills
                    }
                    self.helpRequests.append(helpRequest)
                }
            }
            self.delegate?.helpRequestDataRefreshed(self.helpRequests)
        }
    }
    
    
    
    private func extractLocationData(from data: [String: Any]) -> (street: String, city: String, state: String, zipcode: String)? {
        guard let location = data["location"] as? [String: Any],
              let street = location["street"] as? String,
              let city = location["city"] as? String,
              let state = location["state"] as? String,
              let zipcode = location["zipcode"] as? String else {
            return nil
        }
        return (street, city, state, zipcode)
    }
    
    private func geocodeAddress(_ address: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        print("\nStarting geocoding for address: \(address)")
        var didComplete = false
        geocoder.geocodeAddressString(address) { placemarks, error in
            guard !didComplete else { return }
            didComplete = true
            if let error = error {
                print("Geocoding error for address '\(address)': \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            guard let coordinate = placemarks?.first?.location?.coordinate else {
                print("No coordinates found for address: \(address)")
                completion(.failure(NSError(domain: "Geocoding", code: -1, userInfo: [NSLocalizedDescriptionKey: "No coordinates found"])))
                return
            }
            print("Successfully geocoded '\(address)' to: \(coordinate.latitude), \(coordinate.longitude)")
            completion(.success(coordinate))
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if !didComplete {
                didComplete = true
                print("Geocoding timed out for address: \(address)")
                completion(.failure(NSError(domain: "Geocoding", code: -1001, userInfo: [NSLocalizedDescriptionKey: "Geocoding timed out"])))
            }
        }
    }
    
    func fetchMapMarkers() async -> Bool {
        await withCheckedContinuation { continuation in
            let group = DispatchGroup()
            group.enter()
            self.fetchOutreachEventLocations { result in
                if case .failure(let error) = result {
                    print("Error in outreach events: \(error.localizedDescription)")
                }
                print("Fetched \(self.mapOutreachEvents.count) outreach event markers.")
                group.leave()
            }
            group.enter()
            self.fetchPublicVisitLogLocations { result in
                if case .failure(let error) = result {
                    print("Error in public visitlogs: \(error.localizedDescription)")
                }
                print("Fetched \(self.mapVisitLogs.count) help request markers.")
                group.leave()
            }
            group.notify(queue: .main) {
                let overallSuccess = (!self.mapOutreachEvents.isEmpty) || (!self.mapHelpRequests.isEmpty)
                print("All fetches completed. Overall success: \(overallSuccess)")
                print("Total outreach events: \(self.mapOutreachEvents.count), Total help requests: \(self.mapHelpRequests.count)")
                continuation.resume(returning: overallSuccess)
            }
        }
    }
    
    struct OutreachEvent {
        let title: String
        let description: String?
        let location: String
        let coordinates: CLLocationCoordinate2D
    }
    
    private func fetchOutreachEventLocations(completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        print("Fetching outreach events from Firebase...")
        db.collection("outreachEvents")
            .order(by: "eventDate", descending: false)
            .whereField("status", isEqualTo: "approved")
            .limit(to: 50)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                if let error = error {
                    print("Firebase error fetching outreach events: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("No outreach events found")
                    self.mapOutreachEvents = []
                    completion(.success(()))
                    return
                }
                print("Found \(documents.count) outreach event documents")
                var temporaryEvents: [OutreachEvent] = []
                let serialQueue = DispatchQueue(label: "com.app.geocoding.serial.outreach")
                let group = DispatchGroup()
                for (index, document) in documents.enumerated() {
                    group.enter()
                    let delay = DispatchTime.now() + .milliseconds(index * 250)
                    serialQueue.asyncAfter(deadline: delay) {
                        let data = document.data()
                        guard let title = data["title"] as? String,
                              let locationData = data["location"] as? [String: Any],
                              let street = locationData["street"] as? String,
                              let city = locationData["city"] as? String,
                              let state = locationData["state"] as? String,
                              let zipcode = locationData["zipcode"] as? String else {
                            print("Skipping document \(index + 1) due to missing data")
                            group.leave()
                            return
                        }
                        let address = "\(street), \(city), \(state) \(zipcode)"
                        let description = data["description"] as? String
                        print("Title: " + title + " :: Address " + address)
                        self.geocodeAddress(address) { result in
                            switch result {
                            case .success(let coordinates):
                                let event = OutreachEvent(title: title, description: description, location: address, coordinates: coordinates)
                                temporaryEvents.append(event)
                            case .failure(let error):
                                print("Failed to geocode address '\(address)': \(error.localizedDescription)")
                            }
                            group.leave()
                        }
                    }
                }
                group.notify(queue: .main) { [weak self] in
                    guard let self = self else { return }
                    let count = temporaryEvents.count
                    print("Geocoded \(count) outreach events successfully.")
                    self.mapOutreachEvents = temporaryEvents.map { ($0.coordinates, $0.title, $0.description) }
                    if temporaryEvents.isEmpty {
                        completion(.failure(NSError(domain: "Geocoding", code: -1, userInfo: [NSLocalizedDescriptionKey: "No outreach events could be geocoded."])))
                    } else {
                        completion(.success(()))
                    }
                }
            }
    }
    func fetchPublicVisitLogLocations(completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        print("Fetching public visit logs from Firebase...")

        db.collection("visitLogWebProd")
            .whereField("public", isEqualTo: true)
            .whereField("status", isEqualTo: "approved")
            .order(by: "dateTime", descending: true)
            .limit(to: 50)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }

                if let error = error {
                    print("Firebase error fetching visit logs: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("No public visit logs found")
                    self.mapVisitLogs = []
                    completion(.success(()))
                    return
                }

                print("Found \(documents.count) public visit log documents")

                var temporaryVisitLogs: [(CLLocationCoordinate2D, String, String?)] = []
                let serialQueue = DispatchQueue(label: "com.app.geocoding.serial.visitlog")
                let group = DispatchGroup()

                for (index, document) in documents.enumerated() {
                    group.enter()
                    let delay = DispatchTime.now() + .milliseconds(index * 250)

                    serialQueue.asyncAfter(deadline: delay) {
                        let data = document.data()
                        guard
                            let street = data["street"] as? String,
                            let city = data["city"] as? String,
                            let state = data["state"] as? String,
                            let zipcode = data["zipcode"] as? String,
                            let titleArray = data["whatGiven"] as? [String],
                            !titleArray.isEmpty else {
                                print("Skipping visit log \(index + 1) due to missing data")
                                group.leave()
                                return
                            }

                        let address = "\(street), \(city), \(state) \(zipcode)"
                        let title = titleArray.joined(separator: ", ")
                        let description = data["description"] as? String

                        // ✅ Check cache first
                        if let cachedCoordinates = self.getCachedCoordinates(for: address) {
                            print("✅ Using cached coordinates for: \(address)")
                            temporaryVisitLogs.append((cachedCoordinates, title, description))
                            group.leave()
                            return
                        }

                        print("🔍 Geocoding address: \(address)")
                        self.geocodeAddress(address) { result in
                            switch result {
                            case .success(let coordinates):
                                // Cache the coordinates
                                self.cacheCoordinates(for: address, coordinates: coordinates)
                                temporaryVisitLogs.append((coordinates, title, description))
                            case .failure(let error):
                                print("❌ Failed to geocode address '\(address)': \(error.localizedDescription)")
                            }
                            group.leave()
                        }
                    }
                }

                group.notify(queue: .main) {
                    let count = temporaryVisitLogs.count
                    print("✅ Geocoded \(count) public visit logs successfully.")
                    self.mapVisitLogs = temporaryVisitLogs

                    if temporaryVisitLogs.isEmpty {
                        completion(.failure(NSError(domain: "Geocoding", code: -1, userInfo: [
                            NSLocalizedDescriptionKey: "No visit logs could be geocoded."
                        ])))
                    } else {
                        completion(.success(()))
                    }
                }
            }
    }
    
    
    
    //    private func fetchHelpRequestLocations(completion: @escaping (Result<Void, Error>) -> Void) {
    //        let db = Firestore.firestore()
    //        db.collection("helpRequests")
    //            .order(by: "createdAt", descending: false)
    //            .limit(to: 50).getDocuments { [weak self] snapshot, error in
    //            guard let self = self else { return }
    //            if let error = error {
    //                print("Firestore error for helpRequests: \(error.localizedDescription)")
    //                self.mapHelpRequests = []
    //                completion(.success(()))
    //                return
    //            }
    //            guard let documents = snapshot?.documents else {
    //                self.mapHelpRequests = []
    //                completion(.success(()))
    //                return
    //            }
    //            var temporaryRequests: [(location: CLLocationCoordinate2D, helpType: String, description: String?)] = []
    //            let serialQueue = DispatchQueue(label: "com.app.geocoding.serial.help")
    //            let group = DispatchGroup()
    //            for (index, document) in documents.enumerated() {
    //                group.enter()
    //                let delay = DispatchTime.now() + .milliseconds(index * 250)
    //                serialQueue.asyncAfter(deadline: delay) {
    //                    let data = document.data()
    //                    guard let locationDict = data["location"] as? [String: Any],
    //                          let street = locationDict["street"] as? String,
    //                          let city = locationDict["city"] as? String,
    //                          let state = locationDict["state"] as? String,
    //                          let zipcode = locationDict["zipcode"] as? String else {
    //                        group.leave()
    //                        return
    //                    }
    //                    let helpType = data["title"] as? String ?? ""
    //                    let title = document.get("title") as? String ?? ""
    //                    let address = "\(street), \(city), \(state) \(zipcode)"
    //                    print("Title: " + title + " :: Address " + address)
    //                    self.geocodeAddress(address) { result in
    //                        switch result {
    //                        case .success(let coordinates):
    //                            let request = (location: coordinates, helpType: helpType, description: data["description"] as? String)
    //                            temporaryRequests.append(request)
    //                        case .failure(let error):
    //                            print("Failed to geocode help request address '\(address)': \(error.localizedDescription)")
    //                        }
    //                        group.leave()
    //                    }
    //                }
    //            }
    //            group.notify(queue: .main) { [weak self] in
    //                guard let self = self else { return }
    //                print("Geocoded \(temporaryRequests.count) help requests successfully.")
    //                self.mapHelpRequests = temporaryRequests
    //                completion(.success(()))
    //            }
    //        }
    //    }
    //}
    
    private func cacheCoordinates(for address: String, coordinates: CLLocationCoordinate2D) {
        let dict: [String: Any] = ["lat": coordinates.latitude, "lng": coordinates.longitude]
        UserDefaults.standard.set(dict, forKey: address)
    }

    private func getCachedCoordinates(for address: String) -> CLLocationCoordinate2D? {
        if let dict = UserDefaults.standard.dictionary(forKey: address),
           let lat = dict["lat"] as? CLLocationDegrees,
           let lng = dict["lng"] as? CLLocationDegrees {
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
        return nil
    }
    class EventViewModel: ObservableObject {
        @Published var events: [EventData] = [] // All events fetched from Firestore
        @Published var searchText: String = "" // For filtering based on search text
        @Published var filteredEvents: [EventData] = [] // Filtered events based on search text
        @Published var groupedEvents: [String: [EventData]] = [:] // Grouped events by date
        
        private var db = Firestore.firestore()
        private var cancellables = Set<AnyCancellable>()
        
        init() {
            // Observe changes to `searchText` and `events` to dynamically update `filteredEvents` and `groupedEvents`
            Publishers.CombineLatest($searchText, $events)
                .map { searchText, events in
                    // Filter events based on the search text
                    let filtered = events.filter { event in
                        let title = event.event.title
                        let location = event.event.location ?? ""
                        return searchText.isEmpty ||
                        title.localizedCaseInsensitiveContains(searchText) ||
                        location.localizedCaseInsensitiveContains(searchText)
                    }
                    return filtered
                }
                .sink { [weak self] filtered in
                    self?.filteredEvents = filtered
                    self?.groupedEvents = Dictionary(grouping: filtered) { eventData -> String in
                        guard let eventDate = eventData.event.eventDate else { return "Unknown Date" }
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MMMM yyyy"
                        return formatter.string(from: eventDate)
                    }
                }
                .store(in: &cancellables)
        }
        

        
        func fetchEvents(order: Bool = false) {
            let targetDate = Timestamp(date: Date()) // Current date and time
            
            db.collection("outreachEvents")
                .whereField("status", isEqualTo: "approved")
                .whereField("eventDate", isGreaterThanOrEqualTo: targetDate)
                .order(by: "eventDate", descending: order) // Use the order parameter to toggle sorting
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching events: \(error)")
                        return
                    }
                    
                    // Map Firestore documents to EventData
                    self.events = snapshot?.documents.compactMap { document in
                        let data = document.data()
                        let event = Event()
                        event.eventId = document.documentID
                        event.title = data["title"] as? String ?? "Untitled Event"
                        event.description = data["description"] as? String
                        event.eventDate = (data["eventDate"] as? Timestamp)?.dateValue()
                        event.location = data["location"] as? String
                        event.helpRequest = data["helpRequest"] as? [String]
                        event.skills = data["skills"] as? [String]
                        event.interest = data["interest"] as? Int
                        event.helpType = data["helpType"] as? String
                        
                        event.emailAddress = data["emailAddress"] as? String
                        event.contactNumber = data["contactNumber"] as? String
                        event.consentStatus = data["consentStatus"] as? Bool ?? false
                        event.timeZone = data["timeZone"] as? String
                        
                        
                        
                        // Wrap Event in EventData
                        let eventData = EventData()
                        eventData.event = event
                        return eventData
                    } ?? []
                }
        }
    }
}
