//
//  ProfileDetailsAdapter.swift
//  StreetCare
//
//  Created by Michael Thornton on 6/1/23.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift


protocol ProfileDetailsAdapterProtocol {
    func profileDataRefreshed(_ profile: ProfileDetail)
}



class ProfileDetailsAdapter {

    private let collectionName = "users"
    
    var profile = ProfileDetail()
    var delegate: ProfileDetailsAdapterProtocol?
    
    
    func saveProfile(_ profile: ProfileDetail) {
    
        if profile.documentId.count > 0 {
            
            Firestore.firestore().settings = FirestoreSettings()
            let db = Firestore.firestore()

            print("deleting \(profile.documentId)")
            
            db.collection(collectionName).document(profile.documentId).delete() {_ in
                self.addProfile(profile)
            }
        }
        else {
            addProfile(profile)
        }
    }
    
    
    
    func addProfile(_ profile: ProfileDetail) {
    
        guard let user = Auth.auth().currentUser else {
            print("no user?")
            return
        }
        
        let settings = FirestoreSettings()

        Firestore.firestore().settings = settings
        let db = Firestore.firestore()
        
        var userData = [String: Any]()
        userData["dateCreated"] = Date()
        userData["uid"] = user.uid
        userData["username"] = profile.displayName
        userData["organization"] = profile.organization
        userData["country"] = profile.country != "" ? profile.country : Locale.current.region
        userData["deviceType"] = "iOS"
        if profile.email != ""{
            userData["email"] = profile.email
        }
        userData["isValid"] = true

        
        db.collection(collectionName).document().setData(userData) { err in
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
        
        let _ = db.collection(collectionName).whereField("uid", isEqualTo: user.uid).getDocuments { querySnapshot, error in
            
            if let error = error {
                print(error.localizedDescription)
            }
            else {
                
                for document in querySnapshot!.documents {
                    
                    print(document.data())
                    
                    self.profile.documentId = document.documentID
                    
                    if let uid = document["uid"] as? String {
                        self.profile.id = uid
                    }
                    
                    if let username = document["username"] as? String {
                        self.profile.displayName = username
                    }

                    if let organization = document["organization"] as? String {
                        self.profile.organization = organization
                    }

                    if let country = document["country"] as? String {
                        self.profile.country = country
                    }
                }
            }
            
            self.delegate?.profileDataRefreshed(self.profile)
        }
    }

} // end class
