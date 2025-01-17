//
//  WebViewController.swift
//  StreetCare
//
//  Created by Michael Thornton on 5/4/22.
//

import UIKit
import WebKit


class WebViewController: UIViewController {

    @IBOutlet var webView: WKWebView!
    
    
    var youtubeId: String?
    
    
    override func viewWillAppear(_ animated: Bool) {
        if let youtubeId = youtubeId, let youtubeURL = URL(string: "https://www.youtube.com/embed/\(youtubeId)") {
            webView.load(URLRequest(url: youtubeURL))
        }
    }

} // end class
