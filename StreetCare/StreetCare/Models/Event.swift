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
    //var isRegistered : Bool
    var isFlagged : Bool = false
    var flaggedByUser:String? = ""
    
    var emailAddress: String?
    var contactNumber: String?
    var consentStatus: Bool = false

    
    func updateFlagStatus(newFlagState: Bool, userId: String?) {
        isFlagged = newFlagState
        flaggedByUser = newFlagState ? userId : nil
    }
}

class EventData : ObservableObject, Identifiable{
    @Published var monthYear : String = ""
    @Published var date : (String?, String?, String?) = ("","","")
    @Published var event =  Event()
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
