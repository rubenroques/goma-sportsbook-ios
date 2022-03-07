//
//  BonusDetailViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 04/03/2022.
//

import UIKit

class BonusDetailViewController: UIViewController {
    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var descriptionLabel: UILabel = Self.createDescriptionLabel()
    private lazy var termsTitleLabel: UILabel = Self.createTermsTitleLabel()
    private lazy var termsLinkLabel: UILabel = Self.createTermsLinkLabel()
    private var bonus: EveryMatrix.ApplicableBonus

    // MARK: Lifetime and Cycle
    init(bonus: EveryMatrix.ApplicableBonus) {
        self.bonus = bonus
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

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)

        let termsLinktap = UITapGestureRecognizer(target: self, action: #selector(didTapTermsLinkLabel))

        self.termsLinkLabel.isUserInteractionEnabled = true
        self.termsLinkLabel.addGestureRecognizer(termsLinktap)

        self.setupBonusDetails()
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.descriptionLabel.textColor = UIColor.App.textPrimary

        self.termsTitleLabel.textColor = UIColor.App.textPrimary

        self.termsLinkLabel.textColor = UIColor.App.textPrimary
    }

    private func setupBonusDetails() {
        self.titleLabel.text = self.bonus.name

        self.descriptionLabel.text = self.bonus.description

        self.termsTitleLabel.text = localized("terms_conditions")

        self.termsLinkLabel.text = "https://sportsbook.gomagaming.com/terms/bonus"
    }

}

//
// MARK: - Actions
//
extension BonusDetailViewController {
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapTermsLinkLabel() {
        if let url = URL(string: "https://sportsbook.gomagaming.com/terms/bonus") {
            UIApplication.shared.open(url)
        }
    }

}

//
// MARK: Subviews initialization and setup
//
extension BonusDetailViewController {

    private static func createTopView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        return button
    }

    private static func createTopTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("bonus")
        label.font = AppFont.with(type: .bold, size: 17)
        label.textAlignment = .center
        return label
    }

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Title"
        label.font = AppFont.with(type: .bold, size: 20)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createDescriptionLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Description"
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createTermsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Terms"
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createTermsLinkLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Terms Link"
        label.font = AppFont.with(type: .medium, size: 10)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)

        self.view.addSubview(self.containerView)

        self.containerView.addSubview(self.titleLabel)
        self.containerView.addSubview(self.descriptionLabel)
        self.containerView.addSubview(self.termsTitleLabel)
        self.containerView.addSubview(self.termsLinkLabel)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topView.heightAnchor.constraint(equalToConstant: 70),

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 30),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 20),
            self.backButton.widthAnchor.constraint(equalToConstant: 15),

            self.topTitleLabel.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 40),
            self.topTitleLabel.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -40),
            self.topTitleLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor)

        ])

        // Container view
        NSLayoutConstraint.activate([
            self.containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.containerView.topAnchor.constraint(equalTo: self.topView.bottomAnchor),
            self.containerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 35),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -35),
            self.titleLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 30),

            self.descriptionLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 35),
            self.descriptionLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -35),
            self.descriptionLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 20),

            self.termsTitleLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 35),
            self.termsTitleLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -35),
            self.termsTitleLabel.topAnchor.constraint(equalTo: self.descriptionLabel.bottomAnchor, constant: 30),

            self.termsLinkLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 35),
            self.termsLinkLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -35),
            self.termsLinkLabel.topAnchor.constraint(equalTo: self.termsTitleLabel.bottomAnchor, constant: 20),
        ])
    }

}
