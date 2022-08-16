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

    private var isLoadingBootDataSubscription: AnyCancellable?
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

        self.isLoadingBootDataSubscription = Publishers.CombineLatest(Env.appSession.isLoadingAppSettingsPublisher,
                                                                  Env.userSessionStore.isLoadingUserSessionPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoadingAppSettings, isLoadingUserSession in
                if !isLoadingAppSettings && !isLoadingUserSession {
                    self?.splashLoadingCompleted()
                }
            }
    }

    func splashLoadingCompleted() {
        self.isLoadingBootDataSubscription = nil
        self.loadingCompleted()
    }

}
