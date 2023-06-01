//
//  WebView.swift
//  StreetCare
//
//  Created by Michael on 4/3/23.
//

import SwiftUI
import WebKit


struct WebView: UIViewRepresentable {
    
    var url: URL?
    
    
    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }
    

    func updateUIView(_ webView: WKWebView, context: Context) {
        if let url = url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    
} // end struct
