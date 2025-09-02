//
//  MyBetDetailViewController.swift
//  BetssonCameroonApp
//
//  Created by Assistant on 01/09/2025.
//

import UIKit
import Combine
import GomaUI

final class MyBetDetailViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let viewModel: MyBetDetailViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
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
        let view = MultiWidgetToolbarView(viewModel: viewModel.multiWidgetToolbarViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var customNavigationView: UIView = Self.createCustomNavigationView()
    private lazy var betDetailsTitleLabel: UILabel = Self.createBetDetailsTitleLabel()
    private lazy var backButton: UIButton = Self.createBackButton()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var loadingView: UIView = Self.createLoadingView()
    private lazy var errorView: UIView = Self.createErrorView()
    
    // Wallet Status UI Components
    private lazy var walletStatusView: WalletStatusView = {
        let view = WalletStatusView(viewModel: viewModel.walletStatusViewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
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
    
    // MARK: - Authentication Navigation Closures
    
    var onLoginRequested: (() -> Void)?
    var onRegistrationRequested: (() -> Void)?
    var onProfileRequested: (() -> Void)?
    
    // MARK: - Initialization
    
    init(viewModel: MyBetDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupActions()
        setupMultiWidgetToolbarView()
        
        // Load initial data
        viewModel.loadBetDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    // MARK: - Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return traitCollection.userInterfaceStyle == .dark ? .lightContent : .darkContent
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = UIColor.App.backgroundPrimary
        
        setupViewHierarchy()
        setupConstraints()
    }
    
    private func setupViewHierarchy() {
        // Add topSafeAreaView first (covers notch)
        view.addSubview(topSafeAreaView)
        
        // Add topBarContainerBaseView (contains toolbar)
        view.addSubview(topBarContainerBaseView)
        topBarContainerBaseView.addSubview(multiWidgetToolbarView)
        
        // Rest of the hierarchy
        view.addSubview(customNavigationView)
        view.addSubview(mainStackView)
        view.addSubview(loadingView)
        view.addSubview(errorView)
        
        // Add wallet overlay on top of everything
        view.addSubview(walletStatusOverlayView)
        walletStatusOverlayView.addSubview(walletStatusView)
        
        customNavigationView.addSubview(betDetailsTitleLabel)
        customNavigationView.addSubview(backButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // TopSafeAreaView (covers notch area)
            topSafeAreaView.topAnchor.constraint(equalTo: view.topAnchor),
            topSafeAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSafeAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSafeAreaView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            // TopBarContainerBaseView (contains toolbar)
            topBarContainerBaseView.topAnchor.constraint(equalTo: topSafeAreaView.bottomAnchor),
            topBarContainerBaseView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarContainerBaseView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            // MultiWidget Toolbar (inside container)
            multiWidgetToolbarView.topAnchor.constraint(equalTo: topBarContainerBaseView.topAnchor),
            multiWidgetToolbarView.leadingAnchor.constraint(equalTo: topBarContainerBaseView.leadingAnchor),
            multiWidgetToolbarView.trailingAnchor.constraint(equalTo: topBarContainerBaseView.trailingAnchor),
            multiWidgetToolbarView.bottomAnchor.constraint(equalTo: topBarContainerBaseView.bottomAnchor),
            
            // Custom Navigation View (below toolbar container)
            customNavigationView.topAnchor.constraint(equalTo: topBarContainerBaseView.bottomAnchor),
            customNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavigationView.heightAnchor.constraint(equalToConstant: 56),
            
            // Bet Details Title Label
            betDetailsTitleLabel.centerXAnchor.constraint(equalTo: customNavigationView.centerXAnchor),
            betDetailsTitleLabel.centerYAnchor.constraint(equalTo: customNavigationView.centerYAnchor),
            
            // Back Button (Left side)
            backButton.leadingAnchor.constraint(equalTo: customNavigationView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: customNavigationView.centerYAnchor),
            backButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            backButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            
            // Main Stack View (Content area)
            mainStackView.topAnchor.constraint(equalTo: customNavigationView.bottomAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            // Loading View
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Error View  
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Wallet Status Overlay (covers entire screen)
            walletStatusOverlayView.topAnchor.constraint(equalTo: view.topAnchor),
            walletStatusOverlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            walletStatusOverlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            walletStatusOverlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Wallet Status View (EXACT RootTabBar positioning)
            walletStatusView.leadingAnchor.constraint(equalTo: walletStatusOverlayView.leadingAnchor, constant: 50),
            walletStatusView.trailingAnchor.constraint(equalTo: walletStatusOverlayView.trailingAnchor, constant: -32),
            walletStatusView.topAnchor.constraint(equalTo: topBarContainerBaseView.bottomAnchor, constant: 16)
        ])
    }
    
    private func setupBindings() {
        // Display state binding
        viewModel.$displayState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(displayState: displayState)
            }
            .store(in: &cancellables)
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
    }
    
    private func setupMultiWidgetToolbarView() {
        multiWidgetToolbarView.onWidgetSelected = { [weak self] widgetID in
            self?.handleWidgetSelection(widgetID)
        }
        
        multiWidgetToolbarView.onBalanceTapped = { [weak self] widgetID in
            self?.handleBalanceTapped(widgetID)
        }
    }
    
    // MARK: - Rendering
    
    private func render(displayState: MyBetDetailDisplayState) {
        switch displayState {
        case .loading:
            showLoadingState()
        case .loaded:
            showContentState()
        case .error(let message):
            showErrorState(message: message)
        }
    }
    
    private func showLoadingState() {
        loadingView.isHidden = false
        errorView.isHidden = true
        mainStackView.isHidden = true
        customNavigationView.isHidden = false
    }
    
    private func showContentState() {
        loadingView.isHidden = true
        errorView.isHidden = true
        mainStackView.isHidden = false
        customNavigationView.isHidden = false
    }
    
    private func showErrorState(message: String) {
        loadingView.isHidden = true
        errorView.isHidden = false
        mainStackView.isHidden = true
        customNavigationView.isHidden = false
        
        // Update error message
        if let label = errorView.subviews.first(where: { $0 is UILabel }) as? UILabel {
            label.text = message
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapBack() {
        viewModel.handleBackTap()
    }
    
    @objc private func didTapRetry() {
        viewModel.refreshBetDetails()
    }
    
    private func handleWidgetSelection(_ widgetID: String) {
        switch widgetID {
        case "loginButton":
            print("🔐 MyBetDetail: Login requested")
            onLoginRequested?()
        case "joinButton":
            print("🔐 MyBetDetail: Registration requested")
            onRegistrationRequested?()
        case "avatar":
            print("👤 MyBetDetail: Profile requested")
            onProfileRequested?()
        default:
            print("🔧 MyBetDetail: Widget selected: \(widgetID)")
        }
    }
    
    private func handleBalanceTapped(_ widgetID: String) {
        if widgetID == "wallet" {
            print("💰 MyBetDetail: Wallet balance tapped")
            
            // Add haptic feedback
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            showWalletStatusOverlay()
        }
    }
    
    private func showWalletStatusOverlay() {
        walletStatusOverlayView.alpha = 0
        walletStatusView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        walletStatusOverlayView.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseOut) {
            self.walletStatusOverlayView.alpha = 1.0
            self.walletStatusView.transform = CGAffineTransform.identity
        }
    }
    
    @objc private func hideWalletStatusOverlay() {
        UIView.animate(withDuration: 0.2, animations: {
            self.walletStatusOverlayView.alpha = 0.0
            self.walletStatusView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { _ in
            self.walletStatusOverlayView.isHidden = true
        }
    }
}

// MARK: - Factory Methods

extension MyBetDetailViewController {
    
    private static func createCustomNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundPrimary
        
        // Add bottom separator line
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = StyleProvider.Color.separatorLine
        
        view.addSubview(separatorView)
        
        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        return view
    }
    
    private static func createBetDetailsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Bet Details"
        label.font = StyleProvider.fontWith(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        return label
    }
    
    private static func createBackButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Use standard iOS back arrow icon
        let backImage = UIImage(systemName: "chevron.left")
        button.setImage(backImage, for: .normal)
        button.tintColor = StyleProvider.Color.highlightPrimary
        
        return button
    }
    
    private static func createLoadingView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundPrimary
        view.isHidden = true
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        spinner.color = StyleProvider.Color.textSecondary
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Loading bet details..."
        label.textAlignment = .center
        label.font = StyleProvider.fontWith(type: .medium, size: 16)
        label.textColor = StyleProvider.Color.textSecondary
        
        view.addSubview(spinner)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: spinner.bottomAnchor, constant: 16)
        ])
        
        return view
    }
    
    private static func createErrorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundPrimary
        view.isHidden = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Failed to load bet details"
        label.textAlignment = .center
        label.font = StyleProvider.fontWith(type: .medium, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 0
        
        let retryButton = UIButton(type: .system)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle("Try Again", for: .normal)
        retryButton.setTitleColor(StyleProvider.Color.highlightPrimary, for: .normal)
        retryButton.titleLabel?.font = StyleProvider.fontWith(type: .semibold, size: 16)
        retryButton.backgroundColor = StyleProvider.Color.buttonBackgroundSecondary
        retryButton.layer.cornerRadius = 8
        retryButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)
        
        view.addSubview(label)
        view.addSubview(retryButton)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),
            
            retryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retryButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 24)
        ])
        
        return view
    }
}
