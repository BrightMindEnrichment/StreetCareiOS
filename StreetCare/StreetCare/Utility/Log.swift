//
//  Log.swift
//  MobileCore
//
//  Created by Michael Thornton on 5/19/20.
//  Copyright © 2020 Michael Thornton. All rights reserved.
//

import Foundation


public class Log {
    
    
    public static func Log(_ message: String) {

        #if DEBUG
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        
        print("\(formatter.string(from: Date())) : \(message)")
        #endif
    }
    
} // end class
