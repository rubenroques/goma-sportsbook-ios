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
    @IBOutlet private var termsLabel: UILabel!

    // Variables
    var shouldRememberUser: Bool = true

    var cancellables = Set<AnyCancellable>()

    init() {
        super.init(nibName: "LoginViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "SplashViewController"

        commonInit()
        setupWithTheme()

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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        skipButton.setTitle(localized("string_skip"), for: .normal)

        logoImageView.image = UIImage(named: "logo_horizontal_large")
        logoImageView.sizeToFit()

        loginLabel.font = AppFont.with(type: AppFont.AppFontType.bold, size: 26)
        loginLabel.text = localized("string_login")

        self.usernameHeaderTextFieldView.setPlaceholderText("Email or Username")
        self.passwordHeaderTextFieldView.setPlaceholderText("Password")


        self.usernameHeaderTextFieldView.highlightColor = .white
        self.passwordHeaderTextFieldView.highlightColor = .white

        rememberLabel.text = localized("string_remember")
        rememberLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 12)
        rememberToggleView.layer.cornerRadius = CornerRadius.checkBox
        rememberImageView.backgroundColor = .clear
        rememberImageView.contentMode = .scaleAspectFit

        self.enableRememberUser()

        forgotButton.setTitle(localized("string_forgot"), for: .normal)
        forgotButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 14)

        loginButton.setTitle(localized("string_login"), for: .normal)
        loginButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 18)

        self.passwordHeaderTextFieldView.setSecureField(true)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        let tapImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(rememberUserOptionTapped))
        rememberView.isUserInteractionEnabled = true
        rememberView.addGestureRecognizer(tapImageGestureRecognizer)

        // Label with highlighted text area
        highlightTextLabel()
        // Label with underline and highlighted text area
        underlineTextLabel()

        if self.isModal {
            self.skipButton.isHidden = true
            self.dismissButton.isHidden = false
        }
        else {
            self.skipButton.isHidden = false
            self.dismissButton.isHidden = true
        }

    }

    func setupWithTheme() {
        
        self.view.backgroundColor = UIColor.App.mainBackgroundColor
        skipView.backgroundColor = UIColor.App.mainBackgroundColor

        skipButton.setTitleColor(UIColor.white, for: .normal)
        skipButton.backgroundColor = .clear

        loginLabel.textColor = .white

        usernameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        usernameHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        passwordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        passwordHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        rememberView.backgroundColor = .clear
        rememberLabel.textColor = UIColor.App.headingMain
        if self.shouldRememberUser {
            rememberToggleView.backgroundColor =  UIColor.App.mainTintColor
        }
        else {
            rememberToggleView.backgroundColor =  UIColor.App.backgroundDarkModal
        }

        forgotButton.setTitleColor(UIColor.App.headingMain, for: .normal)

        loginButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .highlighted)
        loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)
        loginButton.backgroundColor = .clear
        loginButton.setBackgroundColor(UIColor.App.primaryButtonNormalColor, for: .normal)
        loginButton.setBackgroundColor(UIColor.App.primaryButtonPressedColor, for: .highlighted)
        loginButton.layer.cornerRadius = CornerRadius.button
        loginButton.layer.masksToBounds = true

        termsLabel.textColor = UIColor.App.headingMain

    }

    func highlightTextLabel() {
        let accountText = localized("string_new_create_account")

        registerLabel.text = accountText
        registerLabel.font = AppFont.with(type: .bold, size: 14.0)

        self.registerLabel.textColor =  UIColor.white

        let highlightAttriString = NSMutableAttributedString(string: accountText)
        let range1 = (accountText as NSString).range(of: localized("string_create_account"))
        highlightAttriString.addAttribute(NSAttributedString.Key.font, value: AppFont.with(type: .bold, size: 14), range: range1)
        highlightAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.App.buttonMain, range: range1)

        registerLabel.attributedText = highlightAttriString
        registerLabel.isUserInteractionEnabled = true
        registerLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapCreateAccount)))
    }

    func underlineTextLabel() {
        let termsText = localized("string_agree_terms_conditions")

        let font = AppFont.with(type: .semibold, size: 11.0)
        termsLabel.text = termsText
        termsLabel.numberOfLines = 0
        termsLabel.font = font


        let underlineAttriString = NSMutableAttributedString(string: termsText)

        let range1 = (termsText as NSString).range(of: localized("string_terms"))
        let range2 = (termsText as NSString).range(of: localized("string_privacy_policy"))
        let range3 = (termsText as NSString).range(of: localized("string_eula"))

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.alignment = .center

        underlineAttriString.addAttribute(.font, value: font, range: range1)
        underlineAttriString.addAttribute(.font, value: font, range: range2)
        underlineAttriString.addAttribute(.font, value: font, range: range3)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.buttonMain, range: range1)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.buttonMain, range: range2)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.buttonMain, range: range3)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range2)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range3)
        underlineAttriString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, underlineAttriString.length))

        termsLabel.attributedText = underlineAttriString
        termsLabel.isUserInteractionEnabled = true
        termsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapUnderlineLabel(gesture:))))
    }

    @objc private func didTapCreateAccount() {
        let smallRegisterViewController = SimpleRegisterEmailCheckViewController()
        self.navigationController?.pushViewController(smallRegisterViewController, animated: true)
    }

    @IBAction private func didTapUnderlineLabel(gesture: UITapGestureRecognizer) {
        let text = localized("string_agree_terms_conditions")

        let termsRange = (text as NSString).range(of: localized("string_terms"))
        let privacyRange = (text as NSString).range(of: localized("string_privacy_policy"))
        let eulaRange = (text as NSString).range(of: localized("string_eula"))

        if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: termsRange) {
            print("Tapped Terms")
            UIApplication.shared.open(NSURL(string: "https://gomadevelopment.pt/")! as URL, options: [:], completionHandler: nil)
        }
        else if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: privacyRange) {
            print("Tapped Privacy")
            UIApplication.shared.open(NSURL(string: "https://gomadevelopment.pt/")! as URL, options: [:], completionHandler: nil)
        }
        else if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: eulaRange) {
            print("Tapped EULA")
            UIApplication.shared.open(NSURL(string: "https://gomadevelopment.pt/")! as URL, options: [:], completionHandler: nil)
        }
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
        rememberToggleView.backgroundColor = UIColor.App.mainTintColor
        Env.remember = true
    }

    private func disableRememberUser() {
        rememberImageView.image = nil
        rememberToggleView.backgroundColor = UIColor.App.backgroundDarkModal
        Env.remember = false
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

        Env.userSessionStore.loginUser(withUsername: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error) where error == .invalidEmailPassword:
                    self.showWrongPasswordStatus()
                case .failure:
                    self.showServerErrorStatus()
                case .finished:
                    ()
                }

                print("completion: \(completion)")
                self.loginButton.isEnabled = true
            }, receiveValue: { userSession in
                print("userSession: \(userSession)")

                self.showNextViewController()
            })
            .store(in: &cancellables)

//        let username = "andrelascas@hotmail.com"
//        let input = self.usernameHeaderTextFieldView.text
//        print(input)
//
//        if username != input {
//            self.usernameHeaderTextFieldView.showErrorOnField(text: "Error", color: UIColor.App.alertError)
//        }

    }

    private func showNextViewController() {
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
        let alert = UIAlertController(title: localized("string_login_error_title"),
                                      message: localized("string_login_error_message"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("string_ok"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func showServerErrorStatus() {
        let alert = UIAlertController(title: localized("string_login_error_title"),
                                      message: localized("string_server_error_message"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("string_ok"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction private func didTapRecoverPassword() {
        self.navigationController?.pushViewController(RecoverPasswordViewController(), animated: true)
    }

}
