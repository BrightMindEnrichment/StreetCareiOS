//
//  PlaylistsView.swift
//  StreetCare
//
//  Created by Michael on 5/8/23.
//

import SwiftUI


struct PlaylistsView: View {

    var links: [PlaylistDefinition] = [
        PlaylistDefinition(title: "An Introduction to Street Outreach", playlistId: "PLh7GZtyt8qiLKwO_WoE0Vmcu6UMV1AtV9"),
        PlaylistDefinition(title: "Homeless Veterans", playlistId: "PLh7GZtyt8qiKevwz9gkTs0OyaglNnfUcl"),
        PlaylistDefinition(title: "Street Safety", playlistId: "PLh7GZtyt8qiJsEwIitzTaZ2l3aA1Kiyx0"),
        PlaylistDefinition(title: "Homelessnes and Mental Illness", playlistId: "PLh7GZtyt8qiKCy8iYdDzMXttuw6s7fdkP")
    ]

    
    var body: some View {

        NavigationStack {
            VStack {
                Image("HelpPhoto2").resizable().frame(width: 300.0, height: 200.0)
                    .clipShape(RoundedRectangle(cornerRadius: 16.0))
                
                ForEach(links, id: \.playlistId) { link in
                    NavigationLink {
                        VideoListView(playlistId: link.playlistId)
                    } label: {
                        NavLinkButton(title: link.title, width: 320.0, secondaryButton: true)
                    }
                    .padding()
                }
                Spacer()
            }
        }
        
    } // end body
} // end struct



struct PlaylistsView_Previews: PreviewProvider {
    static var previews: some View {
        PlaylistsView()
    }
}
