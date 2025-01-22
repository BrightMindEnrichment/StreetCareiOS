//
//  EventListView.swift
//  StreetCare
//
//  Created by Marian John on 12/9/24.
//

import SwiftUI
import FirebaseAuth

struct EventListView: View, EventPopupViewDelegate, EventDataAdapterProtocol {
    @State var user: User?
    @State var currentData = EventData() // Initialize with empty EventData
    let adapter = EventDataAdapter()
    @StateObject private var viewModel = EventViewModel()
    @State private var isBottomSheetPresented = false

    var eventType: EventType = .future

    var body: some View {
        VStack {
            Text("Upcoming Events")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
                .padding(.horizontal)

            SearchBarView(searchText: $viewModel.searchText)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.groupedEvents.keys.sorted(), id: \.self) { month in
                        Text(month)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(Color.gray.opacity(0.1))

                        if let events = viewModel.groupedEvents[month] {
                            EventTimelineView(
                                events: events,
                                currentData: $currentData,
                                isBottomSheetPresented: $isBottomSheetPresented,
                                eventType: eventType
                            )
                        }
                    }
                }
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

    func close() {
        isBottomSheetPresented = false
    }

    func helpRequestDataRefreshed(_ events: [HelpRequest]) {}

    func eventDataRefreshed(_ events: [Event]) {
        let today = Calendar.current.startOfDay(for: Date())
        viewModel.events = events.compactMap { event in
            if let eventDate = event.eventDate, eventDate >= today {
                let eventData = EventData()
                eventData.event = event
                return eventData
            }
            return nil
        }
    }
}

struct EventTimelineView: View {
    let events: [EventData]
    @Binding var currentData: EventData
    @Binding var isBottomSheetPresented: Bool
    let eventType: EventType

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(events) { eventData in
                EventRowView(
                    eventData: eventData,
                   onCardTap: {
                        currentData.event = eventData.event
                        currentData.date = (
                            eventData.date.0 ?? eventData.event.eventDate?.formatted(.dateTime.year().month().day()),
                            eventData.date.1 ?? eventData.event.eventDate?.formatted(.dateTime.hour().minute()),
                            eventData.date.2 ??
                            eventData.event.eventDate?.formatted(.dateTime.year().month().day())
                        )
                        currentData.monthYear = eventData.monthYear

                        isBottomSheetPresented.toggle()
                    },
                    eventType: eventType
                )
            }
        }
        .padding(.horizontal)
    }
}
struct EventRowView: View {
    let eventData: EventData
    let onCardTap: () -> Void
    let eventType: EventType

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 8, height: 8)
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(eventData.event.title ?? "Unnamed Event")
                    .font(.headline)
                    .fontWeight(.bold)
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.gray)
                    Text(eventData.event.location ?? "No location")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                    Text(eventData.event.eventDate?.formatted(.dateTime.hour().minute()) ?? "No time")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                if let helpType = eventData.event.helpType {
                    Text(helpType)
                        .font(.caption)
                        .padding(5)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(5)
                }
            }
            .padding()
            .frame(width: 300)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            )
            .onTapGesture {
                onCardTap()
            }
        }
        .padding(.vertical, 5)
    }
}

struct SearchBarView: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            TextField("Search events", text: $searchText)
                .foregroundColor(.black)
                .frame(height: 40)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding(.horizontal)
    }
}
