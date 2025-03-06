//
//  CommunityEventView.swift
//  StreetCare
//
//  Created by SID on 6/14/24.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct CommunityEventView: View {
    
    @State var user: User?
    @State var currentData = EventData()
    let adapter = EventDataAdapter()
    @StateObject private var viewModel = SearchCommunityModel()
    @State private var isBottomSheetPresented = false
    @State private var selectedFilter: FilterType = .none
    @Binding var isPresented: Bool // Binding to control dismissal of this view
    @State private var shouldDismissAll = false // Shared variable for dismissing all views
    @State private var isNavigationActive = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let formatter = DateFormatter()
    var eventType: EventType
    
    var body: some View {
        VStack {
            // Search and Filter UI
            HStack {
                Image(systemName: "magnifyingglass")
                    .padding(.horizontal, 10)
                    .foregroundColor(.black)
                TextField(NSLocalizedString("searchPlaceholder", comment: "Search bar placeholder"), text: $viewModel.searchText)
                    .frame(height: 50.0)
                Menu {
                    // Dynamically show filters based on eventType
                    ForEach(availableFilterOptions(), id: \.self) { filter in
                        Button(action: {
                            selectedFilter = filter
                            applyFilter(filterType: selectedFilter)
                        }) {
                            HStack {
                                Text(filter.rawValue)
                                Spacer()
                                if selectedFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "line.horizontal.3.decrease.circle")
                                .foregroundColor(.black)
                            if selectedFilter != .none {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 10, y: -5)
                            }
                        }
                        Text("Filter")
                    }
                    .padding(.horizontal, 10)
                    .foregroundColor(.black)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 15.0)
                    .stroke(Color.black, lineWidth: 1)
            )
            .padding()
            LegendView()
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
                                Section(header: SectionHeaderView(date: date, eventCount: eventObj.count)) {
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isNavigationActive = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(Color("SecondaryColor"))
                }
            }
        }
        .sheet(isPresented: $isNavigationActive, onDismiss: {
            isNavigationActive = false
        }) {
            NavigationStack {
                OutreachFormView(isPresented: $isPresented, shouldDismissAll: $shouldDismissAll)
            }
        }
        .onDisappear {
            isBottomSheetPresented = false
            selectedFilter = .none
        }
        .onChange(of: shouldDismissAll) { newValue in
            if newValue {
                // Close all forms and reset state
                isPresented = false
                shouldDismissAll = false // Reset for future interactions
            }
        }
    }
    
    private func applyFilter(filterType: FilterType) {
        selectedFilter = filterType
        // Apply the filter based on event type (future or past)
        viewModel.filterByDate(filterType: selectedFilter, eventType: eventType)  // Make sure `eventType` is passed here
        viewModel.objectWillChange.send()
    }

    // Method to return filter options dynamically based on eventType
    private func availableFilterOptions() -> [FilterType] {
        if eventType == .past {
            return [.last7Days, .last30Days, .last60Days, .last90Days, .otherPast, .reset]
        } else if eventType == .future {
            return [.next7Days, .next30Days, .next60Days, .next90Days, .otherUpcoming, .reset]
        } else {
            return []  // If eventType is "helping hands" or something else, we could define another filter set
        }
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
        viewModel.allEvents = events.filter { event in
            return event.eventDate != nil
        }
        viewModel.filterEvents(eventType: eventType, events: events)
    }
}

/*struct CommunityEventView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityEventView(eventType: .future)
    }
}*/

struct SectionHeaderView: View {
    var date: String
    var eventCount: Int

    var body: some View {
        HStack {
            Text(date)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(Color("TextColor"))
            Spacer()
            Text("(\(eventCount) events)")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(Color("TextColor"))
        }
        .padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 5.0, trailing: 0.0))
    }
}


struct LegendView: View {
    var body: some View {
        HStack(spacing: 12) {
            LegendItem(icon: "checkmark.circle.fill", color: .green, text: "Chapter Leader")
            LegendItem(icon: "checkmark.circle.fill", color: Color.blue.opacity(0.7), text: "Street Care Hub Leader")
            LegendItem(icon: "checkmark.circle.fill", color: .purple, text: "Chapter Member")
            LegendItem(icon: "checkmark.circle.fill", color: .yellow, text: "Account Holder")
        }
        .padding(8)
        .cornerRadius(8)
        .padding(.horizontal)
        .lineLimit(3)
    }
}

struct LegendItem: View {
    var icon: String
    var color: Color
    var text: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .background(Circle().fill(Color.white).frame(width: 18, height: 18))
                .frame(width: 20, height: 20)
            Text(text)
                .font(.system(size: 12))
                .foregroundColor(.black)
        }
    }
}
