//
//  MapViewModel.swift
//  StreetCare
//
//  Created by Amey Kanunje on 10/31/24.
//

import Foundation
import CoreLocation
import GoogleMaps

//To manage the map and retrieve data from EventAdapter
class MapViewModel: ObservableObject {
    @Published var outreachEvents: [(location: CLLocationCoordinate2D, title: String, description: String?)] = []
    @Published var helpRequests: [(location: CLLocationCoordinate2D, identification: String?, description: String?)] = []
    @Published var isLoading = false
    @Published var error: Error?
    weak var mapView: GMSMapView?
    //@Published var hasLoadedInitialData = false
    
    private let eventDataAdapter = EventDataAdapter()
    
    
    
    @MainActor func fetchMarkers() async {
        isLoading = true
        
        do{
            
            let success = await eventDataAdapter.fetchMapMarkers()
            
            if success {
                outreachEvents = eventDataAdapter.mapOutreachEvents
                helpRequests = eventDataAdapter.mapHelpRequests
                isLoading = false
                print("OutReachEvent Count in ViewModel -> \(outreachEvents.count)")
            }else{
                print("Failure to fetchMapMarkers in ViewModel")
            }
        }
    }
}
