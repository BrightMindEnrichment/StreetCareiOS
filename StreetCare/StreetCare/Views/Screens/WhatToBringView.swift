
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
    @State var showingPopup = false

    let columns = [
        GridItem(.fixed(160)),
        GridItem(.fixed(160))
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
            ScrollView {
                Text("Featured Items").font(.title2.bold()).padding()
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(itemsToBring) { item in
                        InfoTile(tile: item).onTapGesture {
                            print("tapped")
                            Button(action: {
                                showingPopup = true
                            }, label: {
                            }).popup(isPresented: $showingPopup) {
                                Text("The popup")
                                    .frame(width: 200, height: 60)
                                    .background(Color(red: 0.85, green: 0.8, blue: 0.95))
                                    .cornerRadius(30.0)
                            } customize: {
                                $0.autohideIn(2)
                            }
                        }
                    }
                }
            }
        }
}

struct WhatToBringView_Previews: PreviewProvider {
    static var previews: some View {
        WhatToBringView()
    }
}
