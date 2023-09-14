//
//  RegisterErrorViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 14/09/2023.
//

import UIKit

class RegisterErrorViewController: UIViewController {

    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var headerView: UIView = Self.createHeaderView()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var iconImageView: UIImageView = Self.createIconImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var continueButton: UIButton = Self.createContinueButton()

    var hasContinueFlow: Bool = false

    var didTapContinueAction: (() -> Void)?
    var didTapCloseAction: (() -> Void)?

    init() {

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

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        self.continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .primaryActionTriggered)

        self.hasContinueFlow = false
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

    }

    private func setupWithTheme() {
        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.closeButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.iconImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.subtitleLabel.textColor = UIColor.App.textPrimary

        StyleHelper.styleButton(button: self.continueButton)

    }

    func setTextInfo(title: String, subtitle: String) {

        self.titleLabel.text = title

        self.subtitleLabel.text = subtitle
    }

    @objc private func didTapCloseButton() {

        self.didTapCloseAction?()

    }

    @objc private func didTapContinueButton() {

        self.didTapContinueAction?()

    }

}

extension RegisterErrorViewController {

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createHeaderView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.setTitle(localized("close"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private static func createIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "avatar_check")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 30)
        label.text = "\(localized("oh_no"))!"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 16)
        label.text = localized("unsucess_register")
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createContinueButton() -> UIButton {
        let button = UIButton()
        button.setTitle(localized("contact_us"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private func setupSubviews() {

        self.view.addSubview(self.containerView)

        self.containerView.addSubview(self.headerView)

        self.headerView.addSubview(self.closeButton)

        self.containerView.addSubview(self.iconImageView)
        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.subtitleLabel)
        self.containerView.addSubview(self.continueButton)

        self.initConstraints()

    }

    private func initConstraints() {

        NSLayoutConstraint.activate([

            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.headerView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.headerView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.headerView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.headerView.heightAnchor.constraint(equalToConstant: 60),

            self.closeButton.trailingAnchor.constraint(equalTo: self.headerView.trailingAnchor, constant: -34),
            self.closeButton.centerYAnchor.constraint(equalTo: self.headerView.centerYAnchor),
            self.closeButton.heightAnchor.constraint(equalToConstant: 40),

            self.iconImageView.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            self.iconImageView.widthAnchor.constraint(equalToConstant: 200),
            self.iconImageView.heightAnchor.constraint(equalTo: self.iconImageView.widthAnchor),
            self.iconImageView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: 40),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 30),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -30),
            self.titleLabel.topAnchor.constraint(equalTo: self.iconImageView.bottomAnchor, constant: 30),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 30),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -30),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 20),

            self.continueButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 30),
            self.continueButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -30),
            self.continueButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -50),
            self.continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])

    }
}
