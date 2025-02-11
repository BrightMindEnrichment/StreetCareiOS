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




protocol EventDataAdapterProtocol {
    func eventDataRefreshed(_ events: [Event])
    func helpRequestDataRefreshed(_ events: [HelpRequest])
}



class EventDataAdapter {
    
    var events = [Event]()
    var helpRequests = [HelpRequest]()
    var delegate: EventDataAdapterProtocol?
    
    
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
    
    
    
    /*func refresh() {
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
                   print(document.data())
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
    }*/

    
    
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
                    let title = event.event.title ?? ""
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
                    
                    // Wrap Event in EventData
                    let eventData = EventData()
                    eventData.event = event
                    return eventData
                } ?? []
            }
    }
}
