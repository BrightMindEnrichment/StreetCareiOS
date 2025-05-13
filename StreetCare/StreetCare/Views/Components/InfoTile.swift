//
//  InfoTile.swift
//  StreetCare
//
//  Created by Michael on 3/27/23.
//


import SwiftUI

struct InfoTile: View {

    var tile : ItemToBring
 
    var body: some View {
        ZStack {
            BasicTile(size: CGSize(width: 160, height: 240))
            VStack {
                Image(tile.imageName)
                Text(NSLocalizedString(tile.title, comment: "")).font(.body).padding()
            }
        }
    }
}

struct InfoTile_Previews: PreviewProvider {
    static var previews: some View {
        InfoTile(tile: ItemToBring(imageName: "Water", title: "water", description: "waterDescription"))
    }
}

