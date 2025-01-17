//
//  EventsController.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/5/22.
//

import Foundation
import FirebaseAuth


protocol EventsControllerProtocol {
    func eventDataRefreshed()
}



class EventsController {
    
    var events = [Event]()
    
    var adapter = EventDataAdapter()
    var delegate: EventsControllerProtocol?

    
    init() {
        adapter.delegate = self
    }
    
    
    
    var count: Int {
        return events.count
    }
    
    
    
    func eventForIndex(_ index: Int) -> Event? {
        
        if events.isValidIndex(index) {
            return events[index]
        }
        else {
            return nil
        }
    }
    
    
    func canEditEventAtIndex(_ index: Int) -> Bool {
        
        guard let user = Auth.auth().currentUser else { return false }
        
        if events.isValidIndex(index) {
            return events[index].uid == user.uid
        }
        else {
            return false
        }
    }
    
    
    func refresh() {
        adapter.refresh()
    }
    

    
    func addEvent(title: String, description: String, date: Date) {
        adapter.addEvent(title: title, description: description, date: date)
    }
    
    
    
    func likeEventForIndex(_ index: Int) {
        
        if events.isValidIndex(index) {
            if let eventId = events[index].eventId {
                adapter.setLikeEvent(eventId, setTo: !events[index].liked)
            }
        }
    }
    
    
    
    func addErrorEvent() {
        self.events.removeAll()
        
        let event = Event()
        event.title = "Log in"
        event.description = "Events are only available to logged in users."
        event.date = Date()
        self.events.append(event)
    }

} // end class



extension EventsController: EventDataAdapterProtocol {
    
    func eventDataRefreshed(_ events: [Event]) {
        
        self.events = events
        delegate?.eventDataRefreshed()
    }
    
} // end extension
