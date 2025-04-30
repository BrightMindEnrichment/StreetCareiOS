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
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(Color("BackgroundColor"))
                .frame(width: size.width, height: size.height)
                .overlay(RoundedRectangle(cornerRadius: 2.0).stroke(Color.clear, lineWidth: 0.5))
                //.shadow(color: .gray.opacity(0.5), radius: 2, x: 0, y: 2)
                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 0)
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 6)
        }
        
    } // end body
} // end struct



struct BasicTile_Previews: PreviewProvider {
    static var previews: some View {
        BasicTile(size: CGSize(width: 165, height: 250))
    }
}
