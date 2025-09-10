//
//  BankingWebViewController.swift
//  BetssonCameroonApp
//
//  Created by Banking Implementation on 10/09/2025.
//

import UIKit
import WebKit
import Combine
import GomaUI
import ServicesProvider


/// Unified WebView controller for banking operations (Deposit/Withdraw)
public final class BankingWebViewController: UIViewController {
    
    // MARK: - Properties
    
    /// Closure called when transaction completes successfully
    public var onTransactionComplete: ((BankingNavigationAction) -> Void)?
    
    /// Closure called when transaction fails
    public var onTransactionFailure: ((String) -> Void)?
    
    /// Closure called when user cancels transaction
    public var onTransactionCancel: (() -> Void)?
    
    /// Closure called when WebView finishes loading
    public var onWebViewDidFinishLoading: (() -> Void)?
    
    private let webView: WKWebView
    private let javaScriptBridge: JavaScriptBridge
    private let loadingView: UIActivityIndicatorView
    private let transactionType: CashierTransactionType
    
    private var cancellables = Set<AnyCancellable>()
    private var isPageLoading = true
    
    // MARK: - Initialization
    
    /// Initialize banking WebView controller
    /// - Parameters:
    ///   - transactionType: Type of banking transaction
    ///   - url: WebView URL to load
    public init(transactionType: CashierTransactionType, url: URL) {
        self.transactionType = transactionType
        self.javaScriptBridge = JavaScriptBridge()
        
        // Create WebView with banking configuration
        let configuration = WebViewConfiguration.forBanking(with: javaScriptBridge)
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        
        // Create loading indicator
        self.loadingView = UIActivityIndicatorView(style: .large)
        
        super.init(nibName: nil, bundle: nil)
        
        // Set up JavaScript bridge delegation
        javaScriptBridge.delegate = self
        
        // Configure WebView
        setupWebView()
        
        // Load the banking URL
        loadBankingURL(url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigationBar()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ensure WebView is visible when page is loaded
        updateWebViewVisibility()
    }
    
    // MARK: - Private Setup
    
    private func setupUI() {
        view.backgroundColor = UIColor.App.backgroundPrimary
        
        // Add WebView
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add loading view
        view.addSubview(loadingView)
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.color = UIColor.App.textPrimary
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // WebView constraints
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Loading view constraints
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Initially hide WebView and show loading
        webView.alpha = 0
        loadingView.startAnimating()
    }
    
    private func setupNavigationBar() {
        // Set title based on transaction type
        title = transactionType.displayName
        
        // Add cancel button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        // Style navigation bar
        navigationController?.navigationBar.backgroundColor = UIColor.App.backgroundPrimary
        navigationController?.navigationBar.tintColor = UIColor.App.textPrimary
    }
    
    private func setupWebView() {
        // Configure appearance
        WebViewConfiguration.configureAppearance(for: webView)
        
        // Set delegates
        webView.navigationDelegate = self
        webView.uiDelegate = self
    }
    
    private func loadBankingURL(_ url: URL) {

        // Create request with security headers
        var request = URLRequest(url: url)
        request.timeoutInterval = 30.0
        
        // Add security headers
        for (key, value) in WebViewConfiguration.securityHeaders() {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Load the request
        webView.load(request)
    }
    
    private func updateWebViewVisibility() {
        UIView.animate(withDuration: 0.3) { [weak self] in
            if self?.isPageLoading == true {
                self?.webView.alpha = 0
                self?.loadingView.alpha = 1
            } else {
                self?.webView.alpha = 1
                self?.loadingView.alpha = 0
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        onTransactionCancel?()
    }
}

// MARK: - WKNavigationDelegate

extension BankingWebViewController: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        isPageLoading = false
        updateWebViewVisibility()
        loadingView.stopAnimating()
        onWebViewDidFinishLoading?()
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        isPageLoading = false
        updateWebViewVisibility()
        loadingView.stopAnimating()
        onTransactionFailure?(error.localizedDescription)
    }
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        isPageLoading = false
        updateWebViewVisibility()
        loadingView.stopAnimating()
        onTransactionFailure?(error.localizedDescription)
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.cancel)
    }
}

// MARK: - WKUIDelegate

extension BankingWebViewController: WKUIDelegate {
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        return nil
    }
}

// MARK: - JavaScriptBridgeDelegate

extension BankingWebViewController: JavaScriptBridgeDelegate {
    
    public func didReceiveTransactionSuccess(message: String, navigationAction: BankingNavigationAction) {
        DispatchQueue.main.async { [weak self] in
            self?.onTransactionComplete?(navigationAction)
        }
    }
    
    public func didReceiveTransactionFailure(message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.onTransactionFailure?(message)
        }
    }
    
    public func didReceiveTransactionCancellation(message: String) {
        DispatchQueue.main.async { [weak self] in
            self?.onTransactionCancel?()
        }
    }
}
