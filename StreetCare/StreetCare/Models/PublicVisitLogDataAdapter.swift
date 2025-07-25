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
                guard let documents = snapshot?.documents, error == nil else {
                    print("⚠️ Error fetching WebProd logs: \(error?.localizedDescription ?? "")")
                    completion([])
                    return
                }

                var logs: [VisitLog] = []
                let dispatchGroup = DispatchGroup()

                for document in documents {
                    let log = VisitLog(id: document.documentID)
                    log.source = "webProd"


                    log.isPublic = document["public"] as? Bool ?? false
                    log.whenVisit = (document["dateTime"] as? Timestamp)?.dateValue() ?? Date()
                    log.street = document["street"] as? String ?? ""
                    log.city = document["city"] as? String ?? ""
                    log.state = document["state"] as? String ?? ""
                    log.stateAbbv = document["stateAbbv"] as? String ?? ""
                    log.whatGiven = document["whatGiven"] as? [String] ?? []
                    log.isFlagged = document["isFlagged"] as? Bool ?? false
                    log.flaggedByUser = document["flaggedByUser"] as? String ?? ""
                    log.description = document["description"] as? String ?? ""
                    log.numberPeopleHelped = document["numberPeopleHelped"] as? String ?? "0"
                    log.itemQtyWeb = document["itemQty"] as? String ?? "0"

                    if let uid = document["uid"] as? String {
                        log.uid = uid
                        dispatchGroup.enter()
                        self.fetchUserDetails(uid: uid, storage: storage) { userDetails in
                            if let userDetails = userDetails {
                                log.user = userDetails
                            }
                            dispatchGroup.leave()
                        }
                    }

                    logs.append(log)
                }

                dispatchGroup.notify(queue: .main) {
                    completion(logs)
                }
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
                guard let documents = snapshot?.documents, error == nil else {
                    print("⚠️ Error fetching VisitLogBook_New: \(error?.localizedDescription ?? "")")
                    completion([])
                    return
                }

                var logs: [VisitLog] = []
                let dispatchGroup = DispatchGroup()

                for document in documents {
                    let log = VisitLog(id: document.documentID)
                    log.source = "new"

                    log.isPublic = document["isPublic"] as? Bool ?? false
                    log.whenVisit = (document["whenVisit"] as? Timestamp)?.dateValue() ?? Date()
                    log.whereVisit = document["whereVisit"] as? String ?? ""
                    log.peopleHelped = document["peopleHelped"] as? Int ?? 0
                    log.whatGiven = document["whatGiven"] as? [String] ?? []
                    log.isFlagged = document["isFlagged"] as? Bool ?? false
                    log.flaggedByUser = document["flaggedByUser"] as? String ?? ""

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
                    }

                    if let uid = document["uid"] as? String {
                        log.uid = uid
                        dispatchGroup.enter()
                        self.fetchUserDetails(uid: uid, storage: storage) { userDetails in
                            if let userDetails = userDetails {
                                log.user = userDetails
                            }
                            dispatchGroup.leave()
                        }
                    }

                    logs.append(log)
                }

                dispatchGroup.notify(queue: .main) {
                    completion(logs)
                }
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
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }

                if let data = snapshot?.documents.first?.data() {
                    userDetails.userName = data["username"] as? String ?? ""
                    userDetails.userType = data["Type"] as? String ?? ""
                }

                let ref = storage.reference().child("webappUserImages/\(uid)")
                userDetails.profilePictureURL = ref.fullPath

                ref.getData(maxSize: 5 * 1024 * 1024) { data, error in
                    DispatchQueue.main.async {
                        if let data = data {
                            userDetails.image = UIImage(data: data)
                        } else {
                            userDetails.image = nil
                        }
                        completion(userDetails)
                    }
                }
            }
    }
}
