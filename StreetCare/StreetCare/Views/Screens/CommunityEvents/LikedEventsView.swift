//
//  LikedEventsView.swift
//  StreetCare
//
//  Created by Gayathri Jayachander on 8/25/25.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct LikedEventView: View {
    
    @State var user: User?
    @State var currentData = EventData()
    let adapter = EventDataAdapter()
    @StateObject private var viewModel = SearchCommunityModel()
    @State private var isBottomSheetPresented = false
    @State private var selectedFilter: FilterType = .none
    @State private var showLoginMessage = false
    @Binding var isPresented: Bool
    @State private var shouldDismissAll = false
    @State private var isNavigationActive = false
    @State private var popupRefresh = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var loggedInUserDetails: UserDetails
    
    let formatter = DateFormatter()
    var eventType: EventType
    
    var noEventsText: String {
        if eventType == .future {
            return NSLocalizedString("noFutureEventsAvailable", comment: "")
        } else if eventType == .past {
            return NSLocalizedString("noPastEventsAvailable", comment: "")
        } else {
            return NSLocalizedString("noHelpingRequestsAvailable", comment: "")
        }
    }
    
    var body: some View {
        VStack {
            // 🔹 Search + Filter UI (copied from CommunityEventView)
            HStack {
                Image(systemName: "magnifyingglass")
                    .padding(.horizontal, 10)
                    .foregroundColor(.black)
                TextField(NSLocalizedString("searchPlaceholder", comment: ""), text: $viewModel.searchText)
                    .frame(height: 50.0)
                Menu {
                    ForEach(availableFilterOptions(), id: \.self) { filter in
                        Button(action: {
                            selectedFilter = filter
                            applyFilter(filterType: selectedFilter)
                        }) {
                            HStack {
                                Text(NSLocalizedString(filter.rawValue, comment: ""))
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
                            if selectedFilter != .none && selectedFilter != .reset {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 8, height: 8)
                                    .offset(x: 10, y: -5)
                            }
                        }
                        Text(NSLocalizedString("filter", comment: ""))
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
            
            LegendView() // ✅ Same legend bar as in CommunityEventView
            
            // 🔹 No events text
            if viewModel.filteredData.isEmpty {
                Text(NSLocalizedString("noLikedEventsAvailable", comment: ""))
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextColor"))
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
                                        EventCardView(
                                            event: event,
                                            eventType: eventType,
                                            onCardTap: {
                                                currentData.date = event.date
                                                currentData.monthYear = event.monthYear
                                                currentData.event = event.event
                                                isBottomSheetPresented.toggle()
                                            },
                                            popupRefresh: $popupRefresh,
                                            loggedInUser: loggedInUserDetails
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .listRowSeparatorTint(.clear, edges: .all)
                    .listSectionSeparatorTint(.clear, edges: .all)
                }
                .listStyle(PlainListStyle())
                .navigationTitle(NSLocalizedString("likedEvents", comment: ""))
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
        }
        .bottomSheet(isPresented: $isBottomSheetPresented) {
            VStack {
                EventPopupView(event: currentData, eventType: eventType, delegate: self, refresh: $popupRefresh)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .onAppear {
            adapter.delegate = self
            adapter.refreshLikedEvents()
            Auth.auth().addStateDidChangeListener { auth, currentUser in
                self.user = currentUser
                print("User updated: \(String(describing: self.user?.uid))")
            }
        }
        .onDisappear {
            isBottomSheetPresented = false
            selectedFilter = .none
        }
        .onChange(of: shouldDismissAll) { newValue in
            if newValue {
                isPresented = false
                shouldDismissAll = false
            }
        }
    }
    
    // 🔹 Same filter logic from CommunityEventView
    private func applyFilter(filterType: FilterType) {
        selectedFilter = filterType
        viewModel.filterByDate(filterType: selectedFilter, eventType: eventType)
        viewModel.objectWillChange.send()
    }
    
    private func availableFilterOptions() -> [FilterType] {
        if eventType == .past {
            return [.last7Days, .last30Days, .last60Days, .last90Days, .otherPast, .reset]
        } else if eventType == .future {
            return [.next7Days, .next30Days, .next60Days, .next90Days, .otherUpcoming, .reset]
        } else {
            return []
        }
    }
}


extension LikedEventView: EventPopupViewDelegate {
    func close() {
        isBottomSheetPresented.toggle()
    }
}

extension LikedEventView: EventDataAdapterProtocol {
    func helpRequestDataRefreshed(_ events: [HelpRequest]) {}
    
    func eventDataRefreshed(_ events: [Event]) {
        viewModel.allEvents = events.filter { event in
            return event.eventDate != nil
        }
        viewModel.filterEvents(eventType: eventType, events: events)
    }
}

