//
//  ProfileViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/09/2021.
//

import UIKit

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

    enum PageMode {
        case user
        case anonymous
    }
    var pageMode: PageMode

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

        currentBalanceBaseView.layer.cornerRadius = BorderRadius.view

        depositButton.layer.cornerRadius = BorderRadius.button
        withdrawButton.layer.cornerRadius = BorderRadius.button

        depositButton.backgroundColor = .clear
        depositButton.layer.cornerRadius = BorderRadius.button
        depositButton.layer.masksToBounds = true

        withdrawButton.backgroundColor = .clear
        withdrawButton.layer.cornerRadius = BorderRadius.button
        withdrawButton.layer.masksToBounds = true
        withdrawButton.layer.borderWidth = 2

        logoutButton.backgroundColor = .clear
        logoutButton.layer.cornerRadius = BorderRadius.button
        logoutButton.layer.masksToBounds = true
        logoutButton.layer.borderWidth = 2

        personalInfoBaseView.layer.cornerRadius = BorderRadius.view
        personalInfoIconBaseView.layer.cornerRadius = BorderRadius.view
        personalInfoIconImageView.backgroundColor = .clear
        let personalInfoTapGesture = UITapGestureRecognizer(target: self, action: #selector(personalInfoViewTapped))
        personalInfoBaseView.addGestureRecognizer(personalInfoTapGesture)

        passwordUpdateBaseView.layer.cornerRadius = BorderRadius.view
        passwordUpdateIconBaseView.layer.cornerRadius = BorderRadius.view
        passwordUpdateIconImageView.backgroundColor = .clear
        let passwordUpdateTapGesture = UITapGestureRecognizer(target: self, action: #selector(passwordUpdateViewTapped))
        passwordUpdateBaseView.addGestureRecognizer(passwordUpdateTapGesture)

        walletBaseView.layer.cornerRadius = BorderRadius.view
        walletIconBaseView.layer.cornerRadius = BorderRadius.view
        walletIconImageView.backgroundColor = .clear
        let walletTapGesture = UITapGestureRecognizer(target: self, action: #selector(walletViewTapped))
        walletBaseView.addGestureRecognizer(walletTapGesture)

        documentsBaseView.layer.cornerRadius = BorderRadius.view
        documentsIconBaseView.layer.cornerRadius = BorderRadius.view
        documentsIconImageView.backgroundColor = .clear
        let documentsTapGesture = UITapGestureRecognizer(target: self, action: #selector(documentsViewTapped))
        documentsBaseView.addGestureRecognizer(documentsTapGesture)

        bonusBaseView.layer.cornerRadius = BorderRadius.view
        bonusIconBaseView.layer.cornerRadius = BorderRadius.view
        bonusIconImageView.backgroundColor = .clear
        let bonusTapGesture = UITapGestureRecognizer(target: self, action: #selector(bonusViewTapped))
        bonusBaseView.addGestureRecognizer(bonusTapGesture)

        historyBaseView.layer.cornerRadius = BorderRadius.view
        historyIconBaseView.layer.cornerRadius = BorderRadius.view
        historyIconImageView.backgroundColor = .clear
        let historyTapGesture = UITapGestureRecognizer(target: self, action: #selector(historyViewTapped))
        historyBaseView.addGestureRecognizer(historyTapGesture)

        limitsBaseView.layer.cornerRadius = BorderRadius.view
        limitsIconBaseView.layer.cornerRadius = BorderRadius.view
        limitsIconImageView.backgroundColor = .clear
        let limitsTapGesture = UITapGestureRecognizer(target: self, action: #selector(limitsViewTapped))
        limitsBaseView.addGestureRecognizer(limitsTapGesture)

        appSettingsBaseView.layer.cornerRadius = BorderRadius.view
        appSettingsIconBaseView.layer.cornerRadius = BorderRadius.view
        appSettingsIconImageView.backgroundColor = .clear
        let appSettingsTapGesture = UITapGestureRecognizer(target: self, action: #selector(appSettingsViewTapped))
        appSettingsBaseView.addGestureRecognizer(appSettingsTapGesture)

        supportBaseView.layer.cornerRadius = BorderRadius.view
        supportIconBaseView.layer.cornerRadius = BorderRadius.view
        supportIconImageView.backgroundColor = .clear
        let supportTapGesture = UITapGestureRecognizer(target: self, action: #selector(supportViewTapped))
        supportBaseView.addGestureRecognizer(supportTapGesture)

        currentBalanceLabel.text = "0,00€"

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
            self.infoLabel.text = "App Version \(versionNumber)(\(buildNumber)\nSportsbook® All Rights Reserved"
        }

    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackgroundColor

        closeButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        closeButton.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)
        closeButton.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.4), for: .disabled)

        safeAreaTopView.backgroundColor = UIColor.App.mainBackgroundColor
        profileBaseView.backgroundColor = UIColor.App.mainBackgroundColor
        profilePictureBaseView.backgroundColor = UIColor.App.mainTintColor
        currentBalanceBaseView.backgroundColor = UIColor.App.secundaryBackgroundColor
        scrollBaseView.backgroundColor = UIColor.App.mainBackgroundColor
        profilePictureImageView.backgroundColor = .clear

        usernameLabel.textColor = UIColor.App.headingMain
        userIdLabel.textColor = UIColor.App.subtitleGray
        currentBalanceTitleLabel.textColor = UIColor.App.headingMain
        currentBalanceLabel.textColor = UIColor.App.headingMain

        //
        depositButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        depositButton.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)
        depositButton.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.4), for: .disabled)
        depositButton.setBackgroundColor(UIColor.App.primaryButtonNormalColor, for: .normal)
        depositButton.setBackgroundColor(UIColor.App.primaryButtonPressedColor, for: .highlighted)

        withdrawButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        withdrawButton.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)
        withdrawButton.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.4), for: .disabled)
        withdrawButton.layer.borderColor = UIColor.App.secundaryBackgroundColor.cgColor

        logoutButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        logoutButton.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.7), for: .highlighted)
        logoutButton.setTitleColor(UIColor.App.headingMain.withAlphaComponent(0.4), for: .disabled)
        logoutButton.layer.borderColor = UIColor.App.secundaryBackgroundColor.cgColor

        //
        personalInfoBaseView.backgroundColor = UIColor.App.secundaryBackgroundColor
        personalInfoIconBaseView.backgroundColor = UIColor.App.mainBackgroundColor
        personalInfoIconImageView.backgroundColor = .clear
        personalInfoLabel.textColor = UIColor.App.headingMain

        passwordUpdateBaseView.backgroundColor = UIColor.App.secundaryBackgroundColor
        passwordUpdateIconBaseView.backgroundColor = UIColor.App.mainBackgroundColor
        passwordUpdateIconImageView.backgroundColor = .clear
        passwordUpdateLabel.textColor = UIColor.App.headingMain

        walletBaseView.backgroundColor = UIColor.App.secundaryBackgroundColor
        walletIconBaseView.backgroundColor = UIColor.App.mainBackgroundColor
        walletIconImageView.backgroundColor = .clear
        walletLabel.textColor = UIColor.App.headingMain

        documentsBaseView.backgroundColor = UIColor.App.secundaryBackgroundColor
        documentsIconBaseView.backgroundColor = UIColor.App.mainBackgroundColor
        documentsIconImageView.backgroundColor = .clear
        documentsLabel.textColor = UIColor.App.headingMain

        bonusBaseView.backgroundColor = UIColor.App.secundaryBackgroundColor
        bonusIconBaseView.backgroundColor = UIColor.App.mainBackgroundColor
        bonusIconImageView.backgroundColor = .clear
        bonusLabel.textColor = UIColor.App.headingMain

        historyBaseView.backgroundColor = UIColor.App.secundaryBackgroundColor
        historyIconBaseView.backgroundColor = UIColor.App.mainBackgroundColor
        historyIconImageView.backgroundColor = .clear
        historyLabel.textColor = UIColor.App.headingMain

        limitsBaseView.backgroundColor = UIColor.App.secundaryBackgroundColor
        limitsIconBaseView.backgroundColor = UIColor.App.mainBackgroundColor
        limitsIconImageView.backgroundColor = .clear
        limitsLabel.textColor = UIColor.App.headingMain

        appSettingsBaseView.backgroundColor = UIColor.App.secundaryBackgroundColor
        appSettingsIconBaseView.backgroundColor = UIColor.App.mainBackgroundColor
        appSettingsIconImageView.backgroundColor = .clear
        appSettingsLabel.textColor = UIColor.App.headingMain

        supportBaseView.backgroundColor = UIColor.App.secundaryBackgroundColor
        supportIconBaseView.backgroundColor = UIColor.App.mainBackgroundColor
        supportIconImageView.backgroundColor = .clear
        supportLabel.textColor = UIColor.App.headingMain

        logoutBaseView.backgroundColor = .clear
        infoBaseView.backgroundColor = .clear
    }

}

extension ProfileViewController {

    @IBAction private func didTapCloseButton() {
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        }
    }

    @IBAction private func didTapLogoutButton() {
        Env.userSessionStore.logout()
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

    }

    @objc func appSettingsViewTapped() {

    }

    @objc func supportViewTapped() {

    }

}
