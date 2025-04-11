//
//  StatsWebViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 11/04/2025.
//

import UIKit
import WebKit
import Combine

class StatsWebViewController: UIViewController, WKNavigationDelegate {
    
    private var loadingView: UIActivityIndicatorView!
    private var webView: WKWebView!
    private var webViewHeightConstraint: NSLayoutConstraint!
    private var closeButton: UIButton!

    private var matchId: String
    private var marketTypeId: String
    
    private var marketStatsSubscriber: AnyCancellable?
    
    init(matchId: String, marketTypeId: String) {
        self.matchId = matchId
        self.marketTypeId = marketTypeId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.7)

        self.setupCloseButton()

        let webConfiguration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
        self.webView.navigationDelegate = self
        self.webView.isOpaque = false

        self.webView.backgroundColor = UIColor.clear
        self.webView.scrollView.backgroundColor = UIColor.clear
        self.webView.scrollView.isScrollEnabled = false
        
        self.view.addSubview(webView)

        self.webView.translatesAutoresizingMaskIntoConstraints = false
        
        self.loadingView = UIActivityIndicatorView()
        self.loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(self.loadingView)
        
        self.webViewHeightConstraint = self.webView.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            self.webView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            self.webView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.webView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.webViewHeightConstraint,
            
            self.loadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.loadingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
        ])

        self.loadingView.startAnimating()
        
        let theme = self.traitCollection.userInterfaceStyle
        self.marketStatsSubscriber = Env.servicesProvider.getStatsWidget(eventId: self.matchId,
                                                                         marketTypeName: self.marketTypeId,
                                                                         isDarkTheme: theme == .dark ? true : false)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print("getStatsWidget completion \(completion)")
            } receiveValue: { [weak self] statsWidgetRenderDataType in
                switch statsWidgetRenderDataType {
                case .url:
                    break
                case .htmlString(let url, let htmlString):
                    self?.webView.loadHTMLString(htmlString, baseURL: url)
                }
            }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeButtonTapped))
        self.view.addGestureRecognizer(tapGesture)
    }

    private func setupCloseButton() {
        self.closeButton = UIButton(type: .custom)
        
        let closeImage = UIImage(named: "arrow_close_icon")?.withRenderingMode(.alwaysTemplate)
        
        self.closeButton.setImage(closeImage, for: .normal)
        self.closeButton.imageView?.setImageColor(color: UIColor.App.buttonTextPrimary)
        self.view.addSubview(self.closeButton)

        self.closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            self.closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            self.closeButton.widthAnchor.constraint(equalToConstant: 40),
            self.closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        self.closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }

    @objc private func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.loadingView.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.loadingView.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webView.evaluateJavaScript("document.readyState", completionHandler: { [weak self] complete, error in
            if complete != nil {
                self?.recalculateWebview()
            }
            else if let error = error {
                Logger.log("Match details WKWebView didFinish error \(error)")
            }
        })
    }
    
    private func recalculateWebview() {
        executeDelayed(0.2) {
             self.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { [weak self] height, error in
                 if let heightFloat = height as? CGFloat {
                     self?.redrawWebView(withHeight: heightFloat)
                 }
                 if let error = error {
                     Logger.log("Match details WKWebView didFinish error \(error)")
                 }
             })
         }
     }
     
     private func redrawWebView(withHeight heigth: CGFloat) {
         if heigth < 10 {
            self.recalculateWebview()
         }
         else {
             self.webViewHeightConstraint.constant = heigth
             self.view.layoutIfNeeded()
             self.loadingView.stopAnimating()
         }
     }
         
}
