//
//  EventEnums.swift
//  StreetCare
//
//  Created by Marian John on 10/14/24.
//

import Foundation

enum EventType: Int {
    case future
    case past
    case helpinghands
}

enum FilterType: String, CaseIterable {
    case none = "Select.."
    case next7Days = "Next 7 Days"
    case next30Days = "Next 30 Days"
    case next60Days = "Next 60 Days"
    case next90Days = "Next 90 Days"
    case otherUpcoming = "Other Upcoming Events"
    case reset = "Reset"
}
