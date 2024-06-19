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
    
    let adapter = EventDataAdapter()
    @State var events = [Event]()
    
    let formatter = DateFormatter()
    var eventType : EventType
    @State var sectionsAndItems: [[String: [EventData]]] = [[String: [EventData]]]()
    
    var body: some View {
        
        VStack {
       
            if let _ = self.user {
                if sectionsAndItems.isEmpty{
                    Text(NSLocalizedString(eventType == .future ? "noFutureEventsAvailable" : eventType == .past ? "noPastEventsAvailable" : "noHelpingRequestsAvailable", comment: "")).fontWeight(.bold).foregroundColor(Color("TextColor"))
                }else{
                    List {
                        ForEach(0..<sectionsAndItems.count, id: \.self) { index in
                            if let date = sectionsAndItems[index].keys.first,
                               let eventObj = sectionsAndItems[index][date] {
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
                                            EventCardView(event: event)
                                        }
                                        //.listRowInsets(EdgeInsets(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0))
                                    }
                                }
                            }
                        }.listRowSeparatorTint(.clear, edges: .all)
                            .listSectionSeparatorTint(.clear, edges: .all)
                    }.listStyle(PlainListStyle())
                        .navigationTitle(eventType == .future ? NSLocalizedString("futureEvents", comment: "") : eventType == .past ? NSLocalizedString("pastEvents", comment: "") : NSLocalizedString("helpRequests", comment: ""))
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                   // .listRowSeparator(.hidden, edges: .all)
                    

                }
            }  else {
                Image("CommunityOfThree").padding()
                Text("Log in to connect with your local community.")
            }
                    
//                    VStack {
//                        if let d = event.date {
//                            HStack {
//                                Text(d.formatted(date: .abbreviated, time: .shortened))
//                                    .foregroundColor(Color("SecondaryColor"))
//                                Spacer()
//                            }
//                        }
//
//                        HStack {
//                            Text(event.title  ?? "")
//                                .font(.headline)
//                                .foregroundColor(Color("TextColor"))
//                            Spacer()
//                        }
//                        
//                        HStack {
//                            Text(event.description ?? "")
//                                .foregroundColor(Color("TextColor"))
//                            Spacer()
//                        }
//                    }
              //  }
                //.scrollContentBackground(.hidden)
               // .background(Color.clear)
           // }
          

        }
        .onAppear {
            if let user = Auth.auth().currentUser {
                self.user = user
                adapter.delegate = self
                adapter.refresh()
            }
        }
    }
    
    func filterEvents(){
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
                let scheduledEventss = result.group(by: {$0.monthYear!})
                
                let newEvents = scheduledEventss.sorted { object1, object2 in
                    return convertDate(from: object1.key)! < convertDate(from: object2.key)!
                }
                for each in newEvents{
                    sectionsAndItems.append(["\(each.key)": each.value])
                }
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
                let scheduledEventss = result.group(by: {$0.monthYear!})
                let newEvents = scheduledEventss.sorted { object1, object2 in
                    return convertDate(from: object1.key)! > convertDate(from: object2.key)!
                }
                for each in newEvents{
                    sectionsAndItems.append(["\(each.key)": each.value])
                }
            }
        }
    }
}



extension CommunityEventView: EventDataAdapterProtocol {
    func eventDataRefreshed(_ events: [Event]) {
        self.events = events
        filterEvents()
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

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {
            Text(event.event!.title!)
                .font(.headline)
            
            HStack {
                Image(systemName: "mappin.and.ellipse")
                Text(event.event!.location!)
                    .font(.subheadline)
            }
            
            HStack {
                Image(systemName: "clock")
                if let date = event.date.2{
                    Text("\(date)")
                        .font(.subheadline)
                }
            }
            
            HStack {
                Image(systemName: "hands.clap")
                Text(event.event!.helpType!)
                    .font(.subheadline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
            }
            if let participants = event.event!.participants?.first{
                if let slots = event.event?.totalSlots{
                    Text("participants: \(participants) / \(slots)")
                        .font(.subheadline)
                }
            }
            
            HStack {
                Spacer()
                NavLinkButton(title: "RSVP", width: 90.0)
                    .onTapGesture {
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
