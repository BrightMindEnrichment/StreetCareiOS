//
//  ProfileViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/2/22.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift


class ProfileViewController: UIViewController {

    @IBOutlet weak var buttonLogin: UIButton!
    @IBOutlet weak var buttonSignUp: UIButton!
    @IBOutlet weak var buttonSignOut: UIButton!
    @IBOutlet weak var textWelcome: UILabel!
    
    var db: Firestore?


    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = FirestoreSettings()

        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
    }
    


    @IBAction func buttonSignOut_touched(_ sender: Any) {
                
        if let _ = Auth.auth().currentUser {
            do {
                try Auth.auth().signOut()
                updateUI()
            }
            catch {
                Log.Log("\(error.localizedDescription)")
            }
            
        }
    }
    
    
    
    func updateUI() {
        
        textWelcome.text = "Welcome"
        
        if let user = Auth.auth().currentUser {
            
            if let db = db {
                let docRef = db.collection("users").document(user.uid)

                docRef.getDocument { doc, error in
                    if let doc = doc, doc.exists {
                        if let dict = doc.data(), let username = dict["username"] {
                            self.textWelcome.text = "Welcome \(username)"
                        }
                    }
                }
            }            
            
            buttonLogin.isUserInteractionEnabled = false
            buttonLogin.isHidden = true
            
            buttonSignUp.isUserInteractionEnabled = false
            buttonSignUp.isHidden = true
            
            buttonSignOut.isUserInteractionEnabled = true
            buttonSignOut.isHidden = false
        }
        else {
            buttonLogin.isUserInteractionEnabled = true
            buttonLogin.isHidden = false
            
            buttonSignUp.isUserInteractionEnabled = true
            buttonSignUp.isHidden = false
            
            buttonSignOut.isUserInteractionEnabled = false
            buttonSignOut.isHidden = true
        }
    }
    
} // end class
