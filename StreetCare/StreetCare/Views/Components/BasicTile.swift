//
//  BasicTile.swift
//  StreetCare
//
//  Created by Michael on 4/10/23.
//

import SwiftUI

struct BasicTile: View {
    var size: CGSize
    var cornerRadius: CGFloat = 10
    var shadowRadiusSmall: CGFloat = 4
    var shadowRadiusLarge: CGFloat = 8
    var backgroundColor: Color = Color("BackgroundColor")
    var shadowOpacitySmall: Double = 0.08
    var shadowOpacityLarge: Double = 0.15
    var shadowYOffset: CGFloat = 6

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .foregroundColor(backgroundColor)
                .frame(width: size.width, height: size.height)
                .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.clear, lineWidth: 0.5))
                .shadow(color: Color.black.opacity(shadowOpacitySmall), radius: shadowRadiusSmall, x: 0, y: 0)
                .shadow(color: Color.black.opacity(shadowOpacityLarge), radius: shadowRadiusLarge, x: 0, y: shadowYOffset)
        }
    }
}

struct BasicTile_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BasicTile(size: CGSize(width: 165, height: 250))
            BasicTile(size: CGSize(width: 360, height: 520), cornerRadius: 16, shadowRadiusSmall: 6, shadowRadiusLarge: 12)
        }
        .previewLayout(.sizeThatFits)
    }
}
