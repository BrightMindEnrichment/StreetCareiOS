//
//  AppDescriptionView.swift
//  StreetCare
//
//  Created by Kevin Phillips on 2/19/25.
//

import Foundation
import SwiftUI

struct AppDescriptionView: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Your toolkit to help homeless individuals")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color("TextColor"))
                .padding(.top, 15)
                .padding(.bottom, 10)
            
            Text("Street Care is brought to you by homelessness care experts to share tools that will enable you to provide transformative help to homeless families and individuals.")
                .foregroundColor(Color("TextColor"))
        }
    }
}

struct AppDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        AppDescriptionView()
    }
}
