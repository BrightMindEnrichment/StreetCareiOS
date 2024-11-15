//
//  MapViewModel.swift
//  StreetCare
//
//  Created by Amey Kanunje on 10/31/24.
//

import Foundation
import CoreLocation

//To manage the map and retrieve data from EventAdapter
class MapViewModel: ObservableObject {
    @Published var outreachEvents: [(location: CLLocationCoordinate2D, title: String, description: String?)] = []
    @Published var helpRequests: [(location: CLLocationCoordinate2D, helpType: String, description: String?)] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let eventDataAdapter = EventDataAdapter()
    
    func fetchMarkers() {
        isLoading = true
        
        eventDataAdapter.fetchMapMarkers { [weak self] success in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if success {
                    //save OutReachEvents and HelpRequest
                    print("In fetchMarkers")
                    self?.outreachEvents = self?.eventDataAdapter.mapOutreachEvents ?? []
                    print("FetchMarkers --> \(self?.outreachEvents)")
                    self?.helpRequests = self?.eventDataAdapter.mapHelpRequests ?? []
                } else {
                    self?.error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch markers"])
                }
            }
        }
    }
}
//Access this data in GoogleMapView in updateView
