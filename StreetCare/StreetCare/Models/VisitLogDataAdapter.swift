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
    func visitLogDataRefreshedNew(_ logs: [VisitLog]) 
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
            print("No user?")
            return
        }

        let collectionName = "VisitLogBook_New"
        let db = Firestore.firestore()

        var userData: [String: Any] = [
            "whenVisit": Timestamp(date: visitLog.whenVisit),
            "whereVisit": visitLog.whereVisit,
            "locationDescription": visitLog.locationDescription,
            "peopleHelped": visitLog.peopleHelped,
            "peopleHelpedDescription": visitLog.peopleHelpedDescription,
            "foodAndDrinks": visitLog.foodAndDrinks,
            "clothes": visitLog.clothes,
            "hygiene": visitLog.hygiene,
            "wellness": visitLog.wellness,
            "medical": visitLog.medical,
            "social": visitLog.social,
            "legal": visitLog.legal,
            "other": visitLog.other,
            "whatGiven": visitLog.whatGiven,
            "otherNotes": visitLog.otherNotes,
            "itemQty": visitLog.itemQty,
            "itemQtyDescription": visitLog.itemQtyDescription,
            "rating": visitLog.rating,
            "ratingNotes": visitLog.ratingNotes,
            "durationHours": visitLog.durationHours,
            "durationMinutes": visitLog.durationMinutes,
            "numberOfHelpers": visitLog.numberOfHelpers,
            "numberOfHelpersComment": visitLog.numberOfHelpersComment,
            "peopleNeedFurtherHelp": visitLog.peopleNeedFurtherHelp,
            "peopleNeedFurtherHelpComment": visitLog.peopleNeedFurtherHelpComment,
            "peopleNeedFurtherHelpLocation": visitLog.peopleNeedFurtherHelpLocation,
            "furtherFoodAndDrinks": visitLog.furtherFoodAndDrinks,
            "furtherClothes": visitLog.furtherClothes,
            "furtherHygiene": visitLog.furtherHygiene,
            "furtherWellness": visitLog.furtherWellness,
            "furtherMedical": visitLog.furtherMedical,
            "furtherSocial": visitLog.furtherSocial,
            "furtherLegal": visitLog.furtherLegal,
            "furtherOther": visitLog.furtherOther,
            "furtherOtherNotes": visitLog.furtherOtherNotes,
            "whatGivenFurther": visitLog.whatGivenFurther,
            "followUpWhenVisit": Timestamp(date: visitLog.followUpWhenVisit),
            "futureNotes": visitLog.futureNotes,
            "volunteerAgain": visitLog.volunteerAgain,
            "lastEdited": Timestamp(date: Date()),
            "type": visitLog.type,
            "timeStamp": Timestamp(date: visitLog.timeStamp),
            "uid": user.uid,
            "isPublic": visitLog.isPublic,
            "isFlagged": visitLog.isFlagged,
            "flaggedByUser": visitLog.flaggedByUser
        ]

        /*if visitLog.location.latitude != 0 || visitLog.location.longitude != 0 {
            userData["location"] = [
                "latitude": visitLog.location.latitude,
                "longitude": visitLog.location.longitude
            ]
        }*/
        // 🔍 Add these debug statements here:
        print("User UID:", user.uid)
        print("VisitLog UID:", visitLog.uid)
        print("userData keys:", userData.keys.sorted())
        db.collection(collectionName).document().setData(userData) { error in
            if let error = error {
                print("⚠️ Error writing VisitLog: \(error.localizedDescription)")
            } else {
                print("✅ Document successfully written to \(collectionName)!")
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
    func refresh_new() {
        print("📥 refresh_new called")
        guard let user = Auth.auth().currentUser else {
            self.visitLogs = [VisitLog]()
            self.delegate?.visitLogDataRefreshed(self.visitLogs)
            return
        }

        let db = Firestore.firestore()
        db.collection("VisitLogBook_New").whereField("uid", isEqualTo: user.uid).getDocuments {
            querySnapshot, error in
            if let error = error {
                print("⚠️", error.localizedDescription)
            } else {
                self.visitLogs.removeAll()

                for document in querySnapshot!.documents {
                    let log = VisitLog(id: document.documentID)

                    log.whenVisit = (document["whenVisit"] as? Timestamp)?.dateValue() ?? Date()
                    log.whereVisit = document["whereVisit"] as? String ?? ""
                    log.locationDescription = document["locationDescription"] as? String ?? ""
                    log.peopleHelped = document["peopleHelped"] as? Int ?? 0
                    log.peopleHelpedDescription = document["peopleHelpedDescription"] as? String ?? ""

                    log.foodAndDrinks = document["foodAndDrinks"] as? Bool ?? false
                    log.clothes = document["clothes"] as? Bool ?? false
                    log.hygiene = document["hygiene"] as? Bool ?? false
                    log.wellness = document["wellness"] as? Bool ?? false
                    log.medical = document["medical"] as? Bool ?? false
                    log.social = document["social"] as? Bool ?? false
                    log.legal = document["legal"] as? Bool ?? false
                    log.other = document["other"] as? Bool ?? false
                    log.whatGiven = document["whatGiven"] as? [String] ?? []
                    log.otherNotes = document["otherNotes"] as? String ?? ""

                    log.itemQty = document["itemQty"] as? Int ?? 0
                    log.itemQtyDescription = document["itemQtyDescription"] as? String ?? ""

                    log.rating = document["rating"] as? Int ?? 0
                    log.ratingNotes = document["ratingNotes"] as? String ?? ""

                    log.durationHours = document["durationHours"] as? Int ?? -1
                    log.durationMinutes = document["durationMinutes"] as? Int ?? -1

                    log.numberOfHelpers = document["numberOfHelpers"] as? Int ?? 0
                    log.numberOfHelpersComment = document["numberOfHelpersComment"] as? String ?? ""

                    log.peopleNeedFurtherHelp = document["peopleNeedFurtherHelp"] as? Int ?? 0
                    log.peopleNeedFurtherHelpComment = document["peopleNeedFurtherHelpComment"] as? String ?? ""
                    log.peopleNeedFurtherHelpLocation = document["peopleNeedFurtherHelpLocation"] as? String ?? ""

                    log.furtherFoodAndDrinks = document["furtherFoodAndDrinks"] as? Bool ?? false
                    log.furtherClothes = document["furtherClothes"] as? Bool ?? false
                    log.furtherHygiene = document["furtherHygiene"] as? Bool ?? false
                    log.furtherWellness = document["furtherWellness"] as? Bool ?? false
                    log.furtherMedical = document["furtherMedical"] as? Bool ?? false
                    log.furtherSocial = document["furtherSocial"] as? Bool ?? false
                    log.furtherLegal = document["furtherLegal"] as? Bool ?? false
                    log.furtherOther = document["furtherOther"] as? Bool ?? false
                    log.furtherOtherNotes = document["furtherOtherNotes"] as? String ?? ""
                    log.whatGivenFurther = document["whatGivenFurther"] as? [String] ?? []

                    log.followUpWhenVisit = (document["followUpWhenVisit"] as? Timestamp)?.dateValue() ?? Date()
                    log.futureNotes = document["futureNotes"] as? String ?? ""
                    log.volunteerAgain = document["volunteerAgain"] as? String ?? ""

                    log.lastEdited = (document["lastEdited"] as? Timestamp)?.dateValue() ?? Date()
                    log.timeStamp = (document["timeStamp"] as? Timestamp)?.dateValue() ?? Date()

                    log.type = document["type"] as? String ?? ""
                    log.uid = document["uid"] as? String ?? ""
                    log.isPublic = document["isPublic"] as? Bool ?? false
                    log.isFlagged = document["isFlagged"] as? Bool ?? false
                    log.flaggedByUser = document["flaggedByUser"] as? String ?? ""

                    if let lat = document["latitude"] as? Double,
                       let lon = document["longitude"] as? Double {
                        log.location = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    }
                    print("✅ Loaded log from VisitLogBook_New with id:", log.id)

                    self.visitLogs.append(log)
                }
            }
            if let snapshot = querySnapshot {
                print("📄 Document count: \(snapshot.documents.count)")
                for doc in snapshot.documents {
                    print("📌 Doc ID: \(doc.documentID), Data: \(doc.data())")
                }
            }
            self.delegate?.visitLogDataRefreshedNew(self.visitLogs)
        }
    }
    
    func refresh() {
        guard let user = Auth.auth().currentUser else {
            self.visitLogs = [VisitLog]()
            self.delegate?.visitLogDataRefreshed(self.visitLogs)
            return
        }
        
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        let db = Firestore.firestore()
        
        db.collection("VisitLogBook").whereField("uid", isEqualTo: user.uid).getDocuments { querySnapshot, error in
            if let error = error {
                print("⚠️", error.localizedDescription)
            } else {
                self.visitLogs.removeAll()
                
                for document in querySnapshot!.documents {
                    let log = VisitLog(id: document.documentID)
                    
                    log.whereVisit = document["whereVisit"] as? String ?? ""
                    log.locationDescription = document["locationDescription"] as? String ?? ""
                    log.peopleHelped = document["peopleHelped"] as? Int ?? 0
                    log.peopleHelpedDescription = document["peopleHelpedDescription"] as? String ?? ""
                    log.foodAndDrinks = document["foodAndDrinks"] as? Bool ?? false
                    log.clothes = document["clothes"] as? Bool ?? false
                    log.hygiene = document["hygiene"] as? Bool ?? false
                    log.wellness = document["wellness"] as? Bool ?? false
                    log.medical = document["medical"] as? Bool ?? false
                    log.social = document["social"] as? Bool ?? false
                    log.legal = document["legal"] as? Bool ?? false
                    log.other = document["other"] as? Bool ?? false
                    log.otherNotes = document["otherNotes"] as? String ?? ""
                    log.itemQty = document["itemQty"] as? Int ?? 0
                    log.itemQtyDescription = document["itemQtyDescription"] as? String ?? ""
                    log.rating = document["rating"] as? Int ?? 0
                    log.ratingNotes = document["ratingNotes"] as? String ?? ""
                    log.durationHours = document["durationHours"] as? Int ?? -1
                    log.durationMinutes = document["durationMinutes"] as? Int ?? -1
                    log.numberOfHelpers = document["numberOfHelpers"] as? Int ?? 0
                    log.numberOfHelpersComment = document["numberOfHelpersComment"] as? String ?? ""
                    log.peopleNeedFurtherHelp = document["peopleNeedFurtherHelp"] as? Int ?? 0
                    log.peopleNeedFurtherHelpComment = document["peopleNeedFurtherHelpComment"] as? String ?? ""
                    log.peopleNeedFurtherHelpLocation = document["peopleNeedFurtherHelpLocation"] as? String ?? ""
                    log.furtherFoodAndDrinks = document["furtherFoodAndDrinks"] as? Bool ?? false
                    log.furtherClothes = document["furtherClothes"] as? Bool ?? false
                    log.furtherHygiene = document["furtherHygiene"] as? Bool ?? false
                    log.furtherWellness = document["furtherWellness"] as? Bool ?? false
                    log.furtherMedical = document["furtherMedical"] as? Bool ?? false
                    log.furtherSocial = document["furtherSocial"] as? Bool ?? false
                    log.furtherLegal = document["furtherLegal"] as? Bool ?? false
                    log.furtherOther = document["furtherOther"] as? Bool ?? false
                    log.furtherOtherNotes = document["furtherOtherNotes"] as? String ?? ""
                    log.type = document["type"] as? String ?? ""
                    log.status = document["status"] as? String ?? ""
                    log.flaggedByUser = document["flaggedByUser"] as? String ?? ""
                    
                    /*if let volunteerAgainStr = document["volunteerAgain"] as? String {
                        switch volunteerAgainStr {
                        case "Yes": log.volunteerAgain = 1
                        case "No": log.volunteerAgain = 0
                        default: log.volunteerAgain = -1
                        }
                    }*/
                    log.volunteerAgain = document["volunteerAgain"] as? String ?? ""
                    
                    if let whenVisit = document["whenVisit"] as? Timestamp {
                        log.whenVisit = whenVisit.dateValue()
                    }
                    if let followUp = document["followUpWhenVisit"] as? Timestamp {
                        log.followUpWhenVisit = followUp.dateValue()
                    }
                    
                    if let latitude = document["latitude"] as? Double,
                       let longitude = document["longitude"] as? Double {
                        log.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                    }
                    
                    self.visitLogs.append(log)
                }
            }
            
            self.delegate?.visitLogDataRefreshed(self.visitLogs)
        }
    }
}
