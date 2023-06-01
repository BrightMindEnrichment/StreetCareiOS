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
    @IBOutlet weak var buttonRemoveAccount: UIButton!
    
    var db: Firestore?


    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = FirestoreSettings()

        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        updateUI()
        
        self.buttonLogin.setTitle(Language.locString("loginButtonTitle"), for: .normal)
        self.buttonSignUp.setTitle(Language.locString("signUpButtonTitle"), for: .normal)
        self.buttonSignOut.setTitle(Language.locString("logoutButtonTitle"), for: .normal)
        self.buttonRemoveAccount.setTitle(Language.locString("removeAccountButtonTitle"), for: .normal)
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
    
    
    
    @IBAction func buttonRemoveAccount_touched(_ sender: Any) {
  
        let alert = UIAlertController(title: "Are you sure?", message: "Delete yourself?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { alertAction in

            if let user = Auth.auth().currentUser {
                user.delete { error in
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    self.updateUI()
                }
            }
        }))
        
        self.present(alert, animated: true)
    }
    
    
    
    func updateUI() {
        
        textWelcome.text = Language.locString("welcome")
        
        if let user = Auth.auth().currentUser {
            
            if let db = db {
                print("user id \(user.uid)")
                let docRef = db.collection("users").document(user.uid)

                docRef.getDocument { doc, error in
                    if let doc = doc, doc.exists {
                        if let dict = doc.data(), let username = dict["username"] {
                            self.textWelcome.text = "\(Language.locString("welcome")) \(username)"
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

            buttonRemoveAccount.isUserInteractionEnabled = true
            buttonRemoveAccount.isHidden = false
        }
        else {
            buttonLogin.isUserInteractionEnabled = true
            buttonLogin.isHidden = false
            
            buttonSignUp.isUserInteractionEnabled = true
            buttonSignUp.isHidden = false
            
            buttonSignOut.isUserInteractionEnabled = false
            buttonSignOut.isHidden = true

            buttonRemoveAccount.isUserInteractionEnabled = false
            buttonRemoveAccount.isHidden = true

        }
    }
    
} // end class

