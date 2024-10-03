//
//  CommunityEventView.swift
//  StreetCare
//
//  Created by SID on 6/14/24.
//

import Foundation
import SwiftUI
import FirebaseAuth

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

struct CommunityEventView: View {
    
    @State var user: User?
    @State var currentData =  EventData()
    let adapter = EventDataAdapter()
    @StateObject private var viewModel = SearchCommunityModel()
    @State private var isBottomSheetPresented = false
    @State private var selectedFilter: FilterType = .none

    let formatter = DateFormatter()
    var eventType : EventType
  
    var body: some View {
        
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .padding(.horizontal, 10)
                    .foregroundColor(.black)
                TextField("Search...", text: $viewModel.searchText).frame(height: 50.0)
            }.overlay(
                RoundedRectangle(cornerRadius: 15.0)
                    .stroke(Color.black, lineWidth: 1))
            .padding()
            
            // Filter Menu
            HStack {
                Spacer()
                Menu {
                    ForEach(FilterType.allCases, id: \.self) { filter in
                        Button(action: {
                            selectedFilter = filter
                            applyFilter(filterType: selectedFilter)
                        }) {
                            Text(filter.rawValue)
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                        Text("Filter")
                    }
                    .padding(.horizontal)
                    .foregroundColor(.black)
                }
                Spacer()
            }
            .padding(.bottom, 10)
            
            if viewModel.filteredData.isEmpty {
                Text(NSLocalizedString(eventType == .future ? "noFutureEventsAvailable" : eventType == .past ? "noPastEventsAvailable" : "noHelpingRequestsAvailable", comment: ""))
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextColor"))
            }
            
            if let _ = self.user {
                if viewModel.filteredData.isEmpty {
                    Spacer(minLength: 50.0)
                } else {
                    List {
                        ForEach(0..<viewModel.filteredData.count, id: \.self) { index in
                            if let date = viewModel.filteredData[index].keys.first,
                               let eventObj = viewModel.filteredData[index][date] {
                                Section(header: SectionHeaderView(date: date)) {
                                    ForEach(eventObj) { event in
                                        HStack {
                                            VStack {
                                                if let date = event.date.0 {
                                                    Text("\(date)")
                                                        .font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(Color("TextColor"))
                                                }
                                                if let date = event.date.1 {
                                                    Text("\(date)")
                                                        .font(.system(size: 12, weight: .regular))
                                                        .foregroundColor(Color("TextColor"))
                                                }
                                            }
                                            EventCardView(event: event, eventType: eventType) {
                                                currentData.date = event.date
                                                currentData.monthYear = event.monthYear
                                                currentData.event = event.event
                                                isBottomSheetPresented.toggle()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .listRowSeparatorTint(.clear, edges: .all)
                        .listSectionSeparatorTint(.clear, edges: .all)
                    }
                    .listStyle(PlainListStyle())
                    .navigationTitle(eventType == .future ? NSLocalizedString("futureEvents", comment: "") : eventType == .past ? NSLocalizedString("pastEvents", comment: "") : NSLocalizedString("helpRequests", comment: ""))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            } else {
                Image("CommunityOfThree").padding()
                Text("Log in to connect with your local community.")
            }
        }
        .bottomSheet(isPresented: $isBottomSheetPresented) {
            VStack {
                EventPopupView(event: currentData, eventType: eventType, delegate: self)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .onAppear {
            if let user = Auth.auth().currentUser {
                self.user = user
                adapter.delegate = self
                adapter.refresh()
            }
        }
        .onDisappear {
            isBottomSheetPresented = false
        }
    }
    
    // Method to apply the filter based on user selection
    private func applyFilter(filterType: FilterType) {
        viewModel.filterByDate(filterType: filterType)
    }
}

extension CommunityEventView: EventPopupViewDelegate {
    func close() {
        isBottomSheetPresented.toggle()
    }
}

extension CommunityEventView: EventDataAdapterProtocol {
    func helpRequestDataRefreshed(_ events: [HelpRequest]) {}
    
    func eventDataRefreshed(_ events: [Event]) {
        viewModel.events = events.filter { event in
            return event.eventDate != nil
        }
        viewModel.filterEvents(eventType: eventType)
    }
}

struct CommunityEventView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityEventView(eventType: .future)
    }
}

struct EventCardView: View {
    var event: EventData
    var eventType: EventType
    var onCardTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(event.event.title.capitalized)
                .font(.headline)
            
            HStack {
                Image(systemName: "mappin.and.ellipse")
                Text(event.event.location!)
                    .font(.system(size: 13))
            }
            
            HStack {
                Image(systemName: "clock")
                if let date = event.date.2 {
                    Text("\(date)")
                        .font(.system(size: 13))
                }
            }
            
            HStack {
                Image("HelpType").resizable().frame(width: 20.0, height: 20.0)
                Text(event.event.helpType!.capitalized).font(.system(size: 13))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color("Color87CEEB").opacity(0.4))
                    .cornerRadius(5)
            }
            
            HStack {
// TODO: hide participants and RSVP visibility until functionality complete
//                if let slots = event.event.totalSlots {
//                    let minimumInterest = Int(Double(slots) * 0.65)
//                    let interest = Int.random(in: minimumInterest...slots)
//
//                    Text("Participants: \(interest) / \(slots)")
//                        .font(.system(size: 13))
//                }
                Spacer()
                if eventType == .past {
                    Text("Completed").font(.system(size: 13))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
        .onTapGesture {
            onCardTap()
        }
    }
}

struct SectionHeaderView: View {
    var date: String

    var body: some View {
        Text(date)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(Color("TextColor"))
            .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 5.0, trailing: 0.0))
    }
}

class SearchCommunityModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var sectionsAndItems: [[String: [EventData]]] = [[String: [EventData]]]()
    @Published var tempSectionsAndItems: [[String: [EventData]]] = [[String: [EventData]]]()
    @Published var events = [Event]()

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
            var filteredEvents = events

            switch filterType {
            case .next7Days:
                filteredEvents = events.filter { event in
                    if let eventDate = event.eventDate {
                        return eventDate > Date() && calendar.isDate(eventDate, inRangeOfDays: 7)
                    }
                    return false
                }

            case .next30Days:
                filteredEvents = events.filter { event in
                    if let eventDate = event.eventDate {
                        return calendar.isDate(eventDate, inRangeOfDays: 30)
                    }
                    return false
                }
            case .next60Days:
                filteredEvents = events.filter { event in
                    if let eventDate = event.eventDate {
                        return calendar.isDate(eventDate, inRangeOfDays: 60)
                    }
                    return false
                }
            case .next90Days:
                filteredEvents = events.filter { event in
                    if let eventDate = event.eventDate {
                        return calendar.isDate(eventDate, inRangeOfDays: 90)
                    }
                    return false
                }
            case .otherUpcoming:
                filteredEvents = events.filter { event in
                    if let eventDate = event.eventDate {
                        return calendar.isDate(eventDate, after: Date().addingTimeInterval(90 * 24 * 60 * 60))
                    }
                    return false
                }
            case .reset:
                filteredEvents = events
            case .none:
                break
            }

            // Update filtered events
            filterEvents(eventType: .future) // Or based on the current event type
        }
        
        func filterEvents(eventType: EventType) {
            // Your existing filter logic by event type (future, past, etc.)
        }
}


// Helper extension to check date range
extension Calendar {
    func isDate(_ date: Date, inRangeOfDays days: Int) -> Bool {
        return date >= Date() && date <= Date().addingTimeInterval(TimeInterval(days * 24 * 60 * 60))
    }

    func isDate(_ date: Date, after dateToCompare: Date) -> Bool {
        return date > dateToCompare
    }
}
