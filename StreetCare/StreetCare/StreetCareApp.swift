//
//  StreetCareApp.swift
//  StreetCare
//
//  Created by Michael on 3/26/23.
//

import SwiftUI
import Firebase
import GoogleSignIn


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        FirebaseApp.configure()

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
            MainTabBarView()
                .onOpenURL { url in
                          GIDSignIn.sharedInstance.handle(url)
                        }
                .environmentObject(userAuth)
                .navigationViewStyle(.stack)
        }
    }

}
