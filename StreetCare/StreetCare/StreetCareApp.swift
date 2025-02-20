//
//  StreetCareApp.swift
//  StreetCare
//
//  Created by Michael on 3/26/23.
//

import SwiftUI
import Firebase
import GoogleSignIn
import GoogleMaps


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        FirebaseApp.configure()
        
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path),
           let googleMapsAPIKey = dict["GoogleMapsAPIKey"] as? String,
           !googleMapsAPIKey.isEmpty {
            GMSServices.provideAPIKey(googleMapsAPIKey)
            print("Google Maps initialized :: googleMapsAPIKey :: " + googleMapsAPIKey)
            AppSettings.shared.mapsAvailable = true
        } else {
            print("Error: Google Maps API key not found in Secrets.plist. Disabling map features.")
            AppSettings.shared.mapsAvailable = false
        }

        if let uid = Auth.auth().currentUser?.uid {
            print("User : \(uid)")
        }
        
        return true
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
