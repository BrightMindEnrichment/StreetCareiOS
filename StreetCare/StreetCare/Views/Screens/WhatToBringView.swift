

//  WhatToBringView.swift
//  StreetCare
//
//  Created by Michael on 4/3/23.
//

import SwiftUI
import ExytePopupView

struct ItemToBring: Identifiable, Equatable {
    let imageName: String
    let title: String
    let description: String
    let id = UUID()
}

struct WhatToBringView: View {
    @State var presentAlert = false
    @State var selectedInfoTile: ItemToBring?
    let columns = [
        GridItem(.fixed(160)),
        GridItem(.fixed(160))
    ]

    let itemsToBring: [ItemToBring] = [
        ItemToBring(imageName: "Food", title: "healthySnacks", description: "healthySnacksDescription"),
        ItemToBring(imageName: "Water", title: "water", description: "waterDescription"),
        ItemToBring(imageName: "DoctorsBag", title: "firstAid", description: "firstAidDescription"),
        ItemToBring(imageName: "PersonalHygyne", title: "personalHygiene", description: "personalHygieneDescription"),
        ItemToBring(imageName: "Cloth", title: "socksClothing", description: "socksClothingDescription"),
        ItemToBring(imageName: "Woman", title: "feminineHygiene", description: "feminineHygieneDescription")
    ]
    
    var body: some View {
            ScrollView {
                Text("featuredItems").font(.title2.bold()).padding()
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(itemsToBring) { item in
                        InfoTile(tile: item).onTapGesture {
                                withAnimation {
                                    presentAlert = true
                                    selectedInfoTile = item
                            }
                        }
                    }
                    }  .alert(isPresented: $presentAlert) {
                        Alert(
                            title: Text(NSLocalizedString(selectedInfoTile!.title, comment: "") + "\n").font(.title),
                            message: Text(NSLocalizedString(selectedInfoTile!.description, comment: "") + "\n").font(.title).bold(),
                            dismissButton: .default(Text(NSLocalizedString("ok", comment: "")).bold().foregroundColor(.green))
                        )
                    }
                }.navigationTitle("whattoBringAndGive")
    }
}

struct WhatToBringView_Previews: PreviewProvider {
    static var previews: some View {
        WhatToBringView()
    }
}
