//
//  CasinoGamePlayViewController.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 31/07/2025.
//

import UIKit
import WebKit
import Combine
import GomaUI

class CasinoGamePlayViewController: UIViewController {
    
    // MARK: - UI Components
    private var webView: WKWebView!
    private let topSafeAreaView = UIView()
    private let bottomBarView = UIView()

    // Bottom bar section containers
    private let exitContainer = UIView()
    private let depositContainer = UIView()

    // New bottom bar components
    private let exitButton = UIButton(type: .system)
    private let exitLabel = UILabel()
    private let depositButton = UIButton(type: .system)
    private let depositLabel = UILabel()
    private let timerContainer = UIView()
    private let timerLabel = UILabel()
    
    private let loadingIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.startAnimating()
        
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    
    // MARK: - Properties
    private let viewModel: CasinoGamePlayViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // Timer properties
    private var sessionTimer: Timer?
    private var sessionStartTime: Date?
    
    // MARK: - Constants
    private enum Constants {
        static let bottomBarHeight: CGFloat = 54.0
        static let horizontalPadding: CGFloat = 24.0
        static let iconSize: CGFloat = 16.0
        static let fontSize: CGFloat = 10.0
        static let timerWidth: CGFloat = 68.0
        static let timerHeight: CGFloat = 32.0
        
        // Hardcoded colors from Figma
        static let backgroundColor = UIColor(red: 0.012, green: 0.024, blue: 0.106, alpha: 1.0) // #03061b
        static let textColor = UIColor.white // #ffffff
    }
    
    // MARK: - Lifecycle
    init(viewModel: CasinoGamePlayViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        stopSessionTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupBindings()
        setupWebViewConfiguration()
        loadGame()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startSessionTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSessionTimer()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true // Full-screen experience
    }
    
    // MARK: - Setup
    private func setupViews() {
        view.backgroundColor = .black
        
        setupTopSafeArea()
        setupWebView()
        setupBottomBar()
        setupLoadingIndicator()
        setupConstraints()
    }
    
    private func setupTopSafeArea() {
        topSafeAreaView.backgroundColor = .black
        topSafeAreaView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topSafeAreaView)
    }
    
    private func setupWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true
        webConfiguration.mediaTypesRequiringUserActionForPlayback = []
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.allowsBackForwardNavigationGestures = true
        
        view.addSubview(webView)
        
        // Connect webView to viewModel
        viewModel.webView = webView
    }
    
    private func setupBottomBar() {
        // Main bottom bar container
        bottomBarView.backgroundColor = Constants.backgroundColor
        bottomBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBarView)
        
        // Setup exit button and label
        setupExitSection()
        
        // Setup deposit button and label  
        setupDepositSection()
        
        // Setup timer container and label
        setupTimerSection()
    }
    
    private func setupExitSection() {
        // Exit container
        exitContainer.isUserInteractionEnabled = true
        exitContainer.translatesAutoresizingMaskIntoConstraints = false
        let exitTap = UITapGestureRecognizer(target: self, action: #selector(exitButtonTapped))
        exitContainer.addGestureRecognizer(exitTap)
        bottomBarView.addSubview(exitContainer)

        // Exit button (icon) - add to container
        exitButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        exitButton.tintColor = Constants.textColor
        exitButton.isUserInteractionEnabled = false  // Let container handle taps
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        exitContainer.addSubview(exitButton)

        // Exit label - add to container
        exitLabel.text = localized("exit")
        exitLabel.textColor = Constants.textColor
        exitLabel.font = UIFont.systemFont(ofSize: Constants.fontSize, weight: .regular)
        exitLabel.textAlignment = .center
        exitLabel.translatesAutoresizingMaskIntoConstraints = false
        exitContainer.addSubview(exitLabel)
    }
    
    private func setupDepositSection() {
        // Deposit container
        depositContainer.isUserInteractionEnabled = true
        depositContainer.translatesAutoresizingMaskIntoConstraints = false
        let depositTap = UITapGestureRecognizer(target: self, action: #selector(depositButtonTapped))
        depositContainer.addGestureRecognizer(depositTap)
        bottomBarView.addSubview(depositContainer)

        // Deposit button (icon) - add to container
        depositButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        depositButton.tintColor = Constants.textColor
        depositButton.isUserInteractionEnabled = false  // Let container handle taps
        depositButton.translatesAutoresizingMaskIntoConstraints = false
        depositContainer.addSubview(depositButton)

        // Deposit label - add to container
        depositLabel.text = localized("deposit")
        depositLabel.textColor = Constants.textColor
        depositLabel.font = UIFont.systemFont(ofSize: Constants.fontSize, weight: .regular)
        depositLabel.textAlignment = .center
        depositLabel.translatesAutoresizingMaskIntoConstraints = false
        depositContainer.addSubview(depositLabel)
    }
    
    private func setupTimerSection() {
        // Timer container with border
        timerContainer.backgroundColor = UIColor.clear
        timerContainer.layer.borderColor = Constants.textColor.cgColor
        timerContainer.layer.borderWidth = 1.0
        timerContainer.layer.cornerRadius = Constants.timerHeight / 2
        timerContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomBarView.addSubview(timerContainer)
        
        // Timer label
        timerLabel.text = "01:00"
        timerLabel.textColor = Constants.textColor
        timerLabel.font = UIFont.systemFont(ofSize: Constants.fontSize, weight: .regular)
        timerLabel.textAlignment = .center
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerContainer.addSubview(timerLabel)
    }
    
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicatorView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Top Safe Area
            topSafeAreaView.topAnchor.constraint(equalTo: view.topAnchor),
            topSafeAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topSafeAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topSafeAreaView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            // WebView - full screen except for bottom bar
            webView.topAnchor.constraint(equalTo: topSafeAreaView.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomBarView.topAnchor),
            
            // Bottom Bar
            bottomBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBarView.heightAnchor.constraint(equalToConstant: Constants.bottomBarHeight),
            
            // Exit Container (Left)
            exitContainer.leadingAnchor.constraint(equalTo: bottomBarView.leadingAnchor, constant: Constants.horizontalPadding),
            exitContainer.centerYAnchor.constraint(equalTo: bottomBarView.centerYAnchor),
            exitContainer.widthAnchor.constraint(equalToConstant: Constants.timerWidth),

            // Exit button/label within container
            exitButton.centerXAnchor.constraint(equalTo: exitContainer.centerXAnchor),
            exitButton.topAnchor.constraint(equalTo: exitContainer.topAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            exitButton.heightAnchor.constraint(equalToConstant: Constants.iconSize),

            exitLabel.centerXAnchor.constraint(equalTo: exitContainer.centerXAnchor),
            exitLabel.topAnchor.constraint(equalTo: exitButton.bottomAnchor, constant: 2),
            exitLabel.bottomAnchor.constraint(equalTo: exitContainer.bottomAnchor),

            // Deposit Container (Center)
            depositContainer.centerXAnchor.constraint(equalTo: bottomBarView.centerXAnchor),
            depositContainer.centerYAnchor.constraint(equalTo: bottomBarView.centerYAnchor),
            depositContainer.widthAnchor.constraint(equalToConstant: Constants.timerWidth),

            // Deposit button/label within container
            depositButton.centerXAnchor.constraint(equalTo: depositContainer.centerXAnchor),
            depositButton.topAnchor.constraint(equalTo: depositContainer.topAnchor),
            depositButton.widthAnchor.constraint(equalToConstant: Constants.iconSize),
            depositButton.heightAnchor.constraint(equalToConstant: Constants.iconSize),

            depositLabel.centerXAnchor.constraint(equalTo: depositContainer.centerXAnchor),
            depositLabel.topAnchor.constraint(equalTo: depositButton.bottomAnchor, constant: 2),
            depositLabel.bottomAnchor.constraint(equalTo: depositContainer.bottomAnchor),
            
            // Timer Section (Right)
            timerContainer.trailingAnchor.constraint(equalTo: bottomBarView.trailingAnchor, constant: -Constants.horizontalPadding),
            timerContainer.centerYAnchor.constraint(equalTo: bottomBarView.centerYAnchor),
            timerContainer.widthAnchor.constraint(equalToConstant: Constants.timerWidth),
            timerContainer.heightAnchor.constraint(equalToConstant: Constants.timerHeight),
            
            timerLabel.centerXAnchor.constraint(equalTo: timerContainer.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: timerContainer.centerYAnchor),
            
            // Loading Indicator
            loadingIndicatorView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingIndicatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingIndicatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingIndicatorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupWebViewConfiguration() {
        // Additional WebView configuration for casino games
        webView.configuration.preferences.javaScriptEnabled = true
        webView.configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        
        // Allow all media to play without user interaction
        webView.configuration.mediaTypesRequiringUserActionForPlayback = []
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        // Loading state
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingIndicatorView.isHidden = !isLoading
            }
            .store(in: &cancellables)
        
        // Error handling
        viewModel.$errorMessage
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] errorMessage in
                self?.showError(errorMessage)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc private func exitButtonTapped() {
        viewModel.navigateBack()
    }
    
    @objc private func depositButtonTapped() {
        viewModel.onDepositRequested()
    }
    
    // MARK: - Timer Management
    private func startSessionTimer() {
        sessionStartTime = Date()
        sessionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTimerDisplay()
        }
        updateTimerDisplay()
    }
    
    private func stopSessionTimer() {
        sessionTimer?.invalidate()
        sessionTimer = nil
    }
    
    private func updateTimerDisplay() {
        guard let startTime = sessionStartTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        let minutes = Int(elapsed) / 60
        let seconds = Int(elapsed) % 60
        
        timerLabel.text = String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: - Data Loading
    private func loadGame() {
        viewModel.$gameURL
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                let request = URLRequest(url: url)
                self?.webView.load(request)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Error Handling
    private func showError(_ message: String) {
        let alert = UIAlertController(
            title: "Game Error",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.refresh()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - WKNavigationDelegate
extension CasinoGamePlayViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        viewModel.webViewDidStartProvisionalNavigation()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        viewModel.webViewDidFinishNavigation()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        viewModel.webViewDidFailNavigation(with: error)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        viewModel.webViewDidFailNavigation(with: error)
    }
}
