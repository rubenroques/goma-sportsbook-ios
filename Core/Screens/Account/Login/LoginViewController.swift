import UIKit
import Combine
import ServicesProvider
import RegisterFlow
import Adyen
import AdyenDropIn
import AdyenComponents
import HeaderTextField
import LocalAuthentication
import OptimoveSDK
import AdjustSdk

class LoginViewController: UIViewController {

    @IBOutlet private var scrollView: UIScrollView!

    @IBOutlet private var skipView: UIView!
    @IBOutlet private var skipButton: UIButton!
    @IBOutlet private var dismissButton: UIButton!

    @IBOutlet private var logoImageView: UIImageView!

    @IBOutlet private var loginView: UIView!
    @IBOutlet private var loginLabel: UILabel!
    @IBOutlet private weak var usernameHeaderTextFieldView: HeaderTextField.HeaderTextFieldView!
    @IBOutlet private weak var passwordHeaderTextFieldView: HeaderTextField.HeaderTextFieldView!

    @IBOutlet private var rememberView: UIView!
    @IBOutlet private var rememberToggleView: UIView!
    @IBOutlet private var rememberImageView: UIImageView!
    @IBOutlet private var rememberLabel: UILabel!

    @IBOutlet private var forgotView: UIView!
    @IBOutlet private var forgotButton: UIButton!
    @IBOutlet private var loginButton: UIButton!
    @IBOutlet private var registerButton: UIButton!
    @IBOutlet private var policyLinkView: PolicyLinkView!

    @IBOutlet private var rightOrView: UIView!
    @IBOutlet private var leftOrView: UIView!
    @IBOutlet private var orLabel: UILabel!

    //
    // Variables
    private var shouldRememberUser: Bool = true

    private var shouldPresentRegisterFlow: Bool

    private var cancellables = Set<AnyCancellable>()

    private let spinnerViewController = LoadingSpinnerViewController()
    
    private let dateFormatter = DateFormatter()
    
    var hasPendingRedirect: Bool = false
    var needsRedirect: (() -> Void)?
    
    var referralCode: String?

    init(shouldPresentRegisterFlow: Bool = false, referralCode: String? = nil) {
        self.referralCode = referralCode
        self.shouldPresentRegisterFlow = shouldPresentRegisterFlow
        super.init(nibName: "LoginViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        AnalyticsClient.sendEvent(event: .loginScreen)

        self.title = "SplashViewController"

        commonInit()
        self.setupWithTheme()

        // Default value
        Env.userSessionStore.shouldRecordUserSession = true

        self.loginButton.isEnabled = false
        Publishers.CombineLatest(self.usernameHeaderTextFieldView.textPublisher, self.passwordHeaderTextFieldView.textPublisher)
            .map { username, password in
                return username.isNotEmpty && password.isNotEmpty
            }
            .sink(receiveCompletion: { _ in
                
            }, receiveValue: { [weak self] validFields in
                self?.loginButton.isEnabled = validFields
            })
            .store(in: &cancellables)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.isModal {
            self.skipButton.isHidden = true
            self.dismissButton.isHidden = false
        }
        else {
            self.skipButton.isHidden = false
            self.dismissButton.isHidden = true
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.shouldPresentRegisterFlow {
            self.presentRegister(animated: true)
            self.shouldPresentRegisterFlow = false
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func commonInit() {

        usernameHeaderTextFieldView.setSecureField(false)
        usernameHeaderTextFieldView.setKeyboardType(.emailAddress)

        passwordHeaderTextFieldView.setSecureField(true)
        passwordHeaderTextFieldView.setKeyboardType(.default)

        usernameHeaderTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        passwordHeaderTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))

        usernameHeaderTextFieldView.setReturnKeyType(.next)
        passwordHeaderTextFieldView.setReturnKeyType(.go)

        usernameHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.passwordHeaderTextFieldView.becomeFirstResponder()
        }

        passwordHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.passwordHeaderTextFieldView.resignFirstResponder()
            self?.didTapLoginButton()
        }

        self.skipButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 17)
        self.skipButton.setTitle(localized("skip"), for: .normal)
        
        self.dismissButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 17)
        self.dismissButton.setTitle(localized("close"), for: .normal)
        
        self.logoImageView.image = UIImage(named: "brand_icon_variation_new")
        self.logoImageView.sizeToFit()
        
        self.loginLabel.font = AppFont.with(type: AppFont.AppFontType.bold, size: 24)
        self.loginLabel.text = localized("login")

        self.usernameHeaderTextFieldView.setPlaceholderText(localized("email"))
        self.passwordHeaderTextFieldView.setPlaceholderText(localized("password"))

        self.usernameHeaderTextFieldView.highlightColor = UIColor.white
        self.passwordHeaderTextFieldView.highlightColor = UIColor.white

        self.rememberLabel.text = localized("remember")
        self.rememberLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 12)
        self.rememberToggleView.layer.cornerRadius = CornerRadius.checkBox
        self.rememberImageView.backgroundColor = .clear
        self.rememberImageView.contentMode = .scaleAspectFit

        self.enableRememberUser()

        self.forgotButton.setTitle(localized("forgot"), for: .normal)
        self.forgotButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 14)

        self.loginButton.setTitle(localized("login"), for: .normal)
        self.loginButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 18)
        self.loginButton.addTarget(self, action: #selector(self.didTapLoginButton), for: .primaryActionTriggered)

        self.passwordHeaderTextFieldView.setSecureField(true)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        let tapImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(rememberUserOptionTapped))
        self.rememberView.isUserInteractionEnabled = true
        self.rememberView.addGestureRecognizer(tapImageGestureRecognizer)

        self.registerButton.setTitle(localized("create_a_new_account"), for: .normal)
        self.registerButton.addTarget(self, action: #selector(self.didTapRegister), for: .primaryActionTriggered)

        self.dismissButton.setTitle(localized("close"), for: .normal)
        self.dismissButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.orLabel.text = localized("or")

        self.checkPolicyLinks()

        self.logoImageView.isUserInteractionEnabled = true

         #if DEBUG
        let debugLogoImageViewTap = UITapGestureRecognizer(target: self, action: #selector(didTapDebugFormFill))
        debugLogoImageViewTap.numberOfTapsRequired = 3
        self.logoImageView.addGestureRecognizer(debugLogoImageViewTap)
         #endif
    }
    
    @objc private func didTapTest() {
        
        let registerSuccessViewController = RegisterSuccessViewController()

        self.navigationController?.pushViewController(registerSuccessViewController, animated: true)
    }

    func setupWithTheme() {
        
        self.view.backgroundColor = UIColor.App.backgroundPrimary
        self.skipView.backgroundColor = UIColor.App.backgroundPrimary

        self.skipButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        self.skipButton.backgroundColor = .clear

        self.loginLabel.textColor = UIColor.App.textHeadlinePrimary

        self.usernameHeaderTextFieldView.highlightColor = UIColor.App.inputBorderActive
        self.usernameHeaderTextFieldView.setViewColor(UIColor.App.inputBackground)
        self.usernameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        self.usernameHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        self.passwordHeaderTextFieldView.highlightColor = UIColor.App.inputBorderActive
        self.passwordHeaderTextFieldView.setViewColor(UIColor.App.inputBackground)
        self.passwordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        self.passwordHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        self.rememberView.backgroundColor = .clear
        self.rememberLabel.textColor = UIColor.App.textPrimary

        self.rememberImageView.setImageColor(color: UIColor.App.buttonTextPrimary)

        if self.shouldRememberUser {
            self.rememberToggleView.backgroundColor =  UIColor.App.buttonBackgroundPrimary
        }
        else {
            self.rememberToggleView.backgroundColor =  UIColor.App.buttonBackgroundPrimary
        }

        self.forgotButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.loginButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.loginButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.loginButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.4), for: .disabled)
        self.loginButton.backgroundColor = .clear
        self.loginButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        self.loginButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .highlighted)
        self.loginButton.layer.cornerRadius = CornerRadius.button
        self.loginButton.layer.masksToBounds = true

        self.rightOrView.backgroundColor =  UIColor.App.separatorLine
        self.rightOrView.alpha = 0.9
        self.leftOrView.backgroundColor =  UIColor.App.separatorLine
        self.leftOrView.alpha = 0.9

        self.orLabel.textColor = UIColor.App.textPrimary

        self.registerButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.registerButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.registerButton.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.4), for: .disabled)
        self.registerButton.backgroundColor = .clear
        self.registerButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .normal)
        self.registerButton.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .highlighted)
        self.registerButton.layer.cornerRadius = CornerRadius.button
        self.registerButton.layer.masksToBounds = true

    }
    
    func checkPolicyLinks() {
        policyLinkView.didTapTerms = {
            if let url = URL(string: "\(TargetVariables.clientBaseUrl)/terms-and-conditions.pdf") {
                UIApplication.shared.open(url)
            }
        }
        
        policyLinkView.didTapPrivacy = {
            if let url = URL(string: "\(TargetVariables.clientBaseUrl)/fr/politique-de-confidentialite") {
                UIApplication.shared.open(url)
            }            }
        
        policyLinkView.didTapEula = {
            if let url = URL(string: "\(TargetVariables.clientBaseUrl)/betting-rules.pdf") {
                UIApplication.shared.open(url)
            }
        }
    }

    @objc private func didTapRegister() {
        self.presentRegister(animated: true)
    }

    private func presentRegister(animated: Bool = true) {

        var userRegisterEnvelopValue: UserRegisterEnvelop = UserDefaults.standard.startedUserRegisterInfo ?? UserRegisterEnvelop()
        
        if let referralCode = self.referralCode {
            userRegisterEnvelopValue.godfatherCode = referralCode
        }

        let userRegisterEnvelopUpdater = UserRegisterEnvelopUpdater(userRegisterEnvelop: userRegisterEnvelopValue)

        userRegisterEnvelopUpdater.didUpdateUserRegisterEnvelop
            .removeDuplicates()
            .sink(receiveValue: { (updatedUserEnvelop: UserRegisterEnvelop) in
                UserDefaults.standard.startedUserRegisterInfo = updatedUserEnvelop
            })
            .store(in: &self.cancellables)

        var registerSteps: [RegisterStep]
        if Env.businessSettingsSocket.clientSettings.requiredPhoneVerification {
            registerSteps = [
                        RegisterStep(forms: [.gender, .names]),
                        RegisterStep(forms: [.avatar, .nickname]),
                        RegisterStep(forms: [.ageCountry]),
                        RegisterStep(forms: [.address]),
                        RegisterStep(forms: [.contacts]),
                        RegisterStep(forms: [.password]),
                        RegisterStep(forms: [.terms, .promoCodes]),
                        RegisterStep(forms: [.phoneConfirmation])
                    ]
        }
        else {
            registerSteps = [
                        RegisterStep(forms: [.gender, .names]),
                        RegisterStep(forms: [.avatar, .nickname]),
                        RegisterStep(forms: [.ageCountry]),
                        RegisterStep(forms: [.address]),
                        RegisterStep(forms: [.contacts]),
                        RegisterStep(forms: [.password]), 
                        RegisterStep(forms: [.terms, .promoCodes])
                    ]
        }
        
        let hasLegalAgeWarning = TargetVariables.features.contains(.legalAgeWarning) ? true : false

        let viewModel = SteppedRegistrationViewModel(registerSteps: registerSteps,
                                                     userRegisterEnvelop: userRegisterEnvelopValue,
                                                     serviceProvider: Env.servicesProvider,
                                                     userRegisterEnvelopUpdater: userRegisterEnvelopUpdater,
                                                     hasLegalAgeWarning: hasLegalAgeWarning)
        
        viewModel.hasReferralCode = self.referralCode != nil ? true : false

        let steppedRegistrationViewController = SteppedRegistrationViewController(viewModel: viewModel)
        steppedRegistrationViewController.isModalInPresentation = true

        let registerNavigationController = Router.navigationController(with: steppedRegistrationViewController)
        registerNavigationController.isModalInPresentation = true
        
        steppedRegistrationViewController.didRegisteredUserAction = { [weak self] registeredUser in
            if let nickname = registeredUser.nickname, let password = registeredUser.password {
                
                self?.triggerLoginAfterRegister(username: nickname, password: password, withUserConsents: registeredUser.acceptedMarketing)
                self?.showRegisterFeedbackViewController(onNavigationController: registerNavigationController)
            }
        }
        
        steppedRegistrationViewController.sendRegisterEventAction = { [weak self] username in
            
            Optimove.shared.reportEvent(
                name: "register_start",
                parameters: [
                    "username": "\(username)"
                ]
            )
            
            Optimove.shared.reportScreenVisit(screenTitle: "register_start")
            
            if let event = ADJEvent(eventToken: "x9jrel") {
                Adjust.trackEvent(event)
            }
        }

        if !animated {
            registerNavigationController.modalPresentationStyle = .fullScreen
        }

        self.present(registerNavigationController, animated: animated)
    }

    private func setUserConsents(enabled: Bool) {
        if enabled {
            let types = [UserConsentType.sms.versionId, UserConsentType.email.versionId]
            Env.servicesProvider.setUserConsents(consentVersionIds: types)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        ()
                    case .failure(let error):
                        print("SET USER CONSENTS REGISTER ERROR: \(error)")
                    }
                    
                }, receiveValue: { _ in
                    UserDefaults.standard.notificationsUserSettings.notificationsSms = true
                    UserDefaults.standard.notificationsUserSettings.notificationsEmail = true
                })
                .store(in: &self.cancellables)
        }
        else {
            UserDefaults.standard.notificationsUserSettings.notificationsSms = false
            UserDefaults.standard.notificationsUserSettings.notificationsEmail = false
        }
    }
    
    private func setTermsConsents() {
        Env.userSessionStore.didAcceptedTermsUpdate()
    }

    private func showRegisterFeedbackViewController(onNavigationController navigationController: UINavigationController) {

        let registerSuccessViewController = RegisterSuccessViewController()

        registerSuccessViewController.didTapContinueAction = { [weak self] in
            self?.showBiometricPromptViewController(onNavigationController: navigationController)
        }

        navigationController.pushViewController(registerSuccessViewController, animated: true)

    }

    private func showBiometricPromptViewController(onNavigationController navigationController: UINavigationController) {
        let biometricPromptViewController = BiometricPromptViewController()
        biometricPromptViewController.didTapBackButtonAction = {
            navigationController.popViewController(animated: true)
        }
        biometricPromptViewController.didTapCancelButtonAction = { [weak self] in
            self?.showLimitsOnRegisterViewController(onNavigationController: navigationController)
        }
        biometricPromptViewController.didTapActivateButtonAction = { [weak self] in
            Env.userSessionStore.setShouldRequestBiometrics(true)
            self?.showLimitsOnRegisterViewController(onNavigationController: navigationController)
        }
        biometricPromptViewController.didTapLaterButtonAction = { [weak self] in
            Env.userSessionStore.setShouldRequestBiometrics(false)
            self?.showLimitsOnRegisterViewController(onNavigationController: navigationController)
        }
        navigationController.pushViewController(biometricPromptViewController, animated: true)
    }

    private func showLimitsOnRegisterViewController(onNavigationController navigationController: UINavigationController) {
        let viewModel = LimitsOnRegisterViewModel(servicesProvider: Env.servicesProvider)
        
        viewModel.hasRollingWeeklyLimits = Env.businessSettingsSocket.clientSettings.hasRollingWeeklyLimits

        let limitsOnRegisterViewController = LimitsOnRegisterViewController(viewModel: viewModel)
        limitsOnRegisterViewController.didTapBackButtonAction = {
            navigationController.popViewController(animated: true)
        }
        limitsOnRegisterViewController.didTapCancelButtonAction = { [weak self] in
            self?.closeLoginRegisterFlow()
        }
        limitsOnRegisterViewController.triggeredContinueAction = { [weak self] in
            self?.showDepositViewController(onNavigationController: navigationController)
        }
        navigationController.pushViewController(limitsOnRegisterViewController, animated: true)
    }

    private func showDepositViewController(onNavigationController navigationController: UINavigationController) {
        
        let depositViewController = DepositViewController()
        
        depositViewController.didTapBackButtonAction = {
            navigationController.popViewController(animated: true)
        }
        
        depositViewController.didTapCancelButtonAction = { [weak self] in
            self?.closeLoginRegisterFlow()
        }
        
        depositViewController.shouldDismissAction = { [weak self] in
            self?.closeLoginRegisterFlow()
        }
        
        depositViewController.shouldRefreshUserWallet = {
            Env.userSessionStore.refreshUserWallet()
        }
        
        navigationController.pushViewController(depositViewController, animated: true)
    }

    private func deleteCachedRegistrationData() {
        UserDefaults.standard.startedUserRegisterInfo = nil
    }

    @objc func rememberUserOptionTapped() {
        if self.shouldRememberUser {
            self.disableRememberUser()
            self.shouldRememberUser = false
        }
        else {
            self.enableRememberUser()
            self.shouldRememberUser = true
        }
    }

    private func enableRememberUser() {
        rememberImageView.image = UIImage(named: "active_toggle_icon")
        rememberImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
        rememberToggleView.backgroundColor = UIColor.App.buttonBackgroundPrimary
        Env.userSessionStore.shouldRecordUserSession = true
    }

    private func disableRememberUser() {
        rememberImageView.image = nil
        rememberImageView.setImageColor(color: UIColor.App.buttonTextPrimary)
        rememberToggleView.backgroundColor = UIColor.App.buttonBackgroundSecondary
        Env.userSessionStore.shouldRecordUserSession = false
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.usernameHeaderTextFieldView.resignFirstResponder()
        self.passwordHeaderTextFieldView.resignFirstResponder()
    }

    @IBAction private func didTapDismissButton() {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction private func didTapSkipButton() {
        UserSessionStore.skippedLoginFlow()

        self.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction private func didTapLoginButton() {

        let username = usernameHeaderTextFieldView.text
        let password = passwordHeaderTextFieldView.text
        
        self.loginButton.isEnabled = false
        
        self.showLoadingSpinner()
        
        Env.userSessionStore.login(withUsername: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .invalidEmailPassword:
                        self?.showWrongPasswordStatus()
                    case .restrictedCountry:
                        self?.showGenericServerErrorStatus()
                    case .serverError:
                        self?.showGenericServerErrorStatus()
                    case .quickSignUpIncomplete:
                        self?.showGenericServerErrorStatus()
                    case .errorMessage:
                        self?.showGenericServerErrorStatus()
                    case .failedTempLock(let date):
                        var dateFinal = date
                        
                        if let dateFormatter = self?.dateFormatter {
                            dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                            
                            if let dateFormatted = dateFormatter.date(from: date) {
                                dateFormatter.dateFormat = "dd-MM-yyyy"
                                dateFinal = dateFormatter.string(from: dateFormatted)
                            }
                        }
                        
                        let failedLockMessage = localized("omega_error_fail_temp_lock").replacingFirstOccurrence(of: "{date}", with: dateFinal)
                        
                        self?.showServerErrorStatus(errorMessage: failedLockMessage)
                    }
                case .finished:
                    ()
                }
                self?.hideLoadingSpinner()
                self?.loginButton.isEnabled = true
            }, receiveValue: { [weak self] _ in
                // self.showNextViewController()
                self?.loginSuccessful()
            })
            .store(in: &cancellables)
    }

    func triggerLoginAfterRegister(username: String, password: String, withUserConsents: Bool = false) {
        Env.userSessionStore.disableForcedLimitsScreen()
        
        Env.userSessionStore.login(withUsername: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                print("triggerLoginAfterRegister ", completion)
                self?.deleteCachedRegistrationData()
            } receiveValue: { [weak self] success in
                print("triggerLoginAfterRegister ", success)
                self?.setUserConsents(enabled: withUserConsents)
                // self?.setTermsConsents()
                
                // Optimove complete register
                Optimove.shared.reportEvent(
                    name: "sign_up",
                    parameters: [
                        "username": "\(username)"
                    ]
                )
                
                Optimove.shared.reportScreenVisit(screenTitle: "sign_up")
                
                // Adjust
                if let event = ADJEvent(eventToken: "p6p4xw") {
                    Adjust.trackEvent(event)
                }
            }
            .store(in: &cancellables)
    }

    func closeLoginRegisterFlow() {
        if self.isModal {
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popToRootViewController(animated: true)
            self.presentedViewController?.dismiss(animated: true)
        }
    }

    func showLoadingSpinner() {
        view.addSubview(spinnerViewController.view)
        spinnerViewController.view.translatesAutoresizingMaskIntoConstraints = false
        spinnerViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        spinnerViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        spinnerViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        spinnerViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        spinnerViewController.didMove(toParent: self)
    }

    func hideLoadingSpinner() {
        spinnerViewController.willMove(toParent: nil)
        spinnerViewController.removeFromParent()
        spinnerViewController.view.removeFromSuperview()
    }

    private func loginSuccessful() {

        // The user had a suc login, we shouldn't start the app with the login anymore
        // is the same behaviour if the user skipped the login
        UserSessionStore.skippedLoginFlow()

        if self.shouldRememberUser {
            self.showBiometricAuthenticationAlert()
        }
        else {
            self.showNextViewController()
        }

        if let userId = Env.userSessionStore.loggedUserProfile?.userIdentifier {
            Optimove.shared.setUserId(userId)
        }

    }

    private func showNextViewController() {

        AnalyticsClient.sendEvent(event: .userLogin)
        
        Env.userSessionStore.loginFlowSuccess.send(true)
        
        if self.isModal {
            if !self.hasPendingRedirect {
                self.dismiss(animated: true, completion: nil)
            }
            else {
                self.dismiss(animated: true, completion: {
                    self.needsRedirect?()
                })
            }
        }
        else {
            self.navigationController?.popToRootViewController(animated: true)
        }

    }

    func showBiometricAuthenticationAlert() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let alertTitle: String
            let alertMessage: String

            switch context.biometryType {
            case .faceID:
                alertTitle = localized("face_id_title")
                alertMessage = localized("face_id_message")
            case .touchID:
                alertTitle = localized("touch_id_title")
                alertMessage = localized("touch_id_message")
            default:
                return
            }

            let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)

            let noAction = UIAlertAction(title: localized("no"), style: .cancel, handler: { _ in
                Env.userSessionStore.setShouldRequestBiometrics(false)
                self.showNextViewController()
            })
            alertController.addAction(noAction)

            let yesAction = UIAlertAction(title: localized("yes"), style: .default) { _ in
                Env.userSessionStore.setShouldRequestBiometrics(true)
                self.showNextViewController()
            }
            alertController.addAction(yesAction)

            alertController.preferredAction = yesAction
            self.present(alertController, animated: true)
        }
        else if let error = error as? LAError, error.code == .userCancel {
            let alertController = UIAlertController(title: localized("biometric_error_title"),
                                                    message: localized("biometric_error_denied_message"),
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: localized("ok"), style: .default, handler: { _ in
                Env.userSessionStore.setShouldRequestBiometrics(false)
                self.showNextViewController()
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true)

        }
        else {
            let alertController = UIAlertController(title: localized("biometric_error_title"),
                                                    message: localized("biometric_error_general_message"),
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: localized("ok"), style: .default, handler: { _ in
                Env.userSessionStore.setShouldRequestBiometrics(false)
                self.showNextViewController()
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        }
    }

    private func showWrongPasswordStatus() {
        let alert = UIAlertController(title: localized("error"),
                                      message: localized("omega_error_fail_un_pw"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func showGenericServerErrorStatus() {
        let alert = UIAlertController(title: localized("error"),
                                        message: localized("server_error_message"),
                                        preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func showServerErrorStatus(errorMessage: String) {
        let alert = UIAlertController(title: localized("login_error_title"),
                                      message: errorMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func didTapRecoverPassword() {
        let recoverPasswordViewModel = RecoverPasswordViewModel()
        let recoverPasswordViewController = RecoverPasswordViewController(viewModel: recoverPasswordViewModel)
        self.navigationController?.pushViewController(recoverPasswordViewController, animated: true)
    }

}

extension LoginViewController {

    @objc func didTapDebugFormFill() {
        if self.usernameHeaderTextFieldView.text.isEmpty {
            self.usernameHeaderTextFieldView.setText("gomaTest") // ("pafeha4474@lance7.com") // ("gomafrontend") // ("ruben@gomadevelopment.pt")
            self.passwordHeaderTextFieldView.setText("Testaccount!1") // ("iosGoma123") // ("Omega123") // ("ruben=GOMA=12345")
            self.loginButton.isEnabled = true
        }
        else if self.usernameHeaderTextFieldView.text == "gomaTest" {
            self.usernameHeaderTextFieldView.setText("rroques107")
            self.passwordHeaderTextFieldView.setText("Ruben-Goma-12345")
            self.loginButton.isEnabled = true
        }
        else if self.usernameHeaderTextFieldView.text == "rroques107" {
            self.usernameHeaderTextFieldView.setText("ivouat")
            self.passwordHeaderTextFieldView.setText("testesdoIvo1@")
            self.loginButton.isEnabled = true
        }
        else if self.usernameHeaderTextFieldView.text == "ivogoma" {
            self.usernameHeaderTextFieldView.setText("jmatos3")
            self.passwordHeaderTextFieldView.setText("i23456789O!")
            self.loginButton.isEnabled = true
        }
        else if self.usernameHeaderTextFieldView.text == "jmatos3" {
            self.usernameHeaderTextFieldView.setText("Ivolrs")
            self.passwordHeaderTextFieldView.setText("testesdoIvo1@")
            self.loginButton.isEnabled = true
        }
        else if self.usernameHeaderTextFieldView.text == "Ivolrs" {
            self.usernameHeaderTextFieldView.setText("bohifo2337@dilanfa.com")
            self.passwordHeaderTextFieldView.setText("Ruben)12345")
            self.loginButton.isEnabled = true
        }
        else if self.usernameHeaderTextFieldView.text == "ruben6" {
            self.usernameHeaderTextFieldView.setText("devil11308@game4hr.com")
            self.passwordHeaderTextFieldView.setText("Ruben)1234")
            self.loginButton.isEnabled = true
        }
        else if self.usernameHeaderTextFieldView.text == "mosafe" {
            self.usernameHeaderTextFieldView.setText("modaf")
            self.passwordHeaderTextFieldView.setText("teste123456.")
            self.loginButton.isEnabled = true
        }
        
    }

}

extension UILabel {

    func highlightTextLabel(fullString: String, highlightString: String) {
        let accountText = fullString

        self.text = accountText
        self.font = AppFont.with(type: .semibold, size: 14.0)

        self.textColor =  UIColor.App.textPrimary

        let highlightAttriString = NSMutableAttributedString(string: accountText)
        let range1 = (accountText as NSString).range(of: highlightString)
        highlightAttriString.addAttribute(NSAttributedString.Key.font, value: AppFont.with(type: .semibold, size: 14), range: range1)
        highlightAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.App.highlightPrimary, range: range1)

        self.attributedText = highlightAttriString
        self.isUserInteractionEnabled = true
    }

}
