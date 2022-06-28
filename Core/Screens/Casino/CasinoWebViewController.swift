//
//  CasinoWebViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/04/2022.
//

import UIKit
import WebKit
import Combine

class CasinoWebViewController: UIViewController {

    // MARK: - Private Properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var webView: WKWebView = Self.createWebView()
    private lazy var botttomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private var userId: String
    private var cancellables = Set<AnyCancellable>()
    
    private var noSessionUrlString: String = TargetVariables.casinoURL
    
    private var viewModel: CasinoViewModel
    private let refreshControl = UIRefreshControl()

    init(userId: String, viewModel: CasinoViewModel = CasinoViewModel() ) {
        self.userId = userId
        self.viewModel = viewModel
        
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

        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        
        self.refreshControl.tintColor = UIColor.lightGray
        self.refreshControl.addTarget(self, action: #selector(self.refreshWebView), for: .valueChanged)
        self.webView.scrollView.refreshControl = self.refreshControl
        
        self.viewModel.isUserLoggedPublisher
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] _ in
                self?.refreshWebView()
            })
            .store(in: &self.cancellables)

    }

    @objc func refreshWebView() {
        self.userId = UserSessionStore.loggedUserSession()?.userId ?? ""
        
        self.showLoading()
        self.loadInitialPage()
    }
    
    func loadInitialPage() {

        Env.everyMatrixClient.getCMSSessionID()
            .receive(on: DispatchQueue.main)
            .map { cmsSessionInfo in
                let cmsSessionInfoId: String? = cmsSessionInfo.id
                return cmsSessionInfoId
            }
            .replaceError(with: nil)
            .sink(receiveValue: { [weak self] cmsSessionInfoId in
                self?.loadWebView(withID: cmsSessionInfoId)
            })
            .store(in: &self.cancellables)

    }

    func loadWebView(withID id: String?) {
        
        var urlString = ""
        if let cmsSessionInfoId = id, self.userId != "" {
            urlString = "\(self.noSessionUrlString)\(self.userId)/\(cmsSessionInfoId)"
        }
        else {
            urlString = self.noSessionUrlString
        }
        
        guard let url = URL(string: urlString) else {
            return
        }

        self.webView.load(URLRequest(url: url))
    }

    func loadGameWebView(request: URLRequest) {
        
        if self.userId == "" {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.present(loginViewController, animated: true, completion: nil)
        }
        else {
            let casinoGameDetailViewController = CasinoGameDetailViewController(url: request)
            self.navigationController?.pushViewController(casinoGameDetailViewController, animated: true)
        }
        
    }
    
    // MARK: - Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.hideLoading()
        self.setupWithTheme()
    }

    private func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
        self.botttomSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary

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

}

extension CasinoWebViewController: WKUIDelegate {

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {

        if navigationAction.targetFrame == nil {
            self.loadGameWebView(request: navigationAction.request)
        }
        return nil
    }

}

extension CasinoWebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        if let url = webView.url {
            let request = URLRequest(url: url)
            self.webView.load(request)
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(WKNavigationResponsePolicy.allow)
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    
        if self.userId == "" && navigationAction.sourceFrame != nil {
            let loginViewController = Router.navigationController(with: LoginViewController())
            self.present(loginViewController, animated: true, completion: nil)
            decisionHandler(.allow)
        }
        else {
            decisionHandler(.allow)
        }
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if self.userId != "" {
            self.showLoading()
            
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.refreshControl.endRefreshing()
        self.hideLoading()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.refreshControl.endRefreshing()
        self.hideLoading()
    }
}

extension CasinoWebViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createWebView() -> WKWebView {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
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

        self.view.addSubview(self.webView)
        self.view.addSubview(self.botttomSafeAreaView)
        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.webView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        NSLayoutConstraint.activate([
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),

            self.view.leadingAnchor.constraint(equalTo: self.loadingBaseView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.loadingBaseView.trailingAnchor),
            self.view.topAnchor.constraint(equalTo: self.loadingBaseView.topAnchor),
            self.view.bottomAnchor.constraint(equalTo: self.loadingBaseView.bottomAnchor)
        ])

    }

}
