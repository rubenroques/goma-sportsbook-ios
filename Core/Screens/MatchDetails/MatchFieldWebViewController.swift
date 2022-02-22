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

    @IBOutlet private weak var heightConstraint: NSLayoutConstraint!

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

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary
        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary
        self.navigationView.backgroundColor = UIColor.App.backgroundPrimary

        self.webView.backgroundColor = UIColor.App.backgroundSecondary
    }

    @IBAction private func didTapBackButton() {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    private func recalculateWebview() {

        executeDelayed(0.5) {

            self.webView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { height, error in
                if let heightFloat = height as? CGFloat {
                    self.redrawWebView(withHeight: heightFloat)
                }
            })
        }
    }

    private func redrawWebView(withHeight heigth: CGFloat) {
        self.heightConstraint.constant = heigth
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        self.recalculateWebview()
    }
}

extension MatchFieldWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.stopAnimating()

        self.webView.evaluateJavaScript("document.readyState", completionHandler: { complete, error in
            if complete != nil {
                self.recalculateWebview()
            }
        })

    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicatorView.stopAnimating()
    }

}
