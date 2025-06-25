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

    private let collectionName = "VisitLogBook_New"
    
    var visitLogs = [VisitLog]()
    var delegate: PublicVisitLogDataAdapterProtocol?

    func resetLogs() {
        visitLogs = []
    }

    func refreshAll() {
        resetLogs()
        var combinedLogs: [VisitLog] = []
        let group = DispatchGroup()

        let db = Firestore.firestore()
        let storage = Storage.storage()

        // WebProd
        group.enter()
        db.collection("visitLogWebProd")
            .whereField("isPublic", isEqualTo: true)
            .whereField("status", isEqualTo: "approved")
            .order(by: "whenVisit", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("⚠️ Error fetching visitLogWebProd: \(error.localizedDescription)")
                    group.leave()
                    return
                }

                for document in snapshot?.documents ?? [] {
                    let log = self.parseLog(document: document)
                    if let uid = document["uid"] as? String {
                        log.uid = uid
                        self.fetchUserDetails(uid: uid, log: log, storage: storage)
                    }
                    combinedLogs.append(log)
                }
                group.leave()
            }

        // VisitLogBook_New
        group.enter()
        db.collection(collectionName)
            .whereField("isPublic", isEqualTo: true)
            .whereField("status", isEqualTo: "approved")
            .order(by: "whenVisit", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("⚠️ Error fetching \(self.collectionName): \(error.localizedDescription)")
                    group.leave()
                    return
                }

                for document in snapshot?.documents ?? [] {
                    let log = self.parseLog(document: document)
                    if let uid = document["uid"] as? String {
                        log.uid = uid
                        self.fetchUserDetails(uid: uid, log: log, storage: storage)
                    }
                    combinedLogs.append(log)
                }
                group.leave()
            }

        group.notify(queue: .main) {
            self.visitLogs = combinedLogs.sorted(by: { $0.whenVisit > $1.whenVisit })
            self.delegate?.visitLogDataRefreshed(self.visitLogs)
        }
    }

    private func parseLog(document: QueryDocumentSnapshot) -> VisitLog {
        let log = VisitLog(id: document.documentID)
        log.isPublic = document["isPublic"] as? Bool ?? false
        log.whenVisit = (document["whenVisit"] as? Timestamp)?.dateValue() ?? Date()
        log.whereVisit = document["whereVisit"] as? String ?? ""
        log.street = document["street"] as? String ?? ""
        log.state = document["state"] as? String ?? ""
        log.stateAbbv = document["stateAbbv"] as? String ?? ""
        log.city = document["city"] as? String ?? ""
        log.isFlagged = document["isFlagged"] as? Bool ?? false
        log.flaggedByUser = document["flaggedByUser"] as? String ?? ""
        log.peopleHelpedDescription = document["peopleHelpedDescription"] as? String ?? ""
        log.peopleHelped = document["peopleHelped"] as? Int ?? 0
        log.numberOfHelpers = document["numberOfHelpers"] as? Int ?? 0
        log.itemQty = document["itemQty"] as? Int ?? 0
        log.whatGiven = document["whatGiven"] as? [String] ?? []
        let components = log.whereVisit
             .components(separatedBy: ",")
             .map { $0.trimmingCharacters(in: .whitespaces) }
             .filter { !$0.isEmpty }

         if components.count >= 4 {
             log.street = components.dropLast(3).joined(separator: ", ")
             log.city = components[components.count - 3]
             log.state = components[components.count - 2]
         } else if components.count == 3 {
             log.street = components[0]
             log.city = components[1]
             log.state = components[2]
         } else if components.count == 2 {
             log.street = ""
             log.city = components[0]
             log.state = components[1]
         } else if components.count == 1 {
             log.street = ""
             log.city = components[0]
             log.state = ""
         } else {
             log.street = ""
             log.city = ""
             log.state = ""
         }
        return log
    }

    private func fetchUserDetails(uid: String, log: VisitLog, storage: Storage) {
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("uid", isEqualTo: uid)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("⚠️ Error fetching user data: \(error.localizedDescription)")
                    return
                }

                guard let data = snapshot?.documents.first?.data() else { return }
                let user = UserDetails()
                user.uid = uid
                user.userName = data["username"] as? String ?? "Firstname Lastname"
                user.userType = data["Type"] as? String ?? "Account Holder"
                log.user = user
                log.username = user.userName
                log.userType = user.userType
                log.photoURL = data["photoUrl"] as? String ?? ""

                DispatchQueue.main.async {
                    if let index = self.visitLogs.firstIndex(where: { $0.id == log.id }) {
                        self.visitLogs[index] = log
                        self.delegate?.visitLogDataRefreshed(self.visitLogs)
                    }
                }

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
                    let reference = storage.reference().child("users/\(uid)/profile.jpg")
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
