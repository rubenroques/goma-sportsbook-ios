//
//  TopBarAlternateView.swift
//  Sportsbook
//
//  Created by André Lascas on 30/05/2023.
//

import UIKit
import Combine

class TopBarAlternateView: UIView {

    // MARK: Private properties
    private lazy var topBarAlternateView: UIView = Self.createTopBarAlternateView()
    private lazy var appIconAlternateImageView: UIImageView = Self.createAppIconAlternateImageView()
    private lazy var profileAlternateBaseView: UIView = Self.createProfileAlternateBaseView()
    private lazy var profilePictureAlternateBaseView: UIView = Self.createProfilePictureAlternateBaseView()
    private lazy var profilePictureBaseInnerAlternateView: UIView = Self.createProfilePictureBaseInnerAlternateView()
    private lazy var profilePictureAlternateImageView: UIImageView = Self.createProfilePictureAlternateImageView()
    private lazy var anonymousUserMenuAlternateBaseView: UIView = Self.createAnonymousUserMenuAlternateBaseView()
    private lazy var anonymousUserMenuAlternateImageView: UIImageView = Self.createAnonymousUserMenuAlternateImageView()
    private lazy var userInfoAlternateStackView: UIStackView = Self.createUserInfoAlternateStackView()
    private lazy var accountValueAlternateBaseView: UIView = Self.createAccountValueAlternateBaseView()
    private lazy var accountValueAlternateView: UIView = Self.createAccountValueAlternateView()
    private lazy var accountPlusAlternateView: UIView = Self.createAccountPlusAlternateView()
    private lazy var accountValueAlternateLabel: UILabel = Self.createAccountValueAlternateLabel()
    private lazy var accountPlusAlternateImageView: UIImageView = Self.createAccountPlusAlternateImageView()
    private lazy var cashbackAlternateBaseView: UIView = Self.createCashbackAlternateBaseView()
    private lazy var cashbackAlternateView: UIView = Self.createCashbackAlternateView()
    private lazy var cashbackIconAlternateImageView: UIImageView = Self.createCashbackIconAlternateImageView()
    private lazy var cashbackAlternateLabel: UILabel = Self.createCashbackAlternateLabel()
    private lazy var loginAlternateBaseView: UIView = Self.createLoginAlternateBaseView()
    private lazy var loginAlternateButton: UIButton = Self.createLoginAlternateButton()

    private var cancellables = Set<AnyCancellable>()

    // MARK: Public properties
    var shouldShowProfile: (() -> Void)?
    var shouldShowLogin: (() -> Void)?
    var shouldShowDeposit: (() -> Void)?
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

        self.profilePictureAlternateBaseView.layer.cornerRadius = profilePictureAlternateBaseView.frame.size.width/2

        self.profilePictureAlternateImageView.layer.cornerRadius = profilePictureAlternateImageView.frame.size.width/2
        profilePictureAlternateImageView.layer.masksToBounds = false
        profilePictureAlternateImageView.clipsToBounds = true

        self.profilePictureBaseInnerAlternateView.layer.cornerRadius = self.profilePictureBaseInnerAlternateView.frame.size.width/2

        self.accountValueAlternateView.layer.cornerRadius = CornerRadius.view
        self.accountValueAlternateView.layer.masksToBounds = true
        self.accountValueAlternateView.isUserInteractionEnabled = true

        self.accountPlusAlternateView.layer.cornerRadius = CornerRadius.squareView
        self.accountPlusAlternateView.layer.masksToBounds = true

        self.accountPlusAlternateImageView.setImageColor(color: UIColor.App.buttonTextPrimary)

        self.cashbackAlternateView.layer.cornerRadius = CornerRadius.squareView
        self.cashbackAlternateView.layer.masksToBounds = true
    }

    func setupWithTheme() {

        if TargetVariables.shouldUseGradientBackgrounds {

            self.topBarAlternateView.backgroundColor = .clear
        }
        else {
            self.topBarAlternateView.backgroundColor = UIColor.App.backgroundPrimary
        }

        self.profilePictureAlternateBaseView.backgroundColor = UIColor.App.highlightPrimary

        self.profilePictureBaseInnerAlternateView.backgroundColor = UIColor.App.backgroundPrimary

        self.userInfoAlternateStackView.backgroundColor = .clear

        self.accountValueAlternateLabel.textColor = UIColor.App.textPrimary

        self.accountValueAlternateView.backgroundColor = UIColor.App.highlightPrimaryContrast.withAlphaComponent(0.1)

        self.accountPlusAlternateView.backgroundColor = UIColor.App.highlightSecondary

        self.cashbackAlternateLabel.textColor = UIColor.App.textSecondary

        self.cashbackAlternateView.backgroundColor = UIColor.App.highlightPrimaryContrast.withAlphaComponent(0.05)

        self.loginAlternateButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.loginAlternateButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.loginAlternateButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.4), for: .disabled)
        self.loginAlternateButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        self.loginAlternateButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .highlighted)

        self.loginAlternateButton.layer.cornerRadius = CornerRadius.view
        self.loginAlternateButton.layer.masksToBounds = true

    }

    private func commonInit() {

        self.loginAlternateButton.addTarget(self, action: #selector(self.didTapLoginButton), for: UIControl.Event.primaryActionTriggered)

        let alternateProfileTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileButton))
        self.profilePictureAlternateBaseView.addGestureRecognizer(alternateProfileTapGesture)

        self.accountValueAlternateLabel.text = localized("loading")
        self.accountValueAlternateLabel.font = AppFont.with(type: .bold, size: 12)

        let alternateAccountValueTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAccountValue))
        self.accountValueAlternateView.addGestureRecognizer(alternateAccountValueTapGesture)

        let alternateAnonymousTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapAnonymousButton))
        self.anonymousUserMenuAlternateBaseView.addGestureRecognizer(alternateAnonymousTapGesture)

        // Cashback
        Env.userSessionStore.userCashbackBalance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cashbackBalance in
                if let cashbackBalance = cashbackBalance,
                   let formattedTotalString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: cashbackBalance)) {
                    self?.cashbackAlternateLabel.text = formattedTotalString
                }
                else {
                    self?.cashbackAlternateLabel.text = "-.--€"
                }
            }
            .store(in: &cancellables)

        Env.userSessionStore.refreshCashbackBalance()

        // User Profile
        if let userProfile = Env.userSessionStore.userProfilePublisher.value {
            self.setupWithState(screenState: .logged(user: userProfile))

            if let avatarName = userProfile.avatarName {
                self.profilePictureAlternateImageView.image = UIImage(named: avatarName)
            }
            else {

                self.profilePictureAlternateImageView.image = UIImage(named: "empty_user_image")
            }
        }
        else {
            self.setupWithState(screenState: .anonymous)

        }

        // User Wallet
        if let userWallet = Env.userSessionStore.userWalletPublisher.value {
            if let formattedTotalString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: userWallet.total)) {

                self.accountValueAlternateLabel.text = formattedTotalString
            }
        }
        else {
            self.accountValueAlternateLabel.text = "-.--€"
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
                        self?.profilePictureAlternateImageView.image = UIImage(named: avatarName)
                    }
                    else {

                        self?.profilePictureAlternateImageView.image = UIImage(named: "empty_user_image")
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
                    self?.accountValueAlternateLabel.text = formattedTotalString
                }
                else {
                    self?.accountValueAlternateLabel.text = "-.--€"
                }
            }
            .store(in: &cancellables)
    }

    func setupWithState(screenState: ScreenState) {

        switch screenState {
        case .logged:
            self.profilePictureAlternateBaseView.isHidden = false
            self.anonymousUserMenuAlternateBaseView.isHidden = true

            self.accountValueAlternateBaseView.isHidden = false
            self.cashbackAlternateBaseView.isHidden = false

            self.loginAlternateBaseView.isHidden = true
        case .anonymous:
            self.profilePictureAlternateBaseView.isHidden = true
            self.anonymousUserMenuAlternateBaseView.isHidden = false

            self.accountValueAlternateBaseView.isHidden = true
            self.cashbackAlternateBaseView.isHidden = true

            self.loginAlternateBaseView.isHidden = false
        }
//        if isLogged {
//            self.profilePictureAlternateBaseView.isHidden = false
//            self.anonymousUserMenuAlternateBaseView.isHidden = true
//
//            self.accountValueAlternateBaseView.isHidden = false
//            self.cashbackAlternateBaseView.isHidden = false
//
//            self.loginAlternateBaseView.isHidden = true
//        }
//        else {
//            self.profilePictureAlternateBaseView.isHidden = true
//            self.anonymousUserMenuAlternateBaseView.isHidden = false
//
//            self.accountValueAlternateBaseView.isHidden = true
//            self.cashbackAlternateBaseView.isHidden = true
//
//            self.loginAlternateBaseView.isHidden = false
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

}

extension TopBarAlternateView {

    private static func createTopBarAlternateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAppIconAlternateImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "logo_horizontal_left")
        return imageView
    }

    private static func createProfileAlternateBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createProfilePictureAlternateBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createProfilePictureBaseInnerAlternateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createProfilePictureAlternateImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "empty_user_image")
        return imageView
    }

    private static func createAnonymousUserMenuAlternateBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAnonymousUserMenuAlternateImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "side_menu_icon")
        return imageView
    }

    private static func createUserInfoAlternateStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .equalSpacing
        stackView.axis = .horizontal
        stackView.spacing = 4
        return stackView
    }

    private static func createAccountValueAlternateBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAccountValueAlternateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAccountPlusAlternateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createAccountValueAlternateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "-.--"
        label.font = AppFont.with(type: .bold, size: 12)
        return label
    }

    private static func createAccountPlusAlternateImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "plus_small_icon")
        return imageView
    }

    private static func createCashbackAlternateBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCashbackAlternateView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createCashbackIconAlternateImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "cashback_icon")
        return imageView
    }

    private static func createCashbackAlternateLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "-.--"
        label.font = AppFont.with(type: .bold, size: 12)
        return label
    }

    private static func createLoginAlternateBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoginAlternateButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("login"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 13)
        return button
    }

    private func setupSubviews() {

        self.addSubview(self.topBarAlternateView)

        self.topBarAlternateView.addSubview(self.appIconAlternateImageView)

        self.topBarAlternateView.addSubview(profileAlternateBaseView)

        self.profileAlternateBaseView.addSubview(self.profilePictureAlternateBaseView)

        self.profilePictureAlternateBaseView.addSubview(self.profilePictureBaseInnerAlternateView)
        self.profilePictureAlternateBaseView.addSubview(self.profilePictureAlternateImageView)

        self.profileAlternateBaseView.addSubview(self.anonymousUserMenuAlternateBaseView)

        self.anonymousUserMenuAlternateBaseView.addSubview(self.anonymousUserMenuAlternateImageView)

        self.topBarAlternateView.addSubview(self.userInfoAlternateStackView)

        // Cashback
        self.userInfoAlternateStackView.addArrangedSubview(self.cashbackAlternateBaseView)

        self.cashbackAlternateBaseView.addSubview(self.cashbackAlternateView)

        self.cashbackAlternateView.addSubview(self.cashbackIconAlternateImageView)
        self.cashbackAlternateView.addSubview(self.cashbackAlternateLabel)

        // Acount value
        self.userInfoAlternateStackView.addArrangedSubview(self.accountValueAlternateBaseView)

        self.accountValueAlternateBaseView.addSubview(self.accountValueAlternateView)

        self.accountValueAlternateView.addSubview(self.accountPlusAlternateView)
        self.accountValueAlternateView.addSubview(self.accountValueAlternateLabel)

        self.accountPlusAlternateView.addSubview(self.accountPlusAlternateImageView)

        self.userInfoAlternateStackView.addArrangedSubview(self.loginAlternateBaseView)

        self.loginAlternateBaseView.addSubview(self.loginAlternateButton)

        self.initConstraints()

        self.setNeedsLayout()
        self.layoutIfNeeded()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([

            self.topBarAlternateView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.topBarAlternateView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.topBarAlternateView.topAnchor.constraint(equalTo: self.topAnchor),
            self.topBarAlternateView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.topBarAlternateView.heightAnchor.constraint(equalToConstant: 64),

            self.appIconAlternateImageView.leadingAnchor.constraint(equalTo: self.topBarAlternateView.leadingAnchor, constant: 15),
            self.appIconAlternateImageView.centerYAnchor.constraint(equalTo: self.topBarAlternateView.centerYAnchor),
            self.appIconAlternateImageView.heightAnchor.constraint(equalToConstant: 30),
            self.appIconAlternateImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 130),

            self.profileAlternateBaseView.trailingAnchor.constraint(equalTo: self.topBarAlternateView.trailingAnchor, constant: -15),
            self.profileAlternateBaseView.centerYAnchor.constraint(equalTo: self.topBarAlternateView.centerYAnchor),
            self.profileAlternateBaseView.widthAnchor.constraint(equalToConstant: 45),
            self.profileAlternateBaseView.heightAnchor.constraint(equalTo: self.profileAlternateBaseView.widthAnchor),

            self.profilePictureAlternateBaseView.widthAnchor.constraint(equalToConstant: 35),
            self.profilePictureAlternateBaseView.heightAnchor.constraint(equalTo: self.profilePictureAlternateBaseView.widthAnchor),
            self.profilePictureAlternateBaseView.centerXAnchor.constraint(equalTo: self.profileAlternateBaseView.centerXAnchor),
            self.profilePictureAlternateBaseView.centerYAnchor.constraint(equalTo: self.profileAlternateBaseView.centerYAnchor),

            self.profilePictureBaseInnerAlternateView.leadingAnchor.constraint(equalTo: self.profilePictureAlternateBaseView.leadingAnchor, constant: 1),
            self.profilePictureBaseInnerAlternateView.trailingAnchor.constraint(equalTo: self.profilePictureAlternateBaseView.trailingAnchor, constant: -1),
            self.profilePictureBaseInnerAlternateView.topAnchor.constraint(equalTo: self.profilePictureAlternateBaseView.topAnchor, constant: 1),
            self.profilePictureBaseInnerAlternateView.bottomAnchor.constraint(equalTo: self.profilePictureAlternateBaseView.bottomAnchor, constant: -1),

            self.profilePictureAlternateImageView.widthAnchor.constraint(equalToConstant: 40),
            self.profilePictureAlternateImageView.heightAnchor.constraint(equalTo: self.profilePictureAlternateImageView.widthAnchor),
            self.profilePictureAlternateImageView.centerXAnchor.constraint(equalTo: self.profilePictureAlternateBaseView.centerXAnchor),
            self.profilePictureAlternateImageView.centerYAnchor.constraint(equalTo: self.profilePictureAlternateBaseView.centerYAnchor),

            self.anonymousUserMenuAlternateBaseView.leadingAnchor.constraint(equalTo: self.profilePictureAlternateBaseView.leadingAnchor),
            self.anonymousUserMenuAlternateBaseView.trailingAnchor.constraint(equalTo: self.profilePictureAlternateBaseView.trailingAnchor),
            self.anonymousUserMenuAlternateBaseView.topAnchor.constraint(equalTo: self.profilePictureAlternateBaseView.topAnchor),
            self.anonymousUserMenuAlternateBaseView.bottomAnchor.constraint(equalTo: self.profilePictureAlternateBaseView.bottomAnchor),

            self.anonymousUserMenuAlternateImageView.leadingAnchor.constraint(equalTo: self.anonymousUserMenuAlternateBaseView.leadingAnchor, constant: 3),
            self.anonymousUserMenuAlternateImageView.trailingAnchor.constraint(equalTo: self.anonymousUserMenuAlternateBaseView.trailingAnchor, constant: -3),
            self.anonymousUserMenuAlternateImageView.topAnchor.constraint(equalTo: self.anonymousUserMenuAlternateBaseView.topAnchor, constant: 3),
            self.anonymousUserMenuAlternateImageView.bottomAnchor.constraint(equalTo: self.anonymousUserMenuAlternateBaseView.bottomAnchor, constant: -3),

            //self.userInfoAlternateStackView.leadingAnchor.constraint(equalTo: self.appIconAlternateImageView.trailingAnchor, constant: 4),
            self.userInfoAlternateStackView.trailingAnchor.constraint(equalTo: self.profileAlternateBaseView.leadingAnchor, constant: -4),
            self.userInfoAlternateStackView.topAnchor.constraint(equalTo: self.topBarAlternateView.topAnchor),
            self.userInfoAlternateStackView.bottomAnchor.constraint(equalTo: self.topBarAlternateView.bottomAnchor),

            // Account value
            self.accountValueAlternateBaseView.centerYAnchor.constraint(equalTo: self.userInfoAlternateStackView.centerYAnchor),

            self.accountValueAlternateView.leadingAnchor.constraint(equalTo: self.accountValueAlternateBaseView.leadingAnchor),
            self.accountValueAlternateView.trailingAnchor.constraint(equalTo: self.accountValueAlternateBaseView.trailingAnchor),
            self.accountValueAlternateView.heightAnchor.constraint(equalToConstant: 24),
            self.accountValueAlternateView.centerYAnchor.constraint(equalTo: self.accountValueAlternateBaseView.centerYAnchor),

            self.accountPlusAlternateView.leadingAnchor.constraint(equalTo: self.accountValueAlternateView.leadingAnchor, constant: 4),
            self.accountPlusAlternateView.topAnchor.constraint(equalTo: self.accountValueAlternateView.topAnchor, constant: 4),
            self.accountPlusAlternateView.bottomAnchor.constraint(equalTo: self.accountValueAlternateView.bottomAnchor, constant: -4),
            self.accountPlusAlternateView.widthAnchor.constraint(equalToConstant: 14),

            self.accountPlusAlternateImageView.widthAnchor.constraint(equalToConstant: 12),
            self.accountPlusAlternateImageView.heightAnchor.constraint(equalTo: self.accountPlusAlternateImageView.widthAnchor),
            self.accountPlusAlternateImageView.centerXAnchor.constraint(equalTo: self.accountPlusAlternateView.centerXAnchor),
            self.accountPlusAlternateImageView.centerYAnchor.constraint(equalTo: self.accountPlusAlternateView.centerYAnchor),

            self.accountValueAlternateLabel.leadingAnchor.constraint(equalTo: self.accountPlusAlternateView.trailingAnchor, constant: 4),
            self.accountValueAlternateLabel.trailingAnchor.constraint(equalTo: self.accountValueAlternateView.trailingAnchor, constant: -4),
            self.accountValueAlternateLabel.centerYAnchor.constraint(equalTo: self.accountValueAlternateView.centerYAnchor),

            // Cashback
            self.cashbackAlternateBaseView.centerYAnchor.constraint(equalTo: self.userInfoAlternateStackView.centerYAnchor),

            self.cashbackAlternateView.leadingAnchor.constraint(equalTo: self.cashbackAlternateBaseView.leadingAnchor),
            self.cashbackAlternateView.trailingAnchor.constraint(equalTo: self.cashbackAlternateBaseView.trailingAnchor),
            self.cashbackAlternateView.heightAnchor.constraint(equalToConstant: 24),
            self.cashbackAlternateView.centerYAnchor.constraint(equalTo: self.cashbackAlternateBaseView.centerYAnchor),

            self.cashbackIconAlternateImageView.leadingAnchor.constraint(equalTo: self.cashbackAlternateView.leadingAnchor, constant: 4),
            self.cashbackIconAlternateImageView.topAnchor.constraint(equalTo: self.cashbackAlternateView.topAnchor, constant: 4),
            self.cashbackIconAlternateImageView.bottomAnchor.constraint(equalTo: self.cashbackAlternateView.bottomAnchor, constant: -4),
            self.cashbackIconAlternateImageView.widthAnchor.constraint(equalToConstant: 14),

            self.cashbackAlternateLabel.leadingAnchor.constraint(equalTo: self.cashbackIconAlternateImageView.trailingAnchor, constant: 4),
            self.cashbackAlternateLabel.trailingAnchor.constraint(equalTo: self.cashbackAlternateView.trailingAnchor, constant: -4),
            self.cashbackAlternateLabel.centerYAnchor.constraint(equalTo: self.cashbackAlternateView.centerYAnchor),

            self.loginAlternateBaseView.centerYAnchor.constraint(equalTo: self.userInfoAlternateStackView.centerYAnchor),

            self.loginAlternateButton.leadingAnchor.constraint(equalTo: self.loginAlternateBaseView.leadingAnchor),
            self.loginAlternateButton.trailingAnchor.constraint(equalTo: self.loginAlternateBaseView.trailingAnchor),
            self.loginAlternateButton.widthAnchor.constraint(equalToConstant: 80),
            self.loginAlternateButton.heightAnchor.constraint(equalToConstant: 30),
            self.loginAlternateButton.centerYAnchor.constraint(equalTo: self.loginAlternateBaseView.centerYAnchor)

        ])

    }

}
