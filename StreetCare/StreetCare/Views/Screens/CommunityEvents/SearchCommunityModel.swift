//
//  SearchCommunityModel.swift
//  StreetCare
//
//  Created by Kevin Phillips on 10/24/24.
//

import Foundation

class SearchCommunityModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var sectionsAndItems: [[String: [EventData]]] = [[String: [EventData]]]()
    @Published var tempSectionsAndItems: [[String: [EventData]]] = [[String: [EventData]]]()
    @Published var allEvents = [Event]() // This holds the original, unfiltered data
    @Published var filteredEvents = [Event]() // This will hold the filtered data

    var filteredData: [[String: [EventData]]] {
        if searchText.isEmpty {
            return tempSectionsAndItems
        } else {
            return self.sectionsAndItems.map { dict in
                dict.mapValues { events in
                    events.filter { $0.event.title.localizedCaseInsensitiveContains(searchText) }
                }.filter { !$0.value.isEmpty }
            }.filter { !$0.isEmpty }
        }
    }
    
    func filterByDate(filterType: FilterType) {
        let calendar = Calendar.current
        let now = Date()
        // Always start filtering from the original allEvents list
        filteredEvents = allEvents
        
        switch filterType {
        case .next7Days:
            filteredEvents = allEvents.filter { event in
                if let eventDate = event.eventDate {
                    return calendar.isDate(eventDate, inRangeOfDays: 7)
                }
                return false
            }

        case .next30Days:
            filteredEvents = allEvents.filter { event in
                if let eventDate = event.eventDate {
                    return calendar.isDate(eventDate, inRangeOfDays: 30)
                }
                return false
            }

        case .next60Days:
            filteredEvents = allEvents.filter { event in
                if let eventDate = event.eventDate {
                    return calendar.isDate(eventDate, inRangeOfDays: 60)
                }
                return false
            }

        case .next90Days:
            filteredEvents = allEvents.filter { event in
                if let eventDate = event.eventDate {
                    return calendar.isDate(eventDate, inRangeOfDays: 90)
                }
                return false
            }

        case .otherUpcoming:
            filteredEvents = allEvents.filter { event in
                if let eventDate = event.eventDate {
                    return eventDate > now.addingTimeInterval(90 * 24 * 60 * 60) // After 90 days from now
                }
                return false
            }

        case .reset:
            filteredEvents = allEvents // Reset to original, unfiltered data
        case .none:
            break
        }

            // Update filtered events
        filterEvents(eventType: .future, events: filteredEvents) // Or based on the current event type
        }
        
    func filterEvents(eventType: EventType, events: [Event]) {
            if events.isEmpty { return }
            if eventType == .future {
                filterAndSortEvents(eventType: .future, dateComparison: { $0 > $1 }, dayComparison: { $0 < $1 }, monthComparison: { $0 < $1 }, events: events)
            } else if eventType == .past {
                filterAndSortEvents(eventType: .past, dateComparison: { $0 < $1 }, dayComparison: { $0 > $1 }, monthComparison: { $0 > $1 }, events: events)
            }
        }
    private func filterAndSortEvents(eventType: EventType, dateComparison: @escaping (Date, Date) -> Bool, dayComparison: @escaping (Int, Int) -> Bool, monthComparison: @escaping (Date, Date) -> Bool, events: [Event]) {
            var result = [EventData]()
            
            let filteredArray = events.sorted { firstEvent, secondEvent in
                return dateComparison(firstEvent.eventDate!, secondEvent.eventDate!)
            }
            
            for each in filteredArray {
                if let dateValue = each.eventDate {
                    let dateObj = convertDateToEst(date: "\(dateValue)")
                    if dateComparison(dateObj, Date()) {
                        let data = EventData()
                        data.monthYear = formatDateString("\(dateObj)")
                        data.date.0 = formatDateString("\(dateObj)", format: "dd")
                        data.date.1 = formatDateString("\(dateObj)", format: "EEE").uppercased()
                        data.date.2 = formatDateString("\(dateObj)", format: "hh:mm a")
                        data.event = each
                        result.append(data)
                    }
                }
            }
            
            let groupedEvents = result.group(by: { $0.monthYear })
            let sortedEventsByMonth = groupedEvents.sorted { object1, object2 in
                return monthComparison(convertDate(from: object1.key)!, convertDate(from: object2.key)!)
            }
            let newEventsValuesSorted = sortedEventsByMonth.map { (key, events) -> (String, [EventData]) in
                        let sortedEvents = events.sorted { event1, event2 in
                            guard let day1 = event1.date.0, let day2 = event2.date.0,
                                  let day1Int = Int(day1), let day2Int = Int(day2) else { return false }
                            return dayComparison(day1Int, day2Int)
                        }
                        return (key, sortedEvents)
                    }
                    
                    sectionsAndItems.removeAll()
                    for (month, events) in newEventsValuesSorted {
                        sectionsAndItems.append(["\(month)": events])
                    }
                    tempSectionsAndItems = sectionsAndItems
                }}

// Helper extension to check date range
extension Calendar {
    func isDate(_ date: Date, inRangeOfDays days: Int) -> Bool {
        return date >= Date() && date <= Date().addingTimeInterval(TimeInterval(days * 24 * 60 * 60))
    }

    func isDate(_ date: Date, after dateToCompare: Date) -> Bool {
        return date > dateToCompare
    }
}
extension Array {
    // Group the array elements by a given key
    func group<Key: Hashable>(by key: (Element) -> Key) -> [Key: [Element]] {
        var groupedDict = [Key: [Element]]()
        for element in self {
            let keyValue = key(element)
            groupedDict[keyValue, default: []].append(element)
        }
        return groupedDict
    }
}
