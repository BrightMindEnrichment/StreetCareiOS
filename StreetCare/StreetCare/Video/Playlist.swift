//
//  Playlist.swift
//  Gym
//
//  Created by Michael Thornton on 5/26/20.
//  Copyright © 2020 Michael Thornton. All rights reserved.
//

import Foundation



class Playlist: Codable {
    
    var kind: String
    var etag: String
    
    var items: [VideoInformation]
    
    var pageInfo: PageInfo
    
} // end class
