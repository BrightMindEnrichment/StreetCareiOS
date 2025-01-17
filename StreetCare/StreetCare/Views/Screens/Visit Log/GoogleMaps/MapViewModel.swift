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
        //        }catch{
        //            await MainActor.run {
        //                print("Unable to fetchMapMarkers -> \(error.localizedDescription)")
        //            }
        //        }
        
    }
    
    //            eventDataAdapter.fetchMapMarkers { [weak self] success in
    //                Task { @MainActor in
    //                    self?.isLoading = false
    //
    //                    if success {
    //                        print("In fetchMarkers")
    //                        var mapOutreachEvents = self?.eventDataAdapter.mapOutreachEvents ?? []
    //                        print("mapOutreachEvents in MapViewModel --> \(mapOutreachEvents)")
    //                        self?.outreachEvents = mapOutreachEvents
    //
    //                        print("FetchMarkers --> \(self?.outreachEvents)")
    //                        self?.helpRequests = self?.eventDataAdapter.mapHelpRequests ?? []
    //                        //self?.hasLoadedInitialData = true
    //                    } else {
    //                        self?.error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to fetch markers"])
    //                    }
    //                }
    //            }
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
