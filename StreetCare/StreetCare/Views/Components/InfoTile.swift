//
//  InfoTile.swift
//  StreetCare
//
//  Created by Michael on 3/27/23.
//

import SwiftUI

struct InfoTile: View {
    
    @State var imageName = ""
    @State var title = ""
    @State var description = ""
    
    var body: some View {

        ZStack {
            BasicTile(size: CGSize(width: 300.0, height: 400.0))

            VStack {
                    Image(imageName)
                    Text(title).font(.headline).padding()
                    Text(description).font(.body).padding()
                }
                .frame(width: 300.0, height: 400.0)
        }
    }
}

struct InfoTile_Previews: PreviewProvider {
    static var previews: some View {
        InfoTile(imageName: "Water", title: "Water", description: "Include items that are easy to chew and pack and nutritious, such as breakfast bars, beef jerky, and dried fruit. Pack food items in a ziplock bag separately from any scented sanitary products.")
    }
}
