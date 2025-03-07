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


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        FirebaseApp.configure()

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
