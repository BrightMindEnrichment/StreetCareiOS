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
    @Published var mapOutreachEvents: [(location: CLLocationCoordinate2D, title: String, description: String?)] = []
    @Published var mapHelpRequests: [(location: CLLocationCoordinate2D, identification: String?, description: String?)] = []
    
   
    
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
    
    //geocode only outReachEvents
    private func geocodeOutReachAddress(_ address: String) async throws -> CLLocationCoordinate2D {
        //print("\nStarting geocoding for address: \(address)") - 512
        //above print statements print all the addresses but not all get geoCoded
        return try await withCheckedThrowingContinuation { continuation in
            
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(address){ placemarkers, error in
                //error
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let coordinate = placemarkers?.first?.location?.coordinate else {
                    let error = NSError(domain: "Geocoding",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "No coordinates found"])
                    print("No coordinates found for address: \(address)")
                    continuation.resume(throwing: error)
                    return
                }
                
                //print("Successfully geocoded data\(coordinate.latitude), \(coordinate.longitude)")
                continuation.resume(returning: coordinate)
                
            }
        }
    }
    
    //geocode helpRequests
    private func geocodeHelpAddress(_ address: String) async throws -> CLLocationCoordinate2D {
        //print("\nStarting geocoding for address: \(address)") - 512
        //above print statements print all the addresses but not all get geoCoded
        return try await withCheckedThrowingContinuation { continuation in
            
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(address){ placemarkers, error in
                //error
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let coordinate = placemarkers?.first?.location?.coordinate else {
                    let error = NSError(domain: "Geocoding",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "No coordinates found"])
                    print("No coordinates found for address: \(address)")
                    continuation.resume(throwing: error)
                    return
                }
                
                //print("Successfully geocoded data\(coordinate.latitude), \(coordinate.longitude)")
                continuation.resume(returning: coordinate)
                
            }
        }
    }
    
    
    func fetchMapMarkers() async -> Bool {
        print("In fetchMapMarkers...")
        do{
            
//            async let outReachEvents = fetchOutreachEventLocations
//            async let helpRequests = fetchHelpRequestLocations()
//            
//            try await outReachEvents
//            try await helpRequests
//            try await fetchOutreachEventLocations()
//            try await fetchHelpRequestLocations()
            
            let(outReachEvents, helpRequests) = try await (fetchOutreachEventLocations(), fetchHelpRequestLocations())
            
            print("MapOutReach Events markers - \(mapOutreachEvents.count)")
            print("Help Request markers - \(mapHelpRequests.count)")
            print("Successfully Fetched Map Markers")
            return true
        }catch{
            print("Error Fetching Map Markers\(error.localizedDescription)")
            return false
        }
    }
    
    //1. Access the document from firebase - outReachEvents
    //2. document - String format - convert that to coordinates ?
    //3. Convert = Geocoding = it helps to convert the string to coordinates (lat, lon)
    //4. Step 3 takes a looooot time - async, await - setting timer
    //5. Test Step 4, try to check only 15 outReachEvents - 512 total
    //
    
    private func fetchOutreachEventLocations() async throws {
        let db = Firestore.firestore()
        print("Fetching outreach events from Firebase...")
        
        let snapshot = try await db.collection("outreachEvents").getDocuments()
        let documents = snapshot.documents
        print("Found \(documents.count) outreach event documents")
        
        // Store all events data first
        var events: [(address: String, title: String, description: String?)] = []
        
        // First collect all valid addresses and their details
        for document in documents {
            let data = document.data()
            
            // More specific error handling for location
            if let location = data["location"] as? [String: String] {  // Changed to [String: String]
                //print("Processing location: \(location)")
                
                // Extract values using dictionary keys
                let street = location["street"]
                let city = location["city"]
                let state = location["state"]  // Changed back to state instead of stateAbbv
                let zipcode = location["zipcode"]
                let title = data["title"] as? String
                let description = data["description"] as? String
                
                // Verify all required fields
                if let street = street,
                   let city = city,
                   let state = state,
                   let zipcode = zipcode,
                   let title = title {
                    
                    let address = "\(street), \(city), \(state) \(zipcode)"
                    events.append((address: address, title: title, description: description))
                    //print("Successfully parsed address: \(address)")
                } else {
                    print("Missing required fields for location in document: \(document.documentID)")
                }
            } else {
                print("Failed to cast location for document ID: \(document.documentID)")
            }
        }
        
        print("Collected \(events.count) valid addresses")
        
        for index in 0..<min(10, events.count){
            do{
                let coordinate = try await geocodeOutReachAddress(events[index].address)
                let mapEvent = (
                    location: coordinate,
                    title: events[index].title,
                    description: events[index].description
                )
                mapOutreachEvents.append(mapEvent)
            }catch{
                print("Detailed geocoding error for \(events[index].address): \(error)")
                continue
            }
        }
        
        print("First batch of \(min(10, events.count)) addresses processed")
        
        for index in 10..<min(30, events.count) {
            do {
                let coordinate = try await geocodeOutReachAddress(events[index].address)
                let mapEvent = (
                    location: coordinate,
                    title: events[index].title,
                    description: events[index].description
                )
                mapOutreachEvents.append(mapEvent)
            } catch {
                print("Detailed geocoding error for \(events[index].address): \(error)")
                continue
            }
        }
        
        // Process all events with delays
//        for (index, event) in events.enumerated() {
//            do {
//                // Add delay between requests
//                if index <= 40 {
//                    //try await Task.sleep(nanoseconds: 100_000_000)  // 3 second delay
//                
//                //print("Attempting to geocode address: \(event.address)")
//                let coordinate = try await geocodeOutReachAddress(event.address)
//                //print("Successfully geocoded: \(event.address)")
//                
//                let mapEvent = (
//                    location: coordinate,
//                    title: event.title,
//                    description: event.description
//                )
//                mapOutreachEvents.append(mapEvent)
//            }
//            } catch {
//                print("Detailed geocoding error for \(event.address): \(error)")
//                continue
//            }
//        }
        
        print("Successfully processed \(mapOutreachEvents.count) addresses")
    }
    
    private func fetchHelpRequestLocations() async throws {
        let db = Firestore.firestore()
        print("Fetching help requests from Firebase...")
        
        let snapshot = try await db.collection("helpRequests").getDocuments()
        let documents = snapshot.documents
        print("Found \(documents.count) help request documents")
        
        // Store all help requests data first
        var requests: [(address: String, identification: String?, description: String?)] = []
        
        // First collect all valid addresses and their details
        for document in documents {
            let data = document.data()
            
            // More specific error handling for location
            if let location = data["location"] as? [String: String] {
                print("Processing location: \(location)")
                
                // Extract values using dictionary keys
                let street = location["street"]
                let city = location["city"]
                let state = location["state"]
                let zipcode = location["zipcode"]
                let identification = data["identification"] as? String
                let description = data["description"] as? String
                
                // Verify all required fields
                if let street = street,
                   let city = city,
                   let state = state,
                   let zipcode = zipcode,
                   let helpType = identification {
                    
                    let address = "\(street), \(city), \(state) \(zipcode)"
                    requests.append((address: address, identification: identification, description: description))
                    print("Successfully parsed address: \(address)")
                } else {
                    print("Missing required fields for location in document: \(document.documentID)")
                }
            } else {
                print("Failed to cast location for document ID: \(document.documentID)")
            }
        }
        
        print("Collected \(requests.count) valid addresses")
        
        // Process all requests with delays
        for (index, request) in requests.enumerated() {
            do {
                // Add delay between requests if needed
                if index <= 30 {
                    //try await Task.sleep(nanoseconds: 100_000_000)  // Optional delay
                    
                    let coordinate = try await geocodeHelpAddress(request.address)
                    
                    let mapRequest = (
                        location: coordinate,
                        identification: request.identification,
                        description: request.description
                    )
                    mapHelpRequests.append(mapRequest)
                }
            } catch {
                print("Detailed geocoding error for \(request.address): \(error)")
                continue
            }
        }
        
        print("Successfully processed help \(mapHelpRequests.count) addresses")
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
                            //print(eventDate)
                            event.eventDateStamp = eventDate
                            event.eventDate = eventDate.dateValue()
                        }
                        if let eventStartTime = document["eventStartTime"] as? Timestamp {
                            //print(eventStartTime)
                            event.eventStartTimeStamp = eventStartTime
                            event.eventStartTime = eventStartTime.dateValue()
                        }
                        if let eventEndTime = document["eventEndTime"] as? Timestamp {
                            //print(eventEndTime)
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
