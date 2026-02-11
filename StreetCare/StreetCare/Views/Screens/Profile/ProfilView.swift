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
    @State var userDetails: UserDetails? = UserDetails()
    @State var isPresented: Bool = false
    @Binding var selection: Int
    @Binding var loginRequested: Bool
    let adapter = VisitLogDataAdapter()
    @State var history = [VisitLog]()
    @State var logsOld = [VisitLog]()
    @State var logsNew = [VisitLog]()
    @EnvironmentObject var googleSignIn: UserAuthModel
    @State private var didReceiveOldLogs = false
    @State private var didReceiveNewLogs = false
    
    @State var logsInteractionDev = [VisitLog]()
    @State private var didReceiveInteractionDev = false
    
    @State var peopleHelped = 0
    @State var outreaches = 0
    @State var itemsDonated = 0
    
    @State var showUserDeleteDialog = false

    @State var showErrorMessage = false
    @State var errorMessage = ""
        
    @StateObject var storage = StorageManager(uid: "")
    @State private var avatarImage: UIImage?
    @State private var showLoginLink = false
    @State var isLoading = false
    
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
                        NavLinkButton(title: NSLocalizedString("editProfile", comment: ""), width: 160.0, height: 40.0,secondaryButton: true,noBorder: true, color: .blue)
                    }
                   // Spacer().frame(height: 10)
                    NavigationLink {
                        BadgesView()
                    } label: {
                        NavLinkButton(title:NSLocalizedString("badgesEarned", comment: ""), width: 160.0, height: 40.0,secondaryButton: true,noBorder: true, color: .blue)
                    }
                    Spacer()
                    NavigationLink {
                        LikedBadgesView()
                    } label: {
                        NavLinkButton(title: NSLocalizedString("Liked Posts", comment: ""), width: 160.0, height: 40.0,secondaryButton: true,noBorder: true, color: .blue)
                    }
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

                    NavLinkButton(title:NSLocalizedString("deleteAccount", comment: ""), width: 190.0, secondaryButton: true, noBorder: true, color: Color.black)
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
                    adapter.refresh_new()
                    adapter.refreshInteractionLogDev()
                    //adapter.refreshWebProd()
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
    private func tryMergeAndUpdate() {
        guard didReceiveOldLogs && didReceiveNewLogs && didReceiveInteractionDev else { return }
        self.history = (logsOld + logsNew + logsInteractionDev)
            .sorted { $0.whenVisit > $1.whenVisit }
        self.updateCounts()
        self.isLoading = false
    }
    
    private func mergeLogs() {
        self.history = (logsOld + logsNew)
            .sorted { $0.whenVisit > $1.whenVisit }  // Sort newest first
    }
    
    private func updateCounts() {
        
        self.outreaches = history.count
        print("outreaches",self.outreaches)
        print("history",self.history)
        self.peopleHelped = history.reduce(0) { total, log in
            if log.peopleHelped > 0 {
                return total + log.peopleHelped
            } else if log.numberOfHelpers > 0 {
                return total + log.numberOfHelpers
            } else {
                return total
            }
        }
        self.itemsDonated = history.reduce(0) { total, log in
            var count = 0
            count = log.listOfSupportsProvided.count
            // If nothing was found, check web-created logs
            if count == 0 {
                count += log.whatGiven.count
            }

            return total + count
        }
    }

    
} // end struct



extension ProfilView: VisitLogDataAdapterProtocol {
    
    func visitLogDataRefreshed(_ logs: [VisitLog]) {
        self.logsOld = logs
        self.didReceiveOldLogs = true
        tryMergeAndUpdate()
    }

    func visitLogDataRefreshedNew(_ logs: [VisitLog]) {
        self.logsNew = logs
        self.didReceiveNewLogs = true
        tryMergeAndUpdate()
    }
    
    func visitLogDataRefreshedInteractionDev(_ logs: [VisitLog]) {
        self.logsInteractionDev = logs
        self.didReceiveInteractionDev = true
        tryMergeAndUpdate()
    }
}


struct ProfilView_Previews: PreviewProvider {
    static var previews: some View {
        ProfilView(selection: .constant(1),loginRequested: .constant(false))
    }
}
