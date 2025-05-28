//
//  PublicVisitLogView.swift
//  StreetCare
//
//  Created by Aishwarya S on 08/05/25.
//

import SwiftUI
import Combine
import FirebaseAuth


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
    let adapter = PublicVisitLogDataAdapter()
    @StateObject private var viewModel = PublicVisitLogViewModel()
    
    private func applyFilter(filter: FilterType) {
        viewModel.filterByDate(filterType: filter)
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
                                                          onDetailsClick: {
                                            presentBottomSheet.toggle()
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
            VStack {
                EmptyView()
            }
            .frame(maxWidth: .infinity)
            .padding()
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
}

extension PublicVisitLogView: PublicVisitLogDataAdapterProtocol {
    func visitLogDataRefreshed(_ logs: [VisitLog]) {
        self.history = logs
        self.viewModel.visitLogs = logs
        self.viewModel.filterByDate(filterType: .reset)
    }
}

//#Preview {
//    PublicVisitLogView()
//}
