//
//  LocationManager.swift
//  StreetCare
//
//  Created by Michael Thornton on 6/12/23.
//

import Foundation
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
}
