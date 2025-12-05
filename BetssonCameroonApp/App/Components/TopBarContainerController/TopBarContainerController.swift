//
//  TopBarContainerController.swift
//  BetssonCameroonApp
//
//  Created on 16/09/2025.
//

import UIKit
import Combine
import GomaUI

class TopBarContainerController: UIViewController {

    // MARK: - Core Components
    private let contentViewController: UIViewController
    private let contentContainerView = UIView()
    private let viewModel: TopBarContainerViewModel

    // MARK: - Top Bar Components
    private lazy var topSafeAreaView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.topBarGradient1
        return view
    }()

    private lazy var topBarContainerBaseView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundPrimary
        return view
    }()

    private lazy var multiWidgetToolbarView: MultiWidgetToolbarView = {
        return MultiWidgetToolbarView(viewModel: viewModel.multiWidgetToolbarViewModel)
    }()

    // MARK: - Overlay Components
    private lazy var overlayContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()

    private lazy var walletStatusOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.isHidden = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideWalletStatusOverlay))
        view.addGestureRecognizer(tapGesture)

        return view
    }()

    private lazy var walletStatusView: WalletStatusView = {
        let view = WalletStatusView(viewModel: viewModel.walletStatusViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Language Selector Overlay Components

    private lazy var languageSelectorOverlayView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.isHidden = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideLanguageSelectorOverlay))
        view.addGestureRecognizer(tapGesture)

        return view
    }()

    private lazy var languageSelectorView: LanguageSelectorView = {
        let view = LanguageSelectorView(
            viewModel: viewModel.languageSelectorViewModelProtocol,
            imageResolver: AppLanguageFlagImageResolver()
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var languageSelectorDismissCancellable: AnyCancellable?

    // MARK: - Navigation Callbacks
    var onLoginRequested: (() -> Void)?
    var onRegistrationRequested: (() -> Void)?
    var onProfileRequested: (() -> Void)?
    var onDepositRequested: (() -> Void)?
    var onWithdrawRequested: (() -> Void)?
    var onSupportRequested: (() -> Void)?
    var onDebugScreenRequested: (() -> Void)?

    // MARK: - Initialization
    init(contentViewController: UIViewController,
         viewModel: TopBarContainerViewModel) {
        self.contentViewController = contentViewController
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupConstraints()
        setupCallbacks()
        embedContentViewController()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return traitCollection.userInterfaceStyle == .dark ? .lightContent : .darkContent
    }

    // MARK: - Setup Methods
    private func setupHierarchy() {
        view.backgroundColor = UIColor.App.backgroundPrimary

        // Layer 1: Content (so we can have the bars on top of it)
        view.addSubview(contentContainerView)

        // Layer 2: Base views
        view.addSubview(topSafeAreaView)
        view.addSubview(topBarContainerBaseView)
        topBarContainerBaseView.addSubview(multiWidgetToolbarView)

        // Layer 3: Overlays (on top of everything)
        view.addSubview(overlayContainerView)
        overlayContainerView.addSubview(walletStatusOverlayView)
        walletStatusOverlayView.addSubview(walletStatusView)
        overlayContainerView.addSubview(languageSelectorOverlayView)
        languageSelectorOverlayView.addSubview(languageSelectorView)
    }

    private func setupConstraints() {
        // All views use Auto Layout
        [topSafeAreaView, topBarContainerBaseView, multiWidgetToolbarView,
         contentContainerView, overlayContainerView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            // Top Safe Area (covers notch)
            topSafeAreaView.topAnchor.constraint(equalTo: view.topAnchor),
            topSafeAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSafeAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSafeAreaView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            // Top Bar Container (contains toolbar)
            topBarContainerBaseView.topAnchor.constraint(equalTo: topSafeAreaView.bottomAnchor),
            topBarContainerBaseView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarContainerBaseView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // MultiWidget Toolbar (inside container)
            multiWidgetToolbarView.topAnchor.constraint(equalTo: topBarContainerBaseView.topAnchor),
            multiWidgetToolbarView.leadingAnchor.constraint(equalTo: topBarContainerBaseView.leadingAnchor),
            multiWidgetToolbarView.trailingAnchor.constraint(equalTo: topBarContainerBaseView.trailingAnchor),
            multiWidgetToolbarView.bottomAnchor.constraint(equalTo: topBarContainerBaseView.bottomAnchor),

            // Content Container (below top bar)
            contentContainerView.topAnchor.constraint(equalTo: topBarContainerBaseView.bottomAnchor),
            contentContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Overlay Container (FULL SCREEN)
            overlayContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Wallet Status Overlay (covers entire screen)
            walletStatusOverlayView.topAnchor.constraint(equalTo: overlayContainerView.topAnchor),
            walletStatusOverlayView.leadingAnchor.constraint(equalTo: overlayContainerView.leadingAnchor),
            walletStatusOverlayView.trailingAnchor.constraint(equalTo: overlayContainerView.trailingAnchor),
            walletStatusOverlayView.bottomAnchor.constraint(equalTo: overlayContainerView.bottomAnchor),

            // Wallet Status View (positioned below top bar)
            walletStatusView.leadingAnchor.constraint(equalTo: overlayContainerView.leadingAnchor, constant: 115),
            walletStatusView.trailingAnchor.constraint(equalTo: overlayContainerView.trailingAnchor, constant: -28),
            walletStatusView.topAnchor.constraint(equalTo: topBarContainerBaseView.bottomAnchor, constant: -9),

            // Language Selector Overlay (covers entire screen)
            languageSelectorOverlayView.topAnchor.constraint(equalTo: overlayContainerView.topAnchor),
            languageSelectorOverlayView.leadingAnchor.constraint(equalTo: overlayContainerView.leadingAnchor),
            languageSelectorOverlayView.trailingAnchor.constraint(equalTo: overlayContainerView.trailingAnchor),
            languageSelectorOverlayView.bottomAnchor.constraint(equalTo: overlayContainerView.bottomAnchor),

            // Language Selector View (centered below top bar)
            languageSelectorView.leadingAnchor.constraint(equalTo: overlayContainerView.leadingAnchor, constant: 32),
            languageSelectorView.trailingAnchor.constraint(equalTo: overlayContainerView.trailingAnchor, constant: -32),
            languageSelectorView.topAnchor.constraint(equalTo: topBarContainerBaseView.bottomAnchor, constant: 16)
        ])
    }

    private func embedContentViewController() {
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false

        
        addChild(contentViewController)
        contentContainerView.addSubview(contentViewController.view)

        contentViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentViewController.view.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            contentViewController.view.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            contentViewController.view.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            contentViewController.view.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])

        contentViewController.didMove(toParent: self)

        // Inject reference so content can trigger overlays if needed
        contentViewController.topBarContainer = self
    }

    private func setupCallbacks() {
        // Widget selection handling
        multiWidgetToolbarView.onWidgetSelected = { [weak self] widgetId in
            self?.handleWidgetSelection(widgetId)
        }

        // Wallet balance tap handling
        multiWidgetToolbarView.onBalanceTapped = { [weak self] widgetId in
            print("💰 WALLET_TAP: TopBarContainerController received balance tap with widgetId: \(widgetId)")
            if widgetId == .wallet {
                print("💰 WALLET_TAP: widgetId matches .wallet, showing overlay")

                // Add haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()

                self?.showWalletStatusOverlay()
                print("💰 WALLET_TAP: showWalletStatusOverlay() called")
            } else {
                print("💰 WALLET_TAP: widgetId '\(widgetId)' does NOT match .wallet, ignoring")
            }
        }

        // Deposit button tap handling
        multiWidgetToolbarView.onDepositTapped = { [weak self] widgetId in
            if widgetId == .wallet {
                print("💳 TopBarContainer: Deposit button tapped")
                self?.onDepositRequested?()
            }
        }

        // Connect ViewModel deposit callback chain
        viewModel.multiWidgetToolbarViewModel.onDepositRequested = { [weak self] in
            print("💳 TopBarContainer: ViewModel deposit requested")
            self?.onDepositRequested?()
        }

        // Setup wallet navigation callbacks
        viewModel.walletStatusViewModel.onDepositRequested = { [weak self] in
            self?.onDepositRequested?()
        }

        viewModel.walletStatusViewModel.onWithdrawRequested = { [weak self] in
            self?.onWithdrawRequested?()
        }

        // Secret logo tap for debug screen
        multiWidgetToolbarView.onLogoSecretTapped = { [weak self] in
            self?.onDebugScreenRequested?()
        }
    }

    // MARK: - Widget Selection Handling
    private func handleWidgetSelection(_ widgetId: WidgetTypeIdentifier) {
        switch widgetId {
        case .loginButton:
            print("🔐 TopBarContainer: Login requested")
            onLoginRequested?()
        case .joinButton:
            print("📝 TopBarContainer: Registration requested")
            onRegistrationRequested?()
        case .avatar:
            print("👤 TopBarContainer: Profile requested")
            onProfileRequested?()
        case .languageSwitcher:
            showLanguageSelectorOverlay()
        case .support:
            print("❓ TopBarContainer: Support requested")
            onSupportRequested?()
        default:
            print("🔧 TopBarContainer: Widget selected: \(widgetId)")
        }
    }

    // MARK: - Public API for Overlays
    func showWalletStatusOverlay() {
        overlayContainerView.isUserInteractionEnabled = true
        walletStatusOverlayView.alpha = 0
        walletStatusView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        walletStatusOverlayView.isHidden = false

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.walletStatusOverlayView.alpha = 1.0
            self.walletStatusView.transform = CGAffineTransform.identity
        }
    }

    @objc private func hideWalletStatusOverlay(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: walletStatusOverlayView)
        let walletViewFrame = walletStatusView.frame

        // Only dismiss if tap is outside the wallet status view
        if !walletViewFrame.contains(location) {
            UIView.animate(withDuration: 0.2, animations: {
                self.walletStatusOverlayView.alpha = 0.0
                self.walletStatusView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                self.walletStatusOverlayView.isHidden = true
                self.overlayContainerView.isUserInteractionEnabled = false
            }
        }
    }

    func showLanguageSelectorOverlay() {
        // Add haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()

        // Prepare language selector via ViewModel
        viewModel.prepareLanguageSelector()

        // Subscribe to dismiss signal from ViewModel
        languageSelectorDismissCancellable = viewModel.shouldDismissLanguageSelectorPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.hideLanguageSelectorOverlayAnimated()
            }

        // Show overlay with animation
        overlayContainerView.isUserInteractionEnabled = true
        languageSelectorOverlayView.alpha = 0
        languageSelectorView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        languageSelectorOverlayView.isHidden = false

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.languageSelectorOverlayView.alpha = 1.0
            self.languageSelectorView.transform = CGAffineTransform.identity
        }
    }

    @objc private func hideLanguageSelectorOverlay(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: languageSelectorOverlayView)
        let selectorViewFrame = languageSelectorView.frame

        // Only dismiss if tap is outside the language selector view
        if !selectorViewFrame.contains(location) {
            hideLanguageSelectorOverlayAnimated()
        }
    }

    private func hideLanguageSelectorOverlayAnimated() {
        languageSelectorDismissCancellable?.cancel()
        languageSelectorDismissCancellable = nil

        UIView.animate(withDuration: 0.2, animations: {
            self.languageSelectorOverlayView.alpha = 0.0
            self.languageSelectorView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.languageSelectorOverlayView.isHidden = true
            self.overlayContainerView.isUserInteractionEnabled = false
        }
    }

    func showDepositPopup() {
        // Can show a half-screen modal or custom popup
        // For now, just trigger the deposit callback
        onDepositRequested?()
    }

    // MARK: - Custom Popup Support
    func showCustomPopup(_ viewController: UIViewController, animated: Bool = true) {
        viewController.modalPresentationStyle = .pageSheet

        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }

        present(viewController, animated: animated)
    }
}

// MARK: - Settings Routing
private extension TopBarContainerController {
    func presentLanguageSettingsConfirmation() {
        let title = localized("set_your_app_language")
        let message = localized("language_settings_message")

        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let openAction = UIAlertAction(title: localized("open_settings"), style: .default) { _ in
            DispatchQueue.main.async {
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString),
                      UIApplication.shared.canOpenURL(settingsURL) else {
                    return
                }
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
        }

        let cancelAction = UIAlertAction(title: localized("cancel"), style: .cancel)

        alertController.addAction(openAction)
        alertController.addAction(cancelAction)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let presenter = self.presentedViewController ?? self
            presenter.present(alertController, animated: true)
        }
    }
}
