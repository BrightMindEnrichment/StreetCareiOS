//
//  LinkData.swift
//  StreetCare
//
//  Created by Michael on 4/3/23.
//

import Foundation
import SwiftUI


struct LinkData: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let view: AnyView
}
