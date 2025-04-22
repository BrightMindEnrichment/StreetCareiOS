//
//  VisitImpactView.swift
//  StreetCare
//
//  Created by Michael on 5/1/23.
//

import SwiftUI
import FirebaseAuth

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
    @State var showAlert = false
    @State var user: User?
    @Binding var selection: Int

    var body: some View {
        NavigationStack {
            VStack {
                Text("VISIT LOG").font(.system(size: 18)).padding()
                ImpactView(peopleHelped: peopleHelped, outreaches: outreaches, itemsDonated: itemsDonated)
                
                Button(action: {
                    if user != nil {
                        showAlert = true
                    } else {
                        showLoginMessage = true
                    }
                }) {
                    ZStack {
                        NavLinkButton(title: "Add new +", width: 120.0, height: 30.0)
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

                //Spacer(minLength: 10.0)
                Divider().frame(maxWidth: UIScreen.main.bounds.width - 50 ,minHeight: 0.5)
                    .background(Color.black)
                //Spacer(minLength: 10.0)

                Text("HISTORY").font(.system(size: 16)).bold()
                
                if history.isEmpty {
                    Text("You have no logged history.")
                        .font(.custom("Poppins-Light", size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 8)
                } else {
                    List(history) { item in
                        HStack(spacing: 0) {
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
                                        NavLinkButton(title:"Details", width: 80.0, secondaryButton: false, noBorder: true, rightArrowNeeded: false, color: .black)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                    }
                                }
                                Divider().frame(maxWidth: UIScreen.main.bounds.width - 50 ,minHeight: 0.5)
                                    .background(Color.gray.opacity(0.4))
                            }
                        }
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
