//
//  RatingView.swift
//  StreetCare
//
//  Created by Michael Thornton on 6/21/23.
//

import SwiftUI

struct RatingView: View {
    
    @Binding var rating: Int
    var readOnly = false
    
    private let starFilled = "star.fill"
    private let starEmpty = "star"
    
    private let colorFill = Color.yellow
    private let colorEmpty = Color.gray
    
    var body: some View {
        
        HStack {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= rating ? starFilled : starEmpty)
                    .foregroundColor(i <= rating ? colorFill : colorEmpty)
                    .onTapGesture {
                        if !readOnly {
                            rating = i
                        }
                    }
            }
        }
    } // end body
    
        
    
} // end struct

struct RatingView_Previews: PreviewProvider {
    
    @State static var rating = 3
    static var previews: some View {
        RatingView(rating: $rating)
    }
}
