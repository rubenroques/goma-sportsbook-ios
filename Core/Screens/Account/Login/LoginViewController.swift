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
    @IBOutlet private var rememberImageView: UIImageView!
    @IBOutlet private var rememberLabel: UILabel!
    @IBOutlet private var forgotView: UIView!
    @IBOutlet private var forgotButton: UIButton!
    @IBOutlet private var loginButton: RoundButton!
    @IBOutlet private var registerLabel: UILabel!
    @IBOutlet private var termsLabel: UILabel!

    // Variables
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

        setupWithTheme()
        commonInit()

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor(patternImage: imageGradient)

        skipView.backgroundColor = UIColor(patternImage: imageGradient)

        skipButton.setTitleColor(UIColor.Core.headingMain, for: .normal)
        skipButton.layer.borderColor = .none
        skipButton.layer.backgroundColor = UIColor.Core.headingMain.withAlphaComponent(0).cgColor

        loginLabel.textColor = UIColor.Core.headingMain

        usernameHeaderTextFieldView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        usernameHeaderTextFieldView.setTextFieldColor(UIColor.Core.headingMain)
        usernameHeaderTextFieldView.setSecureField(false)

        passwordHeaderTextFieldView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        passwordHeaderTextFieldView.setTextFieldColor(UIColor.Core.headingMain)
        passwordHeaderTextFieldView.setSecureField(true)

        rememberView.backgroundColor = UIColor(patternImage: imageGradient)

        rememberImageView.backgroundColor =  UIColor.Core.headerTextFieldGray
        rememberImageView.layer.cornerRadius = BorderRadius.checkBox
        rememberImageView.layer.borderWidth = 1
        rememberImageView.layer.borderColor = UIColor.Core.backgroundDarkModal.withAlphaComponent(0).cgColor

        rememberLabel.textColor = UIColor.Core.headingMain

        forgotButton.setTitleColor(UIColor.Core.headingMain, for: .normal)

        loginButton.setTitleColor(UIColor.Core.headingMain, for: .normal)
        loginButton.setTitleColor(UIColor.Core.headingMain.withAlphaComponent(0.1), for: .disabled)
        //loginButton.backgroundColor = UIColor.Core.backgroundDarkModal
        loginButton.backgroundColor = UIColor.Core.buttonMain
        loginButton.cornerRadius = BorderRadius.button

        // Label with highlighted text area
        highlightTextLabel()
        // Label with underline and highlighted text area
        underlineTextLabel()

    }

    func highlightTextLabel() {
        let accountText = localized("string_new_create_account")
        registerLabel.text = accountText
        registerLabel.font = AppFont.with(type: .regular, size: 14.0)
        self.registerLabel.textColor = UIColor.Core.headingMain
        let highlightAttriString = NSMutableAttributedString(string: accountText)
        let range1 = (accountText as NSString).range(of: localized("string_create_account"))
        highlightAttriString.addAttribute(NSAttributedString.Key.font, value: AppFont.with(type: .regular, size: 14), range: range1)
        highlightAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.Core.buttonMain, range: range1)
        registerLabel.attributedText = highlightAttriString
        registerLabel.isUserInteractionEnabled = true
        registerLabel.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapLabel(gesture:))))
    }

    func underlineTextLabel() {
        let termsText = localized("string_agree_terms_conditions")

        termsLabel.text = termsText
        termsLabel.numberOfLines = 0
        termsLabel.font = AppFont.with(type: .regular, size: 14.0)
        self.termsLabel.textColor = UIColor.Core.headingMain

        let underlineAttriString = NSMutableAttributedString(string: termsText)

        let range1 = (termsText as NSString).range(of: localized("string_terms"))
        let range2 = (termsText as NSString).range(of: localized("string_privacy_policy"))
        let range3 = (termsText as NSString).range(of: localized("string_eula"))

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.alignment = .center

        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: AppFont.with(type: .regular, size: 14), range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: AppFont.with(type: .regular, size: 14), range: range2)
        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: AppFont.with(type: .regular, size: 14), range: range3)
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.Core.buttonMain, range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.Core.buttonMain, range: range2)
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.Core.buttonMain, range: range3)
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

    @IBAction func tapUnderlineLabel(gesture: UITapGestureRecognizer) {
        let text = localized("string_agree_terms_conditions")

        let termsRange = (text as NSString).range(of: localized("string_terms"))
        let privacyRange = (text as NSString).range(of: localized("string_privacy_policy"))
        let eulaRange = (text as NSString).range(of: localized("string_eula"))

        if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: termsRange) {
            print("Tapped Terms")
            // TO-DO: Call VC to register
        } else if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: privacyRange) {
            print("Tapped Privacy")
            // TO-DO: Call VC to register
        } else if gesture.didTapAttributedTextInLabel(label: termsLabel, inRange: eulaRange) {
            print("Tapped EULA")
            // TO-DO: Call VC to register
        } else {
            print("Tapped none")
        }
    }

    func commonInit() {

        skipButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 18)
        skipButton.setTitle(localized("string_skip"), for: .normal)

        logoImageView.image = UIImage(named: "SPORTSBOOK")
        logoImageView.sizeToFit()

        loginLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 26)
        loginLabel.text = localized("string_login")

        self.usernameHeaderTextFieldView.setPlaceholderText("Email or Username")
        self.passwordHeaderTextFieldView.setPlaceholderText("Password")

        self.usernameHeaderTextFieldView.highlightColor = UIColor.Core.headingMain
            self.passwordHeaderTextFieldView.highlightColor = UIColor.Core.headingMain

        rememberLabel.text = localized("string_remember")
        rememberLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 12)
        forgotButton.setTitle(localized("string_forgot"), for: .normal)
        forgotButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 14)

        loginButton.setTitle(localized("string_login"), for: .normal)
        loginButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 18)
        //loginButton.isEnabled = false

        self.passwordHeaderTextFieldView.setSecureField(true)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        let tapImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapImageGestureRecognizer:)))
        rememberImageView.isUserInteractionEnabled = true
        rememberImageView.addGestureRecognizer(tapImageGestureRecognizer)
    }

    @objc func imageTapped(tapImageGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapImageGestureRecognizer.view as! UIImageView

        if !Env.remember {
            tappedImage.image = UIImage(named: "Active")
            Env.remember = true
        } else {
            tappedImage.image = nil
            Env.remember = false
        }
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        _ = self.usernameHeaderTextFieldView.resignFirstResponder()
        _ = self.passwordHeaderTextFieldView.resignFirstResponder()
    }

    @IBAction private func didTapLoginButton() {
        // TEST
        let username = "andrelascas@hotmail.com"
        let input = self.usernameHeaderTextFieldView.text
        print(input)
        if (username != input) {
            self.usernameHeaderTextFieldView.showErrorOnField(text: "Error")
        }
    }

    @IBAction private func didTapRecoverPassword() {
        self.navigationController?.pushViewController(RecoverPasswordViewController(), animated: true)
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
