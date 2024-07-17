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
struct CommunityEventView: View {
    
    @State var user: User?
    @State var currentData =  EventData()
    let adapter = EventDataAdapter()
    @StateObject private var viewModel = SearchCommunityModel()
    @State private var isBottomSheetPresented = false

    let formatter = DateFormatter()
    var eventType : EventType
  
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
            if viewModel.filteredData.isEmpty{
                Text(NSLocalizedString(eventType == .future ? "noFutureEventsAvailable" : eventType == .past ? "noPastEventsAvailable" : "noHelpingRequestsAvailable", comment: "")).fontWeight(.bold).foregroundColor(Color("TextColor"))
            }
            if let _ = self.user {
                if viewModel.filteredData.isEmpty{
                    Spacer(minLength: 50.0)
                }else{
                    List {
                        ForEach(0..<viewModel.filteredData.count, id: \.self) { index in
                            if let date = viewModel.filteredData[index].keys.first,
                               let eventObj = viewModel.filteredData[index][date] {
                                Section(header: SectionHeaderView(date: date)){
                                    ForEach(eventObj) { event in
                                        HStack{
                                            VStack{
                                                if let date = event.date.0{
                                                    Text("\(date)").font(.system(size: 14, weight: .bold))
                                                        .foregroundColor(Color("TextColor"))
                                                }
                                                if let date = event.date.1{
                                                    Text("\(date)").font(.system(size: 12, weight: .regular))
                                                        .foregroundColor(Color("TextColor"))
                                                }
                                            }
                                            Button(action: {
                                                           isBottomSheetPresented.toggle()
                                                            currentData.date = event.date
                                                            currentData.monthYear = event.monthYear
                                                            currentData.event = event.event
                                                       }) {
                                                           EventCardView(event: event,eventType: eventType)
                                                       }
                                        }
                                    }
                                }
                            }
                        }.listRowSeparatorTint(.clear, edges: .all)
                            .listSectionSeparatorTint(.clear, edges: .all)
                    }.listStyle(PlainListStyle())
                        .navigationTitle(eventType == .future ? NSLocalizedString("futureEvents", comment: "") : eventType == .past ? NSLocalizedString("pastEvents", comment: "") : NSLocalizedString("helpRequests", comment: ""))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)

                }
            }  else {
                Image("CommunityOfThree").padding()
                Text("Log in to connect with your local community.")
            }
        }.bottomSheet(isPresented: $isBottomSheetPresented) {
            VStack {
                EventPopupView(event: currentData,eventType: eventType, delegate: self)
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
        }.onDisappear {
            isBottomSheetPresented = false
        }
    }
}

extension CommunityEventView:EventPopupViewDelegate{
  
    func close() {
        isBottomSheetPresented.toggle()
    }
}

extension CommunityEventView: EventDataAdapterProtocol {
    func helpRequestDataRefreshed(_ events: [HelpRequest]) {
    }
    
    func eventDataRefreshed(_ events: [Event]) {
        viewModel.events = events.filter({ event in
            return event.eventDate != nil
        })
        viewModel.filterEvents(eventType: eventType)
    }
}


struct CommunityEventView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityEventView(eventType: .future)
    }
}


extension Sequence where Element: Identifiable {
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        return Dictionary.init(grouping: self, by: key)
    }
}
extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
    func group<U: Hashable>(by key: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        return Dictionary.init(grouping: self, by: key)
    }
}


struct EventCardView: View {
    var event: EventData
    var eventType : EventType

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
                if let interest = event.event.participants?.count{
                    if let slots = event.event.totalSlots{
                        Text("Participants: \(interest) / \(slots)")
                            .font(.system(size: 13))
                    }
                }
                Spacer()
                if eventType == .past{
                    Text("Completed").font(.system(size: 13))
                }else{
                    NavLinkButton(title: event.event.liked ? "Deregister" : "RSVP", width: event.event.liked ? 110.0 : 90.0).fontWeight(.semibold)
                        .onTapGesture {
                        }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 5)
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
              defer{
                  sectionsAndItems = tempSectionsAndItems
              }
          } else {
              return self.sectionsAndItems.map { dict in
                  dict.mapValues { events in
                      events.filter { $0.event.title.localizedCaseInsensitiveContains(searchText)}
                  }.filter { !$0.value.isEmpty }
              }.filter { !$0.isEmpty }
          }
      }
    
    
    func filterEvents(eventType : EventType){
        var result = [EventData]()
        if events.count != 0{
            if eventType == .future{
                let filteredArray = self.events.sorted { firstEvent, secondEvent in
                    return firstEvent.eventDate! > secondEvent.eventDate!
                }
                
                for each in filteredArray{
                    if let dateValue = each.eventDate{
                        let dateObj = convertDateToEst(date: "\(dateValue)")
                        if dateObj > Date(){
                            let data = EventData()
                            data.monthYear = formatDateString("\(dateObj)")
                            data.date.0 = formatDateString("\(dateObj)",format: "dd")
                            data.date.1 = formatDateString("\(dateObj)",format: "EEE").uppercased()
                            data.date.2 = formatDateString("\(dateObj)",format: "hh:mm a")
                            data.event = each
                            result.append(data)
                        }
                    }
                }
                let scheduledEventss = result.group(by: {$0.monthYear})
                
                let newEvents = scheduledEventss.sorted { object1, object2 in
                    return convertDate(from: object1.key)! < convertDate(from: object2.key)!
                }
                for each in newEvents{
                    sectionsAndItems.append(["\(each.key)": each.value])
                }
                tempSectionsAndItems = sectionsAndItems

            }else if eventType == .past{
                let filteredArray = self.events.sorted { firstEvent, secondEvent in
                    return firstEvent.eventDate! < secondEvent.eventDate!
                }
                
                for each in filteredArray{
                    if let dateValue = each.eventDate{
                        let dateObj = convertDateToEst(date: "\(dateValue)")
                        if dateObj < Date(){
                            let data = EventData()
                            data.monthYear = formatDateString("\(dateObj)")
                            data.date.0 = formatDateString("\(dateObj)",format: "dd")
                            data.date.1 = formatDateString("\(dateObj)",format: "EEE").uppercased()
                            data.date.2 = formatDateString("\(dateObj)",format: "hh:mm a")
                            data.event = each
                            result.append(data)
                        }
                    }                }
                let scheduledEventss = result.group(by: {$0.monthYear})
                let newEvents = scheduledEventss.sorted { object1, object2 in
                    return convertDate(from: object1.key)! > convertDate(from: object2.key)!
                }
                for each in newEvents{
                    sectionsAndItems.append(["\(each.key)": each.value])
                }
                tempSectionsAndItems = sectionsAndItems
            }
        }
    }
}
