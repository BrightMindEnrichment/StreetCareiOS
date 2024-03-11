//
//  Event.swift
//  StreetCare
//
//  Created by Michael on 5/5/23.
//

import Foundation

struct Badges: Codable, Hashable, Identifiable {
  var id = UUID()
  var objectId : Int
  var title: String
  var description: String
  var imageName: String
}
