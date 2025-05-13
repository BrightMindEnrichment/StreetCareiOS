//
//  RatingView.swift
//  StreetCare
//
//  Created by Michael Thornton on 6/21/23.
//

import SwiftUI

import SwiftUI

struct RatingView: View {
    
    @Binding var rating: Int
    var readOnly = false
    
    private let starIcon = "star.fill"
    
    private let colorFill = Color(red: 1.0, green: 0.671, blue: 0.0)
    private let colorEmpty = Color.gray.opacity(0.3)

    var body: some View {
        HStack(spacing: 20) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: starIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(i <= rating ? colorFill : colorEmpty)
                    .onTapGesture {
                        if !readOnly {
                            rating = i
                        }
                    }
            }
        }
        .padding()
    }
}
//Read-Only Rating View (used in detail views)
struct ReadOnlyRatingView: View {
    
    var rating: Int
    
    private let starIcon = "star.fill"
    
    private let colorFill = Color(red: 1.0, green: 0.671, blue: 0.0)
    private let colorEmpty = Color.gray.opacity(0.3)

    var body: some View {
        HStack(spacing: 20) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: starIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(i <= rating ? colorFill : colorEmpty)
            }
        }
        .padding()
    }
}
struct RatingView_Previews: PreviewProvider {
    
    @State static var rating = 3
    static var previews: some View {
        RatingView(rating: $rating)
    }
}
