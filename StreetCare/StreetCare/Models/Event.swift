//
//  Event.swift
//  StreetCare
//
//  Created by Michael on 5/5/23.
//  Updated to make Event observable.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

// MARK: - Event Model
class Event: ObservableObject, Identifiable {
    var id = UUID() // test
    
    var eventId: String?
    var title: String = ""
    
    var description: String?
    var eventDate: Date?
    var location: String?
    var eventStartTime: Date?
    var eventEndTime: Date?
    
    // observable properties
    @Published var interest: Int?
    @Published var liked: Bool = false
    
    var uid: String?
    var userType: String?
    var createdAt: String?
    
    var helpRequest: [String]?
    var helpType: String?
    var participants: [String]?
    var skills: [String]?
    var approved: Bool?
    var totalSlots: Int?
    
    var street: String?
    var city: String?
    var state: String?
    var stateAbbv: String?
    var zipcode: String?
    
    var eventDateStamp: Timestamp?
    var eventStartTimeStamp: Timestamp?
    var eventEndTimeStamp: Timestamp?
    
    var timeZone: String?
    @Published var isFlagged: Bool = false
    @Published var flaggedByUser: String? = ""
    
    var emailAddress: String?
    var contactNumber: String?
    var consentStatus: Bool = false
    
    // MARK: - Methods
    func updateFlagStatus(newFlagState: Bool, userId: String?) {
        isFlagged = newFlagState
        flaggedByUser = newFlagState ? userId : nil
    }
}

// MARK: - Event Data Wrapper
class EventData: ObservableObject, Identifiable {
    @Published var monthYear: String = ""
    @Published var date: (String?, String?, String?) = ("", "", "")
    @Published var event: Event = Event()
    
    private var cancellable: AnyCancellable?
    
    init() {
        subscribeToEvent()
    }
    
    // Subscribe to nested event's changes and forward them so views observing EventData will update
    func subscribeToEvent() {
        cancellable = event.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }
    
    // Helper to replace the event instance and re-subscribe (if you ever assign a new Event)
    func setEvent(_ newEvent: Event) {
        cancellable?.cancel()
        event = newEvent
        subscribeToEvent()
    }
}

// MARK: - Help Request Model
class HelpRequest {
    var id: String?
    var description: String?
    var identification: String?
    var status: String?
    
    var street: String?
    var city: String?
    var state: String?
    var zipcode: String?
    var location: String?
    
    var title: String?
    var uid: String?
    var userType: String?
    var createdAt: String?
    
    var skills: [String]?
}
