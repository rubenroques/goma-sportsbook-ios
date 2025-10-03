//
//  NotificationsViewController.swift
//  BetssonCameroonApp
//
//  Created on 29/08/2025.
//

import UIKit
import Combine
import GomaUI

final class NotificationsViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let viewModel: NotificationsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private lazy var customNavigationView: UIView = Self.createCustomNavigationView()
    private lazy var notificationsTitleLabel: UILabel = Self.createNotificationsTitleLabel()
    private lazy var backButton: UIButton = Self.createBackButton()
    
    private var notificationListView: NotificationListView!
    
    private lazy var loadingView: UIView = Self.createLoadingView()
    private lazy var errorView: UIView = Self.createErrorView()
    
    // MARK: - Initialization
    
    init(viewModel: NotificationsViewModel) {
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
    }
    
    // MARK: - Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return traitCollection.userInterfaceStyle == .dark ? .lightContent : .darkContent
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = UIColor.App.backgroundPrimary
        
        // Create GomaUI NotificationListView with our ViewModel
        notificationListView = NotificationListView(viewModel: viewModel.notificationListViewModel)
        notificationListView.translatesAutoresizingMaskIntoConstraints = false
        
        setupViewHierarchy()
        setupConstraints()
    }
    
    private func setupViewHierarchy() {
        view.addSubview(customNavigationView)
        view.addSubview(notificationListView)
        view.addSubview(loadingView)
        view.addSubview(errorView)
        
        customNavigationView.addSubview(notificationsTitleLabel)
        customNavigationView.addSubview(backButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Custom Navigation View
            customNavigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavigationView.heightAnchor.constraint(equalToConstant: 56),
            
            // Notifications Title Label
            notificationsTitleLabel.centerXAnchor.constraint(equalTo: customNavigationView.centerXAnchor),
            notificationsTitleLabel.centerYAnchor.constraint(equalTo: customNavigationView.centerYAnchor),
            
            // Back Button (Left side)
            backButton.leadingAnchor.constraint(equalTo: customNavigationView.leadingAnchor, constant: 16),
            backButton.centerYAnchor.constraint(equalTo: customNavigationView.centerYAnchor),
            backButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            backButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            
            // NotificationListView (Main content)
            notificationListView.topAnchor.constraint(equalTo: customNavigationView.bottomAnchor),
            notificationListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            notificationListView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            notificationListView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Loading View
            loadingView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Error View  
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
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
        
        // No additional bindings needed for back button navigation
    }
    
    private func setupActions() {
        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        
        viewModel.onNotificationActionTapped = { [weak self] notification, action in
            self?.handleNotificationAction(notification: notification, action: action)
        }
    }
    
    // MARK: - Rendering
    
    private func render(displayState: NotificationsDisplayState) {
        // Show/hide loading state
        loadingView.isHidden = !displayState.isLoading
        
        // Show/hide error state
        errorView.isHidden = displayState.error == nil
        
        // Show/hide main content
        let hasError = displayState.error != nil
        notificationListView.isHidden = displayState.isLoading || hasError
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
    
    private func handleNotificationAction(notification: NotificationData, action: NotificationAction) {
        // Show alert for demonstration (in production, this would navigate to specific screens)
        let alert = UIAlertController(
            title: "Notification Action",
            message: "Tapped '\(action.title)' for notification '\(notification.title)'",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    
    @objc private func didTapBack() {
        viewModel.didTapClose()
    }
    
    @objc private func didTapRetry() {
        viewModel.refreshData()
    }
}

// MARK: - Factory Methods

extension NotificationsViewController {
    
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
    
    private static func createNotificationsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Notifications"
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
        label.text = "Loading notifications..."
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
        label.text = "Failed to load notifications"
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
