//
//  WhatToBringView.swift
//  StreetCare
//
//  Created by Michael on 4/3/23.
//

import SwiftUI

struct ItemToBring: Identifiable {
    let imageName: String
    let title: String
    let description: String
    let id = UUID()
}

struct WhatToBringView: View {
    let rows = [
        GridItem(.flexible(minimum: 300.0)),
    ]

    let itemsToBring: [ItemToBring] = [
        ItemToBring(imageName: "Food", title: "healthySnacks", description: "healthySnacksDescription"),
        ItemToBring(imageName: "Water", title: "water", description: "waterDescription"),
        ItemToBring(imageName: "DoctorsBag", title: "firstAid", description: "firstAidDescription"),
        ItemToBring(imageName: "PersonalHygyne", title: "personalHygiene", description: "personalHygieneDescription"),
        ItemToBring(imageName: "Shirt", title: "socksClothing", description: "socksClothingDescription"),
        ItemToBring(imageName: "Woman", title: "feminineHygiene", description: "feminineHygieneDescription")
    ]
    
    
    var body: some View {

        ScrollView(.horizontal) {
            LazyHGrid(rows: rows) {
                HStack {
                    ForEach(itemsToBring) { item in
                        InfoTile(imageName: item.imageName, title: NSLocalizedString(item.title, comment: ""), description:
                                    NSLocalizedString(item.description, comment: ""))
                    }
                }
            }.padding()
        }
    }
}

struct WhatToBringView_Previews: PreviewProvider {
    static var previews: some View {
        WhatToBringView()
    }
}
