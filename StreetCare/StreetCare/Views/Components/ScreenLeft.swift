//
//  TextScreenLeft.swift
//  StreetCare
//
//  Created by Michael Thornton on 6/18/23.
//

import SwiftUI


struct ScreenLeft: ViewModifier {
    
    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
        }
    }
}



extension View {
    func screenLeft() -> some View {
        modifier(ScreenLeft())
    }
}
