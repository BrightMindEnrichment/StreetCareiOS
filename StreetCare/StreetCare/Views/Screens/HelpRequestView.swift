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
    @Environment(\.presentationMode) var presentationMode // Add this line
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AddHelpRequestForm()) {
                    Image(systemName: "plus")
                        .foregroundColor(Color("SecondaryColor"))
                }
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
                if let status = event.status {
                    Text(status.capitalized)
                        .font(.system(size: 13))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.yellow)
                        .cornerRadius(5)
                }
                
                Spacer()
                
                //Image("blueCheckMark")
                /*Circle()
                    .fill(getVerificationColor(for: event.userType)) // Dynamic color
                    .frame(width: 15, height: 15)
                    .overlay(Circle().stroke(Color.white, lineWidth: 1)) // Add a border*/
                HStack(spacing: 5) {
                    // Checkmark icon with dynamic color
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(getVerificationColor(for: event.userType))
                        .font(.system(size: 20))
                }
            }
            
            
            Text(event.title == "" ? "No date available" : event.title!.capitalized)
                .font(.headline)
            
            HStack {
                Image(systemName: "mappin.and.ellipse")
                Text(event.location!)
                    .font(.system(size: 13))
            }
            /*if let userType = event.userType {
                Text("User Type: \(userType)") // Display the user type
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            } else {
                Text("User Type: Unknown") // Fallback if user type is not fetched yet
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }*/
                        
            if let identification = event.identification{
                Text("How to Find: \(identification == "" ? "-" : identification)").font(.system(size: 13))
            }
            Text("Event Description").font(.system(size: 14)).fontWeight(.semibold)
                Text(event.description == "" ? "No date available" : event.description!).font(.system(size: 13))
           
            HStack {
                if let skills = event.skills {
                    ForEach(skills.prefix(4), id: \.self) { skill in
                        Text(skill)
                            .font(.system(size: 10))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .multilineTextAlignment(.center)
                            .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.8), lineWidth: 0.7))
                            .lineLimit(2)
                    }
                }
            }
            .padding(.top, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            
//            TODO: pending implementation of button actions
            HStack{
                Spacer()
                Button {
                    showICanHelpPopup = true
                } label: {
                    Text("I can help")
                        .padding(EdgeInsets(top: 8.0, leading: 20.0, bottom: 8.0, trailing: 20.0))
                        .foregroundColor(Color("PrimaryColor"))
                }
                .background(Color("SecondaryColor"))
                .clipShape(Capsule())
                .sheet(isPresented: $showICanHelpPopup, content: {
                    ICanHelpView(isPresented: $showICanHelpPopup)
                })
            }
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

func getVerificationColor(for userType: String?) -> Color {
    switch userType {
    case nil:
        return Color.yellow // Random person without account or missing type
    case "":
        return Color.yellow
    case "Chapter Member":
        return Color.purple
    case "Internal Member":
        return Color.blue
    case "Chapter Leader":
        return Color.green
    default:
        return Color.yellow
    }
}
