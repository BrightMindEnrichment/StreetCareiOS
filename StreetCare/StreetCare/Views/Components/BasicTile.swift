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
            RoundedRectangle(cornerRadius: 16.0)
                .foregroundColor(Color("BackgroundColor"))
                .frame(width: size.width, height: size.height)
                .overlay(RoundedRectangle(cornerRadius: 16.0).stroke(Color.gray, lineWidth: 1))
                .shadow(radius: 2.0)
        }
        
    } // end body
} // end struct



struct BasicTile_Previews: PreviewProvider {
    static var previews: some View {
        BasicTile(size: CGSize(width: 300.0, height: 400.0))
    }
}
