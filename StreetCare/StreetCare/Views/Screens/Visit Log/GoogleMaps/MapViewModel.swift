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
    //@Published var hasLoadedInitialData = false
    
    private let eventDataAdapter = EventDataAdapter()
    
    
    
    func fetchMarkers() async {
            
            
            print("Fetching markers...")
            await MainActor.run {
                isLoading = true
            }
            
            eventDataAdapter.fetchMapMarkers { [weak self] success in
                Task { @MainActor in
                    self?.isLoading = false
                    
                    if success {
                        print("In fetchMarkers")
                        var mapOutreachEvents = self?.eventDataAdapter.mapOutreachEvents ?? []
                        print("mapOutreachEvents in MapViewModel --> \(mapOutreachEvents)")
                        self?.outreachEvents = mapOutreachEvents
                        
                        print("FetchMarkers --> \(self?.outreachEvents)")
                        self?.helpRequests = self?.eventDataAdapter.mapHelpRequests ?? []
                        //self?.hasLoadedInitialData = true
                    } else {
                        self?.error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch markers"])
                    }
                }
            }
        }
    }
    
    
    
//    func fetchMarkers() {
//        isLoading = true
//        
//        eventDataAdapter.fetchMapMarkers { [weak self] success in
//            
//                self?.isLoading = false
//                
//                if success {
//                    //save OutReachEvents and HelpRequest
//                    print("In fetchMarkers")
//                    var mapOutreachEvents = self?.eventDataAdapter.mapOutreachEvents ?? []
//                    print("mapOutreachEvents in MapViewModel --> \(mapOutreachEvents)")
//                    DispatchQueue.main.async {
//                        self?.outreachEvents = mapOutreachEvents
//                    }
//                    
//                    print("FetchMarkers --> \(self?.outreachEvents)")
//                    self?.helpRequests = self?.eventDataAdapter.mapHelpRequests ?? []
//                } else {
//                    self?.error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch markers"])
//                }
//            
//        }
//    }
//}
//Access this data in GoogleMapView in updateView
