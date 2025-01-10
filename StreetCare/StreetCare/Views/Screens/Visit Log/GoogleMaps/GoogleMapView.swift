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
        
        
        let camera = GMSCameraPosition(
            latitude: 42.333774,
            longitude: -71.064937,
            zoom: 13.0
        )
        
        // Configure map view
        let mapView = GMSMapView(frame: .zero)
        mapView.camera = camera
        
        // Enable user interaction
        mapView.mapType = .normal
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        mapView.delegate = context.coordinator
        
        // Add zoom controls
        let zoomControlView = UIView(frame: CGRect(x: 16, y: 100, width: 40, height: 100))
        zoomControlView.backgroundColor = .clear
        
        // Zoom in button
        let zoomInButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        zoomInButton.backgroundColor = .white
        zoomInButton.layer.cornerRadius = 20
        zoomInButton.setTitle("+", for: .normal)
        zoomInButton.setTitleColor(.black, for: .normal)
        zoomInButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
        zoomInButton.layer.shadowColor = UIColor.black.cgColor
        zoomInButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        zoomInButton.layer.shadowOpacity = 0.2
        zoomInButton.layer.shadowRadius = 2
        zoomInButton.addTarget(context.coordinator, action: #selector(Coordinator.zoomIn), for: .touchUpInside)
        
        // Zoom out button
        let zoomOutButton = UIButton(frame: CGRect(x: 0, y: 50, width: 40, height: 40))
        zoomOutButton.backgroundColor = .white
        zoomOutButton.layer.cornerRadius = 20
        zoomOutButton.setTitle("−", for: .normal)
        zoomOutButton.setTitleColor(.black, for: .normal)
        zoomOutButton.titleLabel?.font = .systemFont(ofSize: 24, weight: .medium)
        zoomOutButton.layer.shadowColor = UIColor.black.cgColor
        zoomOutButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        zoomOutButton.layer.shadowOpacity = 0.2
        zoomOutButton.layer.shadowRadius = 2
        zoomOutButton.addTarget(context.coordinator, action: #selector(Coordinator.zoomOut), for: .touchUpInside)
        
        zoomControlView.addSubview(zoomInButton)
        zoomControlView.addSubview(zoomOutButton)
        mapView.addSubview(zoomControlView)
        
        viewModel.mapView = mapView
        
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
            marker.icon = GMSMarker.markerImage(with: UIColor(named: "OutReachEvents"))
            marker.map = mapView
        }
        
        // Add help request markers (red)
        for request in viewModel.helpRequests {
            let marker = GMSMarker(position: request.location)
            marker.title = request.identification
            marker.snippet = request.description
            marker.icon = GMSMarker.markerImage(with: .red)
            marker.map = mapView
        }
        
        // If we have markers, adjust camera to show them all
        if !viewModel.outreachEvents.isEmpty || !viewModel.helpRequests.isEmpty {
            let bounds = GMSCoordinateBounds()
            
            for event in viewModel.outreachEvents {
                bounds.includingCoordinate(event.location)
            }
            
            for request in viewModel.helpRequests {
                bounds.includingCoordinate(request.location)
            }
            
            let update = GMSCameraUpdate.fit(bounds, withPadding: 100.0)
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
        
        @objc func zoomIn() {
            guard let mapView = parent.viewModel.mapView else { return }
            mapView.animate(toZoom: mapView.camera.zoom + 1)
        }
        
        @objc func zoomOut() {
            guard let mapView = parent.viewModel.mapView else { return }
            mapView.animate(toZoom: mapView.camera.zoom - 1)
        }
        // Handle marker taps
        func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
            // You can add custom marker tap handling here
            return false
        }
    }
    
}
