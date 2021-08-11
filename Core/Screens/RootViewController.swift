//
//  RootViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 20/07/2021.
//

import UIKit
import Combine

class RootViewController: UIViewController {

    var showingDebug: Bool = false
    var networkClient: NetworkManager
    var cancellables = Set<AnyCancellable>()

    init() {
        networkClient = Env.networkManager
        
        super.init(nibName: "RootViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.Core.tint
    }

    @IBAction func didTapAPITest() {

        let endpoint = GomaGamingService.test
        networkClient.requestEndpoint(deviceId: Env.deviceId, endpoint: endpoint)
            .sink(receiveCompletion: {
                    print ("Received completion: \($0).")
            },
                  receiveValue: {
                    user in print ("Received user: \(user).")
                  }
            )
            .store(in: &cancellables)

    }

}

extension RootViewController {

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)


        // Do any additional setup after loading the view.
        AnalyticsClient.logEvent(event: .login)


        let limit = TargetVariables.featureFlags.limitCheckoutItems
        //print("Target config flags \(limit)")

        Logger.log("Target config flags \(limit)")


        if showingDebug {
            return
        }

        Logger.log("Debug screen called")

        showingDebug = true

        if TargetVariables.environmentType == .dev {
            if motion == .motionShake {

                let debugViewController = DebugViewController()
                debugViewController.isBeingDismissedAction = { [weak self] _ in
                    self?.showingDebug = false
                }
                let navigationController = UINavigationController(rootViewController: debugViewController)
                navigationController.modalPresentationStyle = .fullScreen

                self.present(navigationController, animated: true, completion: nil)
            }
        }

    }
    
}
