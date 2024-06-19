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



protocol EventDataAdapterProtocol {
    func eventDataRefreshed(_ events: [Event])
}



class EventDataAdapter {
    
    var events = [Event]()
    
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
    
    
    
    func setLikeEvent(_ eventId: String, setTo doesLike: Bool) {
        
        if let user = Auth.auth().currentUser {
                        
            let settings = FirestoreSettings()
            Firestore.firestore().settings = settings
            let db = Firestore.firestore()
            
            var likedData = [String: Any]()
            likedData["uid"] = user.uid
            likedData["eventId"] = eventId
            
            if doesLike {
                db.collection("likedEvents").document().setData(likedData) { error in
                    
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
                let _ = db.collection("likedEvents").whereField("uid", isEqualTo: user.uid).whereField("eventId", isEqualTo: eventId).getDocuments { querySnapshot, error in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    
                    if let querySnapshot = querySnapshot {
                        for document in querySnapshot.documents {
                            db.collection("likedEvents").document(document.documentID).delete()
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
        
        let _ = db.collection("outreachEvents").getDocuments { querySnapshot, error in
            
            // clear out all the old data
            self.events.removeAll()
            
            if let error = error {
                print(error.localizedDescription)
                return
                //TODO : what to do on db fail
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
                    if let location = document["location"] as? String {
                        var location = location["street"] + ", " + location["city"] + ", " + location["state"]
                        event.location = location
                    }else{
                        event.location = "UnKnown"
                    }
                    if let interest = document["interest"] as? Int {
                        event.interest = interest
                    }
                    if let eventDate = document["eventDate"] as? Timestamp {
                        print(eventDate)
                        event.eventDate = eventDate.dateValue()
                    }
                    if let eventStartTime = document["eventStartTime"] as? Timestamp {
                        print(eventStartTime)
                        event.eventStartTime = eventStartTime.dateValue()
                    }
                    if let eventEndTime = document["eventEndTime"] as? Timestamp {
                        print(eventEndTime)
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
    
} // end class
