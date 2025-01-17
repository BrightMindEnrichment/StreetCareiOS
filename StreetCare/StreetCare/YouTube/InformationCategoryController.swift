//
//  InformationCategoryController.swift
//  Gym
//
//  Created by Michael Thornton on 5/26/20.
//  Copyright © 2020 Michael Thornton. All rights reserved.
//

import Foundation


class InformationCategoryController {
    
    private var categories: [InformationCategory]
    
    static let shared = InformationCategoryController()
    
    
    var count: Int {
        return categories.count
    }
    
    
    
    private init() {
        
        let adapter = FileDataAdapter(fileName: "playlists.json")

        if let categories = adapter.loadCodableObjectFromBundel([InformationCategory].self) as? [InformationCategory] {
            self.categories = categories
        }
        else {
            self.categories = [InformationCategory]()
        }
    }
    
    
    
    func informationCategoryAtIndex(_ index: Int) -> InformationCategory? {
    
        return categories[index]
    }
    
} //end class
