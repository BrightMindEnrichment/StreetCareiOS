//
//  GoogleMapView.swift
//  StreetCare
//
//  Created by Amey Kanunje on 10/15/24.
//

import SwiftUI
import GoogleMaps


struct GoogleMapView: UIViewRepresentable {
    
    @ObservedObject var viewModel: MapViewModel
    
    func makeUIView(context: Context) -> GMSMapView {
        print("Making UIView for Google Maps...")
        
        // Define map coordinates (using Sydney for testing)
        let camera = GMSCameraPosition(
            latitude: -33.86,  // Sydney coordinates
            longitude: 151.20,
            zoom: 15
        )
        
        // Configure map view
        let mapView = GMSMapView(frame: .zero)
        mapView.camera = camera
        
        //            // Debug: Add visual markers
        //            let marker = GMSMarker()
        //            marker.position = camera.target
        //            marker.title = "Sydney"
        //            marker.snippet = "Australia"
        //            marker.map = mapView
        
        // Enable user interaction
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        mapView.delegate = context.coordinator
        
        print("Map view created with camera position: \(camera.target)")
        return mapView
    }
    
    //Update View
    func updateUIView(_ mapView: GMSMapView, context: Context) {
        print("Updating map with outreach events: \(viewModel.outreachEvents.count)")
        print("Updating map with help requests: \(viewModel.helpRequests.count)")
        
        //clear map view
        mapView.clear()
        
        // Add outreach event markers (orange)
        for event in viewModel.outreachEvents {
            let marker = GMSMarker(position: event.location)
            print("Marker from GMSMarker --> \(marker)")
            marker.title = event.title
            marker.snippet = event.description
            marker.icon = GMSMarker.markerImage(with: .orange)
            marker.map = mapView
        }
        
        // Add help request markers (red)
        for request in viewModel.helpRequests {
            let marker = GMSMarker(position: request.location)
            marker.title = request.helpType
            marker.snippet = request.description
            marker.icon = GMSMarker.markerImage(with: .red)
            marker.map = mapView
        }
        
        // If we have markers, adjust camera to show them all
        if !viewModel.outreachEvents.isEmpty || !viewModel.helpRequests.isEmpty {
            let bounds = GMSCoordinateBounds(coordinate: viewModel.outreachEvents.first?.location ??
                                             viewModel.helpRequests.first?.location ??
                                             mapView.camera.target,
                                             coordinate: viewModel.outreachEvents.first?.location ??
                                             viewModel.helpRequests.first?.location ??
                                             mapView.camera.target)
            
            for event in viewModel.outreachEvents {
                bounds.includingCoordinate(event.location)
            }
            
            for request in viewModel.helpRequests {
                bounds.includingCoordinate(request.location)
            }
            
            let update = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
            mapView.animate(with: update)
        }
    }
    
    // Add Coordinator for handling map interactions
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    class Coordinator: NSObject, GMSMapViewDelegate {
        var parent: GoogleMapView
        
        init(_ parent: GoogleMapView) {
            self.parent = parent
        }
        
        // Handle marker taps
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            // You can add custom marker tap handling here
            return false
        }
    }
    
}
