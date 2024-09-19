//
//  CommunityEventView.swift
//  StreetCare
//
//  Created by SID on 6/14/24.
//

import Foundation
import SwiftUI
import FirebaseAuth

enum EventType: Int{
    case future
    case past
    case helpinghands
}
enum DateFilter: Int {
    case next7Days = 7
    case next30Days = 30
    case next60Days = 60
}

struct DateFilterPicker: View {
    @Binding var selectedFilter: DateFilter

    var body: some View {
        Picker("Select Filter", selection: $selectedFilter) {
            Text("Next 7 Days").tag(DateFilter.next7Days)
            Text("Next 30 Days").tag(DateFilter.next30Days)
            Text("Next 60 Days").tag(DateFilter.next60Days)
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct CommunityEventView: View {
    
    @State var user: User?
    @State var currentData = EventData()
    let adapter = EventDataAdapter()
    @StateObject private var viewModel = SearchCommunityModel()
    @State private var isBottomSheetPresented = false
    @State private var selectedFilter: DateFilter = .next7Days
    let formatter = DateFormatter()
    var eventType: EventType
  
    var body: some View {
        
        VStack {
            DateFilterPicker(selectedFilter: $selectedFilter)
                .padding()
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .padding(.horizontal, 10)
                    .foregroundColor(.black)
                
                TextField("Search...", text: $viewModel.searchText)
                    .frame(height: 50.0)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 15.0)
                    .stroke(Color.black, lineWidth: 1)
            )
            .padding()
            
            if viewModel.filteredData.isEmpty {
                Text(NSLocalizedString(eventType == .future ? "noFutureEventsAvailable" : eventType == .past ? "noPastEventsAvailable" : "noHelpingRequestsAvailable", comment: ""))
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextColor"))
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
            
            if user == nil {
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
        .onChange(of: selectedFilter) { newFilter in
            viewModel.filterEvents(eventType: eventType, filter: newFilter)
        }
        .onDisappear {
            isBottomSheetPresented = false
        }
    }
}

extension CommunityEventView: EventPopupViewDelegate {
    func close() {
        isBottomSheetPresented.toggle()
    }
}

extension CommunityEventView: EventDataAdapterProtocol {
    func helpRequestDataRefreshed(_ events: [HelpRequest]) {
        // Implement as needed
    }
    
    func eventDataRefreshed(_ events: [Event]) {
        viewModel.events = events.filter { $0.eventDate != nil }
        viewModel.filterEvents(eventType: eventType, filter: selectedFilter)
    }
}

extension Sequence where Element: Hashable {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        return Dictionary(grouping: self, by: key)
    }
}

struct EventCardView: View {
    var event: EventData
    var eventType : EventType
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
                if let date = event.date.2{
                    Text("\(date)")
                        .font(.system(size: 13))
                }
            }
            
            HStack {
                Image("HelpType").resizable().frame(width: 20.0,height: 20.0)
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
                if eventType == .past{
                    Text("Completed").font(.system(size: 13))
                }else{
//                    NavLinkButton(title: event.event.liked ? "Deregister" : "RSVP", width: event.event.liked ? 110.0 : 90.0).fontWeight(.semibold)
//                        .onTapGesture {
//                            onCardTap()
//                        }
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
            .foregroundColor(Color("TextColor")).padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 5.0, trailing: 0.0))
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
    
    func filterEvents(eventType: EventType, filter: DateFilter?) {
        if events.isEmpty { return }
        
        // Call the filtering function with the correct date range
        if eventType == .future {
            filterAndSortEvents(eventType: .future, dateComparison: { $0 > $1 }, dayComparison: { $0 < $1 }, monthComparison: { $0 < $1 }, filter: filter)
        } else if eventType == .past {
            filterAndSortEvents(eventType: .past, dateComparison: { $0 < $1 }, dayComparison: { $0 > $1 }, monthComparison: { $0 > $1 }, filter: filter)
        }
    }
    
    private func filterAndSortEvents(eventType: EventType, dateComparison: @escaping (Date, Date) -> Bool, dayComparison: @escaping (Int, Int) -> Bool, monthComparison: @escaping (Date, Date) -> Bool, filter: DateFilter?) {
        var result = [EventData]()
        
        // Get the current date and calculate the filter's end date
        let today = Date()
        var endDate: Date? = nil
        if let filter = filter {
            endDate = Calendar.current.date(byAdding: .day, value: filter.rawValue, to: today)
        }
        
        let filteredArray = self.events.sorted { firstEvent, secondEvent in
            return dateComparison(firstEvent.eventDate!, secondEvent.eventDate!)
        }
        
        for each in filteredArray {
            if let dateValue = each.eventDate {
                let dateObj = convertDateToEst(date: "\(dateValue)")
                // Check if the event falls within the selected filter range
                if dateComparison(dateObj, today), let endDate = endDate {
                    if dateObj <= endDate {
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
    }
}
