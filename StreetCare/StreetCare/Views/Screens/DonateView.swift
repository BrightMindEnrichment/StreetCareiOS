//
//  DonateView.swift
//  StreetCare
//
//  Created by Michael on 4/6/23.
//

import SwiftUI
//https://streetcare.us/donations/

struct DonateView: View {
    
    var body: some View {
        WebView(url: URL(string: "https://streetcare.us/donations/"))
    }
}
