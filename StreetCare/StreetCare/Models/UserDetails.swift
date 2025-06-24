//
//  UserDetails.swift
//  StreetCare
//
//  Created by Aishwarya S on 26/05/25.
//

import Foundation
import CoreLocation
import UIKit
import FirebaseFirestore

class UserDetails: ObservableObject, Identifiable {
    @Published var uid = ""
    @Published var profilePictureURL = ""
    @Published var image: UIImage?
    @Published var userType = ""
    @Published var userName = ""
}

protocol UserDetailsDataAdapterDelegateProtocol {
    func userDetailsFetched(_ user: UserDetails?)
}

class UserDetailsAdapter {
    var delegate: UserDetailsDataAdapterDelegateProtocol?
    func getUserDetails(uid: String?) {
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        let db = Firestore.firestore()
        
        let user = UserDetails()
        if let uid = uid {
            db.collection("users")
                .whereField("uid", isEqualTo: uid)
                .limit(to: 1)
                .getDocuments { [weak self] userDoc, error in
                    if let error = error {
                        print("Error fetching user data: \(error.localizedDescription)")
                    } else if let userDoc = userDoc?.documents.first {
                        let userData = userDoc.data()
                        user.uid = uid
                        user.userType = userData["Type"] as? String ?? ""
                        user.userName = userData["username"] as? String ?? ""
                        self?.delegate?.userDetailsFetched(user)
                    }
                }
        }
        delegate?.userDetailsFetched(nil)
    }
}
