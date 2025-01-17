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
            zoom: 12.0
        )
        
        // Configure map view
        let mapView = GMSMapView(frame: .zero)
        mapView.camera = camera
        
        // Enable user interaction
        mapView.mapType = .normal
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        mapView.delegate = context.coordinator
        mapView.settings.compassButton = true
        //mapView.settings.myLocationButton = true
        
        // Create zoom buttons container
                let containerView = UIView()
                containerView.translatesAutoresizingMaskIntoConstraints = false
                
                // Create zoom in button
                let zoomInButton = UIButton()
                zoomInButton.translatesAutoresizingMaskIntoConstraints = false
                zoomInButton.backgroundColor = .white
                zoomInButton.setTitle("+", for: .normal)
                zoomInButton.setTitleColor(.black, for: .normal)
                zoomInButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .medium)
                zoomInButton.layer.cornerRadius = 2
                zoomInButton.layer.shadowColor = UIColor.black.cgColor
                zoomInButton.layer.shadowOpacity = 0.3
                zoomInButton.layer.shadowOffset = CGSize(width: 0, height: 2)
                zoomInButton.addTarget(context.coordinator, action: #selector(Coordinator.zoomIn), for: .touchUpInside)
                
                // Create zoom out button
                let zoomOutButton = UIButton()
                zoomOutButton.translatesAutoresizingMaskIntoConstraints = false
                zoomOutButton.backgroundColor = .white
                zoomOutButton.setTitle("-", for: .normal)
                zoomOutButton.setTitleColor(.black, for: .normal)
                zoomOutButton.titleLabel?.font = .systemFont(ofSize: 22, weight: .medium)
                zoomOutButton.layer.cornerRadius = 2
                zoomOutButton.layer.shadowColor = UIColor.black.cgColor
                zoomOutButton.layer.shadowOpacity = 0.3
                zoomOutButton.layer.shadowOffset = CGSize(width: 0, height: 2)
                zoomOutButton.addTarget(context.coordinator, action: #selector(Coordinator.zoomOut), for: .touchUpInside)
                
                // Add buttons to container
                containerView.addSubview(zoomInButton)
                containerView.addSubview(zoomOutButton)
                
                // Add container to map
                mapView.addSubview(containerView)
                
                // Setup constraints
                NSLayoutConstraint.activate([
                    containerView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -5),
                    containerView.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20),
                    containerView.widthAnchor.constraint(equalToConstant: 40),
                    containerView.heightAnchor.constraint(equalToConstant: 100),
                    
                    zoomInButton.topAnchor.constraint(equalTo: containerView.topAnchor),
                    zoomInButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                    zoomInButton.widthAnchor.constraint(equalToConstant: 40),
                    zoomInButton.heightAnchor.constraint(equalToConstant: 40),
                    
                    zoomOutButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                    zoomOutButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                    zoomOutButton.widthAnchor.constraint(equalToConstant: 40),
                    zoomOutButton.heightAnchor.constraint(equalToConstant: 40)
                ])
        
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
            marker.icon = GMSMarker.markerImage(with: .systemYellow)
            marker.map = mapView
        }
        
        // Add help request markers (red)
        for request in viewModel.helpRequests {
            let marker = GMSMarker(position: request.location)
            marker.title = request.identification
            marker.snippet = request.description
            marker.icon = GMSMarker.markerImage(with: UIColor(Color.red))
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
