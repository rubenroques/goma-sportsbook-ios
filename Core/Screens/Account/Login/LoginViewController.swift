import UIKit
import Combine
import ServicesProvider
import RegisterFlow
import Adyen
import AdyenDropIn
import AdyenComponents
import HeaderTextField
import LocalAuthentication

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

    init(shouldPresentRegisterFlow: Bool = false) {
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

        skipButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 17)
        skipButton.setTitle(localized("skip"), for: .normal)

        dismissButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 17)
        dismissButton.setTitle(localized("close"), for: .normal)

        logoImageView.image = UIImage(named: "logo_horizontal_center")
        logoImageView.sizeToFit()

        loginLabel.font = AppFont.with(type: AppFont.AppFontType.bold, size: 26)
        loginLabel.text = localized("login")

        self.usernameHeaderTextFieldView.setPlaceholderText(localized("email"))
        self.passwordHeaderTextFieldView.setPlaceholderText(localized("password"))

        self.usernameHeaderTextFieldView.highlightColor = .white
        self.passwordHeaderTextFieldView.highlightColor = .white

        rememberLabel.text = localized("remember")
        rememberLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 12)
        rememberToggleView.layer.cornerRadius = CornerRadius.checkBox
        rememberImageView.backgroundColor = .clear
        rememberImageView.contentMode = .scaleAspectFit

        self.enableRememberUser()

        forgotButton.setTitle(localized("forgot"), for: .normal)
        forgotButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 14)

        self.loginButton.setTitle(localized("login"), for: .normal)
        self.loginButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 18)
        self.loginButton.addTarget(self, action: #selector(self.didTapLoginButton), for: .primaryActionTriggered)

        self.passwordHeaderTextFieldView.setSecureField(true)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        let tapImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(rememberUserOptionTapped))
        rememberView.isUserInteractionEnabled = true
        rememberView.addGestureRecognizer(tapImageGestureRecognizer)

        self.registerButton.setTitle(localized("create_a_new_account"), for: .normal)
        self.registerButton.addTarget(self, action: #selector(self.didTapRegister), for: .primaryActionTriggered)

        self.dismissButton.setTitle(localized("close"), for: .normal)
        self.dismissButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.orLabel.text = localized("or")

        self.checkPolicyLinks()

        self.logoImageView.isUserInteractionEnabled = true

        // #if DEBUG
        let debugLogoImageViewTap = UITapGestureRecognizer(target: self, action: #selector(didTapDebugFormFill))
        debugLogoImageViewTap.numberOfTapsRequired = 5
        self.logoImageView.addGestureRecognizer(debugLogoImageViewTap)
        // #endif

    }

    @objc private func showDeposit() {
        if let navigationController = self.navigationController {
            self.showRegisterFeedbackViewController(onNavigationController: navigationController)
        }
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
            if let url = URL(string: "https://goma-uat.betsson.fr/terms-and-conditions.pdf") {
                UIApplication.shared.open(url)
            }
        }
        
        policyLinkView.didTapPrivacy = {
            if let url = URL(string: "https://goma-uat.betsson.fr/fr/privacy-policy") {
                UIApplication.shared.open(url)
            }            }
        
        policyLinkView.didTapEula = {
            if let url = URL(string: "https://goma-uat.betsson.fr/betting-rules.pdf") {
                UIApplication.shared.open(url)
            }
        }
    }

    @objc private func didTapRegister() {
        self.presentRegister(animated: true)
    }

    private func presentRegister(animated: Bool = true) {

        let userRegisterEnvelopValue: UserRegisterEnvelop = UserDefaults.standard.startedUserRegisterInfo ?? UserRegisterEnvelop()

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

        let viewModel = SteppedRegistrationViewModel(registerSteps: registerSteps,
                                                     userRegisterEnvelop: userRegisterEnvelopValue,
                                                     serviceProvider: Env.servicesProvider,
                                                     userRegisterEnvelopUpdater: userRegisterEnvelopUpdater)

        let steppedRegistrationViewController = SteppedRegistrationViewController(viewModel: viewModel)
        steppedRegistrationViewController.isModalInPresentation = true

        let registerNavigationController = Router.navigationController(with: steppedRegistrationViewController)
        registerNavigationController.isModalInPresentation = true
        
        steppedRegistrationViewController.didRegisteredUserAction = { [weak self] registeredUser in
            if let nickname = registeredUser.nickname, let password = registeredUser.password {

                self?.triggerLoginAfterRegister(username: nickname, password: password, withUserConsents: viewModel.isMarketingSelected ? true : false)

                self?.showRegisterFeedbackViewController(onNavigationController: registerNavigationController)
            }
        }

        if !animated {
            registerNavigationController.modalPresentationStyle = .fullScreen
        }

        self.present(registerNavigationController, animated: animated)
    }

    private func setUserConsents() {

        Env.servicesProvider.setUserConsents(consentVersionIds: [UserConsentType.sms.versionId, UserConsentType.email.versionId])
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

    private func showRegisterFeedbackViewController(onNavigationController navigationController: UINavigationController) {

        let registerSuccessViewController = RegisterSuccessViewController()

        registerSuccessViewController.setTextInfo(title: localized("congratulations"), subtitle: localized("singup_success_text"))

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
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .invalidEmailPassword:
                        self.showWrongPasswordStatus()
                    case .restrictedCountry(let errorMessage):
                        self.showServerErrorStatus(errorMessage: errorMessage)
                    case .serverError:
                        self.showServerErrorStatus()
                    case .quickSignUpIncomplete:
                        self.showServerErrorStatus()
                    case .errorMessage(let errorMessage):
                        self.showServerErrorStatus(errorMessage: errorMessage)
                    }
                case .finished:
                    ()
                }
                self.hideLoadingSpinner()
                self.loginButton.isEnabled = true
            }, receiveValue: { _ in
                // self.showNextViewController()
                self.loginSuccessful()
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

                if withUserConsents {
                    self?.setUserConsents()
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

    }

    private func showNextViewController() {

        AnalyticsClient.sendEvent(event: .userLogin)
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
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
            let alertController = UIAlertController(title: localized("biometric_error_title"), message: localized("biometric_error_denied_message"), preferredStyle: .alert)
            let okAction = UIAlertAction(title: localized("ok"), style: .default, handler: { _ in
                Env.userSessionStore.setShouldRequestBiometrics(false)
                self.showNextViewController()
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true)

        }
        else {
            let alertController = UIAlertController(title: localized("biometric_error_title"), message: localized("biometric_error_general_message"), preferredStyle: .alert)
            let okAction = UIAlertAction(title: localized("ok"), style: .default, handler: { _ in
                Env.userSessionStore.setShouldRequestBiometrics(false)
                self.showNextViewController()
            })
            alertController.addAction(okAction)
            self.present(alertController, animated: true)
        }
    }


//    func authenticateUser(with context: LAContext) {
//        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access requires authentication") { (success, error) in
//            DispatchQueue.main.async {
//                if success {
//                    print("Authentication successful")
//                } else {
//                    print("Authentication failed")
//                }
//
//                self.showNextViewController()
//            }
//        }
//    }

    private func showWrongPasswordStatus() {
        let alert = UIAlertController(title: localized("login_error_title"),
                                      message: localized("login_error_message"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func showServerErrorStatus(errorMessage: String? = nil) {
        if let errorMessage = errorMessage {
            let alert = UIAlertController(title: localized("login_error_title"),
                                          message: errorMessage,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: localized("login_error_title"),
                                          message: localized("server_error_message"),
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }

    @IBAction private func didTapRecoverPassword() {
        let recoverPasswordViewModel = RecoverPasswordViewModel()

        let recoverPasswordViewController = RecoverPasswordViewController(viewModel: recoverPasswordViewModel)

        self.navigationController?.pushViewController(recoverPasswordViewController, animated: true)
    }

}

extension LoginViewController {

    @objc func didTapDebugFormFill() {
        
        if self.usernameHeaderTextFieldView.text.isEmpty || self.usernameHeaderTextFieldView.text == "ruben" {
            self.usernameHeaderTextFieldView.setText("rroques7") // ("pafeha4474@lance7.com") // ("gomafrontend") // ("ruben@gomadevelopment.pt")
            self.passwordHeaderTextFieldView.setText("Ruben12345!") // ("iosGoma123") // ("Omega123") // ("ruben=GOMA=12345")
            self.loginButton.isEnabled = true
        }
        else if self.usernameHeaderTextFieldView.text == "rroques7" {
            self.usernameHeaderTextFieldView.setText("pgomes99")
            self.passwordHeaderTextFieldView.setText("12345-gomaA")
            self.loginButton.isEnabled = true
        }
        else if self.usernameHeaderTextFieldView.text == "pgomes99" {
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
