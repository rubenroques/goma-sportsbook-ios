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

    // TODO: Integrate fastlamne

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Logger.log("App Started")

        // Store device id
        if !UserDefaults.standard.isKeyPresentInUserDefaults(key: "device_id") {
            let deviceId = UIDevice.current.identifierForVendor?.uuidString
            print("Device ID: \(deviceId as Any)")
            UserDefaults.standard.set(deviceId!, forKey: "device_id")
        }

        FirebaseApp.configure()

        Auth.auth().signInAnonymously { authResult, _ in
            guard let user = authResult?.user else { return }
            let isAnonymous = user.isAnonymous  // true
            let uid = user.uid
            print("FirebaseCore Auth UID \(uid) [isAnonymous:\(isAnonymous)]")
        }

        self.window = UIWindow()

        window?.overrideUserInterfaceStyle = UserDefaults.standard.theme.userInterfaceStyle

        self.window!.rootViewController = PermissionAccessViewController()

        self.window!.makeKeyAndVisible()

        return true
    }

}
