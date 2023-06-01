//
//  PlaylistDefinitionDataAdapter.swift
//  StreetCare
//
//  Created by Michael on 5/8/23.
//

import Foundation



class PlaylistDefinitionDataAdapter {
    
    var categories: [PlaylistDefinition]
    
    static let shared = PlaylistDefinitionDataAdapter()
    
    
    var count: Int {
        return categories.count
    }
    
    
    
    private init() {
        
        let adapter = FileDataAdapter(fileName: "playlists.json")

        if let categories = adapter.loadCodableObjectFromBundel([PlaylistDefinition].self) as? [PlaylistDefinition] {
            self.categories = categories
        }
        else {
            self.categories = [PlaylistDefinition]()
        }
    }
    
    
    
    func informationCategoryAtIndex(_ index: Int) -> PlaylistDefinition? {
    
        return categories[index]
    }
    
} //end class
