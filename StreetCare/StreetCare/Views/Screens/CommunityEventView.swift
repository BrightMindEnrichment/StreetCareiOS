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
                                    //Section(header: Text(date)) {
                                    ForEach(eventObj) { event in
                                        EventCardView(event: event)
                                    }
                                }
                            }
                        }
                    }//.listStyle(GroupedListStyle())
                    .navigationTitle("Upcoming Events")
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .listRowSeparator(.hidden, edges: .all)
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
                    return firstEvent.date! > secondEvent.date!
                }
                
                for each in filteredArray{
                    if each.date! > Date(){
                        let data = EventData()
                        data.monthYear = formatDateString("\(each.date!)")
                        data.date = formatDateString("\(each.date!)",format: "dd")
                        data.event = each
                        result.append(data)
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
                    return firstEvent.date! < secondEvent.date!
                }
                
                for each in filteredArray{
                    if each.date! < Date(){
                        let data = EventData()
                        data.monthYear = formatDateString("\(each.date!)")
                        data.date = formatDateString("\(each.date!)",format: "dd")
                        data.event = each
                        result.append(data)
                    }
                }
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
                Text("\(event.event!.date)")
                    .font(.subheadline)
            }

            HStack {
                Image(systemName: "hands.clap")
                Text(event.event!.description!)
                    .font(.subheadline)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
            }

            Text("participants: \(event.event!.interest)")
                .font(.subheadline)

            HStack {
                Spacer()
                Button(action: {
                    // RSVP Action
                }) {
                    Text("RSVP")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
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
            .font(.title3)
            .foregroundColor(.gray)
            .padding(.vertical)
    }
}
