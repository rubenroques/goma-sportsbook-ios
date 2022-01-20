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

    @IBOutlet private weak var currentBalanceTitleLabel: UILabel!
    @IBOutlet private weak var currentBalanceBaseView: UIView!
    @IBOutlet private weak var currentBalanceLabel: UILabel!

    @IBOutlet private weak var depositButton: UIButton!
    @IBOutlet private weak var withdrawButton: UIButton!

    @IBOutlet private weak var scrollBaseView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!

    @IBOutlet private var activationStackView: UIStackView!
    @IBOutlet private var activationAlertScrollableView: ActivationAlertScrollableView!

    @IBOutlet private weak var personalInfoBaseView: UIView!
    @IBOutlet private weak var personalInfoIconBaseView: UIView!
    @IBOutlet private weak var personalInfoIconImageView: UIImageView!
    @IBOutlet private weak var personalInfoLabel: UILabel!

    @IBOutlet private weak var passwordUpdateBaseView: UIView!
    @IBOutlet private weak var passwordUpdateIconBaseView: UIView!
    @IBOutlet private weak var passwordUpdateIconImageView: UIImageView!
    @IBOutlet private weak var passwordUpdateLabel: UILabel!

    @IBOutlet private weak var walletBaseView: UIView!
    @IBOutlet private weak var walletIconBaseView: UIView!
    @IBOutlet private weak var walletIconImageView: UIImageView!
    @IBOutlet private weak var walletLabel: UILabel!

    @IBOutlet private weak var documentsBaseView: UIView!
    @IBOutlet private weak var documentsIconBaseView: UIView!
    @IBOutlet private weak var documentsIconImageView: UIImageView!
    @IBOutlet private weak var documentsLabel: UILabel!

    @IBOutlet private weak var bonusBaseView: UIView!
    @IBOutlet private weak var bonusIconBaseView: UIView!
    @IBOutlet private weak var bonusIconImageView: UIImageView!
    @IBOutlet private weak var bonusLabel: UILabel!

    @IBOutlet private weak var historyBaseView: UIView!
    @IBOutlet private weak var historyIconBaseView: UIView!
    @IBOutlet private weak var historyIconImageView: UIImageView!
    @IBOutlet private weak var historyLabel: UILabel!

    @IBOutlet private weak var limitsBaseView: UIView!
    @IBOutlet private weak var limitsIconBaseView: UIView!
    @IBOutlet private weak var limitsIconImageView: UIImageView!
    @IBOutlet private weak var limitsLabel: UILabel!

    @IBOutlet private weak var appSettingsBaseView: UIView!
    @IBOutlet private weak var appSettingsIconBaseView: UIView!
    @IBOutlet private weak var appSettingsIconImageView: UIImageView!
    @IBOutlet private weak var appSettingsLabel: UILabel!

    @IBOutlet private weak var supportBaseView: UIView!
    @IBOutlet private weak var supportIconBaseView: UIView!
    @IBOutlet private weak var supportIconImageView: UIImageView!
    @IBOutlet private weak var supportLabel: UILabel!

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
            .map({ CurrencyFormater.defaultFormat.string(from: NSNumber(value: $0)) ?? "-.--€"})
            .receive(on: DispatchQueue.main)
            .sink { value in
                self.currentBalanceLabel.text = value
            }
            .store(in: &cancellables)

        Env.userSessionStore.forceWalletUpdate()

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        closeButton.setTitle(localized("string_close"), for: .normal)
        closeButton.backgroundColor = .clear

        currentBalanceBaseView.layer.cornerRadius = CornerRadius.view

        depositButton.layer.cornerRadius = CornerRadius.button
        withdrawButton.layer.cornerRadius = CornerRadius.button

        depositButton.backgroundColor = .clear
        depositButton.layer.cornerRadius = CornerRadius.button
        depositButton.layer.masksToBounds = true
        depositButton.setTitle(localized("string_deposit"), for: .normal)

        withdrawButton.backgroundColor = UIColor.App2.buttonBackgroundSecondary
        withdrawButton.layer.cornerRadius = CornerRadius.button
        withdrawButton.layer.masksToBounds = true
        withdrawButton.layer.borderWidth = 2
        withdrawButton.setTitle(localized("string_withdraw"), for: .normal)

        logoutButton.backgroundColor = .clear
        logoutButton.layer.cornerRadius = CornerRadius.button
        logoutButton.layer.masksToBounds = true
        logoutButton.layer.borderWidth = 2
        logoutButton.setTitle(localized("string_logout"), for: .normal)

        personalInfoBaseView.layer.cornerRadius = CornerRadius.view
        personalInfoIconBaseView.layer.cornerRadius = CornerRadius.view
        personalInfoIconImageView.backgroundColor = UIColor.App2.backgroundTertiary
        let personalInfoTapGesture = UITapGestureRecognizer(target: self, action: #selector(personalInfoViewTapped))
        personalInfoBaseView.addGestureRecognizer(personalInfoTapGesture)

        passwordUpdateBaseView.layer.cornerRadius = CornerRadius.view
        passwordUpdateIconBaseView.layer.cornerRadius = CornerRadius.view
        passwordUpdateIconImageView.backgroundColor = .clear
        let passwordUpdateTapGesture = UITapGestureRecognizer(target: self, action: #selector(passwordUpdateViewTapped))
        passwordUpdateBaseView.addGestureRecognizer(passwordUpdateTapGesture)
        passwordUpdateBaseView.backgroundColor = UIColor.App2.backgroundSecondary

        walletBaseView.layer.cornerRadius = CornerRadius.view
        walletIconBaseView.layer.cornerRadius = CornerRadius.view
        walletIconImageView.backgroundColor = .clear
        let walletTapGesture = UITapGestureRecognizer(target: self, action: #selector(walletViewTapped))
        walletBaseView.addGestureRecognizer(walletTapGesture)

        documentsBaseView.layer.cornerRadius = CornerRadius.view
        documentsIconBaseView.layer.cornerRadius = CornerRadius.view
        documentsIconImageView.backgroundColor = .clear
        let documentsTapGesture = UITapGestureRecognizer(target: self, action: #selector(documentsViewTapped))
        documentsBaseView.addGestureRecognizer(documentsTapGesture)

        bonusBaseView.layer.cornerRadius = CornerRadius.view
        bonusIconBaseView.layer.cornerRadius = CornerRadius.view
        bonusIconImageView.backgroundColor = .clear
        let bonusTapGesture = UITapGestureRecognizer(target: self, action: #selector(bonusViewTapped))
        bonusBaseView.addGestureRecognizer(bonusTapGesture)

        historyBaseView.layer.cornerRadius = CornerRadius.view
        historyIconBaseView.layer.cornerRadius = CornerRadius.view
        historyIconImageView.backgroundColor = .clear
        let historyTapGesture = UITapGestureRecognizer(target: self, action: #selector(historyViewTapped))
        historyBaseView.addGestureRecognizer(historyTapGesture)

        limitsBaseView.layer.cornerRadius = CornerRadius.view
        limitsIconBaseView.layer.cornerRadius = CornerRadius.view
        limitsIconImageView.backgroundColor = .clear
        let limitsTapGesture = UITapGestureRecognizer(target: self, action: #selector(limitsViewTapped))
        limitsBaseView.addGestureRecognizer(limitsTapGesture)

        appSettingsBaseView.layer.cornerRadius = CornerRadius.view
        appSettingsIconBaseView.layer.cornerRadius = CornerRadius.view
        appSettingsIconImageView.backgroundColor = .clear
        let appSettingsTapGesture = UITapGestureRecognizer(target: self, action: #selector(appSettingsViewTapped))
        appSettingsBaseView.addGestureRecognizer(appSettingsTapGesture)

        supportBaseView.layer.cornerRadius = CornerRadius.view
        supportIconBaseView.layer.cornerRadius = CornerRadius.view
        supportIconImageView.backgroundColor = .clear
        let supportTapGesture = UITapGestureRecognizer(target: self, action: #selector(supportViewTapped))
        supportBaseView.addGestureRecognizer(supportTapGesture)

        currentBalanceLabel.text = localized("string_loading")

        //
        personalInfoLabel.text = localized("string_personal_info")
        passwordUpdateLabel.text = localized("string_update_password")
        walletLabel.text = localized("string_wallet")
        documentsLabel.text = localized("string_documents")
        bonusLabel.text = localized("string_bonus")
        historyLabel.text = localized("string_history")
        limitsLabel.text = localized("string_limits_management")
        appSettingsLabel.text = localized("string_app_settings")
        supportLabel.text = localized("string_support")

        if let versionNumber = Bundle.main.versionNumber,
           let buildNumber = Bundle.main.buildNumber {
            self.infoLabel.text = "App Version \(versionNumber)(\(buildNumber))\nSportsbook® All Rights Reserved"
        }

        activationAlertScrollableView.layer.cornerRadius = CornerRadius.button
        activationAlertScrollableView.layer.masksToBounds = true

        self.verifyUserActivationConditions()

    }

    func verifyUserActivationConditions() {

        var showActivationAlertScrollableView = false

        if let userEmailVerified = userSession?.isEmailVerified {
            if !userEmailVerified {
                let emailActivationAlertData = ActivationAlert(title: localized("string_verify_email"), description: localized("string_app_full_potential"), linkLabel: localized("string_verify_my_account"), alertType: .email)
                alertsArray.append(emailActivationAlertData)
                showActivationAlertScrollableView = true
            }
        }

        if let userSession = userSession {
            if Env.userSessionStore.isUserProfileIncomplete.value {
                let completeProfileAlertData = ActivationAlert(title: localized("string_complete_your_profile"), description: localized("string_complete_profile_description"), linkLabel: localized("string_finish_up_profile"), alertType: .profile)

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
        self.view.backgroundColor = UIColor.App2.backgroundPrimary

        closeButton.setTitleColor( UIColor.App2.textPrimary, for: .normal)
        closeButton.setTitleColor( UIColor.App2.textPrimary.withAlphaComponent(0.7), for: .highlighted)
        closeButton.setTitleColor( UIColor.App2.textPrimary.withAlphaComponent(0.4), for: .disabled)

        safeAreaTopView.backgroundColor = UIColor.App2.backgroundPrimary
        profileBaseView.backgroundColor = UIColor.App2.backgroundPrimary
        profilePictureBaseView.backgroundColor = UIColor.App2.highlightPrimary
        currentBalanceBaseView.backgroundColor = UIColor.App2.backgroundSecondary
        scrollBaseView.backgroundColor = UIColor.App2.backgroundPrimary
        profilePictureImageView.backgroundColor = .clear

        usernameLabel.textColor = UIColor.App2.textPrimary
        userIdLabel.textColor = UIColor.App.fadeOutHeading
        currentBalanceTitleLabel.textColor =  UIColor.App2.textPrimary
        currentBalanceLabel.textColor =  UIColor.App2.textPrimary

        //
        depositButton.setTitleColor( UIColor.App2.textPrimary, for: .normal)
        depositButton.setTitleColor( UIColor.App2.textPrimary.withAlphaComponent(0.7), for: .highlighted)
        depositButton.setTitleColor( UIColor.App2.textPrimary.withAlphaComponent(0.4), for: .disabled)
        depositButton.setBackgroundColor(UIColor.App2.buttonBackgroundPrimary, for: .normal)
        depositButton.setBackgroundColor(UIColor.App2.buttonBackgroundPrimary, for: .highlighted)

        withdrawButton.setTitleColor( UIColor.App2.textPrimary, for: .normal)
        withdrawButton.setTitleColor( UIColor.App2.textPrimary.withAlphaComponent(0.7), for: .highlighted)
        withdrawButton.setTitleColor( UIColor.App2.textPrimary.withAlphaComponent(0.4), for: .disabled)
        withdrawButton.layer.borderColor = UIColor.App2.backgroundSecondary.cgColor

        logoutButton.setTitleColor( UIColor.App2.textPrimary, for: .normal)
        logoutButton.setTitleColor( UIColor.App2.textPrimary.withAlphaComponent(0.7), for: .highlighted)
        logoutButton.setTitleColor( UIColor.App2.textPrimary.withAlphaComponent(0.4), for: .disabled)
        logoutButton.layer.borderColor = UIColor.App2.backgroundSecondary.cgColor

        //
        personalInfoBaseView.backgroundColor = UIColor.App2.backgroundSecondary
        personalInfoIconBaseView.backgroundColor = UIColor.App2.backgroundPrimary
        personalInfoIconImageView.backgroundColor = .clear
        personalInfoLabel.textColor =  UIColor.App2.textPrimary
        
        passwordUpdateBaseView.backgroundColor = UIColor.App2.backgroundSecondary
        passwordUpdateIconBaseView.backgroundColor = UIColor.App2.backgroundPrimary
        passwordUpdateIconImageView.backgroundColor = .clear
        passwordUpdateLabel.textColor =  UIColor.App2.textPrimary

        walletBaseView.backgroundColor = UIColor.App2.backgroundSecondary
        walletIconBaseView.backgroundColor = UIColor.App2.backgroundPrimary
        walletIconImageView.backgroundColor = .clear
        walletLabel.textColor =  UIColor.App2.textPrimary

        documentsBaseView.backgroundColor = UIColor.App2.backgroundSecondary
        documentsIconBaseView.backgroundColor = UIColor.App2.backgroundPrimary
        documentsIconImageView.backgroundColor = .clear
        documentsLabel.textColor =  UIColor.App2.textPrimary

        bonusBaseView.backgroundColor = UIColor.App2.backgroundSecondary
        bonusIconBaseView.backgroundColor = UIColor.App2.backgroundPrimary
        bonusIconImageView.backgroundColor = .clear
        bonusLabel.textColor =  UIColor.App2.textPrimary

        historyBaseView.backgroundColor = UIColor.App2.backgroundSecondary
        historyIconBaseView.backgroundColor = UIColor.App2.backgroundPrimary
        historyIconImageView.backgroundColor = .clear
        historyLabel.textColor =  UIColor.App2.textPrimary

        limitsBaseView.backgroundColor = UIColor.App2.backgroundSecondary
        limitsIconBaseView.backgroundColor = UIColor.App2.backgroundPrimary
        limitsIconImageView.backgroundColor = .clear
        limitsLabel.textColor =  UIColor.App2.textPrimary

        appSettingsBaseView.backgroundColor = UIColor.App2.backgroundSecondary
        appSettingsIconBaseView.backgroundColor = UIColor.App2.backgroundPrimary
        appSettingsIconImageView.backgroundColor = .clear
        appSettingsLabel.textColor =  UIColor.App2.textPrimary

        supportBaseView.backgroundColor = UIColor.App2.backgroundSecondary
        supportIconBaseView.backgroundColor = UIColor.App2.backgroundPrimary
        supportIconImageView.backgroundColor = .clear
        supportLabel.textColor =  UIColor.App2.textPrimary

        logoutBaseView.backgroundColor = .clear
        infoBaseView.backgroundColor = .clear
    }

    @IBAction private func didTapDepositButton() {

        if !Env.userSessionStore.isUserProfileIncomplete.value {

            let depositViewController = DepositViewController()

            self.navigationController?.pushViewController(depositViewController, animated: true)
        }
        else {
            let alert = UIAlertController(title: localized("string_profile_incomplete"),
                                          message: localized("string_profile_incomplete_deposit"),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("string_ok"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }

    @IBAction private func didTapWithdrawButton() {
        if !Env.userSessionStore.isUserProfileIncomplete.value {

            let withDrawViewController = WithdrawViewController()

            self.navigationController?.pushViewController(withDrawViewController, animated: true)
        }
        else {
            let alert = UIAlertController(title: localized("string_profile_incomplete"),
                                          message: localized("string_profile_incomplete_withdraw"),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("string_ok"), style: .default, handler: nil))
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

    @objc func personalInfoViewTapped() {
        let personalInfoViewController = PersonalInfoViewController(userSession: self.userSession)
        self.navigationController?.pushViewController(personalInfoViewController, animated: true)
    }

    @objc func passwordUpdateViewTapped() {
        let passwordUpdateViewController = PasswordUpdateViewController()
        self.navigationController?.pushViewController(passwordUpdateViewController, animated: true)
    }

    @objc func walletViewTapped() {

    }

    @objc func documentsViewTapped() {

    }

    @objc func bonusViewTapped() {

    }

    @objc func historyViewTapped() {

    }

    @objc func limitsViewTapped() {
        let profileLimitsManagementViewController = ProfileLimitsManagementViewController()
        self.navigationController?.pushViewController(profileLimitsManagementViewController, animated: true)
    }

    @objc func appSettingsViewTapped() {

    }

    @objc func supportViewTapped() {

    }

}
