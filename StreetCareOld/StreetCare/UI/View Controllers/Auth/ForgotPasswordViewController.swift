//
//  ForgotPasswordViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 4/29/22.
//

import UIKit
import FirebaseAuth



class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var textEmail: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    
    @IBAction func buttonSendCode_touched(_ sender: Any) {
    
        // get user input
        guard let email = textEmail.text else {
            self.presentInformationAlertWithTitle("Oops...", message: "Missing required information.") { alertAction in }
            return
        }
        
        
        // show loading screen
        self.presentLoadingViewWithMessage("One moment...", withTimeoutOf: 10) {
            self.presentInformationAlertWithTitle("Oops...", message: "Something went wrong.  Please try again later.") { alertAction in
                self.dismissLoadingView()
            }
        }
        
    
        // try to send password reset
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            
            self.dismissLoadingView()
            
            if let _ = error {
                self.presentInformationAlertWithTitle("Oops...", message: "Error sending password email.") { alertAction in
                }
            }
            else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
                
    }
    
    
} // end class
