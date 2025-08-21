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

let placeholderDate = Date(timeIntervalSince1970: 0)

protocol VisitLogDataAdapterProtocol {
    func visitLogDataRefreshed(_ logs: [VisitLog])
    func visitLogDataRefreshedNew(_ logs: [VisitLog]) 
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
    
    func updateVisitLogField(_ logId: String, field: String, value: Any, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        
        let primaryRef = db.collection("VisitLogBook").document(logId)
        let fallbackRef = db.collection("VisitLogBook_New").document(logId)
        
        // Try updating in the primary collection
        primaryRef.getDocument { docSnapshot, error in
            if let doc = docSnapshot, doc.exists {
                primaryRef.updateData([field: value]) { error in
                    if let error = error {
                        print("⚠️ Error updating \(field) in VisitLogBook: \(error.localizedDescription)")
                    } else {
                        print("✅ \(field) updated successfully in VisitLogBook.")
                        completion()
                    }
                }
            } else {
                // Try the fallback collection
                fallbackRef.getDocument { fallbackDocSnapshot, _ in
                    if let fallbackDoc = fallbackDocSnapshot, fallbackDoc.exists {
                        fallbackRef.updateData([field: value]) { error in
                            if let error = error {
                                print("⚠️ Error updating \(field) in VisitLogBook_New: \(error.localizedDescription)")
                            } else {
                                print("✅ \(field) updated successfully in VisitLogBook_New.")
                                completion()
                            }
                        }
                    } else {
                        print("❌ Document \(logId) not found in either collection.")
                    }
                }
            }
        }
    }
    func updateVisitLogFields(_ logId: String, fields: [String: Any], completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        db.collection("VisitLogBook_New").document(logId).updateData(fields) { error in
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
            //"whatGiven": visitLog.whatGiven,
            "whatGiven": [
                visitLog.foodAndDrinks ? "Food and Drinks" : nil,
                visitLog.clothes ? "Clothes" : nil,
                visitLog.hygiene ? "Hygiene" : nil,
                visitLog.wellness ? "Wellness" : nil,
                visitLog.medical ? "Medical" : nil,
                visitLog.social ? "Social" : nil,
                visitLog.legal ? "Legal" : nil,
                visitLog.other ? "Other" : nil
            ].compactMap { $0 },
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
            //"whatGivenFurther": visitLog.whatGivenFurther,
            "whatGivenFurther": [
                visitLog.furtherFoodAndDrinks ? "Food and Drinks" : nil,
                visitLog.furtherClothes ? "Clothes" : nil,
                visitLog.furtherHygiene ? "Hygiene" : nil,
                visitLog.furtherWellness ? "Wellness" : nil,
                visitLog.furtherMedical ? "Medical" : nil,
                visitLog.furtherSocial ? "Social" : nil,
                visitLog.furtherLegal ? "Legal" : nil,
                visitLog.furtherOther ? "Other" : nil
            ].compactMap { $0 },
//            "followUpWhenVisit": visitLog.followUpWhenVisit,
            "followUpWhenVisit": visitLog.followUpWhenVisit == placeholderDate ? nil : Timestamp(date: visitLog.followUpWhenVisit),
            "futureNotes": visitLog.futureNotes,
            "volunteerAgain": visitLog.volunteerAgain,
            "lastEdited": Timestamp(date: Date()),
            "type": visitLog.type,
            "timeStamp": Timestamp(date: visitLog.timeStamp),
            "uid": user.uid,
            "isPublic": visitLog.isPublic,
            "isFlagged": visitLog.isFlagged,
            "flaggedByUser": visitLog.flaggedByUser,
            "status": visitLog.status
        ]
        
        print("User UID:", user.uid)
        print("VisitLog UID:", visitLog.uid)
        print("userData keys:", userData.keys.sorted())
        let docRef = db.collection(collectionName).document(visitLog.id) // Use visitLog.id
        docRef.setData(userData) { error in
            if let error = error {
                print("⚠️ Error writing VisitLog: \(error.localizedDescription)")
            } else {
                print("✅ Document successfully written with ID \(visitLog.id) to \(collectionName)!")
            }
        }
    }
    /*func addVisitLog_Community(_ visitLog: VisitLog) {
     
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
     }*/
    
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
        db.collection("visitLogWebProd").document(logId).delete { _ in
            completion()
        }
        db.collection("VisitLogBook_New").document(logId).delete { _ in
            completion()
        }
    }
    
    /*func refreshWebProd() {
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
                    log.source = "new"

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
                    
                    log.numberOfHelpers = Int(document["numberOfHelpers"] as? String ?? "") ?? 0
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

                    //log.followUpWhenVisit = (document["followUpWhenVisit"] as? Timestamp)?.dateValue() ?? Date()
                    if let timestamp = document["followUpWhenVisit"] as? Timestamp {
                        log.followUpWhenVisit = timestamp.dateValue()
                    } else {
                        log.followUpWhenVisit = placeholderDate // explicitly set placeholder if not present
                    }
                    log.futureNotes = document["futureNotes"] as? String ?? ""
                    log.volunteerAgain = document["volunteerAgain"] as? String ?? ""
                    
                    log.lastEdited = (document["lastEdited"] as? Timestamp)?.dateValue() ?? Date()
                    log.timeStamp = (document["timeStamp"] as? Timestamp)?.dateValue() ?? Date()
                    
                    log.type = document["type"] as? String ?? ""
                    log.uid = document["uid"] as? String ?? ""
                    log.isPublic = document["isPublic"] as? Bool ?? false
                    log.isFlagged = document["isFlagged"] as? Bool ?? false
                    log.flaggedByUser = document["flaggedByUser"] as? String ?? ""
                    log.status = document["status"] as? String ?? ""
                    
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
            for log in self.visitLogs where log.uid == user.uid {
                if log.source == "new" && log.isPublic {
                    switch log.status.lowercased() {
                    case "approved":
                        self.publishedLogIDs.insert(log.id)
                    case "pending":
                        self.pendingLogIDs.insert(log.id)
                    case "rejected":
                        self.rejectedLogIDs.insert(log.id)
                    default:
                        break
                    }
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
                    
                    log.volunteerAgain = document["volunteerAgain"] as? String ?? ""
                    log.isFromOldCollection = false
                    
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
            //fetch logs from visitLogWebProd
            db.collection("visitLogWebProd").whereField("uid", isEqualTo: user.uid).getDocuments { querySnapshot, error in
                if let error = error {
                    print("⚠️ Error fetching WebProd logs: \(error.localizedDescription)")
                } else {
                    for document in querySnapshot!.documents {
                        let log = VisitLog(id: document.documentID)
                        log.source = "webProd"
                        
                        log.whereVisit = document["whereVisit"] as? String ?? ""
                        log.city = document["city"] as? String ?? ""
                        log.state = document["state"] as? String ?? ""
                        log.stateAbbv = document["stateAbbv"] as? String ?? ""
                        log.street = document["street"] as? String ?? ""
                        log.zipcode = document["zipcode"] as? String ?? ""
                        log.whereVisit = [log.street, log.city, log.state, log.zipcode]
                            .filter { !$0.isEmpty }
                            .joined(separator: ", ")
                        log.numberPeopleHelped = document["numberPeopleHelped"] as? String ?? "0"
                        log.itemQty = document["itemQty"] as? Int ?? 0
                        log.whatGiven = document["whatGiven"] as? [String] ?? []
                        log.rating = document["rating"] as? Int ?? 0
                        log.status = document["status"] as? String ?? ""
                        log.isFlagged = document["isFlagged"] as? Bool ?? false
                        log.flaggedByUser = document["flaggedByUser"] as? String ?? ""
                        log.uid = document["uid"] as? String ?? ""
                        log.isPublic = document["public"] as? Bool ?? false
                        if log.isPublic {
                            switch log.status.lowercased() {
                            case "approved":
                                self.publishedLogIDs.insert(log.id)
                            case "pending":
                                self.pendingLogIDs.insert(log.id)
                            case "rejected":
                                self.rejectedLogIDs.insert(log.id)
                            default:
                                break
                            }
                        }
                        log.whenVisit = (document["dateTime"] as? Timestamp)?.dateValue() ?? Date()
                        log.isFromOldCollection = true
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
}
