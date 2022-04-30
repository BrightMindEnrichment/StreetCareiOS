//
//  PlaylistController.swift
//  Gym
//
//  Created by Michael Thornton on 5/26/20.
//  Copyright © 2020 Michael Thornton. All rights reserved.
//

import Foundation

protocol PlaylistControllerDelegate {
    
    func playlistRefreshed()
}



class PlaylistController {
    
    
    var playlistId: String
    
    var playlist: Playlist?

    var delegate : PlaylistControllerDelegate?
    
    
    
    var count: Int {
        if let playlist = playlist {
            return playlist.items.count
        }
        return 0
    }
    
    
    
    init(playlistId: String) {
        
        self.playlistId = playlistId
    }
    
    
    
    func refresh() {
        
        let network = SafeNetwork()
        
        let request = URLRequest.urlRequestForPlaylist(playlistId)
        
        network.loadCodableObject(Playlist.self, withURLRequest: request) { (playlist, data, response, error) in
            
            if let error = error {
                print("error : \(error.localizedDescription)")
            }
            
            if let playlist = playlist as? Playlist {
                self.playlist = playlist
                
                self.delegate?.playlistRefreshed()
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
