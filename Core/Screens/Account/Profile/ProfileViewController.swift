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
            .sink { [weak self] value in
                self?.currentBalanceLabel.text = value
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
        closeButton.setTitle(localized("close"), for: .normal)
        closeButton.backgroundColor = .clear

        currentBalanceBaseView.layer.cornerRadius = CornerRadius.view

        depositButton.layer.cornerRadius = CornerRadius.button
        withdrawButton.layer.cornerRadius = CornerRadius.button

        depositButton.backgroundColor = .clear
        depositButton.layer.cornerRadius = CornerRadius.button
        depositButton.layer.masksToBounds = true
        depositButton.setTitle(localized("deposit"), for: .normal)

        withdrawButton.backgroundColor = .clear
        withdrawButton.layer.cornerRadius = CornerRadius.button
        withdrawButton.layer.masksToBounds = true
        withdrawButton.layer.borderWidth = 2
        withdrawButton.setTitle(localized("withdraw"), for: .normal)

        logoutButton.backgroundColor = .clear
        logoutButton.layer.cornerRadius = CornerRadius.button
        logoutButton.layer.masksToBounds = true
        logoutButton.layer.borderWidth = 2
        logoutButton.setTitle(localized("logout"), for: .normal)

        personalInfoBaseView.layer.cornerRadius = CornerRadius.view
        personalInfoIconBaseView.layer.cornerRadius = CornerRadius.view
        personalInfoIconImageView.backgroundColor = .clear
        let personalInfoTapGesture = UITapGestureRecognizer(target: self, action: #selector(personalInfoViewTapped))
        personalInfoBaseView.addGestureRecognizer(personalInfoTapGesture)

        passwordUpdateBaseView.layer.cornerRadius = CornerRadius.view
        passwordUpdateIconBaseView.layer.cornerRadius = CornerRadius.view
        passwordUpdateIconImageView.backgroundColor = .clear
        let passwordUpdateTapGesture = UITapGestureRecognizer(target: self, action: #selector(passwordUpdateViewTapped))
        passwordUpdateBaseView.addGestureRecognizer(passwordUpdateTapGesture)

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

        currentBalanceLabel.text = localized("loading")

        //
        personalInfoLabel.text = localized("personal_info")
        passwordUpdateLabel.text = localized("update_password")
        walletLabel.text = localized("wallet")
        documentsLabel.text = localized("documents")
        bonusLabel.text = localized("bonus")
        historyLabel.text = localized("history")
        limitsLabel.text = localized("limits_management")
        appSettingsLabel.text = localized("app_settings")
        supportLabel.text = localized("support")

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
        self.view.backgroundColor = UIColor.App.mainBackground

        closeButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        closeButton.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)
        closeButton.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.4), for: .disabled)

        safeAreaTopView.backgroundColor = UIColor.App.mainBackground
        profileBaseView.backgroundColor = UIColor.App.mainBackground
        profilePictureBaseView.backgroundColor = UIColor.App.mainTint
        currentBalanceBaseView.backgroundColor = UIColor.App.secondaryBackground
        scrollBaseView.backgroundColor = UIColor.App.mainBackground
        profilePictureImageView.backgroundColor = .clear

        usernameLabel.textColor = UIColor.App.headingMain
        userIdLabel.textColor = UIColor.App.fadeOutHeading
        currentBalanceTitleLabel.textColor = UIColor.App.headingMain
        currentBalanceLabel.textColor = UIColor.App.headingMain

        //
        depositButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        depositButton.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)
        depositButton.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.4), for: .disabled)
        depositButton.setBackgroundColor(UIColor.App.primaryButtonNormal, for: .normal)
        depositButton.setBackgroundColor(UIColor.App.primaryButtonPressed, for: .highlighted)

        withdrawButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        withdrawButton.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)
        withdrawButton.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.4), for: .disabled)
        withdrawButton.layer.borderColor = UIColor.App.secondaryBackground.cgColor

        logoutButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        logoutButton.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)
        logoutButton.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.4), for: .disabled)
        logoutButton.layer.borderColor = UIColor.App.secondaryBackground.cgColor

        //
        personalInfoBaseView.backgroundColor = UIColor.App.secondaryBackground
        personalInfoIconBaseView.backgroundColor = UIColor.App.mainBackground
        personalInfoIconImageView.backgroundColor = .clear
        personalInfoLabel.textColor = UIColor.App.headingMain

        passwordUpdateBaseView.backgroundColor = UIColor.App.secondaryBackground
        passwordUpdateIconBaseView.backgroundColor = UIColor.App.mainBackground
        passwordUpdateIconImageView.backgroundColor = .clear
        passwordUpdateLabel.textColor = UIColor.App.headingMain

        walletBaseView.backgroundColor = UIColor.App.secondaryBackground
        walletIconBaseView.backgroundColor = UIColor.App.mainBackground
        walletIconImageView.backgroundColor = .clear
        walletLabel.textColor = UIColor.App.headingMain

        documentsBaseView.backgroundColor = UIColor.App.secondaryBackground
        documentsIconBaseView.backgroundColor = UIColor.App.mainBackground
        documentsIconImageView.backgroundColor = .clear
        documentsLabel.textColor = UIColor.App.headingMain

        bonusBaseView.backgroundColor = UIColor.App.secondaryBackground
        bonusIconBaseView.backgroundColor = UIColor.App.mainBackground
        bonusIconImageView.backgroundColor = .clear
        bonusLabel.textColor = UIColor.App.headingMain

        historyBaseView.backgroundColor = UIColor.App.secondaryBackground
        historyIconBaseView.backgroundColor = UIColor.App.mainBackground
        historyIconImageView.backgroundColor = .clear
        historyLabel.textColor = UIColor.App.headingMain

        limitsBaseView.backgroundColor = UIColor.App.secondaryBackground
        limitsIconBaseView.backgroundColor = UIColor.App.mainBackground
        limitsIconImageView.backgroundColor = .clear
        limitsLabel.textColor = UIColor.App.headingMain

        appSettingsBaseView.backgroundColor = UIColor.App.secondaryBackground
        appSettingsIconBaseView.backgroundColor = UIColor.App.mainBackground
        appSettingsIconImageView.backgroundColor = .clear
        appSettingsLabel.textColor = UIColor.App.headingMain

        supportBaseView.backgroundColor = UIColor.App.secondaryBackground
        supportIconBaseView.backgroundColor = UIColor.App.mainBackground
        supportIconImageView.backgroundColor = .clear
        supportLabel.textColor = UIColor.App.headingMain

        logoutBaseView.backgroundColor = .clear
        infoBaseView.backgroundColor = .clear
    }

    @IBAction private func didTapDepositButton() {

        if !Env.userSessionStore.isUserProfileIncomplete.value {

            let depositViewController = DepositViewController()

            self.navigationController?.pushViewController(depositViewController, animated: true)
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

            self.navigationController?.pushViewController(withDrawViewController, animated: true)
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
