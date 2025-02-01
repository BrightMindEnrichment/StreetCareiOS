//
//  LandingScreenViewModel.swift
//  StreetCare
//
//  Created by Kevin Phillips on 2/1/25.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

class LandingScreenViewModel: ObservableObject {
    @Published var bannerData: BannerData? = nil
    @Published var isBannerVisible: Bool = true
    
    private var db = Firestore.firestore()

    init() {
        fetchBannerData()
    }

    func fetchBannerData() {
        let documentName = isAppLanguageSpanish() ? "banner_data_es" : "banner_data"
        
        db.collection("page_content").document(documentName).getDocument { snapshot, error in
            if let error = error {
                print("Error fetching banner data: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot, snapshot.exists {
                do {
                    let data = try snapshot.data(as: BannerData.self)
                    DispatchQueue.main.async {
                        self.bannerData = data
                    }
                } catch {
                    print("Error decoding banner data: \(error.localizedDescription)")
                }
            }
        }
    }
    
    var shouldShowBanner: Bool {
        guard isBannerVisible, let banner = bannerData else { return false }
        return !banner.body.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func dismissBanner() {
        isBannerVisible = false
    }
    
    func isAppLanguageSpanish() -> Bool {
        guard let languageCode = Locale.preferredLanguages.first else { return false }
        return languageCode.starts(with: "es")
    }
}

struct BannerData: Codable, Identifiable {
    @DocumentID var id: String?
    let header: String
    let subHeader: String
    let body: String

    enum CodingKeys: String, CodingKey {
        case header
        case subHeader = "sub_header"
        case body
    }
}
