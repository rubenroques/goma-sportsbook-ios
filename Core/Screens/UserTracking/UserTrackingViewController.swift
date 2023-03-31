//
//  UserTrackingViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 31/03/2023.
//

import Foundation
import UIKit
import Combine

struct UserTrackingViewModel {

}

class UserTrackingViewController: UIViewController {

    // MARK: - Variables
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var navigationBaseView: UIView = Self.createNavigationBaseView()
    private lazy var backButtonBaseView: UIView = Self.createBackButtonBaseView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()

    private lazy var continueButton: UIButton = Self.createContinueButton()
    private lazy var settingsButton: UIButton = Self.createSettingsButton()
    private lazy var skipButton: UIButton = Self.createSkipButton()

    private lazy var contentBaseView: UIView = Self.createContentBaseView()
    private lazy var contentScrollView: UIScrollView = Self.createScrollBaseView()

    private lazy var descriptionTextLabel: UILabel = Self.createDescriptionTextLabel()

    private lazy var buttonsStackView: UIStackView = Self.createButtonsStackView()
    private lazy var bottomBaseView: UIView = Self.createBottomBaseView()

    private var viewModel: UserTrackingViewModel
    var cancellables = Set<AnyCancellable>()

    // MARK: - Lifetime and Cycle
    init(viewModel: UserTrackingViewModel) {
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
        self.commonInit()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }
    func commonInit() {
        self.backButton.isHidden = true

        self.continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .primaryActionTriggered)
        self.settingsButton.addTarget(self, action: #selector(didTapSettingsButton), for: .primaryActionTriggered)
        self.skipButton.addTarget(self, action: #selector(didTapSkipButton), for: .primaryActionTriggered)
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary
        self.topSafeAreaView.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationBaseView.backgroundColor = UIColor.App.backgroundPrimary
        self.titleLabel.backgroundColor = .clear
        self.titleLabel.textColor = UIColor.App.textPrimary

    }

    // MARK: - Actions

    @objc func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc func didTapContinueButton() {
        Env.userSessionStore.didAcceptedTracking()
    }

    @objc func didTapSettingsButton() {

    }

    @objc func didTapSkipButton() {
        Env.userSessionStore.didSkipedTracking()
    }

}

//
// MARK: - Subviews Initialization and Setup
//
extension UserTrackingViewController {

    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButtonBaseView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBaseView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNavigationBaseView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
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

    private static func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.text = "Tracking Policy"
        titleLabel.font = AppFont.with(type: .bold, size: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textAlignment = .center
        return titleLabel
    }

    private static func createContentBaseView() -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createScrollBaseView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    private static func createDescriptionTextLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = """
                Bienvenue sur Betsson.fr

                Nous respectons vos données, nous souhaitons aussi vous offrir une expérience optimisée:

                - au travers d'une application performante et sécurisée.

                - une offre pertinente via des publicités adaptées.

                Nos partenaires et nous même utilisons des services et cookies afin de vous fournir ses engagements en toute sécurité.

                Il vous ait possible de changer vos préférences.
                """
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createBottomBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createButtonsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 18
        return stackView
    }


    private static func createContinueButton() -> UIButton {
        let sendButton = UIButton()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Tout accepter", for: .normal)
        StyleHelper.styleButton(button: sendButton)
        sendButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        return sendButton
    }

    private static func createSettingsButton() -> UIButton {
        let sendButton = UIButton()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Paramétrer", for: .normal)
        StyleHelper.styleButton(button: sendButton)
        sendButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .normal)
        return sendButton
    }

    private static func createSkipButton() -> UIButton {
        let sendButton = UIButton()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.setTitle("Continuer sans accepter", for: .normal)
        StyleHelper.styleButton(button: sendButton)
        sendButton.setBackgroundColor(.clear, for: .normal)
        sendButton.setTitleColor(UIColor.App.textSecondary, for: .normal)
        return sendButton
    }

    private func setupSubviews() {
        self.navigationBaseView.addSubview(self.titleLabel)
        self.navigationBaseView.addSubview(self.backButtonBaseView)

        self.backButtonBaseView.addSubview(self.backButton)

        self.contentBaseView.addSubview(self.descriptionTextLabel)

        self.buttonsStackView.addArrangedSubview(self.continueButton)
        self.buttonsStackView.addArrangedSubview(self.settingsButton)
        self.buttonsStackView.addArrangedSubview(self.skipButton)

        self.bottomBaseView.addSubview(self.buttonsStackView)

        self.view.addSubview(self.topSafeAreaView)
        self.view.addSubview(self.navigationBaseView)
        self.view.addSubview(self.contentBaseView)

        self.view.addSubview(self.bottomBaseView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        ])

        NSLayoutConstraint.activate([
            self.navigationBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.navigationBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.navigationBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.navigationBaseView.bottomAnchor.constraint(equalTo: self.view.topAnchor, constant: 140),

            self.titleLabel.centerXAnchor.constraint(equalTo: self.navigationBaseView.centerXAnchor),
            self.titleLabel.centerYAnchor.constraint(equalTo: self.backButtonBaseView.centerYAnchor),

            self.backButtonBaseView.leadingAnchor.constraint(equalTo: self.navigationBaseView.leadingAnchor, constant: 27),
            self.backButtonBaseView.centerYAnchor.constraint(equalTo: self.navigationBaseView.centerYAnchor),
            self.backButtonBaseView.heightAnchor.constraint(equalToConstant: 20),
            self.backButtonBaseView.widthAnchor.constraint(equalToConstant: 20),
        ])

        NSLayoutConstraint.activate([
            self.contentBaseView.topAnchor.constraint(equalTo: self.navigationBaseView.bottomAnchor),
            self.contentBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.contentBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.contentBaseView.bottomAnchor.constraint(equalTo: self.bottomBaseView.topAnchor),

            self.descriptionTextLabel.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor, constant: 18),
            self.descriptionTextLabel.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 34),
            self.descriptionTextLabel.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -34),
        ])

        NSLayoutConstraint.activate([
            self.continueButton.heightAnchor.constraint(equalToConstant: 50),
            self.settingsButton.heightAnchor.constraint(equalToConstant: 50),
            self.skipButton.heightAnchor.constraint(equalToConstant: 50),

            self.buttonsStackView.leadingAnchor.constraint(equalTo: self.bottomBaseView.leadingAnchor, constant: 34),
            self.buttonsStackView.trailingAnchor.constraint(equalTo: self.bottomBaseView.trailingAnchor, constant: -34),
            self.buttonsStackView.bottomAnchor.constraint(equalTo: self.bottomBaseView.bottomAnchor),
            self.buttonsStackView.topAnchor.constraint(equalTo: self.bottomBaseView.topAnchor),

            self.bottomBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomBaseView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])

    }

}
