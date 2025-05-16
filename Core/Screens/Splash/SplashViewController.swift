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
import ServicesProvider

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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.reachability = try? Reachability()

        self.reachability?.whenUnreachable = { _ in
            let alert = UIAlertController(title: "No Internet",
                                          message: "No internet connection found. Please check your device settings and try again.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

        // Start theme
        ThemeService.shared.fetchThemeFromServer()

        // Load presentation configuration
        Env.presentationConfigurationStore.loadConfiguration()

        // Env.appSession.isLoadingAppSettingsPublisher,
        self.isLoadingBootDataSubscription = Publishers.CombineLatest3(
            Env.sportsStore.activeSportsPublisher,
            Env.servicesProvider.preFetchHomeContent(),
            Env.presentationConfigurationStore.loadState
                .map { state -> Bool in
                // Check if the presentation configuration is loaded
                if case .loaded = state {
                    return true // Configuration is loaded
                }
                return false // Configuration is not loaded yet or failed
            }
            .setFailureType(to: ServiceProviderError.self)
        )
        .map({ sportsLoadState, _, presentationConfigLoaded -> Bool in
            // Only return true if:
            // 1. Sports are loaded or failed (not loading or idle)
            // 2. Presentation configuration is loaded

            let sportsLoaded = sportsLoadState != .loading && sportsLoadState != .idle
            return sportsLoaded && presentationConfigLoaded
        })
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .finished:
                break
            case .failure(let failure):
                switch failure {
                case .invalidUserLocation:
                    self?.invalidLocationDetected()
                default:
                    break
                }
            }
        }, receiveValue: { [weak self] allRequirementsLoaded in
            if allRequirementsLoaded {
                self?.splashLoadingCompleted()
            }
        })
    }

    func splashLoadingCompleted() {
        self.isLoadingBootDataSubscription = nil
        self.loadingCompleted()
    }

    func invalidLocationDetected() {
        let forbiddenAccessViewController = ForbiddenLocationViewController()
        forbiddenAccessViewController.modalPresentationStyle = .fullScreen
        self.present(forbiddenAccessViewController, animated: false, completion: nil)
    }

}
