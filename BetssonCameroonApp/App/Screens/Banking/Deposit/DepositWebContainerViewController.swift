//
//  DepositWebContainerViewController.swift
//  BetssonCameroonApp
//
//  Created by Banking Implementation on 11/09/2025.
//

import UIKit
import WebKit
import Combine
import GomaUI
import ServicesProvider

/// WebView container for deposit operations
final class DepositWebContainerViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: DepositWebContainerViewModel
    private let webView: WKWebView
    private let loadingView: UIActivityIndicatorView
    private let javaScriptBridge: JavaScriptBridge
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components

    private lazy var customNavigationView: UIView = Self.createCustomNavigationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var cancelButton: UIButton = Self.createCancelButton()
    private lazy var logoImageView: UIImageView = Self.createLogoImageView()
    
    // MARK: - Callbacks
    
    /// Called when transaction completes successfully
    var onTransactionComplete: ((BankingNavigationAction) -> Void)?
    
    /// Called when transaction is cancelled by user
    var onTransactionCancel: (() -> Void)?
    
    // MARK: - Initialization
    
    /// Initialize deposit WebView container
    /// - Parameter viewModel: ViewModel for deposit operations
    init(viewModel: DepositWebContainerViewModel) {
        self.viewModel = viewModel
        self.javaScriptBridge = JavaScriptBridge()
        
        // Create WebView with banking configuration
        let configuration = WebViewConfiguration.forBanking(with: javaScriptBridge)
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        
        // Create loading indicator
        self.loadingView = UIActivityIndicatorView(style: .large)
        
        super.init(nibName: nil, bundle: nil)
        
        // Set up JavaScript bridge
        javaScriptBridge.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        
        // Start loading deposit
        viewModel.loadDeposit(currency: "XAF", language: "EN")
    }
    
    // MARK: - Private Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.App.backgroundPrimary
        
        // Add custom navigation view
        view.addSubview(customNavigationView)
        customNavigationView.addSubview(titleLabel)
        customNavigationView.addSubview(cancelButton)
        customNavigationView.backgroundColor = UIColor.App.backgroundPrimary

        // Add logo
        view.addSubview(logoImageView)

        // Add WebView
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        // Configure WebView appearance
        WebViewConfiguration.configureAppearance(for: webView)
        
        // Add loading view
        view.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.color = UIColor.App.textPrimary
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Custom Navigation View
            customNavigationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavigationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavigationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavigationView.heightAnchor.constraint(equalToConstant: 56),

            // Title Label
            titleLabel.centerXAnchor.constraint(equalTo: customNavigationView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: customNavigationView.centerYAnchor),

            // Cancel Button
            cancelButton.trailingAnchor.constraint(equalTo: customNavigationView.trailingAnchor, constant: -16),
            cancelButton.centerYAnchor.constraint(equalTo: customNavigationView.centerYAnchor),
            cancelButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            cancelButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),

            // Logo constraints
            logoImageView.topAnchor.constraint(equalTo: customNavigationView.bottomAnchor, constant: 18),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 20),

            // WebView constraints
            webView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 18),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Loading view constraints
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Setup button action
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateUI(for: state)
            }
            .store(in: &cancellables)
    }
    
    private func updateUI(for state: CashierFrameState) {
        switch state {
        case .idle:
            webView.isHidden = true
            loadingView.stopAnimating()
            
        case .loadingURL:
            webView.isHidden = true
            loadingView.startAnimating()
            
        case .loadingWebView(let url):
            // Keep loading indicator while WebView loads
            loadingView.startAnimating()
            
            // Create secure request
            var request = URLRequest(url: url)
            request.timeoutInterval = 30.0
            
            // Add security headers
            for (key, value) in WebViewConfiguration.securityHeaders() {
                request.setValue(value, forHTTPHeaderField: key)
            }
            
            // Load the request
            webView.load(request)
            
        case .ready:
            webView.isHidden = false
            loadingView.stopAnimating()
            
        case .error(let message):
            webView.isHidden = true
            loadingView.stopAnimating()
            showErrorAlert(message: message)
        }
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        onTransactionCancel?()
    }
    
    // MARK: - Error Handling
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Deposit Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.loadDeposit(currency: "XAF", language: "EN")
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { [weak self] _ in
            self?.onTransactionCancel?()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension DepositWebContainerViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        viewModel.webViewDidFinishLoading()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        viewModel.webViewDidFail(error: error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        viewModel.webViewDidFail(error: error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Allow navigation for now - JavaScript bridge will handle specific cases
        decisionHandler(.allow)
    }
}

// MARK: - WKUIDelegate

extension DepositWebContainerViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Prevent popup windows
        return nil
    }
}

// MARK: - JavaScriptBridgeDelegate

extension DepositWebContainerViewController: JavaScriptBridgeDelegate {
    
    func didReceiveTransactionSuccess(message: String, navigationAction: BankingNavigationAction) {
        DispatchQueue.main.async { [weak self] in
            self?.onTransactionComplete?(navigationAction)
        }
    }
    
    func didReceiveTransactionFailure(message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.webViewDidFail(error: message)
        }
    }
    
    func didReceiveTransactionCancellation(message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.onTransactionCancel?()
        }
    }
}

// MARK: - UI Factory Methods

extension DepositWebContainerViewController {
    
    private static func createCustomNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Deposit"
        label.font = AppFont.with(type: .semibold, size: 18)
        label.textColor = UIColor.App.textPrimary
        label.textAlignment = .center
        return label
    }
    
    private static func createCancelButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        return button
    }

    private static func createLogoImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "betsson_logo_orange")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
}
