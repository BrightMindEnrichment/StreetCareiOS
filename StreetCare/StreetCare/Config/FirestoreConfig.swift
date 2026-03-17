//
//  FirestoreConfig.swift
//  StreetCare
//
//  Created by Angie on 2026/3/17.
//

import Foundation

enum FirestoreEnvironment: String {
    case development
    case production

    private static let infoPlistKey = "FirestoreEnvironment"

    static var current: FirestoreEnvironment {
        if let rawValue = Bundle.main.object(forInfoDictionaryKey: infoPlistKey) as? String,
           let environment = FirestoreEnvironment(normalizing: rawValue) {
            return environment
        }

        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    init?(normalizing rawValue: String) {
        switch rawValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "dev", "debug", "development":
            self = .development
        case "prod", "production", "release":
            self = .production
        default:
            return nil
        }
    }
}
/* TODO: Migrate Firestore collections
 */
struct FirestoreCollectionNames {
    let interactionHelpRequests: String
    let interactionLogs: String
  
    static var current: FirestoreCollectionNames {
        FirestoreEnvironment.current.collections
    }
}

private extension FirestoreEnvironment {
    var collections: FirestoreCollectionNames {
        switch self {
        case .development:
            // Staging currently reuses the non-production collection set.
            return FirestoreCollectionNames(
                interactionHelpRequests: "HelpRequestDev",
                interactionLogs: "InteractionLogDev",
            )
        case .production:
            return FirestoreCollectionNames(
                interactionHelpRequests: "HelpRequest",
                interactionLogs: "InteractionLog",
            )
        }
    }
}
