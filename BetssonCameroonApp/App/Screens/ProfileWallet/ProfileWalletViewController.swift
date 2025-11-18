//
//  ProfileWalletViewController.swift
//  BetssonCameroonApp
//
//  Created on 29/08/2025.
//

import UIKit
import Combine
import GomaUI

final class ProfileWalletViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let viewModel: ProfileWalletViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private lazy var customNavigationView: UIView = Self.createCustomNavigationView()
    private lazy var profileTitleLabel: UILabel = Self.createProfileTitleLabel()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    
    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var contentStackView: UIStackView = Self.createContentStackView()
    
    private var walletDetailView: WalletDetailView!
    private var profileMenuListView: ProfileMenuListView!
    private var themeSwitcherView: ThemeSwitcherView!
    private lazy var themeSwitcherContainerView: UIView = Self.createThemeSwitcherContainerView()
    
    private lazy var loadingView: UIView = Self.createLoadingView()
    private lazy var errorView: UIView = Self.createErrorView()
    
    private let actionLoadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.isHidden = true

        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()
    // MARK: - Initialization
    
    init(viewModel: ProfileWalletViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        // Setup modal presentation
        modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            sheetPresentationController?.detents = [.large()]
            sheetPresentationController?.prefersGrabberVisible = false
        }
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
        
        // Load initial data
        viewModel.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()

        // Refresh language display in case user changed language in Settings
        viewModel.refreshLanguageDisplay()
    }
    
    // MARK: - Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return traitCollection.userInterfaceStyle == .dark ? .lightContent : .darkContent
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = UIColor.App.backgroundTertiary
        
        customNavigationView.backgroundColor = UIColor.App.backgroundTertiary
        scrollView.backgroundColor = .clear
        contentStackView.backgroundColor = .clear
        
        // Create GomaUI component views
        walletDetailView = WalletDetailView(viewModel: viewModel.walletDetailViewModel)
        walletDetailView.translatesAutoresizingMaskIntoConstraints = false
        
        profileMenuListView = ProfileMenuListView(viewModel: viewModel.profileMenuListViewModel)
        profileMenuListView.translatesAutoresizingMaskIntoConstraints = false
        
        themeSwitcherView = ThemeSwitcherView(viewModel: viewModel.themeSwitcherViewModel)
        themeSwitcherView.translatesAutoresizingMaskIntoConstraints = false
        
        setupViewHierarchy()
        setupConstraints()
    }
    
    private func setupViewHierarchy() {
        view.addSubview(customNavigationView)
        view.addSubview(scrollView)
        view.addSubview(loadingView)
        view.addSubview(errorView)
        view.addSubview(actionLoadingView)

        customNavigationView.addSubview(profileTitleLabel)
        customNavigationView.addSubview(closeButton)
        
        scrollView.addSubview(contentStackView)
        
        contentStackView.addArrangedSubview(walletDetailView)
        contentStackView.addArrangedSubview(profileMenuListView)
        contentStackView.addArrangedSubview(themeSwitcherContainerView)
        
        // Add ThemeSwitcherView to its container and center it
        themeSwitcherContainerView.addSubview(themeSwitcherView)
        
        NSLayoutConstraint.activate([
            // Center ThemeSwitcherView in its container
            themeSwitcherView.centerXAnchor.constraint(equalTo: themeSwitcherContainerView.centerXAnchor),
            themeSwitcherView.centerYAnchor.constraint(equalTo: themeSwitcherContainerView.centerYAnchor),
            themeSwitcherView.topAnchor.constraint(greaterThanOrEqualTo: themeSwitcherContainerView.topAnchor),
            themeSwitcherView.bottomAnchor.constraint(lessThanOrEqualTo: themeSwitcherContainerView.bottomAnchor),
            
            // Set container height to accommodate the ThemeSwitcherView
            themeSwitcherContainerView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Custom Navigation View
            customNavigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavigationView.heightAnchor.constraint(equalToConstant: 56),
            
            // Profile Title Label
            profileTitleLabel.centerXAnchor.constraint(equalTo: customNavigationView.centerXAnchor),
            profileTitleLabel.centerYAnchor.constraint(equalTo: customNavigationView.centerYAnchor),
            
            // Close Button
            closeButton.trailingAnchor.constraint(equalTo: customNavigationView.trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: customNavigationView.centerYAnchor),
            closeButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            closeButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: customNavigationView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content Stack View
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
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
            
            // Action Loading View
            actionLoadingView.topAnchor.constraint(equalTo: customNavigationView.bottomAnchor),
            actionLoadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            actionLoadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            actionLoadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        // Display state binding using @Published
        viewModel.$displayState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayState in
                self?.render(displayState: displayState)
            }
            .store(in: &cancellables)
        
        viewModel.onTransactionIdCopied = { [weak self] transactionId in
            let alert = UIAlertController(
                title: localized("copied"),
                message: localized("transaction_id_copied"),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: localized("ok"), style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    private func setupActions() {
        closeButton.addTarget(self, action: #selector(didTapClose), for: .touchUpInside)
        
        // Setup ViewModel navigation callbacks
        viewModel.onDismiss = { [weak self] in
            DispatchQueue.main.async {
                self?.dismiss(animated: true)
            }
        }
        
        viewModel.isActionLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.actionLoadingView.isHidden = !isLoading
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Rendering
    
    private func render(displayState: ProfileWalletDisplayState) {
        // Show/hide loading state
        loadingView.isHidden = !displayState.isLoading
        
        // Show/hide error state
        errorView.isHidden = displayState.error == nil
        
        // Show/hide main content
        let hasError = displayState.error != nil
        scrollView.isHidden = displayState.isLoading || hasError
        customNavigationView.isHidden = displayState.isLoading || hasError
        
        // Update error message if present
        if let error = displayState.error {
            updateErrorView(with: error)
        }
    }
    
    private func updateErrorView(with errorMessage: String) {
        // Find the error label in errorView and update it
        if let label = errorView.subviews.first(where: { $0 is UILabel }) as? UILabel {
            label.text = errorMessage
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapClose() {
        viewModel.didTapClose()
    }
    
    @objc private func didTapRetry() {
        viewModel.refreshData()
    }
}

// MARK: - Factory Methods

extension ProfileWalletViewController {
    
    private static func createCustomNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.App.backgroundPrimary
        return view
    }
    
    private static func createProfileTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("profile")
        label.font = AppFont.with(type: .bold, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.textAlignment = .center
        return label
    }
    
    private static func createCloseButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("close"), for: .normal)
        button.setTitleColor(StyleProvider.Color.highlightPrimary, for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        return button
    }
    
    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }
    
    private static func createContentStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 16
        return stackView
    }
    
    private static func createThemeSwitcherContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
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
        label.text = localized("loading_profile")
        label.textAlignment = .center
        label.font = AppFont.with(type: .medium, size: 16)
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
        label.text = localized("failed_to_load_profile")
        label.textAlignment = .center
        label.font = AppFont.with(type: .medium, size: 16)
        label.textColor = StyleProvider.Color.textPrimary
        label.numberOfLines = 0
        
        let retryButton = UIButton(type: .system)
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        retryButton.setTitle(localized("try_again"), for: .normal)
        retryButton.setTitleColor(StyleProvider.Color.highlightPrimary, for: .normal)
        retryButton.titleLabel?.font = AppFont.with(type: .semibold, size: 16)
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
