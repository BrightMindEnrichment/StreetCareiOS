//
//  StorgeManager.swift
//  StreetCare
//
//  Created by Michael Thornton on 6/12/23.
//

import Foundation
import UIKit
import FirebaseStorage



class StorageManager: ObservableObject {
    
    let storage = Storage.storage()
    @Published var image: UIImage? = nil
    
    var uid: String
    
    private var path: String {
        "users/\(uid)/profile.jpg"
    }
    
    init(uid: String) {
        self.uid = uid
    }
    
    
    func getImage() {

        let storageRef = storage.reference().child(path)
        
        storageRef.getData(maxSize: .max) { data, error in
            
            if let error = error {
                self.image = nil
                print("error fetching image: \(error.localizedDescription)")
                return
            }

            if let data = data {
                self.image = UIImage(data: data)
            }
        }
    }
    
    
    
    func upload(image: UIImage) {
        let storageRef = storage.reference().child(path)
                
        let data = image.jpegData(compressionQuality: 0.2)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        if let data = data {
            storageRef.putData(data, metadata: metadata) { (metadata, error) in
                if let error = error {
                    print("Error while uploading file: ", error)
                }

                if let metadata = metadata {
                    print("Metadata: ", metadata)
                }
            }
        }
    } // end upload
    
} // end class
