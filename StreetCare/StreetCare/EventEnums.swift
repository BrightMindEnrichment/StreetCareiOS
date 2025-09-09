//
//  EventEnums.swift
//  StreetCare
//
//  Created by Kevin Phillips on 10/23/24.
//

import Foundation

enum EventType: Int {
    case future
    case past
    case helpinghands
    case helpRequest
    case all
}

enum FilterType: String, CaseIterable {
    case none = "Select.."
    case next7Days = "Next 7 Days"
    case next30Days = "Next 30 Days"
    case next60Days = "Next 60 Days"
    case next90Days = "Next 90 Days"
    case otherUpcoming = "Other Upcoming Events"
    case reset = "Reset"
    case last7Days = "Last 7 Days"  // For past events
    case last30Days = "Last 30 Days" // For past events
    case last60Days = "Last 60 Days" // For past events
    case last90Days = "Last 90 Days" // For past events
    case otherPast = "Other Past Events" // For past events
}
