//
//  Endpoints.swift
//  Gym
//
//  Created by Michael Thornton on 5/26/20.
//  Copyright © 2020 Michael Thornton. All rights reserved.
//

import Foundation


enum Endpoints: String {
    case PlaylistVideos = "https://www.googleapis.com/youtube/v3/playlistItems"
}



extension URLRequest {
    
    
    static func urlRequestForPlaylist(_ playlistId: String) -> URLRequest {

        let urlString = "\(Endpoints.PlaylistVideos.rawValue)?key=AIzaSyAV5713sUQ-j8KxDjuPGtyVq1aQY1iJkuY&part=id,contentDetails,snippet&playlistId=\(playlistId)"
        
        if let url = URL(string: urlString) {
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            
            return urlRequest
        }
        
        preconditionFailure("Problem with the url")
    }
}
