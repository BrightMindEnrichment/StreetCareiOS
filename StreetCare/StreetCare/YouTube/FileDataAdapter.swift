//
//  FileDataAdapter.swift
//  MobileCore
//
//  Created by Michael Thornton on 3/18/19.
//  Copyright © 2019 Michael Thornton. All rights reserved.
//

import Foundation


public class FileDataAdapter {
    
    public var fileName: String
    
    
    public init(fileName: String) {
        self.fileName = fileName
    }
    
    
    
    public func saveCodableObject<T : Codable>(_ object: T) {
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(object)
            
            Log.Log("\(String(data: jsonData, encoding: .utf8) ?? "error converting to json")")
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = dir.appendingPathComponent(fileName)
                Log.Log("writing to \(fileURL)")
                try jsonData.write(to: fileURL)
            }
            
        }
        catch {
            Log.Log("error")
        }
    }
    
    
    
    public func loadCodableObject<T : Codable>(_ object: T.Type, fromDirectory directory: FileManager.SearchPathDirectory ) -> Any? {
        
        let jsonDecoder = JSONDecoder()
        
        do {
            if let dir = FileManager.default.urls(for: directory, in: .userDomainMask).first {
                let fileURL = dir.appendingPathComponent(fileName)
                                
                let data = try Data(contentsOf: fileURL)
                
                //return try jsonDecoder.decode([Item].self, from: data)
                return try jsonDecoder.decode(object.self, from: data)
                
            }
            else {
                return nil
            }
            
        }
        catch {
            return nil
        }
    }
    
    
    
    public func loadCodableObjectFromBundel<T: Codable>(_ object: T.Type) -> Any? {
        
        
        if let fileURL = Bundle.main.url(forResource: fileName, withExtension: "") {
            
            let jsonDecoder = JSONDecoder()
            
            do {
                let data = try Data(contentsOf: fileURL)
                return try jsonDecoder.decode(object.self, from: data)
            }
            catch let error {
                Log.Log("json load failed: \(error.localizedDescription)")
                return nil
            }
        }
        
        return nil
    }
    
} // end class

