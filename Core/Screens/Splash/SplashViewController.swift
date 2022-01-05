//
//  SplashViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/09/2021.
//

import UIKit
import Combine
import FirebaseMessaging

class SplashViewController: UIViewController {

    private var isLoadingUserSessionSubscription: AnyCancellable?
    private var loadingCompleted: () -> Void

    init(loadingCompleted: @escaping () -> Void) {
        self.loadingCompleted = loadingCompleted
        
        super.init(nibName: "SplashViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        Logger.log("Starting connections")

        self.isLoadingUserSessionSubscription = Env.userSessionStore.isLoadingUserSessionPublisher
            .sink { isLoadingUserSession in
                if !isLoadingUserSession {
                    self.splashLoadingCompleted()
                }
            }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func splashLoadingCompleted() {
        self.isLoadingUserSessionSubscription = nil
        self.loadingCompleted()
    }

}
