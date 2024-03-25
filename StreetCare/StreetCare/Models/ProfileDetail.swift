//
//  ProfileDetail.swift
//  StreetCare
//
//  Created by Michael Thornton on 6/1/23.
//

import Foundation


class ProfileDetail: ObservableObject, Identifiable {
    @Published var id = ""
    @Published var displayName = ""
    @Published var organization = ""
    @Published var country = ""
    @Published var email = ""

    var documentId = ""
}
