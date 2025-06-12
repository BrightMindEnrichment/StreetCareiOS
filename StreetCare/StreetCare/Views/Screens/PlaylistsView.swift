//
//  PlaylistsView.swift
//  StreetCare
//
//  Created by Michael on 5/8/23.
//

import SwiftUI


struct PlaylistsView: View {

    var links: [PlaylistDefinition] = [        
        PlaylistDefinition(title: NSLocalizedString("howToUseApp", comment: ""), playlistId: "PLh7GZtyt8qiJKRJ0O_oJ5qRlvGeZUH2Zk"),
        PlaylistDefinition(title: NSLocalizedString("introductionToStreetOutreach", comment: ""), playlistId: "PLh7GZtyt8qiLKwO_WoE0Vmcu6UMV1AtV9"),
        PlaylistDefinition(title: NSLocalizedString("homelessVeterans", comment: ""), playlistId: "PLh7GZtyt8qiKevwz9gkTs0OyaglNnfUcl"),
        PlaylistDefinition(title: NSLocalizedString("streetSafety", comment: ""), playlistId: "PLh7GZtyt8qiJsEwIitzTaZ2l3aA1Kiyx0"),
        PlaylistDefinition(title: NSLocalizedString("homelessnesAndMentalIllness", comment: ""), playlistId: "PLh7GZtyt8qiKCy8iYdDzMXttuw6s7fdkP")
    ]

    
    var body: some View {

        NavigationStack {
            VStack {
                ScrollView{
                    Spacer()
                    Spacer(minLength: 70.0)

                ForEach(links, id: \.playlistId) { link in
                    NavigationLink {
                        VideoListView(playlistId: link.playlistId, title: link.title)
                    } label: {
                        NavLinkButton(title: link.title, width: UIScreen.main.bounds.width - 50, height: 50.0,secondaryButton: true, rightArrowNeeded: true).padding(EdgeInsets(top: 5.0, leading: 20.0, bottom: 25.0, trailing: 20.0))
                    }
                    }
                }
            }
        }.padding()
        .navigationTitle(NSLocalizedString("duringOutreach", comment: ""))
        
    } // end body
} // end struct



struct PlaylistsView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistsView()
    }
}
#Preview {
    PlaylistsView()
}
