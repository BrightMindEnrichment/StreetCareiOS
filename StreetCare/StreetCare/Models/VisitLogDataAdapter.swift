// // VisitLogEntry.swift
// StreetCare //
// Created by Saheer on 1/15/26. //

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
    func visitLogDataRefreshedInteractionDev(_ logs: [VisitLog])
}
extension VisitLogDataAdapterProtocol {
    func visitLogDataRefreshedInteractionDev(_ logs: [VisitLog]) { }
}
class VisitLogDataAdapter: ObservableObject{

    private let collectionName = "InteractionLogDev"

    @Published var visitLogs = [VisitLog]()
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
        primaryRef.getDocument { docSnapshot, _ in
            if let doc = docSnapshot, doc.exists {
                primaryRef.updateData([field: value]) { error in
                    if let error = error {
                        print("Error updating \(field) in VisitLogBook: \(error.localizedDescription)")
                    } else {
                        print("\(field) updated successfully in VisitLogBook.")
                        completion()
                    }
                }
            } else {
                // Try the fallback collection
                fallbackRef.getDocument { fallbackDocSnapshot, _ in
                    if let fallbackDoc = fallbackDocSnapshot, fallbackDoc.exists {
                        fallbackRef.updateData([field: value]) { error in
                            if let error = error {
                                print("Error updating \(field) in VisitLogBook_New: \(error.localizedDescription)")
                            } else {
                                print("\(field) updated successfully in VisitLogBook_New.")
                                completion()
                            }
                        }
                    } else {
                        print("Document \(logId) not found in either collection.")
                    }
                }
            }
        }
    }

    func updateVisitLogFields(_ logId: String, fields: [String: Any], completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        db.collection("VisitLogBook_New").document(logId).updateData(fields) { error in
            if let error = error {
                print("Error updating fields: \(error.localizedDescription)")
            } else {
                print("All fields updated successfully.")
                completion()
            }
        }
    }

    // Create HelpRequest document for this InteractionLog
    private func createHelpRequest(for log: VisitLog, interaction: IndividualInteractionItem) {
        let db = Firestore.firestore()

        let docRef = db.collection("HelpRequestDev").document()
        let helpReqId = docRef.documentID
        var helpRequestData: [String: Any] = [
            "interactionLogDocId": log.id,
            "firstName": interaction.firstName,

            "locationLandmark": log.concatenatedLandmark,
            "timestampOfInteraction": Timestamp(date: log.whenVisit),
            "helpProvidedCategory": interaction.helpProvidedCategory,
            "furtherHelpCategory": interaction.furtherHelpCategory,
            "additionalDetails": interaction.additionalDetails
        ]

        if interaction.followUpTimestamp != placeholderDate {
            helpRequestData["followUpTimestamp"] = Timestamp(date: interaction.followUpTimestamp)
        }

        docRef.setData(helpRequestData) { error in
            if let error = error {
                print("Error creating HelpRequestDev:", error.localizedDescription)
                return
            }

            db.collection("InteractionLogDev")
                .document(log.id)
                .updateData([
                    "helpRequestDocIds": FieldValue.arrayUnion([helpReqId])
                ]) { err in
                    if let err = err {
                        print("❌ Failed to link HelpRequest → InteractionLog:", err.localizedDescription)
                    } else {
                        print("✅ Linked HelpRequest \(helpReqId) → InteractionLog \(log.id)")
                    }
                }
        }
    }
    func addVisitLog(_ visitLog: VisitLog, interactions: [IndividualInteractionItem]) {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user")
            return
        }

        let db = Firestore.firestore()
        let collectionName = "InteractionLogDev"

        var data: [String: Any] = [:]

        // Identity / User (dummy-safe)
        data["userId"] = user.uid
        data["firstName"] = visitLog.firstname.isEmpty ? "Unknown" : visitLog.firstname
        data["lastName"] = visitLog.lastname.isEmpty ? "Unknown" : visitLog.lastname
        data["email"] = visitLog.contactemail.isEmpty ? "unknown@email.com" : visitLog.contactemail
        data["phoneNumber"] = visitLog.contactphone.isEmpty ? "" : visitLog.contactphone

        // Dates & Times
        data["interactionDate"] = Timestamp(date: visitLog.whenVisit)
        data["startTimestamp"] = Timestamp(date: visitLog.whenVisit)

        if visitLog.whenVisitEnd.timeIntervalSince1970 > 0 {
            data["endTimestamp"] = Timestamp(date: visitLog.whenVisitEnd)
        } else {
            data["endTimestamp"] = Timestamp(date: visitLog.whenVisit)
        }

        data["lastModifiedTimestamp"] = Timestamp(date: Date())

        // Address
        let addr1Value = !visitLog.street.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? visitLog.street
            : (!visitLog.whereVisit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? visitLog.whereVisit
                : "N/A")

        data["addr1"] = addr1Value
        data["addr2"] = ""
        data["city"] = visitLog.city.isEmpty ? "N/A" : visitLog.city
        data["state"] = visitLog.state.isEmpty ? "N/A" : visitLog.state
        data["zipcode"] = visitLog.zipcode.isEmpty ? "00000" : visitLog.zipcode
        data["country"] = "USA"

        // Counts / Required numbers
        data["numPeopleHelped"] = visitLog.numPeopleHelped
        data["numPeopleJoined"] = visitLog.numPeopleJoined
        data["carePackageContents"] = visitLog.carePackageContents
        data["carePackagesDistributed"] = visitLog.carePackagesDistributed

        // Required backend flags
        data["helpRequestCount"] = 0
        data["status"] = "Pending"
        data["isPublic"] = visitLog.isPublic
        data["listOfSupportsProvided"] = visitLog.listOfSupportsProvided

        // Link field that your rules allow
        data["helpRequestDocIds"] = visitLog.helpRequestDocIds

        // Debug: confirm payload matches allowlist
        print("Writing InteractionLogDev with keys:")
        print(data.keys.sorted())

        db.collection(collectionName)
            .document(visitLog.id)
            .setData(data) { [weak self] error in
                if let error = error {
                    print("InteractionLogDev write failed:", error.localizedDescription)
                    return
                }

                print("InteractionLogDev write success:", visitLog.id)
                if interactions.isEmpty {
                    print("No individual interactions to create HelpRequestDev docs for.")
                    return
                }

                print("Creating \(interactions.count) HelpRequestDev docs for InteractionLog:", visitLog.id)

                for item in interactions {
                    self?.createHelpRequest(for: visitLog, interaction: item)
                }
            }
    }

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

        db.collection("VisitLogBook").document(logId).delete { _ in completion() }
        db.collection("visitLogWebProd").document(logId).delete { _ in completion() }
        db.collection("VisitLogBook_New").document(logId).delete { _ in completion() }
    }

    func refresh_new() {
        print("refresh_new called")
        guard let user = Auth.auth().currentUser else {
            self.visitLogs = [VisitLog]()
            self.delegate?.visitLogDataRefreshed(self.visitLogs)
            return
        }

        let db = Firestore.firestore()
        db.collection("VisitLogBook_New").whereField("uid", isEqualTo: user.uid).getDocuments { querySnapshot, error in
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

                    if let timestamp = document["followUpWhenVisit"] as? Timestamp {
                        log.followUpWhenVisit = timestamp.dateValue()
                    } else {
                        log.followUpWhenVisit = placeholderDate
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
                    print("Loaded log from VisitLogBook_New with id:", log.id)

                    self.visitLogs.append(log)
                }
            }

            if let snapshot = querySnapshot {
                print("Document count: \(snapshot.documents.count)")
                for doc in snapshot.documents {
                    print("Doc ID: \(doc.documentID), Data: \(doc.data())")
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
    func refreshInteractionLogDev() {
        print("refreshInteractionLogDev called")

        guard let user = Auth.auth().currentUser else {
            DispatchQueue.main.async {
                self.visitLogs = []
                self.delegate?.visitLogDataRefreshedInteractionDev([])
            }
            return
        }

        let db = Firestore.firestore()
        db.collection("InteractionLogDev")
            .whereField("userId", isEqualTo: user.uid)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching InteractionLogDev:", error.localizedDescription)
                    DispatchQueue.main.async {
                        self.delegate?.visitLogDataRefreshedInteractionDev([])
                    }
                    return
                }
                var logs: [VisitLog] = []

                for doc in snapshot?.documents ?? [] {
                    let data = doc.data()
                    let log = VisitLog(id: doc.documentID)
                    log.source = "interactionLogDev"

                    log.firstname = data["firstName"] as? String ?? ""
                    log.lastname  = data["lastName"] as? String ?? ""
                    log.contactemail = data["email"] as? String ?? ""
                    log.contactphone = data["phoneNumber"] as? String ?? ""
                    let addr1 = data["addr1"] as? String ?? ""
                    let city  = data["city"] as? String ?? ""
                    let state = data["state"] as? String ?? ""
                    let zip   = data["zipcode"] as? String ?? ""

                    log.whereVisit = [addr1, city, state, zip]
                        .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                        .joined(separator: ", ")

                    if let ts = data["startTimestamp"] as? Timestamp {
                        log.whenVisit = ts.dateValue()
                    }

                    //log.numPeopleHelped = data["numPeopleHelped"] as? Int ?? 0
                    
                    log.peopleHelped = data["numPeopleHelped"] as? Int ?? 0
                    log.numPeopleJoined = data["numPeopleJoined"] as? Int ?? 0
                    log.carePackagesDistributed = data["carePackagesDistributed"] as? Int ?? 0
                    log.carePackageContents = data["carePackageContents"] as? String ?? ""
                    log.listOfSupportsProvided = data["listOfSupportsProvided"] as? [String] ?? []
                    log.status = data["status"] as? String ?? ""
                    log.isPublic = data["isPublic"] as? Bool ?? false
                    log.helpRequestDocIds = data["helpRequestDocIds"] as? [String] ?? []
                    logs.append(log)
                }
                logs.sort { $0.whenVisit > $1.whenVisit }

                DispatchQueue.main.async {
                    self.delegate?.visitLogDataRefreshedInteractionDev(logs)
                    print("InteractionLogDev loaded count:", logs.count)
                }
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

            db.collection("visitLogWebProd").whereField("uid", isEqualTo: user.uid).getDocuments { querySnapshot, error in
                if let error = error {
                    print("Error fetching WebProd logs: \(error.localizedDescription)")
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
