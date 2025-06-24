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

    var visitLogs = [VisitLog]()
    var delegate: PublicVisitLogDataAdapterProtocol?

    func resetLogs() {
        visitLogs = []
    }

    func refreshAll() {
        resetLogs()

        var combinedLogs: [VisitLog] = []

        let group = DispatchGroup()

        group.enter()
        refreshWebProd { logs in
            combinedLogs.append(contentsOf: logs)
            group.leave()
        }

        group.enter()
        refreshVisitLogBookNew { logs in
            combinedLogs.append(contentsOf: logs)
            group.leave()
        }

        group.notify(queue: .main) {
            self.visitLogs = combinedLogs.sorted { $0.whenVisit > $1.whenVisit }
            self.delegate?.visitLogDataRefreshed(self.visitLogs)
        }
    }

    private func refreshWebProd(completion: @escaping ([VisitLog]) -> Void) {
        let db = Firestore.firestore()
        let storage = Storage.storage()

        db.collection("visitLogWebProd")
            .whereField("public", isEqualTo: true)
            .whereField("status", isEqualTo: "approved")
            .order(by: "dateTime", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("⚠️ Error fetching WebProd logs: \(error.localizedDescription)")
                    completion([])
                    return
                }

                var logs: [VisitLog] = []

                for document in snapshot?.documents ?? [] {
                    let log = VisitLog(id: document.documentID)

                    log.isPublic = document["public"] as? Bool ?? false
                    log.whenVisit = (document["dateTime"] as? Timestamp)?.dateValue() ?? Date()
                    log.street = document["street"] as? String ?? ""
                    log.city = document["city"] as? String ?? ""
                    log.state = document["state"] as? String ?? ""
                    log.stateAbbv = document["stateAbbv"] as? String ?? ""
                    log.whatGiven = document["whatGiven"] as? [String] ?? []
                    log.isFlagged = document["isFlagged"] as? Bool ?? false
                    log.flaggedByUser = document["flaggedByUser"] as? String ?? ""

                    // User info
                    if let uid = document["uid"] as? String {
                        log.uid = uid
                        self.fetchUserDetails(uid: uid, storage: storage) { userDetails in
                            if let userDetails = userDetails {
                                log.user = userDetails
                            }
                        }
                    }

                    logs.append(log)
                }

                completion(logs)
            }
    }

    private func refreshVisitLogBookNew(completion: @escaping ([VisitLog]) -> Void) {
        let db = Firestore.firestore()
        let storage = Storage.storage()

        db.collection("VisitLogBook_New")
            .whereField("isPublic", isEqualTo: true)
            .whereField("status", isEqualTo: "approved")
            .order(by: "whenVisit", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("⚠️ Error fetching VisitLogBook_New: \(error.localizedDescription)")
                    completion([])
                    return
                }

                var logs: [VisitLog] = []

                for document in snapshot?.documents ?? [] {
                    let log = VisitLog(id: document.documentID)

                    log.isPublic = document["isPublic"] as? Bool ?? false
                    log.whenVisit = (document["whenVisit"] as? Timestamp)?.dateValue() ?? Date()
                    log.whereVisit = document["whereVisit"] as? String ?? ""
                    log.peopleHelped = document["peopleHelped"] as? Int ?? 0
                    log.whatGiven = document["whatGiven"] as? [String] ?? []
                    log.isFlagged = document["isFlagged"] as? Bool ?? false
                    log.flaggedByUser = document["flaggedByUser"] as? String ?? ""
                    log.uid = document["uid"] as? String ?? ""
                    //userdetails
                    if let uid = document["uid"] as? String {
                        log.uid = uid
                        self.fetchUserDetails(uid: uid, storage: storage) { userDetails in
                            if let userDetails = userDetails {
                                log.user = userDetails
                            }
                        }
                    }

                    logs.append(log)
                }

                completion(logs)
            }
    }

    private func fetchUserDetails(uid: String, storage: Storage, completion: @escaping (UserDetails?) -> Void) {
        let db = Firestore.firestore()
        let userDetails = UserDetails()
        userDetails.uid = uid

        db.collection("users")
            .whereField("uid", isEqualTo: uid)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("⚠️ Error fetching user details: \(error.localizedDescription)")
                    completion(nil)
                    return
                }

                if let data = snapshot?.documents.first?.data() {
                    userDetails.userName = data["username"] as? String ?? ""
                    userDetails.userType = data["Type"] as? String ?? ""
                }

                let ref = storage.reference().child("webappUserImages/\(uid)")
                userDetails.profilePictureURL = ref.fullPath

                ref.getData(maxSize: 5 * 1024 * 1024) { data, error in
                    if let error = error {
                        //print("⚠️ Error fetching profile image: \(error.localizedDescription)")
                        userDetails.image = nil
                    } else if let data = data {
                        userDetails.image = UIImage(data: data)
                    }

                    completion(userDetails)
                }
            }
    }
}
