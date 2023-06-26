//
//  VisitLogDataAdapter.swift
//  StreetCare
//
//  Created by Michael on 5/1/23.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation


protocol VisitLogDataAdapterProtocol {
    func visitLogDataRefreshed(_ logs: [VisitLog])
}



class VisitLogDataAdapter {

    private let collectionName = "VisitLogBook"
    
    var visitLogs = [VisitLog]()
    var delegate: VisitLogDataAdapterProtocol?
    
    func addVisitLog(_ visitLog: VisitLog) {
    
        guard let user = Auth.auth().currentUser else {
            print("no user?")
            return
        }
        
        let settings = FirestoreSettings()

        Firestore.firestore().settings = settings
        let db = Firestore.firestore()
        
        var userData = [String: Any]()
        userData["whereVisit"] = visitLog.whereVisit
        userData["whenVisit"] = visitLog.whenVisit
        userData["peopleHelped"] = visitLog.peopleHelped
        userData["foodAndDrinks"] = visitLog.foodAndDrinks
        userData["clothes"] = visitLog.clothes
        userData["hygine"] = visitLog.hygine
        userData["wellness"] = visitLog.wellness
        userData["other"] = visitLog.other
        userData["otherNotes"] = visitLog.otherNotes
        userData["rating"] = visitLog.rating
        userData["ratingNotes"] = visitLog.ratingNotes
        userData["durationHours"] = visitLog.durationHours
        userData["durationMinutes"] = visitLog.durationMinutes
        userData["numberOfHelpers"] = visitLog.numberOfHelpers
        userData["volunteerAgain"] = visitLog.volunteerAgain

        if visitLog.location.latitude != 0 {
            userData["latitude"] = visitLog.location.latitude
            userData["longitude"] = visitLog.location.longitude
        }
        
        userData["timestamp"] = Date()
        userData["uid"] = user.uid
        
        db.collection(collectionName).document().setData(userData) { err in
            if let err = err {
                // don't bother user with this error
                print(err.localizedDescription)
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    
    func deleteVisitLog(_ logId: String, completion: @escaping () -> ()) {

        Firestore.firestore().settings = FirestoreSettings()
        let db = Firestore.firestore()
        
        db.collection(collectionName).document(logId).delete { _ in
            completion()
        }
    }
    
    
    func refresh() {
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let settings = FirestoreSettings()

        Firestore.firestore().settings = settings
        let db = Firestore.firestore()
        
        let _ = db.collection(collectionName).whereField("uid", isEqualTo: user.uid).getDocuments { querySnapshot, error in
            
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                
                // clear out the existing logs
                self.visitLogs.removeAll()
                
                for document in querySnapshot!.documents {
                                        
                    let log = VisitLog(id: document.documentID)
                    
                    if let whereVisit = document["whereVisit"] as? String {
                        log.whereVisit = whereVisit
                    }
                    
                    if let latitude = document["latitude"] as? Double, let longitude = document["longitude"] as? Double {
                        log.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    }
                    
                    if let whenVisit = document["whenVisit"] as? Timestamp {
                        //print(whenVisit.formatted())
                        log.whenVisit = whenVisit.dateValue()
                    }

                    if let peopleHelped = document["peopleHelped"] as? Int {
                        log.peopleHelped = peopleHelped
                    }

                    if let foodAndDrinks = document["foodAndDrinks"] as? Bool {
                        log.foodAndDrinks = foodAndDrinks
                    }

                    if let clothes = document["clothes"] as? Bool {
                        log.clothes = clothes
                    }

                    if let hygine = document["hygine"] as? Bool {
                        log.hygine = hygine
                    }

                    if let wellness = document["wellness"] as? Bool {
                        log.wellness = wellness
                    }

                    if let other = document["other"] as? Bool {
                        log.other = other
                    }

                    if let otherNotes = document["otherNotes"] as? String {
                        log.otherNotes = otherNotes
                    }

                    if let rating = document["rating"] as? Int {
                        log.rating = rating
                    }
                    
                    if let ratingNotes = document["ratingNotes"] as? String {
                        log.ratingNotes = ratingNotes
                    }
                    
                    if let durationHours = document["durationHours"] as? Int {
                        log.durationHours = durationHours
                    }

                    if let durationMinutes = document["durationMinutes"] as? Int {
                        log.durationMinutes = durationMinutes
                    }

                    if let numberOfHelpers = document["numberOfHelpers"] as? Int {
                        log.numberOfHelpers = numberOfHelpers
                    }

                    if let volunteerAgain = document["volunteerAgain"] as? Int {
                        log.volunteerAgain = volunteerAgain
                    }

                    self.visitLogs.append(log)
                }
            }
            
            self.delegate?.visitLogDataRefreshed(self.visitLogs)
        }
    }

} // end class
