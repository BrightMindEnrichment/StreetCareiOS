//
//  ProfilView.swift
//  StreetCare
//
//  Created by Michael on 3/27/23.
//

import SwiftUI
import FirebaseAuth
import UIKit
import FirebaseFirestore


struct ProfilView: View {
    
    @State var user: User?
    @Binding var selection: Int
    @Binding var loginRequested: Bool
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
    @State private var showLoginLink = false
    
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
                    NotLoggedInProfileView(selection: $selection)
                }
            }
            .onAppear {
                attemptLoginPresentationIfNeeded()        // ← NEW
                if let u = Auth.auth().currentUser {
                    self.user = u
                    adapter.delegate = self
                    adapter.refresh()
                    storage.uid = u.uid
                    // 🔽 ADDED: Check Firestore for photoUrl (for web-created accounts)
                    let db = Firestore.firestore()
                    db.collection("users").whereField("uid", isEqualTo: u.uid).getDocuments { snapshot, error in
                        if let docs = snapshot?.documents, let doc = docs.first {
                            if let url = doc["photoUrl"] as? String, !url.isEmpty {
                                if let imageUrl = URL(string: url) {
                                    URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                                        if let data = data, let image = UIImage(data: data) {
                                            DispatchQueue.main.async {
                                                self.avatarImage = image
                                            }
                                        }
                                    }.resume()
                                }
                            } else {
                                storage.getImage()
                            }
                        }
                    }
                }
            }
            .onChange(of: selection) { _ in
                           attemptLoginPresentationIfNeeded()        // ← NEW
                       }
            
            // push LoginView programmatically
            NavigationLink(
                destination: LoginView(selection: $selection),
                isActive: $showLoginLink
            ) {
                EmptyView()
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
    
    private func attemptLoginPresentationIfNeeded() {
           guard
               user == nil,
               loginRequested,
               selection == 3
           else { return }
           
           showLoginLink   = true
           loginRequested = false
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



extension ProfilView: VisitLogDataAdapterProtocol {
    
    func visitLogDataRefreshed(_ logs: [VisitLog]) {
        self.history = logs
        self.updateCounts()
    }
}


struct ProfilView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilView(selection: .constant(1),loginRequested: .constant(false))
    }
}
