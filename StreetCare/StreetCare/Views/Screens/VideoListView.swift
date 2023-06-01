//
//  VideoListView.swift
//  StreetCare
//
//  Created by Michael on 4/3/23.
//

import SwiftUI

struct VideoListView: View {
    
    var playlistId: String
    
    @StateObject var controller = PlaylistController(playlistId: "")
    
    var body: some View {
        NavigationStack {
            VStack {
                if controller.isLoaded {
                    List(controller.playlist!.items, id: \.videoId) { item in
                        NavigationLink {
                            WebView(url: URL(string: "https://www.youtube.com/embed/\(item.videoId)"))
                        } label: {
                            YoutubeCellView(item: item)
                        }
                    }
                }
            }
            .onAppear {
                controller.refresh(playlistId: self.playlistId)
            }
            .navigationTitle("howToVideos")
        }
    }
}

struct VideoListView_Previews: PreviewProvider {
    static var previews: some View {
        VideoListView(playlistId: "PLh7GZtyt8qiLKwO_WoE0Vmcu6UMV1AtV9")
    }
}
