//
//  SplashInformativeViewController.swift
//  Sportsbook
//
//  Created by Claude on 05/06/2025.
//

import UIKit
import Combine
import FirebaseMessaging
import Reachability
import ServicesProvider

class SplashInformativeViewController: UIViewController {
    
    // MARK: - Private Properties
    private lazy var gradientView: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var brandImageView: UIImageView = Self.createBrandImageView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()
    private lazy var loadingMessageLabel: UILabel = Self.createLoadingMessageLabel()
    
    private var isLoadingBootDataSubscription: AnyCancellable?
    private var loadingCompleted: () -> Void
    private var reachability: Reachability?
    
    private var cancellables: Set<AnyCancellable> = []
    private var messageTimer: Timer?
    private var currentMessageIndex: Int = 0
    
    private let loadingMessages = [
        "Loading sports...",
        "Loading competitions...",
        "Loading featured matches...",
        "Preparing your experience..."
    ]
    
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
        setupSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureGradient()
        startMessageAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.reachability = try? Reachability()
        
        self.reachability?.whenUnreachable = { _ in
            let alert = UIAlertController(
                title: localized("no_internet"),
                message: localized("no_internet_connection_found_check_settings"),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        // Start theme
        ThemeService.shared.fetchThemeFromServer()
        
        // Load presentation configuration
        Env.presentationConfigurationStore.loadConfiguration()
        
        Env.sportsStore.activeSportsPublisher
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("activeSportsPublisher: completion \(completion)")
            } receiveValue: { [weak self] sportsLoadingState in
                print("Sports: \(sportsLoadingState)")
                
                switch sportsLoadingState {
                case .idle:
                    break
                case .loading:
                    break
                case .loaded(let sportsData):
                    self?.splashLoadingCompleted()
                case .failed:
                    break
                }
            }
            .store(in: &self.cancellables)
        
        Env.presentationConfigurationStore.loadState
            .sink { completion in
                print("configurationStore: completion \(completion)")
            } receiveValue: { configurationStore in
                print("configurationStore: \(configurationStore)")
            }
            .store(in: &self.cancellables)
        
        Env.servicesProvider.preFetchHomeContent()
            .sink { completion in
                print("preFetchHomeContent: completion \(completion)")
            } receiveValue: { preFetchHomeContent in
                print("preFetchHomeContent: \(preFetchHomeContent)")
            }
            .store(in: &self.cancellables)
        
        return
        
        // Original loading logic preserved but commented out
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
                if case .loaded = state {
                    return true
                }
                return false
            }
            .setFailureType(to: ServiceProviderError.self)
        )
        .map({ sportsLoadState, _, presentationConfigLoaded -> Bool in
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopMessageAnimation()
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
private extension SplashInformativeViewController {
    
    func setupSubviews() {
        view.addSubview(gradientView)
        view.addSubview(brandImageView)
        view.addSubview(loadingMessageLabel)
        view.addSubview(activityIndicatorView)
        
        initConstraints()
    }
    
    func initConstraints() {
        NSLayoutConstraint.activate([
            // Gradient View Constraints - Full screen
            gradientView.topAnchor.constraint(equalTo: view.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Brand Image View Constraints
            brandImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            brandImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            brandImageView.widthAnchor.constraint(equalToConstant: 140),
            brandImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // Loading Message Label Constraints
            loadingMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingMessageLabel.topAnchor.constraint(equalTo: brandImageView.bottomAnchor, constant: 20),
            loadingMessageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            loadingMessageLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // Activity Indicator View Constraints
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func configureGradient() {
        // Set gradient colors from bottom to top
        gradientView.colors = [
            (color: UIColor.App.backgroundGradientDark, location: 0.0),
            (color: UIColor.App.backgroundGradientLight, location: 1.0)
        ]
        
        gradientView.startPoint = CGPoint(x: 0.5, y: 1.0) // Bottom
        gradientView.endPoint = CGPoint(x: 0.5, y: 0.0)   // Top
    }
    
    func startMessageAnimation() {
        // Show first message immediately
        updateLoadingMessage()
        
        // Start timer to rotate messages
        messageTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateLoadingMessage()
        }
    }
    
    func stopMessageAnimation() {
        messageTimer?.invalidate()
        messageTimer = nil
    }
    
    func updateLoadingMessage() {
        guard !loadingMessages.isEmpty else { return }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.loadingMessageLabel.alpha = 0.0
        }) { _ in
            self.loadingMessageLabel.text = self.loadingMessages[self.currentMessageIndex]
            
            UIView.animate(withDuration: 0.3) {
                self.loadingMessageLabel.alpha = 1.0
            }
            
            self.currentMessageIndex = (self.currentMessageIndex + 1) % self.loadingMessages.count
        }
    }
    
}

// MARK: - Factory Methods
private extension SplashInformativeViewController {
    
    static func createBrandImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "brand_icon_variation_new")
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.tintColor = .white
        return imageView
    }
    
    static func createActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    static func createLoadingMessageLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = AppFont.with(type: .regular, size: 14)
        label.textColor = UIColor.App.textPrimary
        label.numberOfLines = 0
        label.alpha = 0.0
        return label
    }
    
}
