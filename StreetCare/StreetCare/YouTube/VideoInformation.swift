//
//  VideoInformation.swift
//  Gym
//
//  Created by Michael Thornton on 5/26/20.
//  Copyright © 2020 Michael Thornton. All rights reserved.
//

import Foundation


class VideoInformation: Codable {
    
    var contentDetails: ContentDetails
    var snippet: Snippet
    
    
    var title: String { return self.snippet.title }
    var description: String { return self.snippet.description }
    var videoId: String { return self.contentDetails.videoId }
    var thumbnailURL: String { return self.snippet.thumbnails.medium.url }
    
} // end class



class ContentDetails: Codable {
    
    var videoId: String
    var videoPublishedAt: String
} // end class



class Snippet: Codable {
    
    var title: String
    var description: String
    var thumbnails: Thumbnails
} // end class


class Thumbnails: Codable {

    var medium: Thumbnail
}



class Thumbnail: Codable {
    
    var url: String
    var width: Int
    var height: Int
} // end class
