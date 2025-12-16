//
//  GomaCashierWithdrawViewController.swift
//  BetssonCameroonApp
//
//  Created by Goma Cashier Implementation on 10/12/2025.
//

import UIKit
import WebKit
import Combine
import GomaUI
import GomaLogger

/// WebView container for Goma-hosted withdraw operations
final class GomaCashierWithdrawViewController: UIViewController {

    // MARK: - Properties

    private let logPrefix = "[GomaCashier][Withdraw]"
    private let viewModel: GomaCashierWithdrawViewModel
    private let webView: WKWebView
    private let loadingView: UIActivityIndicatorView
    private let gomaBridge: GomaCashierBridge
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Timing Properties

    private var timingMetrics: BankingTimingMetrics?
    private var timerOverlay: LoadingTimerOverlayView?
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

    /// Initialize Goma cashier withdraw WebView container
    /// - Parameter viewModel: ViewModel for withdraw operations
    init(viewModel: GomaCashierWithdrawViewModel) {
        self.viewModel = viewModel
        self.gomaBridge = GomaCashierBridge()

        // Create WebView with Goma cashier configuration
        let configuration = GomaCashierWebViewConfiguration.forGomaCashier(with: gomaBridge)
        self.webView = WKWebView(frame: .zero, configuration: configuration)

        // Create loading indicator
        self.loadingView = UIActivityIndicatorView(style: .large)

        super.init(nibName: nil, bundle: nil)

        // Set up JavaScript bridge
        gomaBridge.delegate = self
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
        viewModel.loadWithdraw()
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
        GomaCashierWebViewConfiguration.configureAppearance(for: webView)

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
            // This state is not used in Goma cashier (no API call)
            webView.isHidden = true
            loadingView.startAnimating()

        case .loadingWebView(let url):
            // Store URL for copy functionality
            cashierURL = url.absoluteString

            // Log URL to console for analysis
            GomaLogger.info("\(logPrefix) Loading cashier URL: \(url.absoluteString)")

            // Keep loading indicator while WebView loads
            loadingView.startAnimating()

            // Create secure request
            var request = URLRequest(url: url)
            request.timeoutInterval = 30.0

            // Add security headers
            for (key, value) in GomaCashierWebViewConfiguration.securityHeaders() {
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
            self?.viewModel.loadWithdraw()
        })

        alert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel) { [weak self] _ in
            self?.onTransactionCancel?()
        })

        present(alert, animated: true)
    }
}

// MARK: - WKNavigationDelegate

extension GomaCashierWithdrawViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // Track WebView provisional load start
        timingMetrics?.startWebViewProvisionalLoad()
        updateTimerOverlay()
        GomaLogger.debug("\(logPrefix) WebView started provisional navigation")
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // Track WebView commit phase
        timingMetrics?.commitWebViewLoad()
        updateTimerOverlay()
        GomaLogger.debug("\(logPrefix) WebView committed navigation")
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Track WebView DOM loaded
        timingMetrics?.finishWebViewDOMLoad()
        timingMetrics?.markWebViewFullyReady()
        updateTimerOverlay()
        GomaLogger.info("\(logPrefix) WebView finished loading")

        // Log final timing breakdown
        if let metrics = timingMetrics {
            GomaLogger.info("\(logPrefix) Timing - APP: \(metrics.formattedAppDuration), API: \(metrics.formattedApiDuration), WEB: \(metrics.formattedWebDuration), TOTAL: \(metrics.formattedTotalDuration)")
        }

        viewModel.webViewDidFinishLoading()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        viewModel.webViewDidFail(error: error.localizedDescription)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        viewModel.webViewDidFail(error: error.localizedDescription)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Allow navigation - JavaScript bridge will handle specific cases
        decisionHandler(.allow)
    }
}

// MARK: - WKUIDelegate

extension GomaCashierWithdrawViewController: WKUIDelegate {

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Prevent popup windows
        return nil
    }
}

// MARK: - GomaCashierBridgeDelegate

extension GomaCashierWithdrawViewController: GomaCashierBridgeDelegate {

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

extension GomaCashierWithdrawViewController {

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
        imageView.image = UIImage(named: "betsson_logo_orange")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }
}
