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
    @State private var navigateToAddNew = false
    

    
    var body: some View {
        NavigationStack {
            VStack {
                Text("VISIT LOG")
                    .font(.system(size: 24, weight: .bold))
                    .padding()
                ImpactView(peopleHelped: peopleHelped, outreaches: outreaches, itemsDonated: itemsDonated)
                Button("ADD NEW+") {
                    navigateToAddNew = true
                }
                .foregroundColor(Color("PrimaryColor"))
                .fontWeight(.bold)
                .padding(.horizontal, 45)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color("SecondaryColor"))
                )
                .frame(width: 197.0, height: 40.0)
                .padding(.bottom)
                
                .navigationDestination(isPresented: $navigateToAddNew) {
                    VisitLogEntry()
                }
                Spacer(minLength: 20.0)
                Divider().frame(maxWidth: UIScreen.main.bounds.width - 150 ,minHeight: 0.5)
                    .background(Color(red: 0, green: 0.16, blue: 0.145))
                Spacer(minLength: 10.0)
                Text("HISTORY")
                    .font(.custom("Poppins", size: 19))
                    .fontWeight(.bold)
                    .frame(width: 87, alignment: .center)
                    .padding(.top, 8)
                    

                List(Array(history.enumerated()), id: \.element.id) { index, item in
                    HStack(alignment: .top, spacing: 3) {
                        ZStack {
                            // Top vertical line (connects to the top of the circle)
                            if index != 0 {
                                Rectangle()
                                    .fill(Color.black) // Use lighter gray for better visibility
                                    .frame(width: 1, height: 70) // Adjusted height
                                    .offset(x: -5, y: -20) // Adjusted y-offset for correct alignment
                            }
                            
                            // Bottom vertical line (connects from the bottom of the circle)
                            if index != history.count - 1 {
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(width: 1, height: 70) // Adjusted height
                                    .offset(x: -5, y: 50) // Adjusted y-offset
                            }
                            
                            // Circle indicator
                            Circle()
                                .fill(Color(red: 1.0, green: 0.933, blue: 0.0))
                                .frame(width: 13, height: 13)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: 1)
                                )
                                .offset(x: -5, y: 15) // Centering the circle with respect to lines
                        }
                        .frame(width: 10) // Ensuring proper spacing

                        GeometryReader { geo in
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(width: 55, height: 55)
                                
                                Image("VisitLogIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(Circle())
                                    .frame(width: 55, height: 55)
                            }
                            .position(x: 40, y: geo.size.height / 2 - 5) // center based on card height
                        }
                        .frame(width: 0) // enough to hold the icon
                        .zIndex(1)

                        
                
                        
                        VStack(spacing: 5) {
                            HStack(alignment: .top, spacing: 5) {
                                Image("MapPin")
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                    .padding(.top, 1)
                                // Extract street and state from `item.whereVisit`
                                let components = item.whereVisit.components(separatedBy: ", ").filter { !$0.isEmpty }
                                let street = components.indices.contains(0) ? components[0] :""
                                let city = components.indices.contains(1) ? components[1] : ""
                                let fullState = components.indices.contains(2) ? components[2].components(separatedBy: .whitespaces).first ?? "" : ""
                                let stateAbbr = stateAbbreviations[fullState] ?? ""
                                VStack(alignment: .leading, spacing: 2) {
                                    if components.count >= 3 {
                                        Text(street)
                                            .font(.system(size: 13.0))
                                            .lineLimit(2)
                                            .fixedSize(horizontal: false, vertical: true)
                                            .frame(maxWidth: UIScreen.main.bounds.width * 0.4, alignment: .leading)
                                        
                                        Text("\(city), \(stateAbbr)")
                                            .font(.system(size: 13.0))
                                    } else {
                                        let city = components[0]
                                        let fullState = components[1].components(separatedBy: .whitespaces).first ?? ""
                                        let stateAbbr = stateAbbreviations[fullState] ?? fullState
                                        
                                        Text("\(city), \(stateAbbr)")
                                            .font(.system(size: 13.0))

                                    }
                                }

                                Spacer()
                            }
                            .padding(.leading, 20)
                            HStack {
                                Image("Clock") // Clock icon
                                    .font(.system(size: 14))
                                    .foregroundColor(.black)
                                    .padding(.trailing, -5)
                                Text("\(item.whenVisit.formatted(date: .abbreviated, time: .omitted)) | \(item.whenVisit.formatted(date: .omitted, time: .shortened))").font(.system(size: 13)).lineLimit(1).layoutPriority(1)
                                GeometryReader { geo in
                                    ZStack {
                                        Button("Details") {
                                            print("Details tapped")
                                        }
                                        .font(.system(size: 10.7, weight: .bold))
                                        .foregroundColor(Color(red: 1.0, green: 0.933, blue: 0.0)) // textColor
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(Color(red: 0, green: 0.16, blue: 0.145)) // background color
                                        )
                                        .frame(width: 70)


                                        NavigationLink(destination: VisitLogView(log: item)) {
                                            EmptyView()
                                        }
                                        .opacity(0)
                                    }
                                    .position(
                                        x: geo.size.width / 2 ,
                                        y: 0
                                    )
                                }
                                .frame(height: 30) //room you want for the button

                            }
                            .padding(.top, -5)
                            .padding(.leading, 20)
                        }
                        .padding(.vertical, 15) //card size
                        .padding(.leading, 55)
                        .background(Color.white)
                        .clipShape(HalfCapsuleShape())
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)



                    }
                    .padding(.horizontal) // Add padding to space out cards
                    .padding(.trailing, 0) //card right side padding
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 10, leading: 10, bottom: 5, trailing: 10))

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
struct HalfCapsuleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let leftRadius = rect.height / 2       // Capsule curve on the left
        let rightRadius: CGFloat = 16         // Rounded corners on the right

        // Start at top-left curve
        path.move(to: CGPoint(x: leftRadius, y: 0))

        // Top edge to top-right corner
        path.addLine(to: CGPoint(x: rect.width - rightRadius, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.width, y: rightRadius),
            control: CGPoint(x: rect.width, y: 0)
        )

        // Right edge to bottom-right corner
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - rightRadius))
        path.addQuadCurve(
            to: CGPoint(x: rect.width - rightRadius, y: rect.height),
            control: CGPoint(x: rect.width, y: rect.height)
        )

        // Bottom edge to start of arc
        path.addLine(to: CGPoint(x: leftRadius, y: rect.height))

        // Left capsule arc
        path.addArc(
            center: CGPoint(x: leftRadius, y: rect.midY),
            radius: leftRadius,
            startAngle: .degrees(90),
            endAngle: .degrees(270),
            clockwise: false
        )

        path.closeSubpath()
        return path
    }
}



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

