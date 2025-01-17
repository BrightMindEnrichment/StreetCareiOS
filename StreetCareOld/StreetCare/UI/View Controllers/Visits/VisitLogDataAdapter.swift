//
//  VisitLogDataAdapter.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/6/22.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift


protocol VisitLogDataAdapterProtocol {
    func visitLogDataRefreshed(_ logs: [VisitLog])
}



class VisitLogDataAdapter {

    var visitLogs = [VisitLog]()
    var delegate: VisitLogDataAdapterProtocol?
    
    
    
    func addVisitLog(_ visitLog: VisitLog) {
    
        
        guard let user = Auth.auth().currentUser else {
            Auth.auth().signInAnonymously { result, error in
                self.addVisitLog(visitLog)
            }
            
            return
        }
//        guard let user = Auth.auth().currentUser else {
//            print("no user?")
//            return
//        }
        
        
        let settings = FirestoreSettings()

        Firestore.firestore().settings = settings
        let db = Firestore.firestore()
        
        var userData = [String: Any]()
        userData["comments"] = visitLog.comments
        userData["date"] = visitLog.date
        userData["helpers"] = visitLog.peopleCount
        userData["hoursSpentOnOutreach"] = visitLog.hours
        userData["location"] = visitLog.location
        userData["rating"] = visitLog.experience
        userData["willPerformOutreachAgain"] = visitLog.visitAgain
        userData["uid"] = user.uid
        
        db.collection("surveys").document().setData(userData) { err in
            if let err = err {
                // don't bother user with this error
                print(err.localizedDescription)
            } else {
                print("Document successfully written!")
            }
        }
    }
    
    
    
    func refresh() {
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let settings = FirestoreSettings()

        Firestore.firestore().settings = settings
        let db = Firestore.firestore()
        
        let _ = db.collection("surveys").whereField("uid", isEqualTo: user.uid).getDocuments { querySnapshot, error in
            
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                
                // clear out the existing logs
                self.visitLogs.removeAll()
                
                for document in querySnapshot!.documents {
                    
                    print(document.data())

                    let log = VisitLog()
                    
                    if let location = document["location"] as? String {
                        log.location = location
                    }
                    
                    if let date = document["date"] as? Timestamp {
                        log.date = date.dateValue()
                    }

                    if let hours = document["hoursSpentOnOutreach"] as? Int {
                        log.hours = hours
                    }

                    if let visitAgain = document["willPerformOutreachAgain"] as? String {
                        log.visitAgain = visitAgain
                    }

                    if let peopleCount = document["helpers"] as? Int {
                        log.peopleCount = peopleCount
                    }
                    
                    if let experience = document["rating"] as? String {
                        log.experience = experience
                    }
                    
                    if let comments = document["comments"] as? String {
                        log.comments = comments
                    }

                    self.visitLogs.append(log)
                }
            }
            
            self.delegate?.visitLogDataRefreshed(self.visitLogs)
        }
    }

} // end class
