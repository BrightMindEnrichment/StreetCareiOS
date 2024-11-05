//
//  HelpRequestView.swift
//  StreetCare
//
//  Created by SID on 6/19/24.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct HelpRequestView: View {
    
    @State var user: User?
    
    let adapter = EventDataAdapter()
    @StateObject private var viewModel = SearchHelpRequestViewModel()

    var body: some View {
        
        VStack {
            HStack {
                    Image(systemName: "magnifyingglass").padding(.horizontal, 10)
                              .foregroundColor(.black)
                    TextField("Search...", text: $viewModel.searchText).frame(height: 50.0)
                }.overlay(
                        RoundedRectangle(cornerRadius: 15.0)
                            .stroke(Color.black, lineWidth: 1))
                .padding()
            if viewModel.filteredItems.isEmpty{
                Text(NSLocalizedString("noHelpingRequestsAvailable", comment: "")).fontWeight(.bold).foregroundColor(Color("TextColor"))
            }
            if let _ = self.user {
                if viewModel.filteredItems.isEmpty{
                    Spacer(minLength: 50.0)
                }else{
                    List {
                        ForEach(0..<viewModel.filteredItems.count, id: \.self) { index in
                             let event = viewModel.filteredItems[index]
                                HStack{
                                    HelpRequestCardView(event: event)
                                }
                            
                        }.listRowSeparatorTint(.clear, edges: .all)
                            .listSectionSeparatorTint(.clear, edges: .all)
                    }.listStyle(PlainListStyle())
                        .navigationTitle(NSLocalizedString("helpRequests", comment: ""))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)

                }
            }  else {
                Image("CommunityOfThree").padding()
                Text("Log in to connect with your local community.")
            }
        }
        .onAppear {
            if let user = Auth.auth().currentUser {
                self.user = user
                adapter.delegate = self
                adapter.getHelpRequest()
            }
        }
    }
}



extension HelpRequestView: EventDataAdapterProtocol {
    func eventDataRefreshed(_ events: [Event]) {
    }
    
    func helpRequestDataRefreshed(_ events: [HelpRequest]) {
        viewModel.events = events
        viewModel.tempEvents = events
    }
}

struct HelpRequestCardView: View {
    var event: HelpRequest
    @State private var showICanHelpPopup = false

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {
            
            HStack {
                Text(event.status!.capitalized).font(.system(size: 13))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.yellow)
                    .cornerRadius(5)
            }
            
            
            Text(event.title == "" ? "No date available" : event.title!.capitalized)
                .font(.headline)
            
            HStack {
                Image(systemName: "mappin.and.ellipse")
                Text(event.location!)
                    .font(.system(size: 13))
            }
       
            if let identification = event.identification{
                Text("How to Find: \(identification == "" ? "-" : identification)").font(.system(size: 13))
            }
            Text("Event Description").font(.system(size: 14)).fontWeight(.semibold)
                Text(event.description == "" ? "No date available" : event.description!).font(.system(size: 13))
           
            HStack {
                if let skills = event.skills{
                    ForEach(0..<skills.count, id: \.self) { index in
                    HStack {
                        Text("  \(skills[index])  ")
                            .font(.system(size: 10))
                    }.frame(height: 30.0).overlay(
                        RoundedRectangle(cornerRadius: 15.0)
                            .stroke(Color.gray.opacity(0.8), lineWidth: 0.7))
                }
            }
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            
//            TODO: pending implementation of button actions
//            HStack{
//                Spacer()
//                Button {
//                    showICanHelpPopup = true
//                } label: {
//                    Text("I can help")
//                        .padding(EdgeInsets(top: 8.0, leading: 20.0, bottom: 8.0, trailing: 20.0))
//                        .foregroundColor(Color("PrimaryColor"))
//                }
//                .background(Color("SecondaryColor"))
//                .clipShape(Capsule())
//                .sheet(isPresented: $showICanHelpPopup, content: {
//                    ICanHelpView(isPresented: $showICanHelpPopup)
//                })
//            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}


class SearchHelpRequestViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var tempEvents: [HelpRequest] = [HelpRequest]()
    @Published var events = [HelpRequest]()

    var filteredItems: [HelpRequest] {
           if searchText.isEmpty {
               return tempEvents
               defer{
                   events = tempEvents
               }
           } else {
               return events.filter { $0.title!.localizedCaseInsensitiveContains(searchText) }
           }
       }
}
