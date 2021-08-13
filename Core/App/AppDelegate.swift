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

    // TODO: Inegrate fastlamne

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Logger.log("App Started")

        FirebaseApp.configure()

        Auth.auth().signInAnonymously { (authResult, _) in
            guard let user = authResult?.user else { return }
            let isAnonymous = user.isAnonymous  // true
            let uid = user.uid
            print("FirebaseCore Auth UID \(uid) [isAnonymous:\(isAnonymous)]")
        }

        let realtimeClient = RealtimeSocketClient()

        self.window = UIWindow()

        window?.overrideUserInterfaceStyle = UserDefaults.standard.theme.userInterfaceStyle

        self.window!.rootViewController = RootViewController()
        self.window!.makeKeyAndVisible()

        return true
    }

}



