//
//  PublicVisitLogDataAdapter.swift
//  StreetCare
//
//  Created by Aishwarya S on 12/05/25.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import CoreLocation
import FirebaseStorage

protocol PublicVisitLogDataAdapterProtocol {
    func visitLogDataRefreshed(_ logs: [VisitLog])
}

class PublicVisitLogDataAdapter {

    private let collectionName = ""
    
    var visitLogs = [VisitLog]()
    var delegate: PublicVisitLogDataAdapterProtocol?
    
    func resetLogs() {
        visitLogs = [VisitLog]()
    }
    
    func refresh() {
        let settings = FirestoreSettings()

        Firestore.firestore().settings = settings
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        let _ = db.collection("VisitLogBook_New")
            .whereField("isPublic", isEqualTo: true)
            .whereField("status", isEqualTo: "approved")
            .order(by: "whenVisit", descending: true)
            .getDocuments { querySnapshot, error in
            
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                self.visitLogs.removeAll()
                for document in querySnapshot!.documents {
                                        
                    let log = VisitLog(id: document.documentID)

                    if let uid = document["uid"] as? String {
                        log.uid = uid

                        // Fetch user data and populate username + userType
                           db.collection("users")
                               .whereField("uid", isEqualTo: uid)
                               .limit(to: 1)
                               .getDocuments { userDoc, error in
                                   if let error = error {
                                       print("Error fetching user data: \(error.localizedDescription)")
                                   } else if let userDoc = userDoc?.documents.first {
                                       let data = userDoc.data()
                                       let user = UserDetails()
                                       user.uid = uid
                                       user.userName = data["username"] as? String ?? "Firstname Lastname"
                                       user.userType = data["Type"] as? String ?? "Account Holder"
                                       let photoURL = data["photoUrl"] as? String ?? ""
                                       
                                       log.user = user
                                       log.username = user.userName
                                       log.userType = user.userType
                                       log.photoURL = photoURL
                                       
                                       DispatchQueue.main.async {
                                           // Push updated log into visitLogs
                                           if let index = self.visitLogs.firstIndex(where: { $0.id == log.id }) {
                                               self.visitLogs[index] = log
                                               self.delegate?.visitLogDataRefreshed(self.visitLogs)
                                           }
                                           // Load image from photoURL if available
                                           if !log.photoURL.isEmpty, let url = URL(string: log.photoURL) {
                                               URLSession.shared.dataTask(with: url) { data, _, _ in
                                                   if let data = data, let image = UIImage(data: data) {
                                                       DispatchQueue.main.async {
                                                           log.user.image = image
                                                           log.image = image
                                                           if let index = self.visitLogs.firstIndex(where: { $0.id == log.id }) {
                                                               self.visitLogs[index] = log
                                                               self.delegate?.visitLogDataRefreshed(self.visitLogs)
                                                           }
                                                       }
                                                   }
                                               }.resume()
                                           } else {
                                               // Fallback to Firebase Storage
                                               let reference = Storage.storage().reference().child("users/\(uid)/profile.jpg")
                                               reference.getData(maxSize: .max) { data, error in
                                                   if let data = data, let image = UIImage(data: data) {
                                                       DispatchQueue.main.async {
                                                           log.user.image = image
                                                           log.image = image
                                                           if let index = self.visitLogs.firstIndex(where: { $0.id == log.id }) {
                                                               self.visitLogs[index] = log
                                                               self.delegate?.visitLogDataRefreshed(self.visitLogs)
                                                           }
                                                       }
                                                   }
                                               }
                                           }
                                       }
                                   }
                               }
                    }
                
                    if let whatGiven = document["whatGiven"] as? [String] {
                        log.whatGiven.append(contentsOf: whatGiven)
                    }
                    
                    if let whenVisit = document["whenVisit"] as? Timestamp {
                        log.whenVisit = whenVisit.dateValue()
                    }
                    if let whereVisit = document["whereVisit"] as? String {
                        log.whereVisit = whereVisit
                    }
                    
                    if let street = document["street"] as? String {
                        log.street = street
                    }
                    
                    if let state = document["state"] as? String {
                        log.state = state
                    }
                    
                    if let stateAbbv = document["stateAbbv"] as? String {
                        log.stateAbbv = stateAbbv
                    }
                    
                    if let city = document["city"] as? String {
                        log.city = city
                    }
                    
                    if let isFlagged = document["isFlagged"] as? Bool {
                        log.isFlagged = isFlagged
                    }
                    
                    if let flaggedByUser = document["flaggedByUser"] as? String {
                        log.flaggedByUser = flaggedByUser
                    }
                    if let peopleHelpedDescription = document["peopleHelpedDescription"] as? String {
                        log.peopleHelpedDescription = peopleHelpedDescription
                    }

                    if let peopleHelped = document["peopleHelped"] as? Int {
                        log.peopleHelped = peopleHelped
                    }

                    if let numberOfHelpers = document["numberOfHelpers"] as? Int {
                        log.numberOfHelpers = numberOfHelpers
                    }

                    if let itemQty = document["itemQty"] as? Int {
                        log.itemQty = itemQty
                    }
                    
                    self.visitLogs.append(log)
                }
            }
            
            self.delegate?.visitLogDataRefreshed(self.visitLogs)
        }
    }
}
