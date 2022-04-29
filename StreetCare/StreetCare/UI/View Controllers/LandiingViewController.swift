//
//  LandiingViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 4/28/22.
//

import UIKit
import FirebaseAuth


class LandiingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let user = Auth.auth().currentUser {
            // user already logged in
            print(user.uid)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "mainTabBarController") as? UITabBarController {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
} // end class
