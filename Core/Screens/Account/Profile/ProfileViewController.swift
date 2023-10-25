//
//  ProfileViewController.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/09/2021.
//

import UIKit
import Combine
import ServicesProvider
import RegisterFlow
import OptimoveSDK

class ProfileViewController: UIViewController {

    public var requestBetSwipeAction: () -> Void = { }
    public var requestHomeAction: () -> Void = { }
    public var requestRegisterAction: () -> Void = { }

    // Outlets
    @IBOutlet private weak var safeAreaTopView: UIView!
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var topBarView: UIView!

    @IBOutlet private weak var profileBaseView: UIView!
    @IBOutlet private weak var profilePictureBaseView: UIView!
    @IBOutlet private weak var profilePictureBaseInnerView: UIView!
    @IBOutlet private weak var profilePictureImageView: UIImageView!
    @IBOutlet private weak var usernameLabel: UILabel!

    @IBOutlet private weak var userCodeStackView: UIStackView!
    @IBOutlet private weak var userIdLabel: UILabel!
    @IBOutlet private weak var userCodeCopyView: UIView!
    @IBOutlet private weak var userCodeCopyImageView: UIImageView!
    @IBOutlet private weak var shadowView: UIView!

    @IBOutlet private weak var totalBalanceView: UIView!
    @IBOutlet private weak var totalBalanceTitleLabel: UILabel!
    @IBOutlet private weak var totalBalanceLabel: UILabel!
    @IBOutlet private weak var totalBalanceInfoImageView: UIImageView!

    @IBOutlet private weak var currentBalanceView: UIView!
    @IBOutlet private weak var currentBalanceTitleLabel: UILabel!
    @IBOutlet private weak var currentBalanceLabel: UILabel!

    @IBOutlet private weak var bonusBalanceBaseView: UIView!
    @IBOutlet private weak var bonusBalanceTitleLabel: UILabel!
    @IBOutlet private weak var bonusBalanceLabel: UILabel!

    @IBOutlet private weak var replayBalanceBaseView: UIView!
    @IBOutlet private weak var replayBalanceTitleLabel: UILabel!
    @IBOutlet private weak var replayBalanceLabel: UILabel!

    @IBOutlet private weak var depositButton: UIButton!
    @IBOutlet private weak var withdrawButton: UIButton!

    @IBOutlet private weak var scrollBaseView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!

    @IBOutlet private var activationStackView: UIStackView!
    @IBOutlet private var activationAlertScrollableView: ActivationAlertScrollableView!

    @IBOutlet private weak var stackView: UIStackView!

    @IBOutlet private weak var logoutBaseView: UIView!
    @IBOutlet private weak var logoutButton: UIButton!

    @IBOutlet private weak var infoBaseView: UIView!
    @IBOutlet private weak var infoLabel: UILabel!

    @IBOutlet private weak var footerBaseView: UIView!
    private var footerResponsibleGamingView = FooterResponsibleGamingView()

    // Custom views
    lazy var totalBalanceInfoDialogView: InfoDialogView = {
        let view = InfoDialogView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(title: localized("total_balance_automated_withdrawal"))
        return view
    }()

    var depositOnRegisterViewController: DepositOnRegisterViewController?

    var userProfile: UserProfile?
    var cancellables = Set<AnyCancellable>()
    let pasteboard = UIPasteboard.general

    enum PageMode {
        case user
        case anonymous
    }
    var pageMode: PageMode
    var alertsArray: [ActivationAlert] = []

    var ibanPaymentDetails: BankPaymentDetail?
    var shouldShowIbanScreen: (() -> Void)?

    init(userProfile: UserProfile? = nil) {

        self.pageMode = .anonymous
        self.userProfile = userProfile

        if userProfile != nil {
            pageMode = .user
        }

        super.init(nibName: "ProfileViewController", bundle: nil)

        self.getPaymentInfo()

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

        // Default is hidden
        self.bonusBalanceBaseView.isHidden = true
        // self.replayBalanceBaseView.isHidden = true

        //
        if let user = self.userProfile {
            self.usernameLabel.text = user.username

            if let avatarName = user.avatarName {
                self.profilePictureImageView.image = UIImage(named: avatarName)
            }
            else {
                self.profilePictureImageView.image = UIImage(named: "empty_user_image")
            }
            self.userIdLabel.text = user.userIdentifier
        }

        if TargetVariables.hasFeatureEnabled(feature: .chat), let userCode = Env.gomaNetworkClient.getCurrentToken()?.code {
            let userCodeString = localized("user_code_dynamic").replacingOccurrences(of: "{code_str}", with: userCode)
            self.userIdLabel.text = userCodeString
            self.userCodeStackView.isHidden = false
        }
        else {
            self.userCodeStackView.isHidden = true
        }
        
        Env.userSessionStore.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userProfile in
                if userProfile == nil {
                    self?.dismiss(animated: false, completion: nil)
                }
            }
            .store(in: &cancellables)

        Env.userSessionStore.refreshUserWallet()

        Env.userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userWallet in
                if let userWallet = userWallet {
                    // Total
                    if let formattedTotalString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: userWallet.total)) {
                        self?.totalBalanceLabel.text = formattedTotalString
                    }
                    else {
                        self?.totalBalanceLabel.text = "-.--€"
                    }

                    // Current
                    if let totalWithdrawable = userWallet.totalWithdrawable,
                       let formattedTotalWithdrawable = CurrencyFormater.defaultFormat.string(from: NSNumber(value: totalWithdrawable)) {
                        self?.currentBalanceLabel.text = formattedTotalWithdrawable
                    }
                    else {
                        self?.currentBalanceLabel.text =  "-.--€"
                    }

                    // Bonus
                    if let bonusValue = userWallet.bonus,
                       let formattedBonusString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: bonusValue)) {
                        self?.bonusBalanceLabel.text = formattedBonusString

                        if bonusValue <= 0 {
                            self?.bonusBalanceBaseView.isHidden = true
                        }
                        else {
                            self?.bonusBalanceBaseView.isHidden = false
                        }
                    }
                    else {
                        self?.bonusBalanceLabel.text = "-.--€"
                        self?.bonusBalanceBaseView.isHidden = true
                    }
                }
                else {
                    self?.totalBalanceLabel.text = "-.--€"
                    self?.currentBalanceLabel.text = "-.--€"
                    self?.bonusBalanceLabel.text = "-.--€"
                }
            }
            .store(in: &cancellables)

        Env.userSessionStore.userCashbackBalance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cashbackBalance in
                self?.replayBalanceLabel.text = "-.--€"

                if let cashbackBalance = cashbackBalance,
                   let formattedTotalString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: cashbackBalance)) {
                    self?.replayBalanceLabel.text = formattedTotalString

                    if cashbackBalance <= 0 {
                        self?.replayBalanceBaseView.isHidden = true
                    }
                    else {
                        self?.replayBalanceBaseView.isHidden = false
                    }
                }
            }
            .store(in: &cancellables)
        
        Env.userSessionStore.isUserProfileCompletePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.verifyUserActivationConditions()
            })
            .store(in: &cancellables)

        Env.userSessionStore.isUserEmailVerifiedPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.verifyUserActivationConditions()
            })
            .store(in: &cancellables)

        Env.userSessionStore.userKnowYourCustomerStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.verifyUserActivationConditions()
            })
            .store(in: &cancellables)

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        profilePictureBaseView.layer.cornerRadius = profilePictureBaseView.frame.size.width/2

        profilePictureBaseInnerView.layer.cornerRadius = profilePictureBaseInnerView.frame.size.width/2

        profilePictureImageView.layer.cornerRadius = profilePictureImageView.frame.size.width/2
        profilePictureImageView.layer.masksToBounds = false
        profilePictureImageView.clipsToBounds = true
    }

    func commonInit() {

        self.footerResponsibleGamingView.translatesAutoresizingMaskIntoConstraints = false

        self.footerResponsibleGamingView.showLinksView()
        self.footerResponsibleGamingView.showSocialView()

        self.footerBaseView.addSubview(self.footerResponsibleGamingView)

        NSLayoutConstraint.activate([
            self.footerResponsibleGamingView.leadingAnchor.constraint(equalTo: self.footerBaseView.leadingAnchor),
            self.footerResponsibleGamingView.trailingAnchor.constraint(equalTo: self.footerBaseView.trailingAnchor),
            self.footerResponsibleGamingView.topAnchor.constraint(equalTo: self.footerBaseView.topAnchor, constant: 8),
            self.footerResponsibleGamingView.bottomAnchor.constraint(equalTo: self.footerBaseView.bottomAnchor),
        ])

        shadowView.layer.shadowRadius = 10
        shadowView.layer.shadowOffset = .zero
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.4

        closeButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 17)
        closeButton.setTitle(localized("close"), for: .normal)
        closeButton.backgroundColor = .clear

        bonusBalanceBaseView.layer.cornerRadius = CornerRadius.view

        totalBalanceTitleLabel.text = localized("total_balance")
        totalBalanceTitleLabel.font = AppFont.with(type: .bold, size: 14)
        totalBalanceLabel.font = AppFont.with(type: .bold, size: 16)

        totalBalanceInfoImageView.image = UIImage(named: "info_small_icon")
        totalBalanceInfoImageView.setImageColor(color: UIColor.App.textPrimary)
        
        let totalBalanceInfoTap = UITapGestureRecognizer(target: self, action: #selector(self.tapTotalBalanceInfo))
        totalBalanceView.addGestureRecognizer(totalBalanceInfoTap)

        self.view.addSubview(self.totalBalanceInfoDialogView)

        NSLayoutConstraint.activate([

            self.totalBalanceInfoDialogView.bottomAnchor.constraint(equalTo: self.totalBalanceInfoImageView.topAnchor, constant: -10),
            self.totalBalanceInfoDialogView.trailingAnchor.constraint(equalTo: self.totalBalanceInfoImageView.trailingAnchor, constant: 8),
            self.totalBalanceInfoDialogView.widthAnchor.constraint(lessThanOrEqualToConstant: 150)
        ])

        self.totalBalanceInfoDialogView.alpha = 0

        currentBalanceTitleLabel.text = localized("current_balance")
        currentBalanceTitleLabel.font = AppFont.with(type: .bold, size: 14)
        currentBalanceLabel.font = AppFont.with(type: .bold, size: 16)

        bonusBalanceTitleLabel.text = localized("bonus")
        bonusBalanceTitleLabel.font = AppFont.with(type: .bold, size: 14)
        bonusBalanceLabel.font = AppFont.with(type: .bold, size: 16)

        replayBalanceTitleLabel.text = localized("replay_balance")
        replayBalanceTitleLabel.font = AppFont.with(type: .bold, size: 14)
        replayBalanceLabel.font = AppFont.with(type: .bold, size: 16)

        depositButton.layer.cornerRadius = CornerRadius.button
        withdrawButton.layer.cornerRadius = CornerRadius.button

        depositButton.backgroundColor = .clear
        depositButton.layer.cornerRadius = CornerRadius.button
        depositButton.layer.masksToBounds = true
        depositButton.setTitle(localized("deposit"), for: .normal)

        withdrawButton.backgroundColor = UIColor.App.buttonBackgroundSecondary
        withdrawButton.layer.cornerRadius = CornerRadius.button
        withdrawButton.layer.masksToBounds = true
        withdrawButton.setTitle(localized("withdraw"), for: .normal)

        logoutButton.backgroundColor = .clear
        logoutButton.layer.cornerRadius = CornerRadius.button
        logoutButton.layer.masksToBounds = true
        logoutButton.layer.borderWidth = 2
        logoutButton.setTitle(localized("logout"), for: .normal)

        currentBalanceLabel.text = localized("loading")

        if let versionNumber = Bundle.main.versionNumber,
           let buildNumber = Bundle.main.buildNumber {
            let appVersionRawString = localized("app_version_profile")
            let appVersionBuildNumberString = appVersionRawString.replacingOccurrences(of: "{version_1}", with: "(\(buildNumber))")
            let appVersionStringFinal = appVersionBuildNumberString.replacingOccurrences(of: "{version_2}", with: "\(versionNumber)")
            self.infoLabel.text = appVersionStringFinal
        }

        self.infoLabel.isUserInteractionEnabled = true

        self.activationAlertScrollableView.layer.cornerRadius = CornerRadius.button
        self.activationAlertScrollableView.layer.masksToBounds = true

        self.verifyUserActivationConditions()

        self.setupStackView()

        let copyCodeTap = UITapGestureRecognizer(target: self, action: #selector(self.tapCopyCode))
        self.userCodeStackView.addGestureRecognizer(copyCodeTap)

    }

    private func getOptInBonus() {

        Env.servicesProvider.getAvailableBonuses()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("AVAILABLE BONUSES ERROR: \(error)")
                }

            }, receiveValue: { [weak self] availableBonuses in

                let filteredBonus = availableBonuses.filter({
                    $0.type == "DEPOSIT"
                })

                self?.depositOnRegisterViewController?.availableBonuses.send(filteredBonus)
            })
            .store(in: &cancellables)

    }

    @objc func tapCopyCode() {
        if let userCode = Env.gomaNetworkClient.getCurrentToken()?.code {
            self.pasteboard.string = userCode

            let customCodeString = localized("user_code_dynamic_copied").replacingOccurrences(of: "{code_str}", with: userCode)

            let customToast = ToastCustom.text(title: customCodeString)

            customToast.show()
        }
    }

    func verifyUserActivationConditions() {

        var showActivationAlertScrollableView = false
        self.alertsArray = []

//        if let isUserEmailVerified = Env.userSessionStore.isUserEmailVerified.value, !isUserEmailVerified {
//            let emailActivationAlertData = ActivationAlert(title: localized("verify_email"),
//                                                           description: localized("app_full_potential"),
//                                                           linkLabel: localized("verify_my_account"),
//                                                           alertType: .email)
//            alertsArray.append(emailActivationAlertData)
//            showActivationAlertScrollableView = true
//        }
//
//        if let isUserProfileComplete = Env.userSessionStore.isUserProfileComplete, !isUserProfileComplete {
//            let completeProfileAlertData = ActivationAlert(title: localized("complete_your_profile"),
//                                                           description: localized("complete_profile_description"),
//                                                           linkLabel: localized("finish_up_profile"),
//                                                           alertType: .profile)
//
//            alertsArray.append(completeProfileAlertData)
//            showActivationAlertScrollableView = true
//        }

        if let isUserKycVerified = Env.userSessionStore.userKnowYourCustomerStatus, isUserKycVerified == .request {
            let uploadDocumentsAlertData = ActivationAlert(title: localized("document_validation_required"),
                                                           description: localized("document_validation_required_description"),
                                                           linkLabel: localized("complete_your_verification"),
                                                           alertType: .documents)

            alertsArray.append(uploadDocumentsAlertData)
            showActivationAlertScrollableView = true
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
                    self.navigationController?.pushViewController(fullRegisterViewController, animated: true)
                }
                else if alertType == ActivationAlertType.documents {
//                    let uploadDocumentsViewModel = UploadDocumentsViewModel()
//                    let uploadDocumentsViewController = UploadDocumentsViewController(viewModel: uploadDocumentsViewModel)
//                    self.present(uploadDocumentsViewController, animated: true, completion: nil)
                    let documentsRootViewModel = DocumentsRootViewModel()

                    let documentsRootViewController = DocumentsRootViewController(viewModel: documentsRootViewModel)

                    self.present(documentsRootViewController, animated: true)
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
        self.topBarView.backgroundColor = UIColor.App.backgroundPrimary
        profileBaseView.backgroundColor = UIColor.App.backgroundPrimary

        profilePictureBaseView.backgroundColor = UIColor.App.highlightPrimary
        bonusBalanceBaseView.backgroundColor = UIColor.App.backgroundPrimary
        scrollBaseView.backgroundColor = UIColor.App.backgroundPrimary
        profilePictureImageView.backgroundColor = .clear

        profilePictureBaseInnerView.backgroundColor = UIColor.App.backgroundPrimary

        usernameLabel.textColor = UIColor.App.textPrimary
        userIdLabel.textColor = UIColor.App.textSecondary

        //
        totalBalanceView.backgroundColor = UIColor.App.backgroundPrimary
        totalBalanceTitleLabel.textColor =  UIColor.App.textPrimary
        totalBalanceLabel.textColor =  UIColor.App.textPrimary

        currentBalanceView.backgroundColor = UIColor.App.backgroundPrimary
        currentBalanceTitleLabel.textColor =  UIColor.App.textPrimary
        currentBalanceLabel.textColor =  UIColor.App.textPrimary

        bonusBalanceBaseView.backgroundColor = UIColor.App.backgroundPrimary
        bonusBalanceTitleLabel.textColor = UIColor.App.textPrimary
        bonusBalanceLabel.textColor = UIColor.App.textPrimary

        replayBalanceBaseView.backgroundColor = UIColor.App.backgroundPrimary
        replayBalanceTitleLabel.textColor = UIColor.App.textPrimary
        replayBalanceLabel.textColor = UIColor.App.textPrimary
        //
        
        //
        depositButton.setTitleColor( UIColor.App.buttonTextPrimary, for: .normal)
        depositButton.setTitleColor( UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        depositButton.setTitleColor( UIColor.App.buttonTextPrimary.withAlphaComponent(0.4), for: .disabled)
        depositButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        depositButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .highlighted)

        withdrawButton.setTitleColor( UIColor.App.buttonTextPrimary, for: .normal)
        withdrawButton.setTitleColor( UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        withdrawButton.setTitleColor( UIColor.App.buttonTextPrimary.withAlphaComponent(0.4), for: .disabled)
        withdrawButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .normal)
        withdrawButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .highlighted)

        logoutButton.setTitleColor( UIColor.App.textPrimary, for: .normal)
        logoutButton.setTitleColor( UIColor.App.textPrimary.withAlphaComponent(0.7), for: .highlighted)
        logoutButton.setTitleColor( UIColor.App.textPrimary.withAlphaComponent(0.4), for: .disabled)
        logoutButton.layer.borderColor = UIColor.App.backgroundSecondary.cgColor

        infoLabel.textColor = UIColor.App.textPrimary
        
        logoutBaseView.backgroundColor = .clear
        infoBaseView.backgroundColor = .clear
    }

    private func setupStackView() {
        let myAccountView = NavigationCardView()
        myAccountView.setupView(title: localized("my_account"), iconTitle: "my_account_profile_icon")
        let myAccountTap = UITapGestureRecognizer(target: self, action: #selector(myAccountViewTapped(sender:)))
        myAccountView.addGestureRecognizer(myAccountTap)

        let cashbackView = NavigationCardView()
        cashbackView.setupView(title: localized("replay"), iconTitle: "cashback_profile_icon")
        let cashbackTap = UITapGestureRecognizer(target: self, action: #selector(cashbackViewTapped(sender:)))
        cashbackView.addGestureRecognizer(cashbackTap)

        let betSwipeView = NavigationCardView()
        betSwipeView.setupView(title: "Bet Swipe", iconTitle: "betswipe_profile_icon")
        let betSwipeTap = UITapGestureRecognizer(target: self, action: #selector(betSwipeViewTapped(sender:)))
        betSwipeView.addGestureRecognizer(betSwipeTap)

        let bonusView = NavigationCardView()
        bonusView.setupView(title: localized("bonus"), iconTitle: "bonus_profile_icon")
        let bonusTap = UITapGestureRecognizer(target: self, action: #selector(bonusViewTapped(sender:)))
        bonusView.addGestureRecognizer(bonusTap)

        let promotionsView = NavigationCardView()
        promotionsView.hasNotifications = true
        promotionsView.setupView(title: localized("promotions"), iconTitle: "promotion_icon")
        let promotionsTap = UITapGestureRecognizer(target: self, action: #selector(promotionsViewTapped(sender:)))
        promotionsView.addGestureRecognizer(promotionsTap)


        let responsibleGamingView = NavigationCardView()
        responsibleGamingView.setupView(title: localized("responsible_gaming"), iconTitle: "responsible_gaming_icon")
        let responsibleGamingTap = UITapGestureRecognizer(target: self, action: #selector(responsibleGamingViewTapped(sender:)))
        responsibleGamingView.addGestureRecognizer(responsibleGamingTap)

//        let recruitFriendView = NavigationCardView()
//        recruitFriendView.setupView(title: localized("referal_friend"), iconTitle: "recruit_icon")
//        let recruitFriendTap = UITapGestureRecognizer(target: self, action: #selector(recruitFriendViewTapped(sender:)))
//        recruitFriendView.addGestureRecognizer(recruitFriendTap)

        let myFavoritesView = NavigationCardView()
        myFavoritesView.setupView(title: localized("my_favorites"), iconTitle: "favorite_profile_icon")
        let myFavoritesTap = UITapGestureRecognizer(target: self, action: #selector(favoritesViewTapped(sender:)))
        myFavoritesView.addGestureRecognizer(myFavoritesTap)

        let settingsView = NavigationCardView()
        settingsView.setupView(title: localized("app_settings"), iconTitle: "app_settings_profile_icon")
        let settingsTap = UITapGestureRecognizer(target: self, action: #selector(appSettingsViewTapped(sender:)))
        settingsView.addGestureRecognizer(settingsTap)

        let supportView = NavigationCardView()
        supportView.setupView(title: localized("support"), iconTitle: "support_profile_icon")
        let supportTap = UITapGestureRecognizer(target: self, action: #selector(supportViewTapped(sender:)))
        supportView.addGestureRecognizer(supportTap)

        self.stackView.addArrangedSubview(myAccountView)
        self.stackView.addArrangedSubview(responsibleGamingView)
        
        // self.stackView.addArrangedSubview(cashbackView)
        // self.stackView.addArrangedSubview(betSwipeView)
        self.stackView.addArrangedSubview(bonusView)

        self.stackView.addArrangedSubview(promotionsView)
//        self.stackView.addArrangedSubview(recruitFriendView)
        self.stackView.addArrangedSubview(myFavoritesView)
        self.stackView.addArrangedSubview(settingsView)
        self.stackView.addArrangedSubview(supportView)

    }

    // MARK: Functions
    private func getPaymentInfo() {

        self.ibanPaymentDetails = nil

        Env.servicesProvider.getPaymentInformation()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("PAYMENT INFO ERROR: \(error)")
                }
            }, receiveValue: { [weak self] paymentInfo in
                let paymentDetails = paymentInfo.data.filter({
                    $0.details.isNotEmpty
                })
                if paymentDetails.isNotEmpty {

                    if let bankPaymentDetail = paymentDetails.filter({
                        $0.type == "BANK"
                    }).first,
                       let ibanPaymentDetail = bankPaymentDetail.details.filter({
                           $0.key == "IBAN"
                       }).first {
                        if ibanPaymentDetail.value != "" {
                            self?.ibanPaymentDetails = ibanPaymentDetail
                        }
                    }

                }

            })
            .store(in: &cancellables)
    }

    // MARK: Actions
    @IBAction private func didTapDepositButton() {
        let depositViewController = DepositViewController()
        let navigationViewController = Router.navigationController(with: depositViewController)
        depositViewController.shouldRefreshUserWallet = {
            Env.userSessionStore.refreshUserWallet()
        }
        self.present(navigationViewController, animated: true, completion: nil)
    }

    @IBAction private func didTapWithdrawButton() {

        if self.ibanPaymentDetails == nil,
           let accountBalance = Env.userSessionStore.userWalletPublisher.value?.totalWithdrawable,
           let userKycStatus = Env.userSessionStore.userKnowYourCustomerStatus,
           accountBalance > 0 && userKycStatus == .passConditional {

            let ibanProofViewModel = IBANProofViewModel()

            let ibanProofViewController = IBANProofViewController(viewModel: ibanProofViewModel)

            ibanProofViewController.shouldReloadPaymentInfo = { [weak self] in
                self?.getPaymentInfo()
            }

            let navigationViewController = Router.navigationController(with: ibanProofViewController)

            self.present(navigationViewController, animated: true, completion: nil)

        }
        else if self.ibanPaymentDetails != nil,
                let userKycStatus = Env.userSessionStore.userKnowYourCustomerStatus,
                userKycStatus == .passConditional   {
            let alert = UIAlertController(title: localized("withdrawal_warning"),
                                          message: localized("withdrawal_iban_pending_approval_message"),
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: localized("understood"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else if let accountBalance = Env.userSessionStore.userWalletPublisher.value?.totalWithdrawable,
           accountBalance > 0,
           let isUserProfileComplete = Env.userSessionStore.isUserProfileComplete,
           let userKycStatus = Env.userSessionStore.userKnowYourCustomerStatus {

            if isUserProfileComplete && userKycStatus == .pass {
                let withDrawViewController = WithdrawViewController()
                let navigationViewController = Router.navigationController(with: withDrawViewController)
                withDrawViewController.shouldRefreshUserWallet = {
                    Env.userSessionStore.refreshUserWallet()
                }
                self.present(navigationViewController, animated: true, completion: nil)
            }
            else if userKycStatus == .request {
                let alert = UIAlertController(title: localized("kyc_message_title"),
                                              message: localized("kyc_message_body"),
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: localized("understood"), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: localized("profile_incomplete"),
                                              message: localized("profile_incomplete_withdraw"),
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: localized("understood"), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }

        }
    }

    @objc private func tapTotalBalanceInfo() {
        print("TAPPED TOTAL BALANCE INFO!")

        UIView.animate(withDuration: 0.5, animations: {
            self.totalBalanceInfoDialogView.alpha = 1
        }) { (completed) in
            if completed {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    UIView.animate(withDuration: 0.5) {
                        self.totalBalanceInfoDialogView.alpha = 0
                    }
                }
            }
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
        self.didTapCloseButton()
    }
}

extension ProfileViewController {

    @objc private func myAccountViewTapped(sender: UITapGestureRecognizer) {
        let myAccountViewController = MyAccountViewController()
        self.navigationController?.pushViewController(myAccountViewController, animated: true)
    }

    @objc func favoritesViewTapped(sender: UITapGestureRecognizer) {
//        let favoritesViewController = MyFavoritesViewController()
//        self.navigationController?.pushViewController(favoritesViewController, animated: true)

        let myFavoritesViewController = MyFavoritesRootViewController()

        self.navigationController?.pushViewController(myFavoritesViewController, animated: true)

    }

    @objc func bonusViewTapped(sender: UITapGestureRecognizer) {
        let bonusRootViewController = BonusRootViewController(viewModel: BonusRootViewModel(startTabIndex: 0))
        self.navigationController?.pushViewController(bonusRootViewController, animated: true)
    }

    @objc func promotionsViewTapped(sender: UITapGestureRecognizer) {

        var gomaBaseUrl = TargetVariables.clientBaseUrl
        let appLanguage = "fr"

        let isDarkTheme = self.traitCollection.userInterfaceStyle == .dark ? true : false
        let urlString = "\(gomaBaseUrl)/\(appLanguage)/in-app/promotions?dark=\(isDarkTheme)"

        if let url = URL(string: urlString) {
            let promotionsWebViewModel = PromotionsWebViewModel()
            let promotionsWebViewController = PromotionsWebViewController(url: url, viewModel: promotionsWebViewModel)
            promotionsWebViewController.openBetSwipeAction = { [weak self] in
                self?.requestBetSwipeAction()
            }
            promotionsWebViewController.openRegisterAction = { [weak self] in
                self?.requestRegisterAction()
            }
            promotionsWebViewController.openHomeAction = { [weak self] in
                self?.requestHomeAction()
            }
            self.navigationController?.pushViewController(promotionsWebViewController, animated: true)
        }
    }

    @objc func responsibleGamingViewTapped(sender: UITapGestureRecognizer) {
        let responsibleGamingViewController = ResponsibleGamingViewController()
        self.navigationController?.pushViewController(responsibleGamingViewController, animated: true)
    }

    @objc func recruitFriendViewTapped(sender: UITapGestureRecognizer) {
        let recruitAFriendViewController = RecruitAFriendViewController()

        self.navigationController?.pushViewController(recruitAFriendViewController, animated: true)
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
        let supportViewController = SupportPageViewController(viewModel: SupportPageViewModel())
        self.navigationController?.pushViewController(supportViewController, animated: true)
    }

    @objc func cashbackViewTapped(sender: UITapGestureRecognizer) {
        let cashbackInfoViewController = CashbackInfoViewController()
        self.navigationController?.pushViewController(cashbackInfoViewController, animated: true)
    }

    @objc func betSwipeViewTapped(sender: UITapGestureRecognizer) {
        let betSelectorViewConroller = InternalBrowserViewController(fileName: "TinderStyleBetBuilder", fileType: "html", fullscreen: true)
        self.navigationController?.pushViewController(betSelectorViewConroller, animated: true)
    }

}
