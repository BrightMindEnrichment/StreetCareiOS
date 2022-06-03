//
//  UIViewControllerExtensions.swift
//  StreetCare
//
//  Created by Michael Thornton on 4/29/22.
//

import Foundation
import UIKit


public extension UIViewController {
    
    
    /**
     Convience function to display a UIAlert when you don't need a colsure on dismissal.
     
     - Parameters:
     - title : UIAlert title
     - message : UIAlert message
     */
    func presentInformationAlertWithTitle(_ title: String?, message: String?, completion: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: completion))
        self.present(alert, animated: true, completion: nil)
    }

    
    
    /**
     Puts a blocking loading view over the entire View Controller.
     
     - Parameters:
     - message : Text to display on the loading view.
     - seconds : Number of seconds to automatically dismiss the loading view
     - timeout : Closure to call when the timeout has passed.  If the loading view gets dismissed by calling dismissLoadingView, the closure is never called.
     */
    func presentLoadingViewWithMessage(_ message: String?, withTimeoutOf seconds: Int, timeoutClosure timeout: @escaping () -> Void) {
        
        let loadingView = LoadingView.init(frame: .zero)
        loadingView.text = message
        loadingView.onTimeoutOf(seconds, runTimeoutClosure: timeout)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(loadingView)
        
        NSLayoutConstraint.activate([
            loadingView.topAnchor.constraint(equalTo: self.view.topAnchor),
            loadingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            loadingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
            ])
    }
    
    
    
    /**
     Searchs for any LoadingViews on the View Controller and removes them.  If there is timeout timer running, it is invalidated.
     */
    func dismissLoadingView() {
        
        for view in self.view.subviews {
            
            if let loadingView = view as? LoadingView {
                loadingView.done = true
                
                UIView.animate(withDuration: 0.5, animations: {
                    loadingView.alpha = 0.0
                }) { (done) in
                    loadingView.isHidden = true
                }
            }
        }
    }
    
} // end extension
