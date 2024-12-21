//
//  EventListView.swift
//  StreetCare
//
//  Created by Marian John on 12/9/24.
//



/*import SwiftUI
import FirebaseAuth

struct EventListView: View {
    @State var user: User?
    @State var currentData = EventData()
    let adapter = EventDataAdapter()
    @StateObject private var viewModel = EventViewModel()
    @State private var isBottomSheetPresented = false

    var eventType: EventType = .future // Adjust based on your requirements

    var body: some View {
        VStack {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .padding(.horizontal, 10)
                    .foregroundColor(.black)
                TextField("Search events", text: $viewModel.searchText)
                    .frame(height: 50.0)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 15.0)
                    .stroke(Color.black, lineWidth: 1)
            )
            .padding()

            // Display grouped events
            if viewModel.groupedEvents.isEmpty {
                Text("No events available.")
                    .fontWeight(.bold)
                    .foregroundColor(Color("TextColor"))
            } else {
                List {
                    ForEach(viewModel.groupedEvents.keys.sorted(), id: \.self) { month in
                        if let events = viewModel.groupedEvents[month] {
                            Section(header: SectionHeaderView(date: month, eventCount: events.count)) {
                                ForEach(events) { eventData in
                                    HStack {
                                        VStack {
                                            if let date = eventData.event.eventDate {
                                                Text(date, style: .date)
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(Color("TextColor"))
                                            }
                                        }
                                        EventCardView(event: eventData, eventType: eventType) {
                                            currentData = eventData
                                            isBottomSheetPresented.toggle()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
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
}

// MARK: - Extensions and Delegate Conformance

extension EventListView: EventPopupViewDelegate {
    func close() {
        isBottomSheetPresented.toggle()
    }
}

extension EventListView: EventDataAdapterProtocol {
    func helpRequestDataRefreshed(_ events: [HelpRequest]) {
        // Handle help request refresh
    }

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
}*/

/*import SwiftUI
import FirebaseAuth

struct EventListView: View {
    @State var user: User?
    @State var currentData = EventData()
    let adapter = EventDataAdapter()
    @StateObject private var viewModel = EventViewModel()
    @State private var isBottomSheetPresented = false

    var eventType: EventType = .future

    var body: some View {
        VStack {
            // Search Bar
            SearchBarView(searchText: $viewModel.searchText)

            // Timeline and Events
            ScrollView {
                EventTimelineView(
                    groupedEvents: viewModel.groupedEvents,
                    currentData: $currentData,
                    isBottomSheetPresented: $isBottomSheetPresented,
                    eventType: eventType
                )
            }
        }
        .bottomSheet(isPresented: $isBottomSheetPresented) {
            EventPopupView(event: currentData, eventType: eventType, delegate: self)
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
}
// MARK: - Section Header View
struct SectionHeaderView1: View {
    let month: String

    var body: some View {
        Text(month)
            .font(.headline)
            .padding(.vertical, 5)
            .padding(.horizontal)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(5)
    }
}

// MARK: - Search Bar Component
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
        .padding()
    }
}

// MARK: - Event Timeline Component
struct EventTimelineView: View {
    let groupedEvents: [String: [EventData]]
    @Binding var currentData: EventData
    @Binding var isBottomSheetPresented: Bool
    let eventType: EventType

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(groupedEvents.keys.sorted(), id: \.self) { month in
                VStack(alignment: .leading, spacing: 10) {
                    // Month Header
                    SectionHeaderView1(month: month)

                    if let events = groupedEvents[month] {
                        ForEach(events) { eventData in
                            EventRowView(
                                eventData: eventData,
                                onCardTap: {
                                    currentData = eventData
                                    isBottomSheetPresented.toggle()
                                },
                                eventType: eventType
                            )
                        }
                    }
                }
            }
        }
    }
}



// MARK: - Event Row View
struct EventRowView: View {
    let eventData: EventData
    let onCardTap: () -> Void
    let eventType: EventType

    var body: some View {
        HStack(alignment: .top) {
            // Timeline Dot
            VStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 8, height: 8)
                    .padding(.top, 5)
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 2)
                    .padding(.bottom, 5)
            }

            // Event Card
            VStack(alignment: .leading, spacing: 5) {
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
                Text(eventData.event.helpType ?? "General")
                    .font(.caption)
                    .padding(5)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(5)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            )
            .onTapGesture {
                onCardTap()
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Extensions and Delegate Conformance
extension EventListView: EventPopupViewDelegate {
    func close() {
        isBottomSheetPresented.toggle()
    }
}

extension EventListView: EventDataAdapterProtocol {
    func helpRequestDataRefreshed(_ events: [HelpRequest]) {
        // Handle help request refresh
    }

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
}*/
/*import SwiftUI
import FirebaseAuth

struct EventListView: View, EventPopupViewDelegate, EventDataAdapterProtocol {
    @State var user: User?
    @State var currentData = EventData()
    let adapter = EventDataAdapter()
    @StateObject private var viewModel = EventViewModel()
    @State private var isBottomSheetPresented = false

    var eventType: EventType = .future

    var body: some View {
        VStack {
            // Title
            Text("Upcoming Events")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
                .padding(.horizontal)

            // Search Bar
            SearchBarView(searchText: $viewModel.searchText)

            // Timeline and Events
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.groupedEvents.keys.sorted(), id: \.self) { month in
                        // Month Header
                        Text(month)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(Color.gray.opacity(0.1))

                        // Events
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

    // MARK: - EventPopupViewDelegate Methods
    func close() {
        isBottomSheetPresented = false
    }

    // MARK: - EventDataAdapterProtocol Methods
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

// MARK: - Search Bar Component
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

// MARK: - Event Timeline Component
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
                        currentData = eventData
                        isBottomSheetPresented.toggle()
                    },
                    eventType: eventType
                )
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Event Row View
struct EventRowView: View {
    let eventData: EventData
    let onCardTap: () -> Void
    let eventType: EventType

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline Dot and Line
            VStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 8, height: 8)
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }

            // Event Card
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
            .frame(width: 300) // Ensures uniform card width
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
}*/
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
            // Title
            Text("Upcoming Events")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
                .padding(.horizontal)

            // Search Bar
            SearchBarView(searchText: $viewModel.searchText)

            // Timeline and Events
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.groupedEvents.keys.sorted(), id: \.self) { month in
                        // Month Header
                        Text(month)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .background(Color.gray.opacity(0.1))

                        // Events
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

    // MARK: - EventPopupViewDelegate Methods
    func close() {
        isBottomSheetPresented = false
    }

    // MARK: - EventDataAdapterProtocol Methods
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
                                eventData.event.eventDate?.formatted(.dateTime.hour().minute())
                        )
                        currentData.monthYear = eventData.monthYear ?? "Unknown Month/Year"

                        isBottomSheetPresented.toggle()
                    },
                    eventType: eventType
                )
            }
        }
        .padding(.horizontal)
    }
}
// MARK: - Event Row View
struct EventRowView: View {
    let eventData: EventData
    let onCardTap: () -> Void
    let eventType: EventType

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline Dot and Line
            VStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 8, height: 8)
                Rectangle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }

            // Event Card
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
            .frame(width: 300) // Ensures uniform card width
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

// MARK: - Search Bar Component
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
