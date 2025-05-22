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

    private let collectionName = ""
    
    var visitLogs = [VisitLog]()
    var delegate: VisitLogDataAdapterProtocol?
    
    func resetLogs() {
        visitLogs = [VisitLog]()
    }

    func updateVisitLogField(_ logId: String, field: String, value: Any, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        db.collection("VisitLogBook").document(logId).updateData([
            field: value
        ]) { error in
            if let error = error {
                print("⚠️ Error updating \(field): \(error.localizedDescription)")
            } else {
                print("✅ \(field) updated successfully.")
                completion()
            }
        }
    }
    func updateVisitLogFields(_ logId: String, fields: [String: Any], completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        db.collection("VisitLogBook").document(logId).updateData(fields) { error in
            if let error = error {
                print("⚠️ Error updating fields: \(error.localizedDescription)")
            } else {
                print("✅ All fields updated successfully.")
                completion()
            }
        }
    }
    func addVisitLog(_ visitLog: VisitLog) {
    
        guard let user = Auth.auth().currentUser else {
            print("no user?")
            return
        }
        let collectionName = "VisitLogBook"
        let settings = FirestoreSettings()
 
        Firestore.firestore().settings = settings
        let db = Firestore.firestore()
        
        var userData = [String: Any]()
        userData["whereVisit"] = visitLog.whereVisit
        userData["whenVisit"] = visitLog.whenVisit
        userData["peopleHelped"] = visitLog.peopleHelped
        userData["itemQty"] = visitLog.itemQty
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
        userData["numberOfHelpers"] = visitLog.numberOfHelpers // totalpeoplecount
        userData["volunteerAgain"] = visitLog.volunteerAgain
        userData["peopleNeedFurtherHelp"] = visitLog.peopleNeedFurtherHelp
        userData["furtherFoodAndDrinks"] = visitLog.furtherfoodAndDrinks
        userData["furtherClothes"] = visitLog.furtherClothes
        userData["furtherHygine"] = visitLog.furtherHygine
        userData["furtherWellness"] = visitLog.furtherWellness
        userData["furthermedical"] = visitLog.furthermedical
        userData["furthersocialworker"] = visitLog.furthersocialworker
        userData["furtherlegal"] = visitLog.furtherlegal
        userData["furtherOther"] = visitLog.furtherOther
        userData["furtherOtherNotes"] = visitLog.furtherOtherNotes
        userData["followUpWhenVisit"] = visitLog.followUpWhenVisit


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
                print("Document successfully written in VisitLogBook!")
            }
        }
    }
    func addVisitLog_Community(_ visitLog: VisitLog) {
    
        guard let user = Auth.auth().currentUser else {
            print("no user?")
            return
        }
        let uid = user.uid
        print("Current user UID: \(uid)")
        
        let collectionName = "visitLogWebProd"
        let settings = FirestoreSettings()

        Firestore.firestore().settings = settings
        let db = Firestore.firestore()
        
        var userData = [String: Any]()
        userData["city"] = visitLog.city
        userData["dateTime"] = visitLog.whenVisit
        userData["description"] = ""
        userData["isFlagged"] = false
        userData["itemQty"] = visitLog.itemQty
        userData["numberPeopleHelped"] = visitLog.peopleHelped
        userData["public"] = true
        userData["rating"] = visitLog.rating
        userData["state"] = visitLog.state
        userData["stateAbbv"] = visitLog.stateAbbv
        userData["status"] = "pending"
        userData["street"] = visitLog.street
        userData["uid"] = uid
        userData["whatGiven"] = visitLog.whatGiven
        userData["zipcode"] = visitLog.zipcode


        //if visitLog.location.latitude != 0 {
            //userData["latitude"] = visitLog.location.latitude
            //userData["longitude"] = visitLog.location.longitude
        //}
        
        //userData["timestamp"] = Date()
        //userData["uid"] = user.uid
        
        db.collection(collectionName).document().setData(userData) { err in
            if let err = err {
                // don't bother user with this error
                print(err.localizedDescription)
            } else {
                print("Document successfully written in visitLogWebProd!")
            }
        }
    }
    
    
    func deleteVisitLog(_ logId: String, completion: @escaping () -> ()) {

        Firestore.firestore().settings = FirestoreSettings()
        let db = Firestore.firestore()
        
        db.collection("VisitLogBook").document(logId).delete { _ in
            completion()
        }
        db.collection("visitLogWebProd").document(logId).delete { _ in
            completion()
        }
    }
    /*func refreshWebProd() {
        
        guard let user = Auth.auth().currentUser else {
            self.visitLogs = [VisitLog]()
            self.delegate?.visitLogDataRefreshed(self.visitLogs)
            return
        }
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        let db = Firestore.firestore()
        
        let _ = db.collection("visitLogWebProd").whereField("uid", isEqualTo: user.uid).getDocuments { querySnapshot, error in
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                
                // Clear out the existing logs
                self.visitLogs.removeAll()
                
                for document in querySnapshot!.documents {
                    
                    let log = VisitLog(id: document.documentID)
                    
                    if let city = document["city"] as? String {
                        log.city = city
                    }
                    
                    if let dateTime = document["dateTime"] as? Timestamp {
                        log.whenVisit = dateTime.dateValue()
                    }
                    
                    if let description = document["description"] as? String {
                        log.otherNotes = description
                    }
                    
                    if let isFlagged = document["isFlagged"] as? Bool {
                        log.other = isFlagged
                    }
                    
                    if let itemQty = document["itemQty"] as? Int {
                        log.itemQty = itemQty
                    }
                    
                    if let numberPeopleHelped = document["numberPeopleHelped"] as? Int {
                        log.peopleHelped = numberPeopleHelped
                    }
                    
                    if let publicStatus = document["public"] as? Bool {
                        log.other = publicStatus
                    }
                    
                    if let rating = document["rating"] as? Int {
                        log.rating = rating
                    }
                    
                    if let state = document["state"] as? String {
                        log.state = state
                    }
                    
                    if let stateAbbv = document["stateAbbv"] as? String {
                        log.stateAbbv = stateAbbv
                    }
                    
                    if let status = document["status"] as? String {
                        log.otherNotes = status
                    }
                    
                    if let street = document["street"] as? String {
                        log.street = street
                    }
                    
                    if let zipcode = document["zipcode"] as? String {
                        log.zipcode = zipcode
                    }

                    // ** Full Mapping of `whatGiven` **
                    if let whatGiven = document["whatGiven"] as? [String] {
                        log.foodAndDrinks = whatGiven.contains("Food and Drink")
                        log.clothes = whatGiven.contains("Clothes")
                        log.hygine = whatGiven.contains("Hygiene Products")
                        log.wellness = whatGiven.contains("Wellness/ Emotional Support")
                        log.medical = whatGiven.contains("Medical Help")
                        log.socialworker = whatGiven.contains("Social Worker /Psychiatrist")
                        log.legal = whatGiven.contains("Legal/Lawyer")
                        
                        // If "Other" category exists, assign `other` to true
                        if let otherItem = whatGiven.first(where: { !["Food and Drink", "Clothes", "Hygiene Products", "Wellness/ Emotional Support", "Medical Help", "Social Worker /Psychiatrist", "Legal/Lawyer"].contains($0) }) {
                            log.other = true
                            log.otherNotes = otherItem  // Store custom other item description
                        }
                    }
                    
                    self.visitLogs.append(log)
                }
            }
            
            self.delegate?.visitLogDataRefreshed(self.visitLogs)
        }
    }*/
    
    func refresh() {
        
        guard let user = Auth.auth().currentUser else {
            self.visitLogs = [VisitLog]()
            self.delegate?.visitLogDataRefreshed(self.visitLogs)
            return
        }
        
        let settings = FirestoreSettings()

        Firestore.firestore().settings = settings
        let db = Firestore.firestore()
        
        let _ = db.collection("VisitLogBook").whereField("uid", isEqualTo: user.uid).getDocuments { querySnapshot, error in
            
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
                        log.whenVisit = whenVisit.dateValue()
                    }

                    if let followUpWhenVisit = document["followUpWhenVisit"] as? Timestamp {
                        log.followUpWhenVisit = followUpWhenVisit.dateValue()
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
                    
                    if let itemQty = document["itemQty"] as? Int {
                        log.itemQty = itemQty
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

                    if let peopleNeedFurtherHelp = document["peopleNeedFurtherHelp"] as? Int {
                        log.peopleNeedFurtherHelp = peopleNeedFurtherHelp
                    }
                    
                    if let furtherFoodAndDrinks = document["furtherFoodAndDrinks"] as? Bool {
                        log.furtherfoodAndDrinks = furtherFoodAndDrinks
                    }

                    if let furtherClothes = document["furtherClothes"] as? Bool {
                        log.furtherClothes = furtherClothes
                    }

                    if let furtherHygine = document["furtherHygine"] as? Bool {
                        log.furtherHygine = furtherHygine
                    }

                    if let furtherWellness = document["furtherWellness"] as? Bool {
                        log.furtherWellness = furtherWellness
                    }
                    
                    if let furtherWellness = document["furtherWellness"] as? Bool {
                        log.furtherWellness = furtherWellness
                    }
                    
                    if let furthermedical = document["furthermedical"] as? Bool {
                        log.furthermedical = furthermedical
                    }
                    
                    if let furthersocialworker = document["furthersocialworker"] as? Bool {
                        log.furthersocialworker = furthersocialworker
                    }
                    

                    if let furtherOther = document["furtherlegal"] as? Bool {
                        log.furtherlegal = furtherOther
                    }

                    if let furtherOtherNotes = document["furtherOtherNotes"] as? String {
                        log.furtherOtherNotes = furtherOtherNotes
                    }

                    self.visitLogs.append(log)
                }
            }
            
            self.delegate?.visitLogDataRefreshed(self.visitLogs)
        }
    }

} // end class
