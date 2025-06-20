//
//  MapViewModel.swift
//  StreetCare
//
//  Created by Amey Kanunje on 10/31/24.
//

import Foundation
import CoreLocation
import GoogleMaps

class MapViewModel: ObservableObject {
    @Published var outreachEvents: [(location: CLLocationCoordinate2D, title: String, description: String?)] = []
    @Published var helpRequests: [(location: CLLocationCoordinate2D, helpType: String, description: String?)] = []
    @Published var mapVisitLogs: [(CLLocationCoordinate2D, String, String?)] = []
    @Published var isLoading = false
    @Published var error: Error?
    weak var mapView: GMSMapView?
    private let eventDataAdapter = EventDataAdapter()
    
    @MainActor
    func fetchMarkers() async {
        isLoading = true
        let success = await eventDataAdapter.fetchMapMarkers()
        if success {
            outreachEvents = eventDataAdapter.mapOutreachEvents
            // helpRequests = eventDataAdapter.mapHelpRequests
            print("✅ outreachEvents Count in ViewModel -> \(outreachEvents.count)")
            print("✅ helpRequests Count in ViewModel -> \(helpRequests.count)")
        } else {
            print("❌ Failure to fetch map markers in ViewModel")
        }
        
        // Now fetch visit logs
        eventDataAdapter.fetchPublicVisitLogLocations { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.mapVisitLogs = self?.eventDataAdapter.mapVisitLogs ?? []
                    print("✅ mapVisitLogs Count in ViewModel -> \(self?.mapVisitLogs.count ?? 0)")
                case .failure(let error):
                    self?.error = error
                    print("❌ Failed to fetch public visit logs: \(error.localizedDescription)")
                }
                self?.isLoading = false
            }
        }
    }
}
