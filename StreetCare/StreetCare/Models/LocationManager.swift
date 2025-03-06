//
//  LocationManager.swift
//  StreetCare
//
//  Created by Michael Thornton on 6/12/23.
//

/*import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    let manager = CLLocationManager()

    var location: CLLocationCoordinate2D?

    var finished: () -> ()
    
    init(finished: @escaping () -> ()) {

        self.finished = finished
        
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("found location")
        location = locations.first?.coordinate
        self.finished()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("did not find locaiton")
        self.finished()
    }
}*/
import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let manager = CLLocationManager()
    @Published var location: CLLocationCoordinate2D?
    var finished: () -> ()

    init(finished: @escaping () -> ()) {
        self.finished = finished
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest // Ensures high accuracy
    }

    func requestLocation() {
        print("Requesting location...")

        let status = CLLocationManager.authorizationStatus()
        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            manager.requestLocation()
        } else {
            print("Location access denied or restricted")
            self.finished()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.first else {
            print("No valid location received.")
            self.finished()
            return
        }
        print("Location found: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
        self.location = loc.coordinate
        self.finished()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
        self.finished()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .notDetermined:
            print("Waiting for user permission...")
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access granted")
            requestLocation()
        case .denied, .restricted:
            print("Location access denied")
            self.finished()
        @unknown default:
            print("Unknown authorization status")
        }
    }
}
