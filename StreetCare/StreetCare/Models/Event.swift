//
//  Event.swift
//  StreetCare
//
//  Created by Michael on 5/5/23.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class Event: Identifiable {

    var id = UUID() // test
    var eventId: String?
    var title: String = ""
    var description: String?
    var eventDate: Date?
    var location : String?
    var eventStartTime : Date?
    var eventEndTime : Date?
    var interest: Int?
    var liked = false
    var uid: String?
    var userType: String? 
    var createdAt : String?
    var helpRequest : Array<String>?
    var helpType : String?
    var participants : Array<String>?
    var skills : Array<String>?
    var approved : Bool?
    var totalSlots : Int?
    var street : String?
    var city : String?
    var state : String?
    var stateAbbv : String?
    var zipcode : String?
    var eventDateStamp : Timestamp?
    var eventStartTimeStamp : Timestamp?
    var eventEndTimeStamp : Timestamp?
    var isFlagged: Bool?
    //var isRegistered : Bool
}

class EventData : ObservableObject, Identifiable{
    var monthYear : String = ""
    var date : (String?, String?, String?) = ("","","")
    var event = Event()
    
    let flagStatus = FlagStatus() // ✅ Minimal, lightweight reactivity
}
class FlagStatus: ObservableObject {
    @Published var isFlagged: Bool = false
}

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
    var skills : Array<String>?
}
