//
//  LandiingViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 4/28/22.
//

import UIKit
import FirebaseAuth


class LandiingViewController: UIViewController {

    
    override func viewWillAppear(_ animated: Bool) {
        if let user = Auth.auth().currentUser {
            // user already logged in
            print(user.uid)
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "mainTabBarController") as? UITabBarController {
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first as? UIWindowScene
                let window = windowScene?.windows.first { $0.isKeyWindow }
                window?.replaceRootViewControllerWith(vc, animated: true, completion: nil)
            }
        }
    }
    
} // end class
