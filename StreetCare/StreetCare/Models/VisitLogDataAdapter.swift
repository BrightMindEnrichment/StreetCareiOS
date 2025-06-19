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
    var publishedLogIDs = Set<String>()
    var pendingLogIDs = Set<String>()
    var rejectedLogIDs = Set<String>()
    
    
    func resetLogs() {
        visitLogs = [VisitLog]()
    }
    
    func addVisitLog(_ visitLog: VisitLog) {
        
        guard let user = Auth.auth().currentUser else {
            print("no user?")
            return
        }
        let collectionName = "VisitLogBook_New"
        let settings = FirestoreSettings()
        
        Firestore.firestore().settings = settings
        let db = Firestore.firestore()
        let docRef = db.collection("VisitLogBook_New").document()
        visitLog.id = docRef.documentID
        
        var userData = [String: Any]()
        userData["whereVisit"] = visitLog.whereVisit
        userData["whenVisit"] = visitLog.whenVisit
        userData["peopleHelped"] = visitLog.peopleHelped
        userData["foodAndDrinks"] = visitLog.foodAndDrinks
        userData["clothes"] = visitLog.clothes
        userData["hygiene"] = visitLog.hygine
        userData["wellness"] = visitLog.wellness
        userData["medical"] = visitLog.medical
        userData["social"] = visitLog.socialworker
        userData["legal"] = visitLog.legal
        userData["other"] = visitLog.other
        userData["otherNotes"] = visitLog.otherNotes
        userData["rating"] = visitLog.rating
        userData["ratingNotes"] = visitLog.ratingNotes
        userData["durationHours"] = visitLog.durationHours
        userData["durationMinutes"] = visitLog.durationMinutes
        userData["numberOfHelpers"] = visitLog.numberOfHelpers
        userData["numberOfHelpersComment"] = ""
        userData["volunteerAgain"] = visitLog.volunteerAgain
        userData["peopleNeedFurtherHelp"] = visitLog.peopleNeedFurtherHelp
        userData["peopleNeedFurtherHelpLocation"] = visitLog.peopleNeedFurtherHelpLocation
        userData["peopleNeedFurtherHelpComment"] = ""
        userData["furtherFoodAndDrinks"] = visitLog.furtherfoodAndDrinks
        userData["furtherClothes"] = visitLog.furtherClothes
        userData["furtherHygiene"] = visitLog.furtherHygine
        userData["furtherWellness"] = visitLog.furtherWellness
        userData["furtherMedical"] = visitLog.furthermedical
        userData["furtherSocial"] = visitLog.furthersocialworker
        userData["furtherLegal"] = visitLog.furtherlegal
        userData["furtherOther"] = visitLog.furtherOther
        userData["furtherOtherNotes"] = visitLog.furtherOtherNotes
        userData["whatGiven"] = visitLog.whatGiven
        userData["whatGivenFurther"] = []
        userData["itemQty"] = visitLog.itemQty
        userData["itemQtyDescription"] = ""
        userData["locationDescription"] = ""
        userData["peopleHelpedDescription"] = visitLog.peopleHelpedDescription
        userData["followUpWhenVisit"] = visitLog.followUpWhenVisit
        userData["futureNotes"] = ""
        userData["lastEdited"] = Date()
        userData["type"] = "iOS"
        userData["timeStamp"] = Date()
        userData["uid"] = user.uid
        userData["isPublic"] = false
        userData["isFlagged"] = false
        userData["flaggedByUser"] = ""
        
        // ✅ Now use the assigned docRef so `visitLog.id` matches the saved doc
        docRef.setData(userData) { err in
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
        let logId = visitLog.id
        let parts = visitLog.whereVisit.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        if parts.count >= 4 {
            visitLog.street = parts[0]
            visitLog.city = parts[1]
            visitLog.stateAbbv = parts[2]
            visitLog.state = fullStateName(from: visitLog.stateAbbv)
            visitLog.zipcode = parts[3]
        }
        
        var userData = [String: Any]()
        //userData["whereVisit"] = visitLog.whereVisit
        userData["dateTime"] = visitLog.whenVisit
        userData["description"] = ""
        userData["isFlagged"] = false
        userData["flaggedByUser"] = ""
        userData["itemQty"] = visitLog.itemQty
        userData["numberPeopleHelped"] = visitLog.peopleHelped
        userData["public"] = true
        userData["rating"] = visitLog.rating
        userData["status"] = "pending"
        userData["uid"] = uid
        userData["whatGiven"] = visitLog.whatGiven
        userData["city"] = visitLog.city
        userData["state"] = visitLog.state
        userData["stateAbbv"] = visitLog.stateAbbv
        userData["street"] = visitLog.street
        userData["zipcode"] = visitLog.zipcode
        
        //if visitLog.location.latitude != 0 {
        //userData["latitude"] = visitLog.location.latitude
        //userData["longitude"] = visitLog.location.longitude
        //}
        
        //userData["timestamp"] = Date()
        //userData["uid"] = user.uid
        
        db.collection("visitLogWebProd").document(logId).setData(userData) { err in
            if let err = err {
                // don't bother user with this error
                print(err.localizedDescription)
            } else {
                print("Document successfully written in visitLogWebProd!")
                self.refreshWebProd()
            }
        }
        
        // NEW: Update VisitLogBook with status = "published"
        /*db.collection("VisitLogBook").document(logId).updateData([
         "status": "published"
         ]) { error in
         if let error = error {
         print("Error updating VisitLogBook status: \(error.localizedDescription)")
         } else {
         print("VisitLogBook log also marked as published!")
         }
         }*/
    }
    func fullStateName(from abbreviation: String) -> String {
        let states = [
            "AL": "Alabama", "AK": "Alaska", "AZ": "Arizona", "AR": "Arkansas", "CA": "California",
            "CO": "Colorado", "CT": "Connecticut", "DE": "Delaware", "FL": "Florida", "GA": "Georgia",
            "HI": "Hawaii", "ID": "Idaho", "IL": "Illinois", "IN": "Indiana", "IA": "Iowa",
            "KS": "Kansas", "KY": "Kentucky", "LA": "Louisiana", "ME": "Maine", "MD": "Maryland",
            "MA": "Massachusetts", "MI": "Michigan", "MN": "Minnesota", "MS": "Mississippi",
            "MO": "Missouri", "MT": "Montana", "NE": "Nebraska", "NV": "Nevada", "NH": "New Hampshire",
            "NJ": "New Jersey", "NM": "New Mexico", "NY": "New York", "NC": "North Carolina",
            "ND": "North Dakota", "OH": "Ohio", "OK": "Oklahoma", "OR": "Oregon", "PA": "Pennsylvania",
            "RI": "Rhode Island", "SC": "South Carolina", "SD": "South Dakota", "TN": "Tennessee",
            "TX": "Texas", "UT": "Utah", "VT": "Vermont", "VA": "Virginia", "WA": "Washington",
            "WV": "West Virginia", "WI": "Wisconsin", "WY": "Wyoming"
        ]
        return states[abbreviation.uppercased()] ?? abbreviation
    }
    
    func deleteVisitLog(_ logId: String, completion: @escaping () -> ()) {
        
        Firestore.firestore().settings = FirestoreSettings()
        let db = Firestore.firestore()
        
        db.collection("VisitLogBook").document(logId).delete { _ in
            completion()
        }
        db.collection("VisitLogBook_New").document(logId).delete { _ in
                completion()
        }
        db.collection("visitLogWebProd").document(logId).delete { _ in
            completion()
        }
    }
    func refreshWebProd() {
        guard let user = Auth.auth().currentUser else { return }
        
        let db = Firestore.firestore()
        
        db.collection("visitLogWebProd")
            .whereField("uid", isEqualTo: user.uid)
            .getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching logs: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("No logs found.")
                    return
                }
                
                var published = Set<String>()
                var pending = Set<String>()
                var rejected = Set<String>()
                
                for doc in documents {
                    let logID = doc.documentID
                    let status = (doc["status"] as? String ?? "").lowercased()
                    
                    switch status {
                    case "approved":
                        published.insert(logID)
                    case "pending":
                        pending.insert(logID)
                    case "rejected":
                        rejected.insert(logID)
                    default:
                        break
                    }
                }
                
                self.publishedLogIDs = published
                self.pendingLogIDs = pending
                self.rejectedLogIDs = rejected
                
                self.delegate?.visitLogDataRefreshed(self.visitLogs)
            }
    }
    /*func refreshWebProd() {
     guard let user = Auth.auth().currentUser else {
     return
     }
     
     let settings = FirestoreSettings()
     Firestore.firestore().settings = settings
     let db = Firestore.firestore()
     
     db.collection("visitLogWebProd").whereField("uid", isEqualTo: user.uid).getDocuments { querySnapshot, error in
     if let error = error {
     print(error.localizedDescription)
     return
     }
     
     guard let documents = querySnapshot?.documents else {
     return
     }
     
     for document in documents {
     let webProdLogID = document.documentID
     
     // ✅ Update the isPublished flag on existing VisitLogBook logs
     if let matchingIndex = self.visitLogs.firstIndex(where: { $0.id == webProdLogID }) {
     self.visitLogs[matchingIndex].isPublished = true
     print("Matched & marked published: \(webProdLogID)")
     } else {
     print("No match found in VisitLogBook for: \(webProdLogID)")
     }
     }
     
     // Notify UI to refresh
     self.delegate?.visitLogDataRefreshed(self.visitLogs)
     }
     
     /*let _ = db.collection("visitLogWebProd").whereField("uid", isEqualTo: user.uid).getDocuments { querySnapshot, error in
      
      if let error = error {
      print(error.localizedDescription)
      } else {
      
      // Clear out the existing logs
      self.visitLogs.removeAll()
      
      for document in querySnapshot!.documents {
      let id = document.documentID
      
      if let index = self.visitLogs.firstIndex(where: { $0.id == id }) {
      self.visitLogs[index].isPublished = true
      }
      
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
      log.status = status
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
      }*/
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
        
        self.visitLogs.removeAll()
        let group = DispatchGroup()
        
        // Fetch from VisitLogBook (old)
        group.enter()
        db.collection("VisitLogBook").whereField("uid", isEqualTo: user.uid).getDocuments { querySnapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
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
                    if let peopleNeedFurtherHelpLocation = document["peopleNeedFurtherHelpLocation"] as? String {
                        log.peopleNeedFurtherHelpLocation = peopleNeedFurtherHelpLocation
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
                    if let furthermedical = document["furthermedical"] as? Bool {
                        log.furthermedical = furthermedical
                    }
                    if let furthersocialworker = document["furthersocialworker"] as? Bool {
                        log.furthersocialworker = furthersocialworker
                    }
                    if let furtherlegal = document["furtherlegal"] as? Bool {
                        log.furtherlegal = furtherlegal
                    }
                    if let furtherOtherNotes = document["furtherOtherNotes"] as? String {
                        log.furtherOtherNotes = furtherOtherNotes
                    }
                    self.visitLogs.append(log)
                }
            }
            group.leave()
        }
        
        // Fetch from visitlogbook_New (new)
        group.enter()
        db.collection("VisitLogBook_New").whereField("uid", isEqualTo: user.uid).getDocuments { querySnapshot, error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    let log = VisitLog(id: document.documentID)
                    if let uid = document["uid"] as? String {
                        log.uid = uid
                    }
                    if let itemQty = document["itemQty"] as? Int {
                        log.itemQty = itemQty
                    }
                    if let peopleHelpedDescription = document["peopleHelpedDescription"] as? String {
                        log.peopleHelpedDescription = peopleHelpedDescription
                    }
                    if let isFlagged = document["isFlagged"] as? Bool {
                        log.isFlagged = isFlagged
                    }
                    if let flaggedByUser = document["flaggedByUser"] as? String {
                        log.flaggedByUser = flaggedByUser
                    }
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
                    if let medical = document["medical"] as? Bool {
                        log.medical = medical
                    }
                    if let social = document["social"] as? Bool {
                        log.socialworker = social
                    }
                    if let legal = document["legal"] as? Bool {
                        log.legal = legal
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
                    if let peopleNeedFurtherHelp = document["peopleNeedFurtherHelp"] as? Int {
                        log.peopleNeedFurtherHelp = peopleNeedFurtherHelp
                    }
                    if let peopleNeedFurtherHelpLocation = document["peopleNeedFurtherHelpLocation"] as? String {
                        log.peopleNeedFurtherHelpLocation = peopleNeedFurtherHelpLocation
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
                    if let furthermedical = document["furthermedical"] as? Bool {
                        log.furthermedical = furthermedical
                    }
                    if let furthersocialworker = document["furthersocialworker"] as? Bool {
                        log.furthersocialworker = furthersocialworker
                    }
                    if let furtherlegal = document["furtherlegal"] as? Bool {
                        log.furtherlegal = furtherlegal
                    }
                    if let furtherOtherNotes = document["furtherOtherNotes"] as? String {
                        log.furtherOtherNotes = furtherOtherNotes
                    }
                    self.visitLogs.append(log)
                }
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.delegate?.visitLogDataRefreshed(self.visitLogs)
        }
    }// end class
}
