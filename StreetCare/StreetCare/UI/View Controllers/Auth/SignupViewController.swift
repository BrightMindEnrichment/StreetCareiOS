//
//  SignupViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 4/28/22.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift


class SignupViewController: UIViewController {
    
    @IBOutlet weak var textUsername: UITextField!
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    @IBOutlet weak var textOrganization: UITextField!
    
    
    var db: Firestore?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = FirestoreSettings()

        Firestore.firestore().settings = settings
        db = Firestore.firestore()
    }
    


    @IBAction func buttonSignUp_touched(_ sender: UIButton) {
        
        
        // setup loading view - don't forget to dismiss it when errors happen!
        self.presentLoadingViewWithMessage("Creating user", withTimeoutOf: 10) {
            // if timeout:
            self.presentInformationAlertWithTitle(Language.errorTitle, message: "Timeout creating account.  Please try again later.") { alertAction in
                self.dismissLoadingView()
            }
        }
        
        
        // make user all required fields have data
        guard let email = textEmail.text, let password = textPassword.text , let username = textUsername.text else {
            self.presentInformationAlertWithTitle(Language.errorTitle, message: "Missing required information.") { alertAction in
                self.dismissLoadingView()
            }
            return
        }
        

        // create the user in firestore auth
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            
            guard let db = self.db, let user = authResult?.user, error == nil else {
                self.presentInformationAlertWithTitle(Language.errorTitle, message: "Problem creating user : \(error!.localizedDescription)") { alertAction in
                    self.dismissLoadingView()
                }
                return
            }
            
            print("created \(user.uid)")
            
            // data saved to user record
            var userData = [String: Any]()
            userData["dateCreated"] = Date()
            userData["deviceType"] = "iOS"
            userData["email"] = email
            userData["isValid"] = true
            userData["organization"] = nil
            userData["uid"] = user.uid
            userData["username"] = username
            
            db.collection("users").document(user.uid).setData(userData) { err in
                if let err = err {
                    // don't bother user with this error
                    print(err.localizedDescription)
                } else {
                    print("Document successfully written!")
                }
                
                self.dismissLoadingView()
                self.navigationController?.popViewController(animated: true)
            }
            
        }
    }
    

}
