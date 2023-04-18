//
//  SplashViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 28/09/2021.
//

import UIKit
import Combine
import FirebaseMessaging
import Reachability

class SplashViewController: UIViewController {

    private var isLoadingBootDataSubscription: AnyCancellable?
    private var loadingCompleted: () -> Void
    private var reachability: Reachability?

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

        self.reachability = try? Reachability()

        self.reachability?.whenUnreachable = { _ in
            let alert = UIAlertController(title: "No Internet",
                                          message: "No internet connection found. Please check your device settings and try again.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

        // Env.appSession.isLoadingAppSettingsPublisher,
        self.isLoadingBootDataSubscription = Env.sportsStore.isLoadingSportTypesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self]  isLoadingSportTypes in
                if !isLoadingSportTypes {
                    self?.splashLoadingCompleted()
                }
            }
    }

    func splashLoadingCompleted() {
        self.isLoadingBootDataSubscription = nil
        self.loadingCompleted()
    }

}
