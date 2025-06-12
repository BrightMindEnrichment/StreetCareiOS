//
//  MainTabBarView.swift
//  StreetCare
//
//  Created by Michael on 3/27/23.
//

import SwiftUI
import FirebaseAuth

struct MainTabBarView: View {
    
    @State private var selection = 0
    @State private var user: User? = nil
    @State private var loginRequested = false
    
    var body: some View {
        TabView(selection: $selection) {
            
            LandingScreenView()
                .tabItem {
                    TabButtonView(imageName: "Tab-HowToHelp", title: NSLocalizedString("howToHelp", comment: ""), isActive: (selection == 0))
                }
                .tag(0)
            
            Group {
                if user != nil {
                    VisitImpactView(selection: $selection)
                } else {
                    NotLoggedInView(loginRequested: $loginRequested, selection: $selection)
                }
            }
            .tabItem {
                TabButtonView(imageName: "Tab-VisitLog", title: NSLocalizedString("interactionLog", comment: ""), isActive: (selection == 1))
            }
            .tag(1)
            
            CommunityView()
                .tabItem {
                    TabButtonView(imageName: "Tab-Community", title: NSLocalizedString("community", comment: ""), isActive: (selection == 2))
                }
                .tag(2)
            
            ProfilView(selection: $selection, loginRequested: $loginRequested)
                .tabItem {
                    TabButtonView(imageName: "Tab-Profile", title: NSLocalizedString("profile", comment: ""), isActive: (selection == 3))
                }
                .tag(3)
        }
        .onAppear {
            Auth.auth().addStateDidChangeListener { _, currentUser in
                self.user = currentUser
            }
        }
    }
}

struct MainTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabBarView()
    }
}
