//
//  UpcomingEventsView.swift
//  StreetCare
//
//  Created by SID on 12/3/24.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct UpcomingEventsView: View {
    @State var user: User?
    @StateObject private var viewModel = UpcomingEventsViewModel()
    @State private var selectedFilter: FilterType = .none

    var body: some View {
        VStack {
            // Header with Filters
            HStack {
                Text("Upcoming Events")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.leading, 10)
                Spacer()
            }
            .padding(.top, 20)
            .padding(.horizontal)
            
            HStack {
                TextField("Search events", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 10)
                
                Menu {
                    // Filter options for upcoming events
                    ForEach(viewModel.filterOptions, id: \.self) { filter in
                        Button(action: {
                            selectedFilter = filter
                            viewModel.applyFilter(filter)
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
                        Image(systemName: "line.horizontal.3.decrease.circle")
                        Text("Filter")
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 10)
            
            if viewModel.filteredEvents.isEmpty {
                Text("No upcoming events available.")
                    .fontWeight(.bold)
                    .padding(.top, 50)
            } else {
                List(viewModel.filteredEvents) { event in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.otherField) // Replace with event-specific details
                            .font(.headline)
                        Text("Date: \(event.eventDate.dateValue().formatted())")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                }
                .listStyle(PlainListStyle())
            }
        }
        .onAppear {
            if let user = Auth.auth().currentUser {
                self.user = user
                viewModel.fetchUpcomingEvents()
            }
        }
        .padding()
    }
}

// MARK: - ViewModel

class UpcomingEventsViewModel: ObservableObject {
    @Published var allEvents: [Event] = []
    @Published var filteredEvents: [Event] = []
    @Published var searchText: String = ""

    private let db = Firestore.firestore()

    var filterOptions: [FilterType] {
        [.next7Days, .next30Days, .next60Days, .next90Days, .otherUpcoming, .reset]
    }

    func fetchUpcomingEvents() {
        let collection = "outreachEvents"
        let timestamp = Timestamp(seconds: 1732664850, nanoseconds: 165000000)
        let userID = "PsfYiBOrzRMd3IC1hA07"

        let query = db.collection(collection)
            .whereField("eventDate", isGreaterThanOrEqualTo: timestamp)
            .whereField("helpRequestarray", arrayContains: userID)
            .order(by: "eventDate")
            .order(by: "__name__")

        query.getDocuments { [weak self] (snapshot, error) in
            if let error = error {
                print("Error fetching upcoming events: \(error)")
                return
            }

            guard let documents = snapshot?.documents else { return }
            let events: [Event] = documents.compactMap { Event(document: $0) }
            DispatchQueue.main.async {
                self?.allEvents = events
                self?.filteredEvents = events
            }
        }
    }

    func applyFilter(_ filter: FilterType) {
        switch filter {
        case .next7Days:
            if let endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) {
                filteredEvents = allEvents.filter { $0.eventDate.dateValue() <= endDate }
            }
        case .reset:
            filteredEvents = allEvents
        default:
            break
        }
    }
}

