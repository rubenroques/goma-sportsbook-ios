import UIKit

class LoginViewController: UIViewController {

    @IBOutlet private var scrollView: UIScrollView!

    @IBOutlet private var skipView: UIView!
    @IBOutlet private var skipButton: UIButton!

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
    var imageGradient: UIImage = UIImage()

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

        imageGradient = UIImage.init().getGradientColorImage(red: 37, green: 40, blue: 50, alpha: 1.0, bounds: self.view.bounds)

        commonInit()
        setupWithTheme()
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

        logoImageView.image = UIImage(named: "SPORTSBOOK")
        logoImageView.sizeToFit()

        loginLabel.font = AppFont.with(type: AppFont.AppFontType.bold, size: 26)
        loginLabel.text = localized("string_login")

        self.usernameHeaderTextFieldView.setPlaceholderText("Email or Username")
        self.passwordHeaderTextFieldView.setPlaceholderText("Password")

        self.usernameHeaderTextFieldView.highlightColor = .white
        self.passwordHeaderTextFieldView.highlightColor = .white

        rememberLabel.text = localized("string_remember")
        rememberLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 12)
        rememberToggleView.layer.cornerRadius = BorderRadius.checkBox
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
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor(patternImage: imageGradient)

        skipView.backgroundColor = UIColor(patternImage: imageGradient)

        skipButton.setTitleColor(UIColor.white, for: .normal)
        skipButton.layer.borderColor = .none
        skipButton.layer.backgroundColor = UIColor.white.withAlphaComponent(0).cgColor

        loginLabel.textColor = .white

        usernameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        usernameHeaderTextFieldView.setTextFieldColor(.white)

        passwordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        passwordHeaderTextFieldView.setTextFieldColor(.white)

        rememberView.backgroundColor = .clear
        rememberLabel.textColor = .white
        if self.shouldRememberUser {
            rememberToggleView.backgroundColor =  UIColor.App.mainTintColor
        }
        else {
            rememberToggleView.backgroundColor =  UIColor.App.backgroundDarkModal
        }

        forgotButton.setTitleColor(.white, for: .normal)

        loginButton.setTitleColor(.white, for: .normal)
        loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .highlighted)
        loginButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)

        loginButton.backgroundColor = .clear
        loginButton.setBackgroundColor(UIColor.App.primaryButtonNormalColor, for: .normal)
        loginButton.setBackgroundColor(UIColor.App.primaryButtonPressedColor, for: .highlighted)


        loginButton.layer.cornerRadius = BorderRadius.button
        loginButton.layer.masksToBounds = true

        /*
         loginButton.backgroundColor = UIColor.App.primaryButtonNormalColor
         loginButton.setBackgroundColor(UIColor.App.primaryButtonNormalColor, for: .normal)
         loginButton.setBackgroundColor(UIColor.App.primaryButtonPressedColor, for: .selected)

         loginButton.layer.masksToBounds = true
         loginButton.layer.cornerRadius = BorderRadius.button
         */

        // Label with highlighted text area
        highlightTextLabel()
        // Label with underline and highlighted text area
        underlineTextLabel()

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
        registerLabel.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapLabel(gesture:))))
    }

    func underlineTextLabel() {
        let termsText = localized("string_agree_terms_conditions")

        let font = AppFont.with(type: .semibold, size: 11.0)
        termsLabel.text = termsText
        termsLabel.numberOfLines = 0
        termsLabel.font = font
        self.termsLabel.textColor =  UIColor.white

        let underlineAttriString = NSMutableAttributedString(string: termsText)

        let range1 = (termsText as NSString).range(of: localized("string_terms"))
        let range2 = (termsText as NSString).range(of: localized("string_privacy_policy"))
        let range3 = (termsText as NSString).range(of: localized("string_eula"))

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.alignment = .center

        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: font, range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: font, range: range2)
        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: font, range: range3)
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.App.buttonMain, range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.App.buttonMain, range: range2)
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.App.buttonMain, range: range3)
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range2)
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range3)
        underlineAttriString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, underlineAttriString.length))

        termsLabel.attributedText = underlineAttriString
        termsLabel.isUserInteractionEnabled = true
        termsLabel.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapUnderlineLabel(gesture:))))
    }

    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        let text = localized("string_new_create_account")

        let termsRange = (text as NSString).range(of: localized("string_create_account"))

        if gesture.didTapAttributedTextInLabel(label: registerLabel, inRange: termsRange) {
            print("Tapped Create a new account")
            // TO-DO: Call VC to register
        } else {
            print("Tapped none")
        }
    }

    @IBAction private func tapUnderlineLabel(gesture: UITapGestureRecognizer) {
        let text = localized("string_agree_terms_conditions")

        let termsRange = (text as NSString).range(of: localized("string_terms"))
        let privacyRange = (text as NSString).range(of: localized("string_privacy_policy"))
        let eulaRange = (text as NSString).range(of: localized("string_eula"))

        if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: termsRange) {
            print("Tapped Terms")
            // TO-DO: Call VC to register
        }
        else if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: privacyRange) {
            print("Tapped Privacy")
            // TO-DO: Call VC to register
        }
        else if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: eulaRange) {
            print("Tapped EULA")
            // TO-DO: Call VC to register
        } else {
            print("Tapped none")
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

    @IBAction private func didTapLoginButton() {
        // TEST
        let username = "andrelascas@hotmail.com"
        let input = self.usernameHeaderTextFieldView.text
        print(input)
        if (username != input) {
            self.usernameHeaderTextFieldView.showErrorOnField(text: "Error", color: UIColor.App.alertError)
        }
    }

    @IBAction private func didTapRecoverPassword() {
        self.navigationController?.pushViewController(RecoverPasswordViewController(), animated: true)
    }

    @IBAction private func didTapSkipButton() {
        
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(textField: UITextField) {
        if ((self.usernameHeaderTextFieldView.text.isEmpty != nil) && (self.passwordHeaderTextFieldView.text.isEmpty != nil)){
            self.loginButton.isEnabled = true
            }else{
                self.loginButton.isEnabled = false
            }
        }
}
