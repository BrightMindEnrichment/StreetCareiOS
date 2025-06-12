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
            Text(NSLocalizedString("yourToolkitToHelpHomelessIndividuals", comment: ""))
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(Color("TextColor"))
                .padding(.top, 15)
                .padding(.bottom, 10)
            
            Text(NSLocalizedString("streetCareDescText", comment: ""))
                .foregroundColor(Color("TextColor"))
        }
    }
}

struct AppDescriptionView_Previews: PreviewProvider {
    static var previews: some View {
        AppDescriptionView()
    }
}
