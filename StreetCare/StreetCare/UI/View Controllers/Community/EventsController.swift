//
//  EventsController.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/5/22.
//

import Foundation


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
    
} // end class



extension EventsController: EventDataAdapterProtocol {
    
    func eventDataRefreshed(_ events: [Event]) {
        
        self.events = events
        delegate?.eventDataRefreshed()
    }
    
} // end extension
