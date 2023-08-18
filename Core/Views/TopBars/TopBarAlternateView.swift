//
//  TopBarView.swift
//  Sportsbook
//
//  Created by André Lascas on 30/05/2023.
//

import UIKit
import Combine

class TopBarView: UIView {

    // MARK: Private properties
    private lazy var topBarView: UIView = Self.createTopBarView()
    private lazy var appIconImageView: UIImageView = Self.createAppIconImageView()
    private lazy var profileBaseView: UIView = Self.createProfileBaseView()
    private lazy var profilePictureBaseView: UIView = Self.createProfilePictureBaseView()
    private lazy var profilePictureBaseInnerView: UIView = Self.createProfilePictureBaseInnerView()
    private lazy var profilePictureImageView: UIImageView = Self.createProfilePictureImageView()
    private lazy var anonymousUserMenuBaseView: UIView = Self.createAnonymousUserMenuBaseView()
    private lazy var anonymousUserMenuImageView: UIImageView = Self.createAnonymousUserMenuImageView()
    private lazy var userInfoStackView: UIStackView = Self.createUserInfoStackView()
    private lazy var accountValueBaseView: UIView = Self.createAccountValueBaseView()
    private lazy var accountValueView: UIView = Self.createAccountValueView()
    private lazy var accountPlusView: UIView = Self.createAccountPlusView()
    private lazy var accountValueLabel: UILabel = Self.createAccountValueLabel()
    private lazy var accountPlusImageView: UIImageView = Self.createAccountPlusImageView()
    private lazy var cashbackBaseView: UIView = Self.createCashbackBaseView()
    private lazy var cashbackView: UIView = Self.createCashbackView()
    private lazy var cashbackIconImageView: UIImageView = Self.createCashbackIconImageView()
    private lazy var cashbackLabel: UILabel = Self.createCashbackLabel()
    private lazy var loginBaseView: UIView = Self.createLoginBaseView()
    private lazy var loginButton: UIButton = Self.createLoginButton()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public properties
    var shouldShowProfile: (() -> Void)?
    var shouldShowLogin: (() -> Void)?
    var shouldShowDeposit: (() -> Void)?
    var shouldShowReplay: (() -> Void)?
    var shouldShowAnonymousMenu: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupSubviews()

        self.commonInit()

        self.setupWithTheme()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setupSubviews()

        self.commonInit()

        self.setupWithTheme()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.profilePictureBaseView.layer.cornerRadius = profilePictureBaseView.frame.size.width/2

        self.profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width/2
        self.profilePictureImageView.layer.masksToBounds = false
        self.profilePictureImageView.clipsToBounds = true

        self.profilePictureBaseInnerView.layer.cornerRadius = self.profilePictureBaseInnerView.frame.size.width/2

        self.accountValueView.layer.cornerRadius = CornerRadius.view
        self.accountValueView.layer.masksToBounds = true
        self.accountValueView.isUserInteractionEnabled = true

        self.accountPlusView.layer.cornerRadius = CornerRadius.squareView
        self.accountPlusView.layer.masksToBounds = true

        self.accountPlusImageView.setImageColor(color: UIColor.App.buttonTextPrimary)

        self.cashbackView.layer.cornerRadius = CornerRadius.squareView
        self.cashbackView.layer.masksToBounds = true
    }

    func setupWithTheme() {

        if TargetVariables.shouldUseGradientBackgrounds {

            self.topBarView.backgroundColor = .clear
        }
        else {
            self.topBarView.backgroundColor = UIColor.App.backgroundPrimary
        }

        self.profilePictureBaseView.backgroundColor = UIColor.App.highlightPrimary
        self.profilePictureBaseInnerView.backgroundColor = UIColor.App.backgroundPrimary

        self.userInfoStackView.backgroundColor = .clear

        self.accountValueLabel.textColor = UIColor.App.textPrimary
        self.accountValueView.backgroundColor = UIColor.App.highlightPrimaryContrast.withAlphaComponent(0.1)
        self.accountPlusView.backgroundColor = UIColor.App.highlightSecondary

        self.cashbackLabel.textColor = UIColor.App.textSecondary
        self.cashbackView.backgroundColor = UIColor.App.highlightPrimaryContrast.withAlphaComponent(0.05)

        self.loginButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.loginButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.loginButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.4), for: .disabled)
        self.loginButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        self.loginButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .highlighted)

        self.loginButton.layer.cornerRadius = CornerRadius.view
        self.loginButton.layer.masksToBounds = true

    }

    private func commonInit() {

        self.loginButton.addTarget(self, action: #selector(self.didTapLoginButton), for: UIControl.Event.primaryActionTriggered)

        let profileTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileButton))
        self.profilePictureBaseView.addGestureRecognizer(profileTapGesture)

        self.accountValueLabel.text = localized("loading")
        self.accountValueLabel.font = AppFont.with(type: .bold, size: 12)

        let accountValueTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAccountValue))
        self.accountValueView.addGestureRecognizer(accountValueTapGesture)

        let anonymousTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAnonymousButton))
        self.anonymousUserMenuBaseView.addGestureRecognizer(anonymousTapGesture)

        let replayTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapReplayBaseView))
        self.cashbackBaseView.addGestureRecognizer(replayTapGesture)
        
        // Cashback
        Env.userSessionStore.userCashbackBalance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cashbackBalance in
                if let cashbackBalance = cashbackBalance,
                   let formattedTotalString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: cashbackBalance)) {
                    self?.cashbackLabel.text = formattedTotalString
                }
                else {
                    self?.cashbackLabel.text = "-.--€"
                }
            }
            .store(in: &cancellables)

        Env.userSessionStore.refreshUserWallet()

        // User Profile
        if let userProfile = Env.userSessionStore.userProfilePublisher.value {
            self.setupWithState(screenState: .logged(user: userProfile))

            if let avatarName = userProfile.avatarName {
                self.profilePictureImageView.image = UIImage(named: avatarName)
            }
            else {

                self.profilePictureImageView.image = UIImage(named: "empty_user_image")
            }
        }
        else {
            self.setupWithState(screenState: .anonymous)

        }

        // User Wallet
        if let userWallet = Env.userSessionStore.userWalletPublisher.value {
            if let formattedTotalString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: userWallet.total)) {

                self.accountValueLabel.text = formattedTotalString
            }
        }
        else {
            self.accountValueLabel.text = "-.--€"
        }

        self.setupPublishers()
        
    }

    private func setupPublishers() {

        Env.userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                if let userProfile = userProfile {

                    self?.setupWithState(screenState: .logged(user: userProfile))

                    if let avatarName = userProfile.avatarName {
                        self?.profilePictureImageView.image = UIImage(named: avatarName)
                    }
                    else {

                        self?.profilePictureImageView.image = UIImage(named: "empty_user_image")
                    }
                }
                else {
                    self?.setupWithState(screenState: .anonymous)
                }
            }
            .store(in: &cancellables)

        Env.userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userWallet in
                if let userWallet = userWallet,
                   let formattedTotalString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: userWallet.total)) {
                    self?.accountValueLabel.text = formattedTotalString
                }
                else {
                    self?.accountValueLabel.text = "-.--€"
                }
            }
            .store(in: &cancellables)
    }

    func setupWithState(screenState: ScreenState) {

        switch screenState {
        case .logged:
            self.profilePictureBaseView.isHidden = false
            self.anonymousUserMenuBaseView.isHidden = true

            self.accountValueBaseView.isHidden = false
            self.cashbackBaseView.isHidden = false

            self.loginBaseView.isHidden = true
        case .anonymous:
            self.profilePictureBaseView.isHidden = true
            self.anonymousUserMenuBaseView.isHidden = false

            self.accountValueBaseView.isHidden = true
            self.cashbackBaseView.isHidden = true

            self.loginBaseView.isHidden = false
        }
//        if isLogged {
//            self.profilePictureBaseView.isHidden = false
//            self.anonymousUserMenuBaseView.isHidden = true
//
//            self.accountValueBaseView.isHidden = false
//            self.cashbackBaseView.isHidden = false
//
//            self.loginBaseView.isHidden = true
//        }
//        else {
//            self.profilePictureBaseView.isHidden = true
//            self.anonymousUserMenuBaseView.isHidden = false
//
//            self.accountValueBaseView.isHidden = true
//            self.cashbackBaseView.isHidden = true
//
//            self.loginBaseView.isHidden = false
//        }
    }

    // MARK: Action

    @objc private func didTapLoginButton() {
        self.shouldShowLogin?()
    }

    @objc private func didTapProfileButton() {
        self.shouldShowProfile?()
    }

    @objc private func didTapAccountValue() {
        self.shouldShowDeposit?()
    }

    @objc private func didTapAnonymousButton() {
        self.shouldShowAnonymousMenu?()
    }

    @objc private func didTapReplayBaseView() {
        self.shouldShowReplay?()
    }

}

extension TopBarView {

    private static func createTopBarView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAppIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logo_horizontal_left")
        return imageView
    }

    private static func createProfileBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createProfilePictureBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createProfilePictureBaseInnerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createProfilePictureImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "empty_user_image")
        return imageView
    }

    private static func createAnonymousUserMenuBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAnonymousUserMenuImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "side_menu_icon")
        return imageView
    }

    private static func createUserInfoStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }

    private static func createAccountValueBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAccountValueView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAccountPlusView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAccountValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "-.--"
        label.font = AppFont.with(type: .bold, size: 12)
        return label
    }

    private static func createAccountPlusImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "plus_small_icon")
        return imageView
    }

    private static func createCashbackBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCashbackView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCashbackIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "cashback_small_blue_icon")
        return imageView
    }

    private static func createCashbackLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "-.--"
        label.font = AppFont.with(type: .bold, size: 12)
        return label
    }

    private static func createLoginBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoginButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("login"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 13)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 11, right: 16)
        return button
    }

    private func setupSubviews() {

        self.addSubview(self.topBarView)

        self.topBarView.addSubview(self.appIconImageView)

        self.topBarView.addSubview(profileBaseView)

        self.profileBaseView.addSubview(self.profilePictureBaseView)

        self.profilePictureBaseView.addSubview(self.profilePictureBaseInnerView)
        self.profilePictureBaseView.addSubview(self.profilePictureImageView)

        self.profileBaseView.addSubview(self.anonymousUserMenuBaseView)

        self.anonymousUserMenuBaseView.addSubview(self.anonymousUserMenuImageView)

        self.topBarView.addSubview(self.userInfoStackView)

        // Cashback
        self.userInfoStackView.addArrangedSubview(self.cashbackBaseView)

        self.cashbackBaseView.addSubview(self.cashbackView)

        self.cashbackView.addSubview(self.cashbackIconImageView)
        self.cashbackView.addSubview(self.cashbackLabel)

        // Acount value
        self.userInfoStackView.addArrangedSubview(self.accountValueBaseView)

        self.accountValueBaseView.addSubview(self.accountValueView)

        self.accountValueView.addSubview(self.accountPlusView)
        self.accountValueView.addSubview(self.accountValueLabel)

        self.accountPlusView.addSubview(self.accountPlusImageView)

        self.userInfoStackView.addArrangedSubview(self.loginBaseView)

        self.loginBaseView.addSubview(self.loginButton)

        self.initConstraints()

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([

            self.topBarView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.topBarView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.topBarView.topAnchor.constraint(equalTo: self.topAnchor),
            self.topBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.topBarView.heightAnchor.constraint(equalToConstant: 64),

            self.appIconImageView.leadingAnchor.constraint(equalTo: self.topBarView.leadingAnchor, constant: 15),
            self.appIconImageView.centerYAnchor.constraint(equalTo: self.topBarView.centerYAnchor),
            self.appIconImageView.heightAnchor.constraint(equalToConstant: 30),
            self.appIconImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 130),

            self.profileBaseView.trailingAnchor.constraint(equalTo: self.topBarView.trailingAnchor, constant: -15),
            self.profileBaseView.centerYAnchor.constraint(equalTo: self.topBarView.centerYAnchor),
            self.profileBaseView.widthAnchor.constraint(equalToConstant: 45),
            self.profileBaseView.heightAnchor.constraint(equalTo: self.profileBaseView.widthAnchor),

            self.profilePictureBaseView.widthAnchor.constraint(equalToConstant: 35),
            self.profilePictureBaseView.heightAnchor.constraint(equalTo: self.profilePictureBaseView.widthAnchor),
            self.profilePictureBaseView.centerXAnchor.constraint(equalTo: self.profileBaseView.centerXAnchor),
            self.profilePictureBaseView.centerYAnchor.constraint(equalTo: self.profileBaseView.centerYAnchor),

            self.profilePictureBaseInnerView.leadingAnchor.constraint(equalTo: self.profilePictureBaseView.leadingAnchor, constant: 1),
            self.profilePictureBaseInnerView.trailingAnchor.constraint(equalTo: self.profilePictureBaseView.trailingAnchor, constant: -1),
            self.profilePictureBaseInnerView.topAnchor.constraint(equalTo: self.profilePictureBaseView.topAnchor, constant: 1),
            self.profilePictureBaseInnerView.bottomAnchor.constraint(equalTo: self.profilePictureBaseView.bottomAnchor, constant: -1),

            self.profilePictureImageView.widthAnchor.constraint(equalToConstant: 40),
            self.profilePictureImageView.heightAnchor.constraint(equalTo: self.profilePictureImageView.widthAnchor),
            self.profilePictureImageView.centerXAnchor.constraint(equalTo: self.profilePictureBaseView.centerXAnchor),
            self.profilePictureImageView.centerYAnchor.constraint(equalTo: self.profilePictureBaseView.centerYAnchor),

            self.anonymousUserMenuBaseView.leadingAnchor.constraint(equalTo: self.profilePictureBaseView.leadingAnchor),
            self.anonymousUserMenuBaseView.trailingAnchor.constraint(equalTo: self.profilePictureBaseView.trailingAnchor),
            self.anonymousUserMenuBaseView.topAnchor.constraint(equalTo: self.profilePictureBaseView.topAnchor),
            self.anonymousUserMenuBaseView.bottomAnchor.constraint(equalTo: self.profilePictureBaseView.bottomAnchor),

            self.anonymousUserMenuImageView.leadingAnchor.constraint(equalTo: self.anonymousUserMenuBaseView.leadingAnchor, constant: 3),
            self.anonymousUserMenuImageView.trailingAnchor.constraint(equalTo: self.anonymousUserMenuBaseView.trailingAnchor, constant: -3),
            self.anonymousUserMenuImageView.topAnchor.constraint(equalTo: self.anonymousUserMenuBaseView.topAnchor, constant: 3),
            self.anonymousUserMenuImageView.bottomAnchor.constraint(equalTo: self.anonymousUserMenuBaseView.bottomAnchor, constant: -3),

            //self.userInfoStackView.leadingAnchor.constraint(equalTo: self.appIconImageView.trailingAnchor, constant: 4),
            self.userInfoStackView.trailingAnchor.constraint(equalTo: self.profileBaseView.leadingAnchor, constant: -4),
            self.userInfoStackView.topAnchor.constraint(equalTo: self.topBarView.topAnchor),
            self.userInfoStackView.bottomAnchor.constraint(equalTo: self.topBarView.bottomAnchor),

            // Account value
            self.accountValueBaseView.centerYAnchor.constraint(equalTo: self.userInfoStackView.centerYAnchor),

            self.accountValueView.leadingAnchor.constraint(equalTo: self.accountValueBaseView.leadingAnchor),
            self.accountValueView.trailingAnchor.constraint(equalTo: self.accountValueBaseView.trailingAnchor),
            self.accountValueView.heightAnchor.constraint(equalToConstant: 24),
            self.accountValueView.centerYAnchor.constraint(equalTo: self.accountValueBaseView.centerYAnchor),

            self.accountPlusView.leadingAnchor.constraint(equalTo: self.accountValueView.leadingAnchor, constant: 4),
            self.accountPlusView.topAnchor.constraint(equalTo: self.accountValueView.topAnchor, constant: 4),
            self.accountPlusView.bottomAnchor.constraint(equalTo: self.accountValueView.bottomAnchor, constant: -4),
            self.accountPlusView.widthAnchor.constraint(equalToConstant: 14),

            self.accountPlusImageView.widthAnchor.constraint(equalToConstant: 12),
            self.accountPlusImageView.heightAnchor.constraint(equalTo: self.accountPlusImageView.widthAnchor),
            self.accountPlusImageView.centerXAnchor.constraint(equalTo: self.accountPlusView.centerXAnchor),
            self.accountPlusImageView.centerYAnchor.constraint(equalTo: self.accountPlusView.centerYAnchor),

            self.accountValueLabel.leadingAnchor.constraint(equalTo: self.accountPlusView.trailingAnchor, constant: 4),
            self.accountValueLabel.trailingAnchor.constraint(equalTo: self.accountValueView.trailingAnchor, constant: -4),
            self.accountValueLabel.centerYAnchor.constraint(equalTo: self.accountValueView.centerYAnchor),

            // Cashback
            self.cashbackBaseView.centerYAnchor.constraint(equalTo: self.userInfoStackView.centerYAnchor),

            self.cashbackView.leadingAnchor.constraint(equalTo: self.cashbackBaseView.leadingAnchor),
            self.cashbackView.trailingAnchor.constraint(equalTo: self.cashbackBaseView.trailingAnchor),
            self.cashbackView.heightAnchor.constraint(equalToConstant: 24),
            self.cashbackView.centerYAnchor.constraint(equalTo: self.cashbackBaseView.centerYAnchor),

            self.cashbackIconImageView.leadingAnchor.constraint(equalTo: self.cashbackView.leadingAnchor, constant: 4),
            self.cashbackIconImageView.topAnchor.constraint(equalTo: self.cashbackView.topAnchor, constant: 4),
            self.cashbackIconImageView.bottomAnchor.constraint(equalTo: self.cashbackView.bottomAnchor, constant: -4),
            self.cashbackIconImageView.widthAnchor.constraint(equalToConstant: 14),

            self.cashbackLabel.leadingAnchor.constraint(equalTo: self.cashbackIconImageView.trailingAnchor, constant: 4),
            self.cashbackLabel.trailingAnchor.constraint(equalTo: self.cashbackView.trailingAnchor, constant: -4),
            self.cashbackLabel.centerYAnchor.constraint(equalTo: self.cashbackView.centerYAnchor),

            self.loginBaseView.centerYAnchor.constraint(equalTo: self.userInfoStackView.centerYAnchor),

            self.loginButton.leadingAnchor.constraint(equalTo: self.loginBaseView.leadingAnchor),
            self.loginButton.trailingAnchor.constraint(equalTo: self.loginBaseView.trailingAnchor),
            self.loginButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            self.loginButton.heightAnchor.constraint(equalToConstant: 30),
            self.loginButton.centerYAnchor.constraint(equalTo: self.loginBaseView.centerYAnchor)

        ])

    }

}
