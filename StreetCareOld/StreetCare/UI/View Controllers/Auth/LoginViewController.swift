//
//  LoginViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 4/29/22.
//

import UIKit
import FirebaseAuth


class LoginViewController: UIViewController {

    
    @IBOutlet weak var textEmail: UITextField!
    @IBOutlet weak var textPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    @IBAction func buttonLogin_touched(_ sender: UIButton) {
        
        self.presentLoadingViewWithMessage("One moment...", withTimeoutOf: 30) {
            // if timeout:
            self.presentInformationAlertWithTitle("Oops...", message: "Please try again later.") { alertAction in
                self.dismissLoadingView()
            }
            return
        }
        
        
        // get the user input
        guard let email = textEmail.text, let password = textPassword.text else {
            self.presentInformationAlertWithTitle("Oops...", message: "Missing some required information") { alertAction in
                self.dismissLoadingView()
            }
            return
        }

        // try to log in
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            
            if let error = error {
                self.presentInformationAlertWithTitle("Oops...", message: "Error with login: \(error.localizedDescription)") { alertAction in
                    self.dismissLoadingView()
                }
            }
            else {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
} // end class
