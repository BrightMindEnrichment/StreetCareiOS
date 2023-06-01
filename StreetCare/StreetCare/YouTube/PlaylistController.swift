//
//  PlaylistController.swift
//  Gym
//
//  Created by Michael Thornton on 5/26/20.
//  Copyright © 2020 Michael Thornton. All rights reserved.
//

import Foundation


class PlaylistController: ObservableObject {
    
    @Published var playlistId: String
    
    @Published var playlist: Playlist?

    @Published var isLoaded = false
    
    
    init(playlistId: String) {
        
        self.playlistId = playlistId
    }
    
    
    
    func refresh(playlistId: String) {
        
        self.playlistId = playlistId
        
        let network = SafeNetwork()
        
        let request = URLRequest.urlRequestForPlaylist(playlistId)
        
        network.loadCodableObject(Playlist.self, withURLRequest: request) { (playlist, data, response, error) in
            
            if let error = error {
                print("error : \(error.localizedDescription)")
            }
            
            if let playlist = playlist as? Playlist {
                self.playlist = playlist
                
                print("got data, record count of \(self.playlist!.items.count)")
                self.isLoaded = true
            }
        }
    }
    
    
    
    func videoInformationAtIndex(_ index: Int) -> VideoInformation? {
        
        if let playlist = playlist {
            return playlist.items[index]
        }
        
        return nil
    }
    
} // end class
