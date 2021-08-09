//
//  AppDelegate.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/07/2021.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()

        //Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
        
        Auth.auth().signInAnonymously { (authResult, _) in
            guard let user = authResult?.user else { return }
            let isAnonymous = user.isAnonymous  // true
            let uid = user.uid
            print("FirebaseCore Auth UID \(uid) [isAnonymous:\(isAnonymous)]")
        }
        
        self.window = UIWindow()

        window?.overrideUserInterfaceStyle = UserDefaults.standard.theme.userInterfaceStyle

        self.window!.rootViewController = RootViewController()
        self.window!.makeKeyAndVisible()

        return true
    }

}


