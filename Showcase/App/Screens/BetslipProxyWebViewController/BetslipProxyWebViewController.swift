//
//  BetslipProxyWebViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 11/09/2023.
//

import Foundation
import WebKit
import Combine

// Define a struct to represent the message model
struct WebMessage: Codable {
    let messageType: String
    let data: BetSwipeData?
}

struct BetSwipeData: Codable {
    let externalEventId: String?
    let externalMarketId: String?
    let externalOutcomeId: String?
    let outcomeOdds: Double?
}


class BetslipProxyWebViewController: UIViewController {

    var closeBetSwipe: () -> Void = { }
    var showsBetslip: () -> Void = { }
    var addToBetslip: (BetSwipeData) -> Void = { _ in }
    
    // MARK: - Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationView: UIView = Self.createNavigationView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var backButton: UIButton = Self.createBackButton()

    private lazy var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: "postMessageListener")
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        return webView
    }()

    private lazy var botttomSafeAreaView: UIView = Self.createBottomSafeAreaView()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private var url: URL?

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.webView.navigationDelegate = self
        
        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.showLoading()

        if let url = self.url {
            self.webView.load(URLRequest(url: url))
        }
       
    }

    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {

        self.view.backgroundColor = .black

        self.topSafeAreaView.backgroundColor = .black
        self.botttomSafeAreaView.backgroundColor = .black

        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.backgroundColor = .clear
        self.titleLabel.textColor = UIColor.App.textPrimary

        self.webView.backgroundColor = UIColor.App.backgroundPrimary

        self.loadingBaseView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        self.loadingActivityIndicatorView.color = UIColor.lightGray

    }

    private func showLoading() {
        self.loadingBaseView.isHidden = false
        self.loadingActivityIndicatorView.startAnimating()
    }

    private func hideLoading() {
        self.loadingBaseView.isHidden = true
        self.loadingActivityIndicatorView.stopAnimating()
    }

    @objc private func didTapBackButton() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}

extension BetslipProxyWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.showLoading()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.hideLoading()
        
        var odd = 1.0
        let tickets = Env.betslipManager.bettingTicketsPublisher.value.map { bettingTicket in
            odd *= bettingTicket.decimalOdd
            return "{ marketId: \(bettingTicket.marketId), id: \(bettingTicket.outcomeId) }"
        }
        .joined(separator: ", ")
        let oddString = String(format: "%.2f", odd)
        
        let javascriptCode = """
             var event = new Event('message');
             event.data = {
                 event: 'betslip',
                 selections: [ \(tickets) ],
                 multipleTotalOddConverted: \(oddString)
             };
             window.dispatchEvent(event);
         """
         webView.evaluateJavaScript(javascriptCode, completionHandler: nil)
        
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.hideLoading()
    }
}

extension BetslipProxyWebViewController: WKScriptMessageHandler {

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "postMessageListener" {
            // Parse the JSON data directly into the WebMessage struct
            if let jsonData = try? JSONSerialization.data(withJSONObject: message.body, options: []),
               let webMessage = try? JSONDecoder().decode(WebMessage.self, from: jsonData) {

                switch webMessage.messageType {
                case "closeBetSwipe":
                    self.closeBetSwipeReceived()
                case "goToBetSlip":
                    self.goToBetslipReceived()
                case "betSwipeBetAdded":
                    if let data = webMessage.data {
                        self.betAddedReceived(withData: data)
                    }
                default:
                    break
                }
            }
        }
    }
    
}

extension BetslipProxyWebViewController {
        
    private func closeBetSwipeReceived() {
        self.closeBetSwipe()
    }
    
    private func goToBetslipReceived() {
        self.showsBetslip()
    }
    
    private func betAddedReceived(withData betSwipeData: BetSwipeData) {
        self.addToBetslip(betSwipeData)
    }
    
}

extension BetslipProxyWebViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNavigationView() -> UIView {
        let view = UIView()
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = UIColor.App.textPrimary
        titleLabel.font = AppFont.with(type: .semibold, size: 14)
        titleLabel.textAlignment = .center
        titleLabel.text = ""
        return titleLabel
    }

    private static func createBackButton() -> UIButton {
        let backButton = UIButton.init(type: .custom)
        backButton.setImage(UIImage(named: "arrow_close_icon"), for: .normal)
        backButton.setTitle(nil, for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        return backButton
    }

    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        return activityIndicatorView
    }

    private func setupSubviews() {
        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.navigationView)
        self.navigationView.addSubview(self.backButton)
        self.navigationView.addSubview(self.titleLabel)

        self.view.addSubview(self.webView)
        self.view.addSubview(self.botttomSafeAreaView)
        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
        ])

        NSLayoutConstraint.activate([
            self.botttomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.botttomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.botttomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.botttomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.navigationView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationView.topAnchor.constraint(equalTo: self.topSafeAreaView.bottomAnchor),
            self.navigationView.heightAnchor.constraint(equalToConstant: 0),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationView.centerXAnchor),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 44),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),

            self.backButton.widthAnchor.constraint(equalTo: self.backButton.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),
            self.backButton.centerYAnchor.constraint(equalTo: self.navigationView.centerYAnchor),
            self.backButton.leadingAnchor.constraint(equalTo: self.navigationView.leadingAnchor, constant: 10),
        ])

        NSLayoutConstraint.activate([
            self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.webView.topAnchor.constraint(equalTo: self.navigationView.bottomAnchor),
            self.webView.bottomAnchor.constraint(equalTo: self.botttomSafeAreaView.topAnchor)
        ])

        NSLayoutConstraint.activate([
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),

            self.view.leadingAnchor.constraint(equalTo: self.loadingBaseView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.loadingBaseView.trailingAnchor),
            self.navigationView.bottomAnchor.constraint(equalTo: self.loadingBaseView.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.loadingBaseView.bottomAnchor)
        ])

    }
}
