//
//  VisitImpactView.swift
//  StreetCare
//
//  Created by Michael on 5/1/23.
//

import SwiftUI
import FirebaseAuth

struct CustomHelpAlert: View {
    let onOK: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            
            Text(LocalizedStringKey("providedHelpTitle"), comment: "")
                .font(.custom("Poppins-SemiBold", size: 19))
                .multilineTextAlignment(.center)
            Text(LocalizedStringKey("providedHelpMessage"), comment: "")
                .font(.custom("Poppins-Light", size: 13))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
//            Divider()
//                   .frame(height: 1)
//                   .frame(maxWidth: .infinity)
//                   .background(Color.gray.opacity(0.3))
//                   .padding(.top, -10)
            
            Button(action: onOK) {
                Text("OK")
                    .font(.custom("Poppins-Regular", size: 17))
                    .foregroundColor(Color(red:   0/255,
                                           green: 122/255,
                                           blue: 255/255))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .cornerRadius(8)
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
        .frame(maxWidth: 300, maxHeight: 310)  // fixed maximum width
    }
}


struct VisitImpactView: View {
    
    let adapter = VisitLogDataAdapter()
    @State var history = [VisitLog]()
    
    var currentUser = Auth.auth().currentUser
    
    @State var peopleHelped = 0
    @State var outreaches = 0
    @State var itemsDonated = 0
    
    @State var showActionSheet = false
    
    @State var isLoading = false
    @State var isNavigationActive = false
    @State var showLoginMessage = false
    @State var user: User?
    @Binding var selection: Int
    @State private var showProvidedHelpAlert = false

    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    
                    Text("VISIT LOG").font(.system(size: 18)).padding()
                    ImpactView(peopleHelped: peopleHelped, outreaches: outreaches, itemsDonated: itemsDonated)
                    
                    Button(action: {
                        if user != nil {
                            showProvidedHelpAlert = true
                            //isNavigationActive = true
                        } else {
                            showLoginMessage = true
                        }
                    }) {
                        ZStack {
                            NavLinkButton(title: "Add new +", width: 120.0, height: 30.0)
                        }
                    }
                    .alert(NSLocalizedString("loginRequiredTitle", comment: "")
                           , isPresented: $showLoginMessage) {
                        Button("OK", role: .cancel) {
                            selection = 3
                        }
                        Button("Cancel") { }
                        
                    } message: {
                        Text(NSLocalizedString("loginRequiredMessage", comment: ""))
                    }
//                    .alert("I provided help!", isPresented: $showProvidedHelpAlert) {
//                        Button("OK") {
//                            isNavigationActive = true
//                        }
//                    } message: {
//                        Text("Please fill out this form each time you perform an outreach.This helps you track your contributions and allows StreetCare to bring more support and services to help the community!")
//                    }
                    
                    .navigationDestination(isPresented: $isNavigationActive) {
                        VisitLogEntry()
                    }
                    Spacer(minLength: 10.0)
                    Divider().frame(maxWidth: UIScreen.main.bounds.width - 50 ,minHeight: 0.5)
                        .background(Color.black)
                    Spacer(minLength: 10.0)
                    Text("HISTORY").font(.system(size: 16)).bold()
                    List(history) { item in
                        HStack(spacing: 0) {
                            // ListConnectorDecorationView()
                            VStack {
                                HStack {
                                    Text("\(item.whereVisit)").font(.system(size: 15.0)).bold()
                                    Spacer()
                                }
                                HStack {
                                    Text("\(item.whenVisit.formatted(date: .abbreviated, time: .omitted))").font(.system(size: 15.0))
                                    Spacer()
                                    NavigationLink {
                                        VisitLogView(log: item)
                                    } label: {
                                        NavLinkButton(title:"Details", width: 80.0,secondaryButton: false,noBorder: true, rightArrowNeeded: false,color: .black).frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                }
                                Divider().frame(maxWidth: UIScreen.main.bounds.width - 50 ,minHeight: 0.5)
                                    .background(Color.gray.opacity(0.4))
                            }
                        }.listRowSeparatorTint(.clear, edges: .all)
                            .listSectionSeparatorTint(.clear, edges: .all)
                    }.listStyle(PlainListStyle())
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                }
                .loadingAnimation(isLoading: isLoading)
                .onAppear {
                    print("Impact view onAppear")
                    adapter.delegate = self
                    Auth.auth().addStateDidChangeListener { auth, currentUser in
                        /*
                         This listener detects changes in authentication state.
                         - If the user logs in, `currentUser` is updated.
                         - If the user logs out, `currentUser` becomes nil.
                         */
                        self.user = currentUser  // Update the user state
                    }
                    
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
            if showProvidedHelpAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                CustomHelpAlert {
                    showProvidedHelpAlert   = false
                    isNavigationActive = true
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

