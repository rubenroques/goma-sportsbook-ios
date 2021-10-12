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

    // TODO: Integrate fastlane
    var window: UIWindow?
    var bootstrap: Bootstrap!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        Logger.log("App Started")

        // Store device id
        if !UserDefaults.standard.isKeyPresentInUserDefaults(key: "device_id") {
            let deviceId = UIDevice.current.identifierForVendor?.uuidString
            Logger.log("Device ID: \(deviceId ?? "")")
            UserDefaults.standard.set(deviceId!, forKey: "device_id")
        }

        FirebaseConfiguration.shared.setLoggerLevel(.min)

        FirebaseApp.configure()

        Auth.auth().signInAnonymously { authResult, _ in
            guard let user = authResult?.user else { return }
            let isAnonymous = user.isAnonymous  // true
            let uid = user.uid
            print("FirebaseCore Auth UID \(uid) [isAnonymous:\(isAnonymous)]")
        }

        self.window = UIWindow()

        self.bootstrap = Bootstrap(router: Router(window: self.window!))

        self.bootstrap.boot()

        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        if !Env.userSessionStore.shouldRecordUserSession {
            Env.userSessionStore.logout()
        }
    }

}
