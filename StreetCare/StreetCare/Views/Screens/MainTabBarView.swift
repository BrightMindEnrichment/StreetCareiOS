//
//  MainTabBarView.swift
//  StreetCare
//
//  Created by Michael on 3/27/23.
//

import SwiftUI

struct MainTabBarView: View {
    
    @State private var selection = 0
    var body: some View {
        TabView(selection: $selection) {
            LandingScreenView()
                .tabItem{
                    TabButtonView(imageName: "Tab-HowToHelp", title: "How to Help", isActive: (selection == 0))
                }
                .tag(0)
            VisitImpactView()
                .tabItem{
                    TabButtonView(imageName: "Tab-VisitLog", title: "Visit Log", isActive: (selection == 1))
                }
                .tag(1)

            CommunityView()
                .tabItem{
                    TabButtonView(imageName: "Tab-Community", title: "Community", isActive: (selection == 2))
                }
                .tag(2)

            ProfilView()
                .tabItem{
                    TabButtonView(imageName: "Tab-Profile", title: "Profile", isActive: (selection == 3))
                }
                .tag(3)

        }
    }
}

struct MainTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabBarView()
    }
}
