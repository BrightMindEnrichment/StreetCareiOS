//
//  SafeNetwork.swift
//  NetworkSecurity
//
//  Created by Michael Thornton on 8/12/19.
//  Copyright © 2019 Michael Thornton. All rights reserved.
//

import Foundation


enum SafeNetworkError: Error {
    case noDataReturned
    case invalidServerResponse
}



/**
 Use for making network calls.
 
 Calls are cert pinned using @URLSessionPinningDelegate
 */
public class SafeNetwork {
    

    /**
     Method signature used when a network call is complete.
     Data : data from the service
     [String: Any] : additional information.  Two items typically: "responseCode" and "headers".
     Error: Populated when the call failed for some reason
     */
    public typealias NetworkCompletionHandler = (Any?, [String: Any]?, Error?) -> Void
    
    
    //see session() function
    private var _session: URLSession?
    
    
    public init() {}
    
    
    /***
     To keep cookies intact, we need to make sure all calls are on the same session.
     Probably a slicker way to do this than a function, might come back to this later.
     */
    private func session() -> URLSession {
        
        if let s = _session {
            return s
        }
        else {
            
            let sessionConfiguration = URLSessionConfiguration.ephemeral
            sessionConfiguration.httpCookieStorage = HTTPCookieStorage.shared
                        

            //_session = URLSession(configuration: sessionConfiguration, delegate: URLSessionPinningDelegate(), delegateQueue: OperationQueue.main)
            _session = URLSession(configuration: sessionConfiguration, delegate: nil, delegateQueue: OperationQueue.main)
            
            
            return _session!
        }
    }

    
    
    public func fetchWithURLRequest(_ urlRequest: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        Log.Log("Initating call for \(urlRequest.url?.absoluteString ?? "none")")
        
        let task = self.session().dataTask(with: urlRequest) { (data, urlResponse, error) in
            
            // call failed if we have an error object or no data
            if error != nil || data == nil {
                
                if let error = error {
                    completionHandler(data, urlResponse, error)
                }
                else {
                    completionHandler(data, urlResponse, SafeNetworkError.noDataReturned)
                }
                return
            }
            

            //make sure the server did not return an error
            guard let response = urlResponse as? HTTPURLResponse else {
                Log.Log("response is not an HTTPURLResponse")
                completionHandler(data, urlResponse, SafeNetworkError.invalidServerResponse)
                return
            }
            
            Log.Log("Completed call for : \(response.url?.absoluteString ?? "none")")
            Log.Log("response code : \(response.statusCode)")
            if let data = data {
                Log.Log("response text : \(String(data: data, encoding: .utf8) ?? "")")
            }
            
            
            if !(200...299).contains(response.statusCode) {
                completionHandler(data, urlResponse, SafeNetworkError.invalidServerResponse)
                return
            }

            
            //success!
            completionHandler(data, urlResponse, error)
        }
        
        task.resume()
    }
    
    
    
    public func loadCodableObject<T: Codable>(_ object: T.Type, withURLRequest urlRequest: URLRequest, completionHandler: @escaping (Any?, Data?, URLResponse?, Error?) -> Void) {
        
        self.fetchWithURLRequest(urlRequest) { (data, urlResponse, error) in
            
            if let error = error {
                completionHandler(nil, data, urlResponse, error)
            }
            
            let jsonDecoder = JSONDecoder()
            
            do {
                if let data = data {
                    let result = try jsonDecoder.decode(object.self, from: data)
                    completionHandler(result, data, urlResponse, error)
                }
                else {
                    completionHandler(nil, data, urlResponse, SafeNetworkError.noDataReturned)
                }
            }
            catch let error {
                completionHandler(nil, data, urlResponse, error)
            }
            
        }
    }
    
} // end class
