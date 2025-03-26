//
//  VisitImpactView.swift
//  StreetCare
//
//  Created by Michael on 5/1/23.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore


struct VisitImpactView: View {
    
    let adapter = VisitLogDataAdapter()
    @State var history = [VisitLog]()
    
    var currentUser = Auth.auth().currentUser
    
    @State var peopleHelped = 0
    @State var outreaches = 0
    @State var itemsDonated = 0
    
    @State var showActionSheet = false
    
    @State var isLoading = false
    

    
    var body: some View {
        NavigationStack {
            VStack {
                Text("VISIT LOG").font(.system(size: 18)).padding()
                ImpactView(peopleHelped: peopleHelped, outreaches: outreaches, itemsDonated: itemsDonated)
                
                NavigationLink {
                    VisitLogEntry()
                } label: {
                    ZStack {
                        NavLinkButton(title: "Add new +", width: 120.0, height: 30.0)
                    }
                }
                Spacer(minLength: 10.0)
                Divider().frame(maxWidth: UIScreen.main.bounds.width - 50 ,minHeight: 0.5)
                    .background(Color.black)
                Spacer(minLength: 10.0)
                Text("HISTORY").font(.system(size: 16)).bold()
                List(history) { item in
                    HStack(spacing: 0) {
                        ZStack {

                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 50, height: 50)
                        }
                        
                        .zIndex(1) // Ensures it overlays on top of the card
                        .padding(.trailing, -50)
                        
                        VStack(spacing: 0) {
                            HStack {
                                Image(systemName: "mappin.and.ellipse") // Location icon
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                // Extract street and state from `item.whereVisit`
                                let components = item.whereVisit.components(separatedBy: ", ").filter { !$0.isEmpty }
                                let street = components.indices.contains(0) ? components[0] : "N/A"
                                let fullState = components.indices.contains(2) ? components[2].components(separatedBy: .whitespaces).first ?? "N/A" : "N/A"
                                let stateAbbr = stateAbbreviations[fullState] ?? "N/A"
                                
                                // Display
                                Text("\(street), \(stateAbbr)")
                                    .font(.system(size: 14.0))
                                    .bold()
                                Spacer()
                            }
                            .padding(.bottom, 0)
                            HStack {
                                Image(systemName: "clock") // Clock icon
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                Text("\(item.whenVisit.formatted(date: .abbreviated, time: .omitted)) | \(item.whenVisit.formatted(date: .omitted, time: .shortened))").font(.system(size: 13)).lineLimit(1).layoutPriority(1)
                                Spacer()
                                NavigationLink {
                                    VisitLogView(log: item)
                                } label: {
                                    NavLinkButton(title:"Details", width: 80.0,secondaryButton: false,noBorder: true, rightArrowNeeded: false,color: .black).frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.trailing, -30)//details button padding
                                }
                            }
                            .padding(.top, -5)
                        }
                        .padding()
                        .padding(.leading, 45)
                        .background(Color.white) // Card-like background
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .clipShape(Capsule()) // Rounded on all sides
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 3) // Subtle shadow



                    }
                    .padding(.horizontal) // Add padding to space out cards
                    .padding(.trailing, -20) //card padding
                    .listRowSeparator(.hidden)
                }
                .listStyle(PlainListStyle())
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            }
            .loadingAnimation(isLoading: isLoading)
            .onAppear {
                print("Imact view onAppear")
                adapter.delegate = self
                
                // not sure why I need to do this, the refresh method
                // checks for no user and if so calls
                // delegate function
                // but the loading animation never goes away
                // despite the state flagging changing to false
                if Auth.auth().currentUser != nil {
                    adapter.refresh()
                    self.isLoading = true
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
    } // end body
    
    
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
let stateAbbreviations: [String: String] = [
    "Alabama": "AL", "Alaska": "AK", "Arizona": "AZ", "Arkansas": "AR",
    "California": "CA", "Colorado": "CO", "Connecticut": "CT", "Delaware": "DE",
    "Florida": "FL", "Georgia": "GA", "Hawaii": "HI", "Idaho": "ID",
    "Illinois": "IL", "Indiana": "IN", "Iowa": "IA", "Kansas": "KS",
    "Kentucky": "KY", "Louisiana": "LA", "Maine": "ME", "Maryland": "MD",
    "Massachusetts": "MA", "Michigan": "MI", "Minnesota": "MN", "Mississippi": "MS",
    "Missouri": "MO", "Montana": "MT", "Nebraska": "NE", "Nevada": "NV",
    "New Hampshire": "NH", "New Jersey": "NJ", "New Mexico": "NM", "New York": "NY",
    "North Carolina": "NC", "North Dakota": "ND", "Ohio": "OH", "Oklahoma": "OK",
    "Oregon": "OR", "Pennsylvania": "PA", "Rhode Island": "RI", "South Carolina": "SC",
    "South Dakota": "SD", "Tennessee": "TN", "Texas": "TX", "Utah": "UT",
    "Vermont": "VT", "Virginia": "VA", "Washington": "WA", "West Virginia": "WV",
    "Wisconsin": "WI", "Wyoming": "WY"
]


//func displayUserName() {
//    let collectionName = "users"
//    let db = Firestore.firestore()
//    
//    // Directly using the test UID (replace visitLog with the test UID)
//    let userUID = VisitLog.uid
//    
//    db.collection(collectionName).whereField("uid", isEqualTo: userUID).getDocuments { querySnapshot, error in
//        
//        if let error = error {
//            print("Error fetching documents: \(error.localizedDescription)")
//        } else {
//            if let documents = querySnapshot?.documents, !documents.isEmpty {
//                let document = documents[0]
//                
//                if let username = document["username"] as? String {
//                    print("Username retrieved: \(username)")
//                } else {
//                    print("Username not found in document")
//                }
//            } else {
//                print("No user document found with the given UID.")
//            }
//        }
//    }
//}

extension VisitImpactView: VisitLogDataAdapterProtocol {
    
    func visitLogDataRefreshed(_ logs: [VisitLog]) {
        self.history = logs
        self.updateCounts()
        self.isLoading = false
    }
}


struct VisitImpactView_Previews: PreviewProvider {
    static var previews: some View {
        VisitImpactView()
    }
}

