//
//  FeaturedItemController.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/2/22.
//

import Foundation

class FeaturedItemController {
    
    private var featuredItems: [FeaturedItem]
    
    static let shared = FeaturedItemController()
    
    
    var count: Int {
        return featuredItems.count
    }
    
    
    
    private init() {
        
        let adapter = FileDataAdapter(fileName: "what_to_give.json")
        
        if let featuredItems = adapter.loadCodableObjectFromBundel([FeaturedItem].self) as? [FeaturedItem] {
            self.featuredItems = featuredItems
        }
        else {
            self.featuredItems = [FeaturedItem]()
        }
    }
    
    
    
    func featuredItemAtIndex(_ index: Int) -> FeaturedItem? {
    
        return featuredItems[index]
    }
    
} // end class
