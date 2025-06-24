//
//  PublicVisitLogView.swift
//  StreetCare
//
//  Created by Aishwarya S on 08/05/25.
//

import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct CustomSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search..."
    var filterTapped: (FilterType) -> Void
    var filterOptions: [FilterType]
    @State private var selectedFilter: FilterType = .none
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .padding(.horizontal, 10)
                .foregroundColor(.black)
            
            TextField(NSLocalizedString("searchPlaceholder", comment: "Search bar placeholder"), text: $text)
                .frame(height: 50.0)
            // Filter options
            Menu {
                ForEach(filterOptions, id: \.self) { filter in
                    Button(action: {
                        selectedFilter = filter
                        filterTapped(selectedFilter)
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
                        if selectedFilter != .none && selectedFilter != .reset {
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
        }.overlay(
            RoundedRectangle(cornerRadius: 15.0)
                .stroke(Color.black, lineWidth: 1)
        )
    }
    
}


struct PublicVisitLogView: View {
    @ObservedObject var loggedInUserDetails: UserDetails
    private let filterOptions: [FilterType] = [.last7Days, .last30Days, .last60Days, .last90Days, .otherPast, .reset]
    @State private var history: [VisitLog] = []
    @State private var presentBottomSheet = false
    @State private var popupRefresh = false
    @State var user: User?
    @State private var userType: String = ""
    @EnvironmentObject var imageLoader: StorageManager
    
    @State private var selectedVisit: VisitLog? = nil
    @State private var showPublicPopup = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let adapter = PublicVisitLogDataAdapter()
    @StateObject private var viewModel = PublicVisitLogViewModel()
    
    
    private func applyFilter(filter: FilterType) {
        viewModel.filterByDate(filterType: filter)
    }
    
    private var bottomSheetContent: some View {
            Group {
                if let visit = selectedVisit {
                    PublicInteractionPopupView(
                        visit: visit,
                        user: user,
                        userType: userType,
                        onCancel: {
                            presentBottomSheet = false
                        },
                        delegate: self,
                        refresh: $popupRefresh
                    )
                    //.environmentObject(imageLoader)
                    .frame(maxWidth: .infinity)
                    .padding()
                }
            }
        }
    
    var body: some View {
        VStack{
            CustomSearchBar(text: $viewModel.searchText, filterTapped: applyFilter, filterOptions: filterOptions).padding()
            LegendView()
            List  {
                ForEach(0..<viewModel.filteredData.count, id: \.self) {
                    index in
                    let current = viewModel.filteredData[index]
                    if let month = current.keys.first, let logs = current[month] {
                        Section(header: SectionHeaderView(date: month, eventCount: logs.count)) {
                            ForEach(0..<logs.count, id: \.self) {
                                dataIndex in
                                if let visitLog = logs[dataIndex].log {
                                    HStack {
                                        VStack {
                                            let (date, day) =  getDateAndDay(date: visitLog.whenVisit)
                                            Text("\(date)")
                                                .font(.system(size: 14, weight: .bold))
                                            
                                            Text("\(day)")
                                                .font(.system(size: 12, weight: .regular))
                                                .foregroundColor(Color("TextColor"))
                                        }
                                        
                                        PublicLogViewCard(log: visitLog,
                                                          user: visitLog.user,
                                                          loggedInUser: loggedInUserDetails,
                                                          onDetailsClick:{
                                            Task {
                                                // 1. Preload EVERYTHING first (username, userType, photoURL, image)
                                                await preloadPopupData(for: visitLog)

                                                // 2. Then assign and show the popup
                                                await MainActor.run {
                                                    selectedVisit = visitLog
                                                    presentBottomSheet = true
                                                }
                                            }
                                        })
                                        .background(Color.clear)
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {}
                                    .listRowBackground(Color.white)
                                    .padding(.top, 8)
                                }
                            }
                        }
                    }
                }
                .listRowSeparatorTint(.clear, edges: .all)
                .listSectionSeparatorTint(.clear, edges: .all)
            }
            .listStyle(PlainListStyle())
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .navigationTitle("Public Interaction Logs")
        }
        .bottomSheet(isPresented: $presentBottomSheet) {
            bottomSheetContent
        }
        .onAppear {
            print("Public log view on appear.")
            adapter.delegate = self
            adapter.refresh()
        }
        .onDisappear {
            presentBottomSheet = false
        }
    }
    
private func preloadPopupData(for visit: VisitLog) async {
       guard let _ = Auth.auth().currentUser else { return }
       let db = Firestore.firestore()

       do {
           let query = db.collection("users").whereField("uid", isEqualTo: visit.uid)
           let snapshot = try await query.getDocuments()
           if let userDoc = snapshot.documents.first {
               let data = userDoc.data()
               visit.userType = data["Type"] as? String ?? "Account Holder"
               visit.username = data["username"] as? String ?? "Firstname Lastname"
               visit.photoURL = data["photoUrl"] as? String ?? ""
           }
       } catch {
           print("❌ Error fetching from users: \(error)")
       }

       await MainActor.run {
           if !visit.photoURL.isEmpty, let url = URL(string: visit.photoURL) {
               URLSession.shared.dataTask(with: url) { data, _, _ in
                   if let data = data, let image = UIImage(data: data) {
                       Task { @MainActor in
                           imageLoader.image = image
                       }
                   }
               }.resume()
           } else {
               let manager = StorageManager(uid: visit.uid)
               manager.getImage()
               DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                   if let img = manager.image {
                       imageLoader.image = img
                   }
               }
           }
       }
   }
}

extension PublicVisitLogView: PublicVisitLogDataAdapterProtocol {
    func visitLogDataRefreshed(_ logs: [VisitLog]) {
        self.history = logs
        self.viewModel.visitLogs = logs
        self.viewModel.filterByDate(filterType: .reset)
    }
}

extension PublicVisitLogView: EventPopupViewDelegate {
    func close() {
        // You can leave this empty if you already handle onCancel separately.
    }
}
#Preview {
    PublicVisitLogView(loggedInUserDetails: UserDetails())
}

