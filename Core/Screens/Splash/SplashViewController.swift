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

    // MARK: - Private Properties
    private lazy var brandImageView: UIImageView = Self.createBrandImageView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()

    private var isLoadingBootDataSubscription: AnyCancellable?
    private var loadingCompleted: () -> Void
    private var reachability: Reachability?

    init(loadingCompleted: @escaping () -> Void) {
        self.loadingCompleted = loadingCompleted

        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(named: "backgroundPrimary")
        setupSubviews()
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

        #if DEBUG
        self.splashLoadingCompleted()
        return
        #endif
        
        // Env.appSession.isLoadingAppSettingsPublisher,
        self.isLoadingBootDataSubscription = Publishers.CombineLatest3(
            Env.sportsStore.activeSportsPublisher.map({ input in
                return input
            }),
            Env.servicesProvider.preFetchHomeContent().map({ input in
                return input
            }),
            Env.presentationConfigurationStore.loadState.map({ input in
                return input
            })
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

// MARK: - Private Methods
private extension SplashViewController {
    
    func setupSubviews() {
        view.addSubview(brandImageView)
        view.addSubview(activityIndicatorView)
        
        initConstraints()
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            // Brand Image View Constraints
            brandImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            brandImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            brandImageView.widthAnchor.constraint(equalTo: brandImageView.heightAnchor, multiplier: 1.0),
            brandImageView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: -100),
            brandImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 1000),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(greaterThanOrEqualTo: brandImageView.trailingAnchor, constant: 50),
            
            // Activity Indicator View Constraints
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: activityIndicatorView.bottomAnchor, constant: 16)
        ])
    }
    
}

// MARK: - Factory Methods
private extension SplashViewController {
    
    static func createBrandImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "brand_icon_variation_new")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        return imageView
    }
    
    static func createActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = UIColor.label
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
}
