import UIKit
import Combine

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
        setupWithTheme()

        // Default value
        Env.userSessionStore.shouldRecordUserSession = true

        Publishers.CombineLatest(self.usernameHeaderTextFieldView.textPublisher, self.passwordHeaderTextFieldView.textPublisher)
            .map { username, password in
                return (username?.isNotEmpty ?? false) && (password?.isNotEmpty ?? false)
            }
            .assign(to: \.isEnabled, on: loginButton)
            .store(in: &cancellables)

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
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

        skipButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 18)
        skipButton.setTitle(localized("skip"), for: .normal)

        logoImageView.image = UIImage(named: "logo_horizontal_large")
        logoImageView.sizeToFit()

        loginLabel.font = AppFont.with(type: AppFont.AppFontType.bold, size: 26)
        loginLabel.text = localized("login")

        self.usernameHeaderTextFieldView.setPlaceholderText(localized("email_address_or_username"))
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

        checkPolicyLinks()

        if self.isModal {
            self.skipButton.isHidden = true
            self.dismissButton.isHidden = false
        }
        else {
            self.skipButton.isHidden = false
            self.dismissButton.isHidden = true
        }

        #if DEBUG
        let debugLogoImageViewTap = UITapGestureRecognizer(target: self, action: #selector(didTapDebugFormFill))
        debugLogoImageViewTap.numberOfTapsRequired = 3
        logoImageView.isUserInteractionEnabled = true
        logoImageView.addGestureRecognizer(debugLogoImageViewTap)
        #endif
    }

    func setupWithTheme() {
        
        self.view.backgroundColor = UIColor.App2.backgroundPrimary
        skipView.backgroundColor = UIColor.App2.backgroundPrimary

        skipButton.setTitleColor(UIColor.white, for: .normal)
        skipButton.backgroundColor = .clear

        loginLabel.textColor = UIColor.App2.textHeadlinePrimary

        usernameHeaderTextFieldView.setHeaderLabelColor(UIColor.App2.inputTextTitle)
        usernameHeaderTextFieldView.setTextFieldColor(UIColor.App2.textPrimary)
    
        passwordHeaderTextFieldView.setHeaderLabelColor(UIColor.App2.inputTextTitle)
        passwordHeaderTextFieldView.setTextFieldColor(UIColor.App2.textPrimary)

        rememberView.backgroundColor = .clear
        rememberLabel.textColor = UIColor.App2.textPrimary
        if self.shouldRememberUser {
            rememberToggleView.backgroundColor =  UIColor.App2.buttonBackgroundPrimary
        }
        else {
            rememberToggleView.backgroundColor =  UIColor.App2.buttonBackgroundPrimary
        }

        forgotButton.setTitleColor(UIColor.App2.textPrimary, for: .normal)

        loginButton.setTitleColor(UIColor.App2.buttonTextPrimary, for: .normal)
        loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .highlighted)
        loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        loginButton.backgroundColor = .clear
        loginButton.setBackgroundColor(UIColor.App2.buttonBackgroundPrimary, for: .normal)
        loginButton.setBackgroundColor(UIColor.App2.buttonBackgroundPrimary, for: .highlighted)
        loginButton.layer.cornerRadius = CornerRadius.button
        loginButton.layer.masksToBounds = true

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
        let smallRegisterViewController = SimpleRegisterEmailCheckViewController()
        self.navigationController?.pushViewController(smallRegisterViewController, animated: true)
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
        rememberToggleView.backgroundColor = UIColor.App2.buttonBackgroundPrimary
        Env.userSessionStore.shouldRecordUserSession = true
    }

    private func disableRememberUser() {
        rememberImageView.image = nil
        rememberToggleView.backgroundColor = UIColor.App2.buttonBackgroundSecondary
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

        Env.userSessionStore.loginUser(withUsername: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    if case error = UserSessionError.invalidEmailPassword {
                        self.showWrongPasswordStatus()
                    }
                    else {
                        self.showServerErrorStatus()
                    }
                case .finished:
                    ()
                }
                self.hideLoadingSpinner()
                self.loginButton.isEnabled = true
            }, receiveValue: { user in
                self.getProfileStatus()

                self.loginGomaAPI(username: user.username, password: user.userId)
            })
            .store(in: &cancellables)

    }

    func getProfileStatus() {
        Env.everyMatrixClient.getProfileStatus()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                self.hideLoadingSpinner()
            }, receiveValue: { value in
                Env.userSessionStore.isUserProfileIncomplete.send(value.isProfileIncomplete)
                self.showNextViewController()
            })
            .store(in: &cancellables)
    }

    func loginGomaAPI(username: String, password: String) {
        let userLoginForm = UserLoginForm(username: username, password: password, deviceToken: Env.deviceFCMToken)
        Env.gomaNetworkClient.requestLogin(deviceId: Env.deviceId, loginForm: userLoginForm)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in

            }, receiveValue: { value in
                Env.gomaNetworkClient.refreshAuthToken(token: value)
            })
            .store(in: &cancellables)
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

    private func showServerErrorStatus() {
        let alert = UIAlertController(title: localized("login_error_title"),
                                      message: localized("server_error_message"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction private func didTapRecoverPassword() {
        self.navigationController?.pushViewController(RecoverPasswordViewController(), animated: true)
    }

}

extension LoginViewController {

    @objc func didTapDebugFormFill() {

        if TargetVariables.environmentType == .dev {
            self.usernameHeaderTextFieldView.setText("ruben@gomadevelopment.pt") // Ivotest30
            self.passwordHeaderTextFieldView.setText("ruben=GOMA=12345") // testesdoIvo1
            self.loginButton.isEnabled = true
        }
    }

}
