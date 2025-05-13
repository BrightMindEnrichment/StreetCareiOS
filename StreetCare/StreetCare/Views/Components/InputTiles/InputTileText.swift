//
//  InputTileText.swift
//  StreetCare
//
//  Created by Shaik Saheer on 12/05/25.
//

import Foundation
import SwiftUI

struct InputTileText: View {
    var questionNumber: Int
    var totalQuestions: Int
    var question: String
    var placeholderText: String
    @Binding var textValue: String

    var nextAction: () -> Void
    var previousAction: () -> Void
    var skipAction: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            SegmentedProgressBar(totalSegments: totalQuestions, filledSegments: questionNumber, tileWidth: 300)

            Text(question)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)

            TextEditor(text: $textValue)
                .padding()
                .frame(height: 150)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))

            Text(placeholderText)
                .font(.caption)
                .foregroundColor(.gray)

            HStack(spacing: 12) {
                Button("Back") {
                    previousAction()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.3))
                .cornerRadius(8)

                Button("Skip") {
                    skipAction()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange.opacity(0.3))
                .cornerRadius(8)

                Button("Next") {
                    nextAction()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
    }
}
