//
//  CommunityView.swift
//  StreetCare
//
//  Created by Michael on 3/27/23.
//

import SwiftUI
import FirebaseAuth

struct BadgesView: View {
    
    @State var user: User?
    
    let adapter = EventDataAdapter()
    @State var events = [Event]()
    
    let formatter = DateFormatter()

    var body: some View {
        
        VStack {
            
            if let _ = self.user {
                
                List{
                    ForEach(events){ event in
                        Badge(description: event.description!, title: event.title!, imageName: "Clothes").border(.black).listRowSeparator(.hidden)
                    }
                }.navigationTitle("Your Badges").scrollContentBackground(.hidden).background(.clear)  .listStyle(.plain)
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



extension BadgesView: EventDataAdapterProtocol {
    
    func eventDataRefreshed(_ events: [Event]) {
        self.events = events
    }
}


struct BadgesView_Previews: PreviewProvider {
    static var previews: some View {
        BadgesView()
    }
}
