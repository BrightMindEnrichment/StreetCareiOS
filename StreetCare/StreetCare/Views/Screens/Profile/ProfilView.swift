//
//  ProfilView.swift
//  StreetCare
//
//  Created by Michael on 3/27/23.
//

import SwiftUI
import FirebaseAuth
import UIKit


struct ProfilView: View {
    
    @State var user: User?
    
    let adapter = VisitLogDataAdapter()
    @State var history = [VisitLog]()
    @EnvironmentObject var googleSignIn: UserAuthModel

    @State var peopleHelped = 0
    @State var outreaches = 0
    @State var itemsDonated = 0
    
    @State var showUserDeleteDialog = false

    @State var showErrorMessage = false
    @State var errorMessage = ""
        
    @StateObject var storage = StorageManager(uid: "")
    @State private var avatarImage: UIImage?

    
    var body: some View {
        NavigationStack {
            VStack {
                
                if let user = self.user {
                    //Spacer().frame(height: 20)
                    AvatarView(image: $avatarImage)

                    if let displayName = user.displayName {
                        Text("\(displayName)")
                    }
                    else {
                        if let email = user.email {
                            Text("\(email)")
                        }
                    }
                    Spacer().frame(height: 30)
                    
                    
                    NavigationLink {
                        ProfileDetails()
                    } label: {
                        NavLinkButton(title:"Edit Profile", width: 160.0, height: 40.0,secondaryButton: true,noBorder: true, color: .blue)
                    }
                   // Spacer().frame(height: 10)

                    NavigationLink {
                        BadgesView()
                    } label: {
                        NavLinkButton(title:"Badges Earned", width: 160.0, height: 40.0,secondaryButton: true,noBorder: true, color: .blue)
                    }
                    Spacer()

                    ImpactView(peopleHelped: peopleHelped, outreaches: outreaches, itemsDonated: itemsDonated)
                        .padding()
                    
                
                    NavLinkButton(title: NSLocalizedString("logoutButtonTitle", comment: ""), width: 190.0, secondaryButton: true)
                        .padding()
                        .onTapGesture {
                            do {
                                try Auth.auth().signOut()
                                googleSignIn.signOut()
                                self.avatarImage = nil
                                self.user = nil
                            }
                            catch {
                                self.user = nil
                            }
                        }

                    NavLinkButton(title: "Delete Account", width: 190.0, secondaryButton: true, noBorder: true, color: Color.black)
                        .padding()
                        .onTapGesture {
                            showUserDeleteDialog = true
                        }
                    
                    Spacer()
                }
                else {
                    NotLoggedInProfileView()
                }
            }
            .onAppear {
                if let user = Auth.auth().currentUser {
                    self.user = user
                    
                    adapter.delegate = self
                    adapter.refresh()
                    
                    storage.uid = user.uid
                    storage.getImage()
                }
            }
            .onChange(of: storage.image, perform: { newValue in
                if let img = newValue {
                    self.avatarImage = img
                }
            })
            .alert("Error...", isPresented: $showErrorMessage, actions: {
                Button("OK") {
                    // nothing to do
                }
            }, message: {
                Text(errorMessage)
            })
            .alert("Delete your account?", isPresented: $showUserDeleteDialog) {
                Button("OK", role: .destructive)
                {
                    if let user = Auth.auth().currentUser {
                        user.delete { error in
                            
                            if let error = error {
                                errorMessage = error.localizedDescription
                                showErrorMessage = true
                            }
                            else {
                                self.user = nil
                            }
                        }
                    }
                }
                
                Button("Cancel", role: .cancel) {
                    showUserDeleteDialog = false
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



extension ProfilView: VisitLogDataAdapterProtocol {
    
    func visitLogDataRefreshed(_ logs: [VisitLog]) {
        self.history = logs
        self.updateCounts()
    }
}


struct ProfilView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilView()
    }
}
