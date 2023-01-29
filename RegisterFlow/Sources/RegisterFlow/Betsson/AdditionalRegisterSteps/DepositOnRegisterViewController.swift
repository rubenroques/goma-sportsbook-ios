//
//  DepositOnRegisterViewController.swift
//  
//
//  Created by Ruben Roques on 27/01/2023.
//

import Foundation
import Foundation
import UIKit
import Theming

public class DepositOnRegisterViewController: UIViewController {

    public var didTapDepositButtonAction: () -> Void = { }

    public var didTapBackButtonAction: () -> Void = { }
    public var didTapCancelButtonAction: () -> Void = { }

    private lazy var headerBaseView: UIView = Self.createHeaderBaseView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var cancelButton: UIButton = Self.createCancelButton()

    private lazy var contentBaseView: UIView = Self.createContentBaseView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()

    private lazy var footerBaseView: UIView = Self.createFooterBaseView()
    private lazy var depositButton: UIButton = Self.createDepositButton()

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.titleLabel.text = "Deposit"
        self.subtitleLabel.text = "Make your first deposit and win 5€ of freebet."

        self.depositButton.setTitle("Deposit", for: .normal)

        self.depositButton.addTarget(self, action: #selector(didTapDepositButton), for: .primaryActionTriggered)

        self.cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .primaryActionTriggered)
        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = AppColor.backgroundPrimary
        self.contentBaseView.backgroundColor = AppColor.backgroundPrimary

        self.cancelButton.setTitleColor(AppColor.highlightPrimary, for: .normal)

        self.titleLabel.textColor = AppColor.textPrimary
        self.subtitleLabel.textColor = AppColor.textPrimary

        // Continue button styling
        self.depositButton.setTitleColor(AppColor.buttonTextPrimary, for: .normal)
        self.depositButton.setTitleColor(AppColor.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.depositButton.setTitleColor(AppColor.buttonTextDisablePrimary.withAlphaComponent(0.39), for: .disabled)

        self.depositButton.setBackgroundColor(AppColor.buttonBackgroundPrimary, for: .normal)
        self.depositButton.setBackgroundColor(AppColor.buttonBackgroundSecondary, for: .highlighted)

        self.depositButton.layer.cornerRadius = 8
        self.depositButton.layer.masksToBounds = true
        self.depositButton.backgroundColor = .clear

    }

    @objc func didTapBackButton() {
        self.didTapBackButtonAction()
    }

    @objc func didTapCancelButton() {
        self.didTapCancelButtonAction()
    }

    @objc func didTapDepositButton() {
        self.didTapDepositButtonAction()
    }

}

public extension DepositOnRegisterViewController {

    private static func createHeaderBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        let image = UIImage(named: "back_icon", in: Bundle.module, with: nil)
        button.setImage(image, for: .normal)
        button.setTitle(nil, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private static func createCancelButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Close", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    private static func createContentBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createFeedbackImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 30)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createFooterBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createDepositButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        return button
    }

    private func setupSubviews() {

        self.view.addSubview(self.headerBaseView)
        self.headerBaseView.addSubview(self.backButton)
        self.headerBaseView.addSubview(self.cancelButton)

        self.view.addSubview(self.contentBaseView)
        self.contentBaseView.addSubview(self.titleLabel)
        self.contentBaseView.addSubview(self.subtitleLabel)

        self.view.addSubview(self.footerBaseView)
        self.footerBaseView.addSubview(self.depositButton)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.headerBaseView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.headerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerBaseView.heightAnchor.constraint(equalToConstant: 68),

            self.backButton.leadingAnchor.constraint(equalTo: self.headerBaseView.leadingAnchor, constant: 18),
            self.backButton.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.backButton.widthAnchor.constraint(equalTo: self.backButton.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.cancelButton.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.cancelButton.trailingAnchor.constraint(equalTo: self.headerBaseView.trailingAnchor, constant: -34),

            self.titleLabel.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor, constant: 8),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),

            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 28),
            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),
            self.subtitleLabel.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor, constant: -8),

            self.contentBaseView.leadingAnchor.constraint(equalTo: self.depositButton.leadingAnchor),
            self.contentBaseView.trailingAnchor.constraint(equalTo: self.depositButton.trailingAnchor),

            self.contentBaseView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -10),

            self.footerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.footerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.footerBaseView.heightAnchor.constraint(equalToConstant: 70),
            self.footerBaseView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.depositButton.centerXAnchor.constraint(equalTo: self.footerBaseView.centerXAnchor),
            self.depositButton.centerYAnchor.constraint(equalTo: self.footerBaseView.centerYAnchor),
            self.depositButton.leadingAnchor.constraint(equalTo: self.footerBaseView.leadingAnchor, constant: 34),
            self.depositButton.heightAnchor.constraint(equalToConstant: 50),

        ])
    }

}
