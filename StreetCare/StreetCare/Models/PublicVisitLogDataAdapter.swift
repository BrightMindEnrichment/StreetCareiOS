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
        
        let _ = db.collection("visitLogWebProd")
            .whereField("public", isEqualTo: true)
            .whereField("status", isEqualTo: "approved")
            .order(by: "dateTime", descending: true)
            .getDocuments { querySnapshot, error in
            
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                self.visitLogs.removeAll()
                for document in querySnapshot!.documents {
                                        
                    let log = VisitLog(id: document.documentID)
                    if let isPublic = document["public"] as? Bool {
                        log.isPublic = isPublic
                    }
                    
                    if let uid = document["uid"] as? String {
                        // fetch user details and profile picture url
                        let user = UserDetails()
                        db.collection("users")
                            .whereField("uid", isEqualTo: uid)
                            .limit(to: 1)
                            .getDocuments { userDoc, error in
                                if let error = error {
                                print("Error fetching user data: \(error.localizedDescription)")
                            } else if let userDoc = userDoc?.documents.first {
                                let userData = userDoc.data()
                                user.uid = uid
                                user.userType = userData["Type"] as? String ?? ""
                                user.userName = userData["username"] as? String ?? ""
                            }
                        }
                        
                        let reference = storage.reference().child("webappUserImages/").child(uid)
                        user.profilePictureURL = reference.fullPath
                        reference.getData(maxSize: .max) { data, error in
                            if let error = error {
                                user.image = nil
                                print("error fetching image: \(error.localizedDescription)")
                            }
                            if let data = data {
                                print("successs: \(uid)")
                                user.image = UIImage(data: data)
                            }
                        }
                        log.user = user
                    }
                    
                    if let whatGiven = document["whatGiven"] as? [String] {
                        log.whatGiven.append(contentsOf: whatGiven)
                    }
                    
                    if let dateTime = document["dateTime"] as? Timestamp {
                        log.whenVisit = dateTime.dateValue()
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
                    
                    self.visitLogs.append(log)
                }
            }
            
            self.delegate?.visitLogDataRefreshed(self.visitLogs)
        }
    }
}
