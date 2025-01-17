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
        
        print("Initializing Google Maps...")
        //GMSServices.provideAPIKey("AIzaSyDjWi5sE_do337K32ie9iZ7xdBjqGgTA54")
        GMSServices.provideAPIKey("AIzaSyBpaLVj2EjhjCeHbTUXfcBhBoaQLVathvE")
        print("Is Google Maps initialized")
        

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
