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
    let adapter = VisitLogDataAdapter()
    @State var history = [VisitLog]()
    @State var peopleHelped = 0
    @State var outreaches = 0
    @State var itemsDonated = 0
    
    
    var badgesList: [Badges] = [
        Badges(objectId : 1,title: "Neighborhood All-Star",description: "Joined > 3 Outreaches in the same neighborhood",imageName: "neighborhood_all_star_badge"),
        Badges(objectId : 2,title: "Benevolent Donar",description:"Donated more than 10 items",imageName: "benevolent_donor_badge"),
        Badges(objectId : 3,title: "Outreach All-Star",description:"Joined more than 15 \nOutreaches or has helped more than 60 people",imageName: "outreach_all_star_badge")
    ]
    let formatter = DateFormatter()

    var body: some View {
        
        VStack {
            
            if let _ = self.user {
                List{
                    ForEach(badgesList){ badge in
                        
                        Badge(description: badge.description, title: badge.title, imageName: badge.imageName, objectId: badge.objectId,peopleHelped: peopleHelped, outreaches: outreaches,itemsDonated: itemsDonated).cornerRadius(10.0).border(.black).listRowSeparator(.hidden)
                    }
                }.navigationTitle("Your Badges").scrollContentBackground(.hidden).background(.clear)  .listStyle(.plain)
            }
            else {
                Image("CommunityOfThree").padding()
                Text("Log in to connect with your local community.")
            }

        }.loadingAnimation(isLoading: false)
            .onAppear {
                print("Imact view onAppear")
                adapter.delegate = self
                if let user = Auth.auth().currentUser {
                    self.user = user
                    adapter.delegate = self
                    adapter.refresh()
                }
                else {
                    adapter.resetLogs()
                    history = [VisitLog]()
                    peopleHelped = 0
                    outreaches = 0
                    itemsDonated = 0
                }
            }
    }
    
    private func updateCounts() {

        self.outreaches = history.count
        
        self.peopleHelped = history.reduce(0, { partialResult, visitLog in
            partialResult + visitLog.peopleHelped
        })
        
        self.itemsDonated = history.reduce(0, { partialResult, visitLog in
            
            var newDonations = 0
            
            if visitLog.foodAndDrinks {
                newDonations += 1
            }

            if visitLog.clothes {
                newDonations += 1
            }

            if visitLog.hygine {
                newDonations += 1
            }
            
            if visitLog.wellness {
                newDonations += 1
            }

            if visitLog.other {
                newDonations += 1
            }
            return partialResult + newDonations
        })
    }
} // end struct

extension BadgesView: VisitLogDataAdapterProtocol {
    
    func visitLogDataRefreshed(_ logs: [VisitLog]) {
        self.history = logs
        self.updateCounts()
    }
}



struct BadgesView_Previews: PreviewProvider {
    static var previews: some View {
        BadgesView()
    }
}
