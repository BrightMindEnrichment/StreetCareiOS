//
//  InputTileConsent.swift
//  StreetCare
//
//  Created by Rinal on 11/3/25.
//

import SwiftUI

struct InputTileConsent: View {
    var size: CGSize
    var submitAction: () -> ()
    
    @State private var isAgreed: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Header
            //Text("Log your Interaction")
              //  .font(.title2)
              //  .fontWeight(.bold)
              //  .padding(.top, 24)
              //  .padding(.bottom, 40)
            
            // Tile Background
            ZStack {
                BasicTile(size: CGSize(width: size.width, height: size.height))
                
                VStack(alignment: .leading, spacing: 25) {
                    
                    // Checkbox + Consent text
                    HStack(alignment: .top, spacing: 12) {
                        // Checkbox
                        Button(action: {
                            isAgreed.toggle()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 24, height: 24)
                                    .background(isAgreed ? Color.black : Color.clear)
                                if isAgreed {
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 14, height: 14)
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        .alignmentGuide(.top) { d in d[.top] } // keeps checkbox top-aligned

                        // Text
                        Text("""
                        By selecting this checkbox, I consent to sharing my contact details and event address publicly on this platform community space. I understand that this information will be visible to others and acknowledge the associated privacy considerations.
                        """)
                            .font(.body)
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center) // center align text
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 16)
                    
                    // Submit Button
                    Button(action: {
                        submitAction()
                    }) {
                        Text("SUBMIT")
                            .fontWeight(.bold)
                            .padding(.horizontal, 28)   // ⬅️ controls width
                            .padding(.vertical, 12)
                            .background(Color.black)
                            .foregroundColor(.yellow)
                            .cornerRadius(24)           // ⬅️ pill shape
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .disabled(!isAgreed)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Consent")
        .frame(width: size.width, height: size.height)
        .padding(.top, 36)
        Spacer()
    }
}

#Preview {
    InputTileConsent(
        size: CGSize(width: 350, height: 300),
        submitAction: {}
    )
}
