import UIKit
import Combine
import ServicesProvider
import AppTrackingTransparency
import AdSupport
import RegisterFlow

class LoginViewController: UIViewController {

    @IBOutlet private var scrollView: UIScrollView!

    @IBOutlet private var skipView: UIView!
    @IBOutlet private var skipButton: UIButton!
    @IBOutlet private var dismissButton: UIButton!

    @IBOutlet private var logoImageView: UIImageView!

    @IBOutlet private var loginView: UIView!
    @IBOutlet private var loginLabel: UILabel!
    @IBOutlet private weak var usernameHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private weak var passwordHeaderTextFieldView: HeaderTextFieldView!

    @IBOutlet private var rememberView: UIView!
    @IBOutlet private var rememberToggleView: UIView!
    @IBOutlet private var rememberImageView: UIImageView!
    @IBOutlet private var rememberLabel: UILabel!

    @IBOutlet private var forgotView: UIView!
    @IBOutlet private var forgotButton: UIButton!
    @IBOutlet private var loginButton: UIButton!
    @IBOutlet private var registerLabel: UILabel!
    @IBOutlet private var policyLinkView: PolicyLinkView!

    // Variables
    var shouldRememberUser: Bool = true

    private let registrationFormDataKey = "RegistrationFormDataKey"

    var cancellables = Set<AnyCancellable>()

    let spinnerViewController = SpinnerViewController()

    init() {
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

        // TEMP EM SHUTDOWN
        self.loginButton.isEnabled = false
        Publishers.CombineLatest(self.usernameHeaderTextFieldView.textPublisher, self.passwordHeaderTextFieldView.textPublisher)
            .map { username, password in
                return (username?.isNotEmpty ?? false) && (password?.isNotEmpty ?? false)
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

        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // Tracking authorization dialog was shown
                    // and we are authorized
                    print("Authorized")

                    // Now that we are authorized we can get the IDFA
                    print(ASIdentifierManager.shared().advertisingIdentifier)
                case .denied:
                    // Tracking authorization dialog was
                    // shown and permission is denied
                    print("Denied")
                case .notDetermined:
                    // Tracking authorization dialog has not been shown
                    print("Not Determined")
                case .restricted:
                    print("Restricted")
                @unknown default:
                    print("Unknown")
                }
            }
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

        usernameHeaderTextFieldView.headerLabel.font = AppFont.with(type: .semibold, size: 16)
        passwordHeaderTextFieldView.headerLabel.font = AppFont.with(type: .semibold, size: 16)

        usernameHeaderTextFieldView.textField.returnKeyType = .next
        passwordHeaderTextFieldView.textField.returnKeyType = .go

        usernameHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.passwordHeaderTextFieldView.textField.becomeFirstResponder()
        }

        passwordHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.passwordHeaderTextFieldView.textField.resignFirstResponder()
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

        self.usernameHeaderTextFieldView.setPlaceholderText(localized("email_address_placeholder"))
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

        loginButton.setTitle(localized("login"), for: .normal)
        loginButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 18)

        self.passwordHeaderTextFieldView.setSecureField(true)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        let tapImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(rememberUserOptionTapped))
        rememberView.isUserInteractionEnabled = true
        rememberView.addGestureRecognizer(tapImageGestureRecognizer)

        registerLabel.highlightTextLabel(fullString: localized("new_create_account"), highlightString: localized("create_account"))
        registerLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCreateAccount)))

        self.dismissButton.setTitle(localized("close"), for: .normal)
        self.dismissButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.checkPolicyLinks()


        self.logoImageView.isUserInteractionEnabled = true

        let debugLogoImageViewTap = UITapGestureRecognizer(target: self, action: #selector(didTapDebugFormFill))
        debugLogoImageViewTap.numberOfTapsRequired = 3
        self.logoImageView.addGestureRecognizer(debugLogoImageViewTap)

        let debug2LogoImageViewTap = UITapGestureRecognizer(target: self, action: #selector(didTapDebug))
        debug2LogoImageViewTap.numberOfTapsRequired = 2
        self.logoImageView.addGestureRecognizer(debug2LogoImageViewTap)

    }

    func setupWithTheme() {
        
        self.view.backgroundColor = UIColor.App.backgroundPrimary
        self.skipView.backgroundColor = UIColor.App.backgroundPrimary

        self.skipButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        self.skipButton.backgroundColor = .clear

        self.loginLabel.textColor = UIColor.App.textHeadlinePrimary

        self.usernameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        self.usernameHeaderTextFieldView.setTextFieldColor(UIColor.App.textPrimary)
    
        self.passwordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        self.passwordHeaderTextFieldView.setTextFieldColor(UIColor.App.textPrimary)

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

        self.registerLabel.highlightTextLabel(fullString: localized("new_create_account"), highlightString: localized("create_account"))
    }

    func checkPolicyLinks() {
            policyLinkView.didTapTerms = {
                // TO-DO: Terms link
            }

            policyLinkView.didTapPrivacy = {
                // TO-DO: Privacy link
            }

            policyLinkView.didTapEula = {
                // TO-DO: EULA link
            }
        }

    @objc private func didTapCreateAccount() {

        let userRegisterEnvelop: UserRegisterEnvelop? = UserDefaults.standard.codable(forKey: self.registrationFormDataKey)
        let userRegisterEnvelopValue: UserRegisterEnvelop = userRegisterEnvelop ?? UserRegisterEnvelop()

        let userRegisterEnvelopUpdater = UserRegisterEnvelopUpdater(userRegisterEnvelop: userRegisterEnvelopValue)
        userRegisterEnvelopUpdater.didUpdateUserRegisterEnvelop.sink(receiveValue: { (updatedUserEnvelop: UserRegisterEnvelop) in
            UserDefaults.standard.set(codable: updatedUserEnvelop, forKey: self.registrationFormDataKey)
            UserDefaults.standard.synchronize()
        })
        .store(in: &self.cancellables)

        let viewModel = SteppedRegistrationViewModel(userRegisterEnvelop: userRegisterEnvelopValue,
                                                     serviceProvider: Env.servicesProvider,
                                                     userRegisterEnvelopUpdater: userRegisterEnvelopUpdater)

        let steppedRegistrationViewController = SteppedRegistrationViewController(viewModel: viewModel)

        let registerNavigationController = Router.navigationController(with: steppedRegistrationViewController)

        steppedRegistrationViewController.didRegisteredUserAction = { [weak self] registeredUser in
            if let nickname = registeredUser.nickname, let password = registeredUser.password {
                self?.triggerLoginAfterRegister(username: nickname, password: password)
                self?.deleteCachedRegistrationData()
                self?.showRegisterFeedbackViewController(onNavigationController: registerNavigationController)
            }
        }

        self.present(registerNavigationController, animated: true)
    }

    private func showRegisterFeedbackViewController(onNavigationController navigationController: UINavigationController) {
        let registerFeedbackViewController = RegisterFeedbackViewController(viewModel: RegisterFeedbackViewModel(registerSuccess: true))
        registerFeedbackViewController.didTapContinueButtonAction = { [weak self] in
            self?.showBiometricPromptViewController(onNavigationController: navigationController)
        }
        navigationController.pushViewController(registerFeedbackViewController, animated: true)
    }

    private func showBiometricPromptViewController(onNavigationController navigationController: UINavigationController) {
        let biometricPromptViewController = BiometricPromptViewController()
        biometricPromptViewController.didTapBackButtonAction = {
            navigationController.popViewController(animated: true)
        }
        biometricPromptViewController.didTapCancelButtonAction = { [weak self] in
            self?.closeLoginRegisterFlow()
        }
        biometricPromptViewController.didTapActivateButtonAction = { [weak self] in
            Env.userSessionStore.setShouldRequestFaceId(true)
            self?.showLimitsOnRegisterViewController(onNavigationController: navigationController)
        }
        biometricPromptViewController.didTapLaterButtonAction = { [weak self] in
            Env.userSessionStore.setShouldRequestFaceId(false)
            self?.showLimitsOnRegisterViewController(onNavigationController: navigationController)
        }
        navigationController.pushViewController(biometricPromptViewController, animated: true)
    }

    private func showDepositOnRegisterViewController(onNavigationController navigationController: UINavigationController) {
        self.closeLoginRegisterFlow()
        let depositOnRegisterViewController = DepositOnRegisterViewController()
        depositOnRegisterViewController.didTapBackButtonAction = {
            navigationController.popViewController(animated: true)
        }
        depositOnRegisterViewController.didTapCancelButtonAction = { [weak self] in
            self?.closeLoginRegisterFlow()
        }
        navigationController.pushViewController(depositOnRegisterViewController, animated: true)
    }

    private func showLimitsOnRegisterViewController(onNavigationController navigationController: UINavigationController) {
        self.closeLoginRegisterFlow()
        let limitsOnRegisterViewController = LimitsOnRegisterViewController()
        limitsOnRegisterViewController.didTapBackButtonAction = {
            navigationController.popViewController(animated: true)
        }
        limitsOnRegisterViewController.didTapCancelButtonAction = { [weak self] in
            self?.closeLoginRegisterFlow()
        }
        navigationController.pushViewController(limitsOnRegisterViewController, animated: true)
    }

    private func deleteCachedRegistrationData() {
        UserDefaults.standard.removeObject(forKey: self.registrationFormDataKey)
        UserDefaults.standard.synchronize()
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

        let mainScreenViewController = Router.mainScreenViewController()
        self.navigationController?.pushViewController(mainScreenViewController, animated: true)
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
                    default:
                        self.showServerErrorStatus()
                    }
                case .finished:
                    ()
                }
                self.hideLoadingSpinner()
                self.loginButton.isEnabled = true
            }, receiveValue: { _ in
                self.showNextViewController()
            })
            .store(in: &cancellables)
    }


    func triggerLoginAfterRegister(username: String, password: String) {
        Env.userSessionStore.login(withUsername: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                print("triggerLoginAfterRegister ", completion)
            } receiveValue: { [weak self] success in
                print("triggerLoginAfterRegister ", success)
            }
            .store(in: &cancellables)
    }

    func closeLoginRegisterFlow() {
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.presentedViewController?.dismiss(animated: true)

            let mainScreenViewController = Router.mainScreenViewController()
            self.navigationController?.pushViewController(mainScreenViewController, animated: true)
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

    private func showNextViewController() {
        AnalyticsClient.sendEvent(event: .userLogin)
        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            self.pushMainViewController()
        }
    }

    private func pushMainViewController() {
        let rootViewController = Router.mainScreenViewController()
        self.navigationController?.pushViewController(rootViewController, animated: true)
    }

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

    @objc func didTapDebug() {
        UserDefaults.standard.removeObject(forKey: "RegistrationFormDataKey")
        UserDefaults.standard.synchronize()

        UIAlertController.showMessage(title: "Debug", message: "Register cached data cleared", on: self)
    }

    @objc func didTapDebugFormFill() {
        
        if self.usernameHeaderTextFieldView.text.isEmpty || self.usernameHeaderTextFieldView.text == "ruben" {
            self.usernameHeaderTextFieldView.setText("gomafrontend") // ("pafeha4474@lance7.com") // ("gomafrontend") // ("ruben@gomadevelopment.pt")
            self.passwordHeaderTextFieldView.setText("Omega123") // ("iosGoma123") // ("Omega123") // ("ruben=GOMA=12345")
            self.loginButton.isEnabled = true
        }
        else if self.usernameHeaderTextFieldView.text == "gomafrontend" {
            self.usernameHeaderTextFieldView.setText("pafeha4474@lance7.com")
            self.passwordHeaderTextFieldView.setText("iosGoma123")
            self.loginButton.isEnabled = true
        }
        else if self.usernameHeaderTextFieldView.text == "ruben5" {
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
