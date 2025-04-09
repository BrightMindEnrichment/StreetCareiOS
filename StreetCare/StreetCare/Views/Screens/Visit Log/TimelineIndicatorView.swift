//
//  TimelineIndicatorView.swift
//  StreetCare
//
//  Created by Nandipati Oohasripriya on 3/26/25.
//

import SwiftUI

struct TimelineIndicatorView: View {
    var isFirst: Bool = false
    var isLast: Bool = false

    var body: some View {
        VStack(spacing: 0) { // No spacing so we control it manually
            
            // 🔼 Top Line
            if !isFirst {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 2, height: 60) // taller to reach the circle
                    .offset(x: 10)
                    .padding(.bottom, -35) // pull the line up toward the circle
            } else {
                Spacer(minLength: 25) // top margin for the first item
            }

            // 🟡 Circle
            Circle()
                .fill(Color.yellow)
                .frame(width: 10, height: 10)
                .offset(x: -15, y: 35) // customized position

            // 🔽 Bottom Line
            if !isLast {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 2, height: 50)
                    .offset(x: 10)
                    .padding(.top, -35) // pull it up to connect to the dot
            } else {
                Spacer(minLength: 20)
            }
        }
        .frame(width: 30)
        .padding(.top, 5)
    }
}
