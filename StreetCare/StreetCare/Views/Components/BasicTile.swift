//
//  BasicTile.swift
//  StreetCare
//
//  Created by Michael on 4/10/23.
//

import SwiftUI

struct BasicTile: View {
    
    var size: CGSize
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2.0)
                .foregroundColor(Color("BackgroundColor"))
                .frame(width: size.width, height: size.height)
                .overlay(RoundedRectangle(cornerRadius: 2.0).stroke(Color.clear, lineWidth: 0.5))
                .shadow(radius: 1.0)
        }
        
    } // end body
} // end struct



struct BasicTile_Previews: PreviewProvider {
    static var previews: some View {
        BasicTile(size: CGSize(width: 165, height: 250))
    }
}
