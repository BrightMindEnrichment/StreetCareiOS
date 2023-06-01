//
//  YoutubeCellView.swift
//  StreetCare
//
//  Created by Michael on 4/3/23.
//

import SwiftUI

struct YoutubeCellView: View {

    var item: VideoInformation
    
    var body: some View {
        
        VStack {
            AsyncImage(url: URL(string: item.thumbnailURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            
            Text(item.title)
        }
    } // end body
} // end struct

