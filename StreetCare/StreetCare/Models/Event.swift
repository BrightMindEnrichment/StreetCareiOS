//
//  Event.swift
//  StreetCare
//
//  Created by Michael on 5/5/23.
//

import Foundation


class Event: Identifiable {

    var id = UUID()
    
    var eventId: String?
    
    var title: String?
    var description: String?
    var date: Date?
    var interest: Int?
    var liked = false
    var uid: String?
    var location : String?
}


class EventData : Identifiable{
    var monthYear : String?
    var date : String?
    var event : Event?
}
