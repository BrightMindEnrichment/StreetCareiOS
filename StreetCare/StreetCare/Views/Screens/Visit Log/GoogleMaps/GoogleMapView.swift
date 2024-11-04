//
//  GoogleMapView.swift
//  StreetCare
//
//  Created by Amey Kanunje on 10/15/24.
//

import SwiftUI
import GoogleMaps

struct GoogleMapView: UIViewRepresentable {
    @Binding var markers: [GMSMarker]
    
    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: 40.7128, longitude: -74.0060, zoom: 12.0)
        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        return mapView
    }
    
    func updateUIView(_ uiView: GMSMapView, context: Context) {
        uiView.clear()
        for marker in markers {
            marker.map = uiView
        }
    }
}

//#Preview {
//    GoogleMapView(markers: <#Binding<[GMSMarker]>#>)
//}
