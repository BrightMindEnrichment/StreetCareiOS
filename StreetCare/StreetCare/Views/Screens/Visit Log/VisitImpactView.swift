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
    //@State private var navigateToAddNew = false
    @State var isNavigationActive = false
    @State var showLoginMessage = false
    @State var showAlert = false
    @State var user: User?
    @Binding var selection: Int

    var body: some View {
        NavigationStack {
            VStack {
                Text("INTERACTION LOG").font(.system(size: 18, weight: .bold)).padding()
                ImpactView(peopleHelped: peopleHelped, outreaches: outreaches, itemsDonated: itemsDonated)
                Spacer(minLength: -5)
                Button(action: {
                    if user != nil {
                        showAlert = true
                    } else {
                        showLoginMessage = true
                    }
                }) {
                    
                    ZStack {
                        NavLinkButton(title: "ADD NEW+", width: 197.0, height: 40.0)
                            .clipShape(Capsule())
                    }
                }
                .alert(NSLocalizedString("loginRequiredTitle", comment: ""), isPresented: $showLoginMessage) {
                    Button("OK", role: .cancel) {
                        selection = 3
                    }
                    Button("Cancel", role: .destructive) { }
                } message: {
                    Text(NSLocalizedString("loginRequiredMessage", comment: ""))
                }
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text(NSLocalizedString("providedHelpTitle", comment: "")),
                        message: Text(NSLocalizedString("providedHelpMessage", comment: "")),
                        dismissButton: .default(Text("OK"), action: {
                            isNavigationActive = true
                        })
                    )
                }
                .navigationDestination(isPresented: $isNavigationActive) {
                    VisitLogEntry()
                }

                Spacer(minLength: 15.0)
                Divider().frame(maxWidth: UIScreen.main.bounds.width - 150 ,minHeight: 0.5)
                    .background(Color.black)
                    .padding(.top, 8)
                //Spacer(minLength: 10.0)

                Text("HISTORY")
                    .font(.custom("Poppins-Regular", size: 20))
                    //.font(.system(size: 16))
                    .fontWeight(.bold)
                    .padding(.top, 8)

                if history.isEmpty {
                    Text("You have no logged history.")
                        .font(.custom("Poppins-Light", size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                } else {
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
                                    .frame(width: 13, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                                    .offset(x: -5, y: 15) // Centering the circle with respect to lines
                            }
                            .frame(width: 5) // Ensuring proper spacing
                            
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
                                    
                                    let street = components.indices.contains(0) ? components[0] : ""
                                    let city = components.indices.contains(1) ? components[1] : ""
                                    let state = components.indices.contains(2) ? components[2] : ""  // no split
                                    let stateAbbr = stateAbbreviations[state] ?? state  // supports both "OK" and "Oklahoma"
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        if components.count >= 3 {
                                            Text(street)
                                                .font(.system(size: 13.0))
                                                .lineLimit(2)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .frame(maxWidth: UIScreen.main.bounds.width * 0.4, alignment: .leading)
                                            
                                            Text("\(city), \(stateAbbr)")
                                                .font(.system(size: 13.0))
                                        }  else {
                                            let city = components.indices.contains(0) ? components[0] : ""
                                            let fullState = components.indices.contains(1) ? components[1] : ""
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
                                            .font(.custom("Poppins-SemiBold", size: 13))
                                            .foregroundColor(Color(red: 1.0, green: 0.933, blue: 0.0)) // textColor
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                Capsule()
                                                    .fill(Color(red: 0, green: 0.16, blue: 0.145)) // background color
                                            )
                                            .frame(width: 80)
                                            
                                            
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
                        .padding(.horizontal, 5) // Add padding to space out cards
                        .padding(.trailing, 0) //card right side padding
                        .listRowSeparatorTint(.clear, edges: .all)
                        .listSectionSeparatorTint(.clear, edges: .all)
                    }
                    .listStyle(PlainListStyle())
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }

                Spacer()
            }
            .loadingAnimation(isLoading: isLoading)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                print("Impact view onAppear")
                adapter.delegate = self
                Auth.auth().addStateDidChangeListener { _, currentUser in
                    self.user = currentUser
                }
                if Auth.auth().currentUser != nil {
                    adapter.refresh()
                    self.isLoading = true
                } else {
                    adapter.resetLogs()
                    history = [VisitLog]()
                    peopleHelped = 0
                    outreaches = 0
                    itemsDonated = 0
                }
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
        VisitImpactView(selection: .constant(1))
    }
}
