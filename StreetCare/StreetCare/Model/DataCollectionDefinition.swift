//
//  DataCollectionDefinition.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/3/22.
//

import Foundation

enum DataCollectionTypes {
    case Text
    case Date
    case Number
    case Selection
}



class DataCollectionDefinition {
    
    var type: DataCollectionTypes
    var prompt: String
    var placeholder: String?
    var dataDisplay: String?
    
    init(type: DataCollectionTypes, prompt: String, placeholder: String?, dataDisplay: String?) {
        self.type = type
        self.prompt = prompt
        self.placeholder = placeholder
        self.dataDisplay = dataDisplay
    }
    
} // end class
