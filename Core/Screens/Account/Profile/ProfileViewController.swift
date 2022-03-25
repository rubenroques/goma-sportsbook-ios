//
//  ProfileViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/09/2021.
//

import UIKit
import Combine

class ProfileViewController: UIViewController {

    @IBOutlet private weak var safeAreaTopView: UIView!

    @IBOutlet private weak var closeButton: UIButton!

    @IBOutlet private weak var profileBaseView: UIView!
    @IBOutlet private weak var profilePictureBaseView: UIView!
    @IBOutlet private weak var profilePictureImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var userIdLabel: UILabel!
    @IBOutlet private weak var shadowView: UIView!

    @IBOutlet private weak var totalBalanceView: UIView!
    @IBOutlet private weak var totalBalanceTitleLabel: UILabel!
    @IBOutlet private weak var totalBalanceLabel: UILabel!

    @IBOutlet private weak var currentBalanceView: UIView!
    @IBOutlet private weak var currentBalanceTitleLabel: UILabel!
    @IBOutlet private weak var currentBalanceLabel: UILabel!

    @IBOutlet private weak var bonusBalanceBaseView: UIView!
    @IBOutlet private weak var bonusBalanceTitleLabel: UILabel!
    @IBOutlet private weak var bonusBalanceLabel: UILabel!

    @IBOutlet private weak var depositButton: UIButton!
    @IBOutlet private weak var withdrawButton: UIButton!

    @IBOutlet private weak var scrollBaseView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!

    @IBOutlet private var activationStackView: UIStackView!
    @IBOutlet private var activationAlertScrollableView: ActivationAlertScrollableView!

    @IBOutlet private weak var stackView: UIStackView!

//    @IBOutlet private weak var personalInfoBaseView: UIView!
//    @IBOutlet private weak var personalInfoIconBaseView: UIView!
//    @IBOutlet private weak var personalInfoIconImageView: UIImageView!
//    @IBOutlet private weak var personalInfoLabel: UILabel!
//
//    @IBOutlet private weak var favoritesBaseView: UIView!
//    @IBOutlet private weak var favoritesIconBaseView: UIView!
//    @IBOutlet private weak var favoritesIconImageView: UIImageView!
//    @IBOutlet private weak var favoritesLabel: UILabel!
//
//    @IBOutlet private weak var historyBaseView: UIView!
//    @IBOutlet private weak var historyIconBaseView: UIView!
//    @IBOutlet private weak var historyIconImageView: UIImageView!
//    @IBOutlet private weak var historyLabel: UILabel!
//
//    @IBOutlet private weak var bonusBaseView: UIView!
//    @IBOutlet private weak var bonusIconBaseView: UIView!
//    @IBOutlet private weak var bonusIconImageView: UIImageView!
//    @IBOutlet private weak var bonusLabel: UILabel!
//
//    @IBOutlet private weak var appSettingsBaseView: UIView!
//    @IBOutlet private weak var appSettingsIconBaseView: UIView!
//    @IBOutlet private weak var appSettingsIconImageView: UIImageView!
//    @IBOutlet private weak var appSettingsLabel: UILabel!
//
//    @IBOutlet private weak var supportBaseView: UIView!
//    @IBOutlet private weak var supportIconBaseView: UIView!
//    @IBOutlet private weak var supportIconImageView: UIImageView!
//    @IBOutlet private weak var supportLabel: UILabel!

    @IBOutlet private weak var logoutBaseView: UIView!
    @IBOutlet private weak var logoutButton: UIButton!

    @IBOutlet private weak var infoBaseView: UIView!
    @IBOutlet private weak var infoLabel: UILabel!

    var userSession: UserSession?
    var cancellables = Set<AnyCancellable>()

    enum PageMode {
        case user
        case anonymous
    }
    var pageMode: PageMode
    var alertsArray: [ActivationAlert] = []

    init(userSession: UserSession? = nil) {

        self.pageMode = .anonymous
        self.userSession = userSession

        if userSession.hasValue {
            pageMode = .user
        }

        super.init(nibName: "ProfileViewController", bundle: nil)
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let user = self.userSession {
            self.usernameLabel.text = user.username
            self.userIdLabel.text = user.userId
        }

        Env.everyMatrixClient.getProfileStatus()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { _ in

            } receiveValue: { _ in
            }
        .store(in: &cancellables)

        Env.userSessionStore.userBalanceWallet
            .compactMap({$0})
            .map(\.amount)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if let bonusWallet = Env.userSessionStore.userBonusBalanceWallet.value {
                    let accountValue = bonusWallet.amount + value
                    self?.totalBalanceLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: accountValue)) ?? "-.--€"

                }
                else {
                    self?.totalBalanceLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: value)) ?? "-.--€"
                }
                self?.currentBalanceLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: value)) ?? "-.--€"
            }
            .store(in: &cancellables)

        Env.userSessionStore.userBonusBalanceWallet
            .compactMap({$0})
            .map(\.amount)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                if let currentWallet = Env.userSessionStore.userBalanceWallet.value {
                    let accountValue = currentWallet.amount + value

                    self?.totalBalanceLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: accountValue)) ?? "-.--€"
                }
                self?.bonusBalanceLabel.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: value)) ?? "-.--€"
            }
            .store(in: &cancellables)

        Env.userSessionStore.forceWalletUpdate()

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        profilePictureBaseView.layer.cornerRadius = profilePictureBaseView.frame.size.width/2
        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width/2
    }

    func commonInit() {

        shadowView.layer.shadowRadius = 10
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.4

        closeButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 18)
        closeButton.setTitle(localized("close"), for: .normal)
        closeButton.backgroundColor = .clear

        bonusBalanceBaseView.layer.cornerRadius = CornerRadius.view

        totalBalanceTitleLabel.text = localized("total")
        totalBalanceTitleLabel.font = AppFont.with(type: .bold, size: 14)

        totalBalanceLabel.font = AppFont.with(type: .bold, size: 16)

        currentBalanceTitleLabel.text = localized("available_balance")
        currentBalanceTitleLabel.font = AppFont.with(type: .bold, size: 14)

        currentBalanceLabel.font = AppFont.with(type: .bold, size: 16)

        bonusBalanceTitleLabel.text = localized("bonus")
        bonusBalanceTitleLabel.font = AppFont.with(type: .bold, size: 14)

        bonusBalanceLabel.font = AppFont.with(type: .bold, size: 16)

        depositButton.layer.cornerRadius = CornerRadius.button
        withdrawButton.layer.cornerRadius = CornerRadius.button

        depositButton.backgroundColor = .clear
        depositButton.layer.cornerRadius = CornerRadius.button
        depositButton.layer.masksToBounds = true
        depositButton.setTitle(localized("deposit"), for: .normal)

        withdrawButton.backgroundColor = UIColor.App.buttonBackgroundSecondary
        withdrawButton.layer.cornerRadius = CornerRadius.button
        withdrawButton.layer.masksToBounds = true
        withdrawButton.layer.borderWidth = 2
        withdrawButton.setTitle(localized("withdraw"), for: .normal)

        logoutButton.backgroundColor = .clear
        logoutButton.layer.cornerRadius = CornerRadius.button
        logoutButton.layer.masksToBounds = true
        logoutButton.layer.borderWidth = 2
        logoutButton.setTitle(localized("logout"), for: .normal)

//        personalInfoBaseView.layer.cornerRadius = CornerRadius.view
//        personalInfoIconBaseView.layer.cornerRadius = CornerRadius.view
//        personalInfoIconImageView.backgroundColor = UIColor.App.backgroundTertiary
//        let personalInfoTapGesture = UITapGestureRecognizer(target: self, action: #selector(myAccountViewTapped(sender:)))
//        personalInfoBaseView.addGestureRecognizer(personalInfoTapGesture)
//
//        favoritesBaseView.layer.cornerRadius = CornerRadius.view
//        favoritesIconBaseView.layer.cornerRadius = CornerRadius.view
//        let favoritesTapGesture = UITapGestureRecognizer(target: self, action: #selector(favoritesViewTapped))
//        favoritesBaseView.addGestureRecognizer(favoritesTapGesture)
//
//        historyBaseView.layer.cornerRadius = CornerRadius.view
//        historyIconBaseView.layer.cornerRadius = CornerRadius.view
//        historyIconImageView.backgroundColor = .clear
//        let historyTapGesture = UITapGestureRecognizer(target: self, action: #selector(historyViewTapped))
//        historyBaseView.addGestureRecognizer(historyTapGesture)
//
//        bonusBaseView.layer.cornerRadius = CornerRadius.view
//        bonusIconBaseView.layer.cornerRadius = CornerRadius.view
//        bonusIconImageView.backgroundColor = .clear
//        let bonusTapGesture = UITapGestureRecognizer(target: self, action: #selector(bonusViewTapped))
//        bonusBaseView.addGestureRecognizer(bonusTapGesture)
//
//        appSettingsBaseView.layer.cornerRadius = CornerRadius.view
//        appSettingsIconBaseView.layer.cornerRadius = CornerRadius.view
//        appSettingsIconImageView.backgroundColor = .clear
//        let appSettingsTapGesture = UITapGestureRecognizer(target: self, action: #selector(appSettingsViewTapped))
//        appSettingsBaseView.addGestureRecognizer(appSettingsTapGesture)
//
//        supportBaseView.layer.cornerRadius = CornerRadius.view
//        supportIconBaseView.layer.cornerRadius = CornerRadius.view
//        supportIconImageView.backgroundColor = .clear
//        let supportTapGesture = UITapGestureRecognizer(target: self, action: #selector(supportViewTapped))
//        supportBaseView.addGestureRecognizer(supportTapGesture)

        currentBalanceLabel.text = localized("loading")

        //
//        personalInfoLabel.text = localized("my_account")
//        favoritesLabel.text = localized("my_favorites")
//        historyLabel.text = localized("history")
//        bonusLabel.text = localized("bonus")
//        appSettingsLabel.text = localized("app_settings")
//        supportLabel.text = localized("support")

        if let versionNumber = Bundle.main.versionNumber,
           let buildNumber = Bundle.main.buildNumber {
            let appVersionRawString = localized("app_version_profile")
            let appVersionBuildNumberString = appVersionRawString.replacingOccurrences(of: "(%s)", with: "(\(buildNumber))")
            let appVersionStringFinal = appVersionBuildNumberString.replacingOccurrences(of: "%s", with: "\(versionNumber)")
            self.infoLabel.text = appVersionStringFinal
        }

        activationAlertScrollableView.layer.cornerRadius = CornerRadius.button
        activationAlertScrollableView.layer.masksToBounds = true

        self.verifyUserActivationConditions()

        self.setupStackView()

    }

    func verifyUserActivationConditions() {

        var showActivationAlertScrollableView = false

        if let userEmailVerified = userSession?.isEmailVerified {
            if !userEmailVerified {
                let emailActivationAlertData = ActivationAlert(title: localized("verify_email"),
                                                               description: localized("app_full_potential"),
                                                               linkLabel: localized("verify_my_account"),
                                                               alertType: .email)
                alertsArray.append(emailActivationAlertData)
                showActivationAlertScrollableView = true
            }
        }

        if let userSession = userSession {
            if Env.userSessionStore.isUserProfileIncomplete.value {
                let completeProfileAlertData = ActivationAlert(title: localized("complete_your_profile"),
                                                               description: localized("complete_profile_description"),
                                                               linkLabel: localized("finish_up_profile"),
                                                               alertType: .profile)

                alertsArray.append(completeProfileAlertData)
                showActivationAlertScrollableView = true
            }
        }

        if showActivationAlertScrollableView {
            activationAlertScrollableView.setAlertArrayData(arrayData: alertsArray)

            activationAlertScrollableView.activationAlertCollectionViewCellLinkLabelAction = { alertType in
                if alertType == ActivationAlertType.email {
                    let emailVerificationViewController = EmailVerificationViewController()
                    self.present(emailVerificationViewController, animated: true, completion: nil)
                }
                else if alertType == ActivationAlertType.profile {
                    let fullRegisterViewController = FullRegisterPersonalInfoViewController()
                    // self.present(fullRegisterViewController, animated: true, completion: nil)
                    self.navigationController?.pushViewController(fullRegisterViewController, animated: true)
                }
            }
        }
        else {
            activationAlertScrollableView.isHidden = true
        }

    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        closeButton.setTitleColor( UIColor.App.highlightPrimary, for: .normal)
        closeButton.setTitleColor( UIColor.App.highlightPrimary.withAlphaComponent(0.7), for: .highlighted)
        closeButton.setTitleColor( UIColor.App.highlightPrimary.withAlphaComponent(0.4), for: .disabled)

        safeAreaTopView.backgroundColor = UIColor.App.backgroundPrimary
        profileBaseView.backgroundColor = UIColor.App.backgroundPrimary
        profilePictureBaseView.backgroundColor = UIColor.App.highlightSecondary
        bonusBalanceBaseView.backgroundColor = UIColor.App.backgroundPrimary
        scrollBaseView.backgroundColor = UIColor.App.backgroundPrimary
        profilePictureImageView.backgroundColor = .clear

        totalBalanceView.backgroundColor = UIColor.App.backgroundPrimary

        currentBalanceView.backgroundColor = UIColor.App.backgroundPrimary

        bonusBalanceBaseView.backgroundColor = UIColor.App.backgroundPrimary

        usernameLabel.textColor = UIColor.App.textPrimary
        userIdLabel.textColor = UIColor.App.textSecondary

        totalBalanceTitleLabel.textColor =  UIColor.App.textPrimary
        totalBalanceLabel.textColor =  UIColor.App.textPrimary

        currentBalanceTitleLabel.textColor =  UIColor.App.textPrimary
        currentBalanceLabel.textColor =  UIColor.App.textPrimary

        bonusBalanceTitleLabel.textColor = UIColor.App.textPrimary
        bonusBalanceLabel.textColor = UIColor.App.textPrimary

        //
        depositButton.setTitleColor( UIColor.App.buttonTextPrimary, for: .normal)
        depositButton.setTitleColor( UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        depositButton.setTitleColor( UIColor.App.buttonTextPrimary.withAlphaComponent(0.4), for: .disabled)
        depositButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        depositButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .highlighted)

        withdrawButton.setTitleColor( UIColor.App.buttonTextPrimary, for: .normal)
        withdrawButton.setTitleColor( UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        withdrawButton.setTitleColor( UIColor.App.buttonTextPrimary.withAlphaComponent(0.4), for: .disabled)
        withdrawButton.layer.borderColor = UIColor.App.backgroundSecondary.cgColor

        logoutButton.setTitleColor( UIColor.App.textPrimary, for: .normal)
        logoutButton.setTitleColor( UIColor.App.textPrimary.withAlphaComponent(0.7), for: .highlighted)
        logoutButton.setTitleColor( UIColor.App.textPrimary.withAlphaComponent(0.4), for: .disabled)
        logoutButton.layer.borderColor = UIColor.App.backgroundSecondary.cgColor

        //
//        personalInfoBaseView.backgroundColor = UIColor.App.backgroundSecondary
//        personalInfoIconBaseView.backgroundColor = UIColor.App.backgroundPrimary
//        personalInfoIconImageView.backgroundColor = .clear
//        personalInfoLabel.textColor =  UIColor.App.textPrimary
//
//        favoritesBaseView.backgroundColor = UIColor.App.backgroundSecondary
//        favoritesIconBaseView.backgroundColor = UIColor.App.backgroundPrimary
//        favoritesIconImageView.backgroundColor = .clear
//        favoritesLabel.textColor =  UIColor.App.textPrimary
//
//        historyBaseView.backgroundColor = UIColor.App.backgroundSecondary
//        historyIconBaseView.backgroundColor = UIColor.App.backgroundPrimary
//        historyIconImageView.backgroundColor = .clear
//        historyLabel.textColor =  UIColor.App.textPrimary
//
//        bonusBaseView.backgroundColor = UIColor.App.backgroundSecondary
//        bonusIconBaseView.backgroundColor = UIColor.App.backgroundPrimary
//        bonusIconImageView.backgroundColor = .clear
//        bonusLabel.textColor =  UIColor.App.textPrimary
//
//        appSettingsBaseView.backgroundColor = UIColor.App.backgroundSecondary
//        appSettingsIconBaseView.backgroundColor = UIColor.App.backgroundPrimary
//        appSettingsIconImageView.backgroundColor = .clear
//        appSettingsLabel.textColor =  UIColor.App.textPrimary
//
//        supportBaseView.backgroundColor = UIColor.App.backgroundSecondary
//        supportIconBaseView.backgroundColor = UIColor.App.backgroundPrimary
//        supportIconImageView.backgroundColor = .clear
//        supportLabel.textColor =  UIColor.App.textPrimary

        infoLabel.textColor = UIColor.App.textPrimary
        
        logoutBaseView.backgroundColor = .clear
        infoBaseView.backgroundColor = .clear
    }

    private func setupStackView() {
        let myAccountView = NavigationCardView()
        myAccountView.setupView(title: localized("my_account"), iconTitle: "my_account_profile_icon")
        let myAccountTap = UITapGestureRecognizer(target: self, action: #selector(myAccountViewTapped(sender:)))
        myAccountView.addGestureRecognizer(myAccountTap)

        let myFavoritesView = NavigationCardView()
        myFavoritesView.setupView(title: localized("my_favorites"), iconTitle: "favorite_profile_icon")
        let myFavoritesTap = UITapGestureRecognizer(target: self, action: #selector(favoritesViewTapped(sender:)))
        myFavoritesView.addGestureRecognizer(myFavoritesTap)

        let bonusView = NavigationCardView()
        bonusView.setupView(title: localized("bonus"), iconTitle: "bonus_profile_icon")
        let bonusTap = UITapGestureRecognizer(target: self, action: #selector(bonusViewTapped(sender:)))
        bonusView.addGestureRecognizer(bonusTap)

        let historyView = NavigationCardView()
        historyView.setupView(title: localized("history"), iconTitle: "history_profile_icon")
        let historyTap = UITapGestureRecognizer(target: self, action: #selector(historyViewTapped(sender:)))
        historyView.addGestureRecognizer(historyTap)

        let settingsView = NavigationCardView()
        settingsView.setupView(title: localized("app_settings"), iconTitle: "app_settings_profile_icon")
        let settingsTap = UITapGestureRecognizer(target: self, action: #selector(appSettingsViewTapped(sender:)))
        settingsView.addGestureRecognizer(settingsTap)

        let supportView = NavigationCardView()
        supportView.setupView(title: localized("support"), iconTitle: "support_profile_icon")
        let supportTap = UITapGestureRecognizer(target: self, action: #selector(supportViewTapped(sender:)))
        supportView.addGestureRecognizer(supportTap)

        self.stackView.addArrangedSubview(myAccountView)
        self.stackView.addArrangedSubview(myFavoritesView)
        self.stackView.addArrangedSubview(bonusView)
        self.stackView.addArrangedSubview(historyView)
        self.stackView.addArrangedSubview(settingsView)
        self.stackView.addArrangedSubview(supportView)

    }

    @IBAction private func didTapDepositButton() {

        if !Env.userSessionStore.isUserProfileIncomplete.value {

            let depositViewController = DepositViewController()

            let navigationViewController = Router.navigationController(with: depositViewController)
            self.present(navigationViewController, animated: true, completion: nil)

            //self.navigationController?.pushViewController(depositViewController, animated: true)
        }
        else {
            let alert = UIAlertController(title: localized("profile_incomplete"),
                                          message: localized("profile_incomplete_deposit"),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }

    @IBAction private func didTapWithdrawButton() {
        if !Env.userSessionStore.isUserProfileIncomplete.value {

            let withDrawViewController = WithdrawViewController()

            //self.navigationController?.pushViewController(withDrawViewController, animated: true)
            let navigationViewController = Router.navigationController(with: withDrawViewController)
            self.present(navigationViewController, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: localized("profile_incomplete"),
                                          message: localized("profile_incomplete_withdraw"),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

extension ProfileViewController {

    @IBAction private func didTapCloseButton() {
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction private func didTapLogoutButton() {
        AnalyticsClient.sendEvent(event: .userLogout)
        Env.userSessionStore.logout()
        Env.favoritesManager.favoriteEventsIdPublisher.send([])
        self.didTapCloseButton()
    }
}

extension ProfileViewController {

    @objc private func myAccountViewTapped(sender: UITapGestureRecognizer) {
        let myAccountViewController = MyAccountViewController()
        self.navigationController?.pushViewController(myAccountViewController, animated: true)
    }

    @objc func favoritesViewTapped(sender: UITapGestureRecognizer) {
        let favoritesViewController = MyFavoritesViewController()
        self.navigationController?.pushViewController(favoritesViewController, animated: true)

    }

    @objc func bonusViewTapped(sender: UITapGestureRecognizer) {
        let bonusViewController = BonusViewController()
        self.navigationController?.pushViewController(bonusViewController, animated: true)
    }

    @objc func historyViewTapped(sender: UITapGestureRecognizer) {
        let historyViewController = HistoryViewController()
        self.navigationController?.pushViewController(historyViewController, animated: true)
    }
//
//    @objc func limitsViewTapped() {
//        let profileLimitsManagementViewController = ProfileLimitsManagementViewController()
//        self.navigationController?.pushViewController(profileLimitsManagementViewController, animated: true)
//    }

    @objc func appSettingsViewTapped(sender: UITapGestureRecognizer) {
        let appSettingsViewController = AppSettingsViewController()
        self.navigationController?.pushViewController(appSettingsViewController, animated: true)
    }

    @objc func supportViewTapped(sender: UITapGestureRecognizer) {

    }

}
