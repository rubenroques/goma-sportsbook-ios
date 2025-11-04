//
//  ExtendedListFooterViewController.swift
//  GomaUIDemo
//
//  Created on 02/11/2025.
//

import UIKit
import GomaUI

// MARK: - Extended List Footer View Controller

class ExtendedListFooterViewController: UIViewController {

    // MARK: - Properties

    private lazy var scrollView: UIScrollView = Self.createScrollView()
    private lazy var footerView: ExtendedListFooterView = Self.createFooterView()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSubviews()
        setupBindings()
    }

    // MARK: - Setup

    private func setupView() {
        title = "Extended List Footer"
        view.backgroundColor = StyleProvider.Color.backgroundPrimary
    }

    private func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(footerView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            footerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            footerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            footerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func setupBindings() {
        // Footer view already has tap handlers configured in createFooterView()
    }
}

// MARK: - Subviews Initialization

extension ExtendedListFooterViewController {

    private static func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        return scrollView
    }

    private static func createFooterView() -> ExtendedListFooterView {
        let viewModel = MockExtendedListFooterViewModel.cameroonFooter

        // Configure tap handler for demo
        viewModel.onLinkTap = { [weak viewModel] linkType in
            switch linkType {
            case .termsAndConditions:
                print("📄 Demo: Tapped Terms and Conditions")
                showAlert(title: "Terms and Conditions", message: "Would open terms page in production")

            case .affiliates:
                print("🤝 Demo: Tapped Affiliates")
                showAlert(title: "Affiliates", message: "Would open affiliates page in production")

            case .privacyPolicy:
                print("🔒 Demo: Tapped Privacy Policy")
                showAlert(title: "Privacy Policy", message: "Would open privacy policy page in production")

            case .cookiePolicy:
                print("🍪 Demo: Tapped Cookie Policy")
                showAlert(title: "Cookie Policy", message: "Would open cookie policy page in production")

            case .responsibleGambling:
                print("⚠️ Demo: Tapped Responsible Gambling")
                showAlert(title: "Responsible Gambling", message: "Would open responsible gambling resources in production")

            case .gameRules:
                print("📋 Demo: Tapped Game Rules")
                showAlert(title: "Game Rules", message: "Would open game rules page in production")

            case .helpCenter:
                print("❓ Demo: Tapped Help Center")
                showAlert(title: "Help Center", message: "Would open help center in production")

            case .contactUs:
                print("📧 Demo: Tapped Contact Us")
                showAlert(title: "Contact Us", message: "Would open email composer in production: support-en@betsson.com")

            case .socialMedia(let platform):
                print("📱 Demo: Tapped Social Media - \(platform.displayName)")
                showAlert(title: platform.displayName, message: "Would open \(platform.displayName) app/website in production")
            }
        }

        return ExtendedListFooterView(viewModel: viewModel)
    }

    private static func showAlert(title: String, message: String) {
        // Get the top-most view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootVC = window.rootViewController else {
            return
        }

        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        topVC.present(alert, animated: true)
    }
}
