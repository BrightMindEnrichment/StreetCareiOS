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
    
    // Add new properties for map data
    var mapOutreachEvents: [(location: CLLocationCoordinate2D, title: String, description: String?)] = []
    var mapHelpRequests: [(location: CLLocationCoordinate2D, helpType: String, description: String?)] = []
    
    
    
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
    
    enum GeocodingError: Error {
        case noCoordinatesFound
        case geocodingFailed(Error)
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
    
    // Geocoding function with completion handler
    private func geocodeAddress(_ address: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        print("\nStarting geocoding for address: \(address)")
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let coordinate = placemarks?.first?.location?.coordinate else {
                print("No coordinates found for address: \(address)")
                completion(.failure(NSError(domain: "Geocoding", code: -1,
                                            userInfo: [NSLocalizedDescriptionKey: "No coordinates found"])))
                return
            }
            
            print("Successfully geocoded to: \(coordinate.latitude), \(coordinate.longitude)")
            completion(.success(coordinate))
        }
    }
    
    
    func fetchMapMarkers(completion: @escaping (Bool) -> Void) {
        print("Starting fetchMapMarkers...")
        let group = DispatchGroup()
        var success = true
        
        // Fetch outreach events
        group.enter()
        fetchOutreachEventLocations { result in
            print("Outreach events fetch completed")
            switch result {
            case .success:
                print("Successfully fetched outreach events: \(self.mapOutreachEvents.count)")
            case .failure(let error):
                print("Error fetching outreach events: \(error.localizedDescription)")
                success = false
            }
            group.leave()
        }
        
        // Fetch help requests
        group.enter()
        fetchHelpRequestLocations { result in
            print("Help requests fetch completed")
            switch result {
            case .success:
                print("Successfully fetched help requests: \(self.mapHelpRequests.count)")
            case .failure(let error):
                print("Error fetching help requests: \(error.localizedDescription)")
                success = false
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            print("All fetches completed. Success: \(success)")
            completion(success)
        }
    }
    
    
    
    private func fetchOutreachEventLocations(completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        print("Fetching outreach events from Firebase...")
        
        db.collection("outreachEventsDev").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Firebase error fetching outreach events: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found in outreachEventsDev")
                completion(.success(()))
                return
            }
            
            print("Found \(documents.count) outreach event documents")
            
            let geocodingGroup = DispatchGroup()
            var temporaryEvents: [(location: CLLocationCoordinate2D, title: String, description: String?)] = []
            var geocodingError: Error?
            let syncQueue = DispatchQueue(label: "com.app.geocoding.sync")
            
            for (index, document) in documents.enumerated() {
                let data = document.data()
                print("\n--- Processing document \(index + 1) ---")
                
                // Debug print the entire location object
                if let location = data["location"] {
                    //print("Location data type: \(type(of: location))")
                    //print("Raw location data: \(location)")
                }
                
                // Extract location data with detailed debugging
                guard let location = data["location"] as? [String: Any] else {
                    print("Failed to cast location to dictionary for document \(index + 1)")
                    continue
                }
                
                // Debug print each field
               // print("Attempting to extract address components...")
                
                let street = location["street"] as? String
               // print("Street: \(street ?? "nil")")
                
                let city = location["city"] as? String
               // print("City: \(city ?? "nil")")
                
                let state = location["state"] as? String
                //print("State: \(state ?? "nil")")
                
                let zipcode = location["zipcode"] as? String
                //print("Zipcode: \(zipcode ?? "nil")")
                
                let title = data["title"] as? String
                //print("Title: \(title ?? "nil")")
                
                // Verify all required fields
                guard let street = street,
                      let city = city,
                      let state = state,
                      let zipcode = zipcode,
                      let title = title else {
                    print("Missing required fields in document \(index + 1)")
                    print("street: \(street != nil)")
                    print("city: \(city != nil)")
                    print("state: \(state != nil)")
                    print("zipcode: \(zipcode != nil)")
                    print("title: \(title != nil)")
                    continue
                }
                
                let address = "\(street), \(city), \(state) \(zipcode)"
                //print("Created address string: \(address)")
                
                geocodingGroup.enter()
                self.geocodeAddress(address) { result in
                    switch result {
                    case .success(let coordinates):
                        print("Successfully geocoded address: \(address)")
                        print("Coordinates: \(coordinates.latitude), \(coordinates.longitude)")
                        
                        let event = (
                            location: coordinates,
                            title: title,
                            description: data["description"] as? String
                        )
                        
                        syncQueue.sync {
                            self.mapOutreachEvents.append(event)
                            print("Added event to mapOutreachEvents array. Current count: \(self.mapOutreachEvents.count)")
                        }
                        
                    case .failure(let error):
                        print("Geocoding failed for address \(address)")
                        print("Error: \(error.localizedDescription)")
                        syncQueue.sync {
                            if geocodingError == nil {
                                geocodingError = error
                            }
                        }
                    }
                    geocodingGroup.leave()
                }
            }
            
            geocodingGroup.notify(queue: .main) { [weak self] in
                print("\n--- Geocoding group completed ---")
                if let error = geocodingError {
                    print("Geocoding completed with errors: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("Geocoding completed successfully")
                    print("Final number of processed events: \(temporaryEvents.count)")
                    //self?.mapOutreachEvents = temporaryEvents
                    
                    completion(.success(()))
                }
            }
        }
    }
    
    // Updated help requests fetch
    private func fetchHelpRequestLocations(completion: @escaping (Result<Void, Error>) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("helpRequests").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion(.success(()))
                return
            }
            
            let geocodingGroup = DispatchGroup()
            var temporaryRequests: [(location: CLLocationCoordinate2D, helpType: String, description: String?)] = []
            var geocodingError: Error?
            let syncQueue = DispatchQueue(label: "com.app.geocoding.sync")
            
            for document in documents {
                let data = document.data()
                
                guard let street = data["street"] as? String,
                      let city = data["city"] as? String,
                      let state = data["state"] as? String,
                      let zipcode = data["zipcode"] as? String,
                      let helpType = data["helpType"] as? String else {
                    continue
                }
                
                let address = "\(street), \(city), \(state) \(zipcode)"
                
                geocodingGroup.enter()
                self.geocodeAddress(address) { result in
                    switch result {
                    case .success(let coordinates):
                        let request = (
                            location: coordinates,
                            helpType: helpType,
                            description: data["description"] as? String
                        )
                        syncQueue.sync {
                            temporaryRequests.append(request)
                        }
                    case .failure(let error):
                        syncQueue.sync {
                            if geocodingError == nil {
                                geocodingError = error
                            }
                        }
                    }
                    geocodingGroup.leave()
                }
            }
            
            geocodingGroup.notify(queue: .main) { [weak self] in
                if let error = geocodingError {
                    completion(.failure(error))
                } else {
                    self?.mapHelpRequests = temporaryRequests
                    completion(.success(()))
                }
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
        let _ = db.collection("outreachEventsDev")
            .order(by: "eventDate", descending: true)
            .getDocuments { querySnapshot, error in
                
                // clear out all the old data
                self.events.removeAll()
                
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        //print(document.data())
                        let event = Event()
                        event.eventId = document.documentID
                        
                        if let title = document["title"] as? String {
                            event.title = title
                        }
                        if let description = document["description"] as? String {
                            event.description = description
                        }
                        if let location = document["location"] as? NSDictionary {
                            var field = ""
                            if let street = location["street"] as? String{
                                event.street = street
                                field += street
                            }
                            if let ciity = location["city"] as? String{
                                event.city = ciity
                                field +=  ", " + ciity
                            }
                            if let state = location["state"] as? String{
                                event.state = state
                                field +=  ", " + state
                            }
                            if let zipcode = location["zipcode"] as? String{
                                event.zipcode = zipcode
                                field +=  " " + zipcode
                            }
                            event.location = field
                        }else{
                            event.location = "UnKnown"
                        }
                        if let interest = document["interests"] as? Int {
                            event.interest = interest
                        }
                        if let eventDate = document["eventDate"] as? Timestamp {
                            print(eventDate)
                            event.eventDateStamp = eventDate
                            event.eventDate = eventDate.dateValue()
                        }
                        if let eventStartTime = document["eventStartTime"] as? Timestamp {
                            print(eventStartTime)
                            event.eventStartTimeStamp = eventStartTime
                            event.eventStartTime = eventStartTime.dateValue()
                        }
                        if let eventEndTime = document["eventEndTime"] as? Timestamp {
                            print(eventEndTime)
                            event.eventEndTimeStamp = eventEndTime
                            event.eventEndTime = eventEndTime.dateValue()
                        }
                        
                        if let uid = document["uid"] as? String {
                            event.uid = uid
                        }
                        if let createdAt = document["createdAt"] as? String {
                            event.createdAt = createdAt
                        }
                        if let helpType = document["helpType"] as? String {
                            event.helpType = helpType
                        }
                        if let approved = document["approved"] as? Bool {
                            event.approved = approved
                        }
                        if let totalSlots = document["totalSlots"] as? String {
                            event.totalSlots = Int(totalSlots)
                        }
                        if let helpRequest = document["helpRequest"] as? Array<String> {
                            event.helpRequest = helpRequest
                        }
                        if let participants = document["participants"] as? Array<String> {
                            event.participants = participants
                        }
                        if let skills = document["skills"] as? Array<String> {
                            event.skills = skills
                        }
                        self.events.append(event)
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
                    //print(document.data())
                    
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
    
    
} // end class
