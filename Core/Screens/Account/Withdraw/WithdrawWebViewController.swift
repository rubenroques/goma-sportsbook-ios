//
//  WithdrawWebViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 21/12/2021.
//

import UIKit
import WebKit

class WithdrawWebViewController: UIViewController {

    @IBOutlet private var topView: UIView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var navigationView: UIView!
    @IBOutlet private var navigationLabel: UILabel!
    @IBOutlet private var navigationButton: UIButton!
    @IBOutlet private var webView: WKWebView!

    // Variables
    var withdrawUrl: String?

    init(withdrawUrl: String? = nil) {

        self.withdrawUrl = withdrawUrl

        super.init(nibName: "WithdrawWebViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.commonInit()
        self.setupWithTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func commonInit() {
        self.navigationLabel.text = localized("withdraw")
        self.navigationLabel.font = AppFont.with(type: .bold, size: 17)

        self.navigationButton.setImage(UIImage(named: "thin_close_cross_icon"), for: .normal)
        self.navigationButton.contentMode = .scaleAspectFit

        self.setupWebView()
    }

    func setupWithTheme() {
        self.topView.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = .clear

        self.navigationLabel.textColor = UIColor.App.textPrimary

        self.navigationButton.backgroundColor = .clear
        self.navigationButton.tintColor = UIColor.App.textPrimary
    }

    func setupWebView() {

        guard let withdrawUrlString = self.withdrawUrl else { return }

        guard let withdrawUrl = URL(string: withdrawUrlString) else { return }

        self.webView.load(URLRequest(url: withdrawUrl))
    }

    @IBAction func didTapCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }

}
