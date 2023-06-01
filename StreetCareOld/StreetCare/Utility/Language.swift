//
//  Language.swift
//  StreetCare
//
//  Created by Michael Thornton on 4/29/22.
//

import Foundation


class Language {
    
    
    static var errorTitle: String {
        return NSLocalizedString("errorTitle", comment: "")
    }
    
    static func locString(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
    
} // end class
