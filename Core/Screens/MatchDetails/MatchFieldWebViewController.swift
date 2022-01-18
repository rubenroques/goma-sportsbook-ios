//
//  MatchFieldWebViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 14/01/2022.
//

import UIKit
import WebKit

class MatchFieldWebViewController: UIViewController {

    @IBOutlet private var topSafeAreaView: UIView!
    @IBOutlet private var navigationView: UIView!

    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var webView: WKWebView!

    private var match: Match

    init(match: Match) {
        self.match = match

        super.init(nibName: "MatchFieldWebViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupWithTheme()

        self.activityIndicatorView.hidesWhenStopped = true

        self.webView.navigationDelegate = self

        self.activityIndicatorView.startAnimating()

        let request = URLRequest(url: URL(string: "https://sportsbook-cms.gomagaming.com/widget/\(match.id)/\(match.sportType)")!)
        self.webView.load(request)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackground
        self.topSafeAreaView.backgroundColor = UIColor.App.mainBackground
        self.navigationView.backgroundColor = UIColor.App.mainBackground

        self.webView.backgroundColor = UIColor.App.secondaryBackground
    }


    @IBAction private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension MatchFieldWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.stopAnimating()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicatorView.stopAnimating()
    }
}
