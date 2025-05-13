//
//  StreetCareApp.swift
//  StreetCare
//
//  Created by Michael on 3/26/23.
//

import SwiftUI
import Firebase
import GoogleSignIn
import UIKit
import GooglePlaces
import GoogleMaps


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        FirebaseApp.configure()
        
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let googleMapsAPIKey = dict["GoogleMapsAPIKey"] as? String,
           !googleMapsAPIKey.isEmpty {
            print("Google Maps initialiing with :: googleMapsAPIKey :: " + googleMapsAPIKey)
            GMSServices.provideAPIKey(googleMapsAPIKey)
            testGoogleMapsAPIKey { isValid in
                if isValid {
                    AppSettings.shared.mapsAvailable = true
                    print("Google Maps initialized successfully")
                } else {
                    AppSettings.shared.mapsAvailable = false
                    print("Google Maps invalid api key.")
                }
            }
        } else {
            print("Error: Google Maps API key not found in Secrets.plist. Disabling map features.")
            AppSettings.shared.mapsAvailable = false
        }

        if let uid = Auth.auth().currentUser?.uid {
            print("User : \(uid)")
        }
        // Load API Key from Secrets.plist
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let keys = NSDictionary(contentsOfFile: path),
           let apiKey = keys["API_KEY"] as? String {
            GMSPlacesClient.provideAPIKey(apiKey)
            print("✅ Google Places API Key Loaded Successfully")
        } else {
            print("❌ Failed to load Google Places API Key") 
        }
        
        return true
    }
}

func testGoogleMapsAPIKey(completion: @escaping (Bool) -> Void) {
    // Using New York City as a test location
    let testCoordinate = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
    let geocoder = GMSGeocoder()
    
    geocoder.reverseGeocodeCoordinate(testCoordinate) { response, error in
        if let error = error {
            print("Google Maps test call error: \(error.localizedDescription)")
            completion(false)
        } else if let placemark = response?.firstResult(), placemark.lines != nil {
            completion(true)
        } else {
            completion(false)
        }
    }
}

@main
struct StreetCareApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var userAuth: UserAuthModel =  UserAuthModel()

    var body: some Scene {
        WindowGroup {
            SplashView()
                        .onOpenURL { url in
                            GIDSignIn.sharedInstance.handle(url)
                        }
                        .environmentObject(userAuth)
                        .navigationViewStyle(.stack)
        }
    }

}

final class AppSettings {
    static let shared = AppSettings()
    var mapsAvailable: Bool = false
    
    private init() { }
}
