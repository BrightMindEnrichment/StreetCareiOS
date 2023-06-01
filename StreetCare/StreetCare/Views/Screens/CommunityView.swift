//
//  CommunityView.swift
//  StreetCare
//
//  Created by Michael on 3/27/23.
//

import SwiftUI
import FirebaseAuth

struct CommunityView: View {
    
    @State var user: User?
    
    let adapter = EventDataAdapter()
    @State var events = [Event]()
    
    let formatter = DateFormatter()

    var body: some View {
        
        VStack {
            Text("Community")
                .font(.title)
            
            if let _ = self.user {
                List(events) { event in
                    VStack {
                        if let d = event.date {
                            HStack {
                                Text(d.formatted(date: .abbreviated, time: .shortened))
                                    .foregroundColor(Color("SecondaryColor"))
                                Spacer()
                            }
                        }

                        HStack {
                            Text(event.title  ?? "")
                                .font(.headline)
                                .foregroundColor(Color("TextColor"))
                            Spacer()
                        }
                        
                        HStack {
                            Text(event.description ?? "")
                                .foregroundColor(Color("TextColor"))
                            Spacer()
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            else {
                Image("CommunityOfThree").padding()
                Text("Log in to connect with your local community.")
            }

        }
        .onAppear {
            if let user = Auth.auth().currentUser {
                self.user = user
                
                adapter.delegate = self
                adapter.refresh()
            }
        }
    }
}



extension CommunityView: EventDataAdapterProtocol {
    
    func eventDataRefreshed(_ events: [Event]) {
        self.events = events
    }
}


struct CommunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}
