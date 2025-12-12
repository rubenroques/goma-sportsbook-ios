//
//  WithdrawWebContainerViewController.swift
//  BetssonCameroonApp
//
//  Created by Banking Implementation on 11/09/2025.
//

import UIKit
import WebKit
import Combine
import GomaUI
import ServicesProvider

/// WebView container for withdraw operations
final class WithdrawWebContainerViewController: UIViewController {
    
    // MARK: - Properties

    private let viewModel: WithdrawWebContainerViewModel
    private let webView: WKWebView
    private let loadingView: UIActivityIndicatorView
    private let javaScriptBridge: JavaScriptBridge
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Timing Properties

    private var timingMetrics: BankingTimingMetrics?
    private var timerOverlay: LoadingTimerOverlayView?
    private var spinnerPollingTimer: Timer?
    private var cashierURL: String?
    
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
    
    /// Initialize withdraw WebView container
    /// - Parameter viewModel: ViewModel for withdraw operations
    init(viewModel: WithdrawWebContainerViewModel) {
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
        setupTimingOverlay()

        // Start loading withdraw
        viewModel.loadWithdraw(currency: "XAF")
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

    private func setupTimingOverlay() {
        // Initialize timing metrics and start app phase
        var metrics = BankingTimingMetrics()
        metrics.startAppInitialization()
        timingMetrics = metrics

        // Create and add timer overlay
        let overlay = LoadingTimerOverlayView(metrics: metrics)

        // Set up URL callback for copy functionality
        overlay.onCopyRequested = { [weak self] in
            return self?.cashierURL
        }

        view.addSubview(overlay)

        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: customNavigationView.bottomAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        timerOverlay = overlay
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

            // Track API call start
            timingMetrics?.startAPICall()
            updateTimerOverlay()

        case .loadingWebView(let url):
            // Track API call end
            timingMetrics?.endAPICall()
            updateTimerOverlay()

            // Store URL for copy functionality
            cashierURL = url.absoluteString

            // Log URL to console for analysis
            print("💰 [Withdraw] Cashier URL received: \(url.absoluteString)")

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

            // Mark timing as complete
            timingMetrics?.complete()
            updateTimerOverlay()

        case .error(let message):
            webView.isHidden = true
            loadingView.stopAnimating()
            stopSpinnerPolling()
            showErrorAlert(message: message)
        }
    }

    private func updateTimerOverlay() {
        guard let metrics = timingMetrics else { return }
        timerOverlay?.updateMetrics(metrics)
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        onTransactionCancel?()
    }
    
    // MARK: - Error Handling
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: localized("withdraw_error"),
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: localized("retry"), style: .default) { [weak self] _ in
            self?.viewModel.loadWithdraw(currency: "XAF")
        })

        alert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel) { [weak self] _ in
            self?.onTransactionCancel?()
        })

        present(alert, animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension WithdrawWebContainerViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Track WebView provisional load start
        timingMetrics?.startWebViewProvisionalLoad()
        updateTimerOverlay()
        print("🌐 [Withdraw] WebView started provisional navigation")
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // Track WebView commit phase
        timingMetrics?.commitWebViewLoad()
        updateTimerOverlay()
        print("🌐 [Withdraw] WebView committed navigation")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Track WebView DOM loaded
        timingMetrics?.finishWebViewDOMLoad()
        updateTimerOverlay()
        print("🌐 [Withdraw] WebView finished loading DOM")

        // Start polling for spinner removal (true webpage ready state)
        startSpinnerPolling()

        viewModel.webViewDidFinishLoading()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        stopSpinnerPolling()
        viewModel.webViewDidFail(error: error.localizedDescription)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        stopSpinnerPolling()
        viewModel.webViewDidFail(error: error.localizedDescription)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Allow navigation for now - JavaScript bridge will handle specific cases
        decisionHandler(.allow)
    }
}

// MARK: - Spinner Polling

extension WithdrawWebContainerViewController {

    private func startSpinnerPolling() {
        // Mark that we're polling for webpage ready state
        timingMetrics?.startPollingForWebViewReady()
        updateTimerOverlay()

        print("🔍 [Withdraw] Started polling for spinner removal")

        var pollCount = 0
        spinnerPollingTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            pollCount += 1

            // Check if spinner element is removed
            let javascript = "document.getElementById('spinner') === null"
            self.webView.evaluateJavaScript(javascript) { result, error in
                if let isRemoved = result as? Bool, isRemoved {
                    // Spinner is gone - webpage is fully ready
                    print("✅ [Withdraw] Spinner removed - webpage fully loaded (poll count: \(pollCount))")
                    self.onSpinnerRemoved()
                } else if pollCount >= 60 {
                    // Timeout after 30 seconds (60 polls * 0.5s)
                    print("⏱️ [Withdraw] Spinner polling timeout after 30 seconds")
                    self.onSpinnerPollingTimeout()
                }
            }
        }
    }

    private func stopSpinnerPolling() {
        spinnerPollingTimer?.invalidate()
        spinnerPollingTimer = nil
    }

    private func onSpinnerRemoved() {
        stopSpinnerPolling()

        // Mark webpage as fully ready
        timingMetrics?.markWebViewFullyReady()
        updateTimerOverlay()

        // Log final timing breakdown
        if let metrics = timingMetrics {
            print("📊 [Withdraw] Final Timing Breakdown:")
            print("   APP: \(metrics.formattedAppDuration)")
            print("   API: \(metrics.formattedApiDuration)")
            print("   WEB: \(metrics.formattedWebDuration)")
            print("   TOTAL: \(metrics.formattedTotalDuration)")
        }
    }

    private func onSpinnerPollingTimeout() {
        stopSpinnerPolling()

        // Mark as ready anyway (timeout doesn't mean failure)
        timingMetrics?.markWebViewFullyReady()
        updateTimerOverlay()

        print("⚠️ [Withdraw] Spinner polling timed out, marking as ready anyway")
    }
}

// MARK: - WKUIDelegate

extension WithdrawWebContainerViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Prevent popup windows
        return nil
    }
}

// MARK: - JavaScriptBridgeDelegate

extension WithdrawWebContainerViewController: JavaScriptBridgeDelegate {
    
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

extension WithdrawWebContainerViewController {
    
    private static func createCustomNavigationView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("withdraw")
        label.font = AppFont.with(type: .semibold, size: 18)
        label.textColor = UIColor.App.textPrimary
        label.textAlignment = .center
        return label
    }
    
    private static func createCancelButton() -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("cancel"), for: .normal)
        button.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        button.titleLabel?.font = AppFont.with(type: .semibold, size: 14)
        return button
    }

    private static func createLogoImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: TargetVariables.brandLogoAssetName)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
}
