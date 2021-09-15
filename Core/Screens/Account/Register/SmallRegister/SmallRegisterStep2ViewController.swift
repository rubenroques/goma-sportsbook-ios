//
//  SmallRegisterStep2ViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 15/09/2021.
//

import UIKit

class SmallRegisterStep2ViewController: UIViewController {

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var backView: UIView!
    @IBOutlet private var backImageView: UIImageView!
    @IBOutlet private var registerTitleLabel: UILabel!
    @IBOutlet private var topSignUpView: UIView!
    @IBOutlet private var usernameHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var dateHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var phoneView: UIView!
    @IBOutlet private var indicativeHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var phoneHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var lineView: UIView!
    @IBOutlet private var emailHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var passwordHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var confirmPasswordHeaderTextView: HeaderTextFieldView!
    @IBOutlet private var termsLabel: UILabel!
    @IBOutlet private var signUpButton: RoundButton!


    // Variables
    var imageGradient: UIImage = UIImage()
    var emailUser: String = ""

    init() {
        super.init(nibName: "SmallRegisterStep2ViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageGradient = UIImage.init().getGradientColorImage(red: 37, green: 40, blue: 50, alpha: 1.0, bounds: self.view.bounds)
        // TEST
        emailUser = "gomadev@gomadevelopment.pt"
        setupWithTheme()
        commonInit()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    

    func setupWithTheme() {

        self.view.backgroundColor = UIColor(patternImage: imageGradient)

        containerView.backgroundColor = UIColor(patternImage: imageGradient)

        backView.backgroundColor = UIColor(patternImage: imageGradient)

        registerTitleLabel.textColor = .white

        topSignUpView.backgroundColor = UIColor(patternImage: imageGradient)

        usernameHeaderTextView.backgroundColor = UIColor(patternImage: imageGradient)
        usernameHeaderTextView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        usernameHeaderTextView.setTextFieldColor(.white)
        usernameHeaderTextView.setSecureField(false)

        dateHeaderTextView.backgroundColor = UIColor(patternImage: imageGradient)
        dateHeaderTextView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        dateHeaderTextView.setTextFieldColor(.white)
        dateHeaderTextView.setSecureField(false)

        phoneView.backgroundColor = UIColor(patternImage: imageGradient)

        indicativeHeaderTextView.backgroundColor = UIColor(patternImage: imageGradient)
        indicativeHeaderTextView.setTextFieldColor(.white)
        indicativeHeaderTextView.setViewColor(UIColor(patternImage: imageGradient))
        indicativeHeaderTextView.setViewBorderColor(UIColor.Core.headerTextFieldGray)
        indicativeHeaderTextView.setSecureField(false)

        phoneHeaderTextView.backgroundColor = UIColor(patternImage: imageGradient)
        phoneHeaderTextView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        phoneHeaderTextView.setTextFieldColor(.white)
        phoneHeaderTextView.setSecureField(false)

        lineView.backgroundColor = UIColor.Core.headerTextFieldGray.withAlphaComponent(0.2)

        emailHeaderTextView.backgroundColor = UIColor(patternImage: imageGradient)
        emailHeaderTextView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        emailHeaderTextView.setTextFieldColor(.white)
        emailHeaderTextView.setSecureField(false)
        emailHeaderTextView.setTextFieldDefaultValue(emailUser)
        emailHeaderTextView.isDisabled = true

        passwordHeaderTextView.backgroundColor = UIColor(patternImage: imageGradient)
        passwordHeaderTextView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        passwordHeaderTextView.setTextFieldColor(.white)
        passwordHeaderTextView.setSecureField(true)

        confirmPasswordHeaderTextView.backgroundColor = UIColor(patternImage: imageGradient)
        confirmPasswordHeaderTextView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        confirmPasswordHeaderTextView.setTextFieldColor(.white)
        confirmPasswordHeaderTextView.setSecureField(true)

        underlineTextLabel()

        signUpButton.backgroundColor = UIColor.Core.buttonMain
        signUpButton.cornerRadius = BorderRadius.button

    }

    func commonInit() {
        backImageView.image = UIImage(named: "caret-left")
        backImageView.sizeToFit()

        registerTitleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 26)
        registerTitleLabel.text = localized("string_signup")

        usernameHeaderTextView.setPlaceholderText(localized("string_username"))

        dateHeaderTextView.setPlaceholderText(localized("string_birth_date"))
        dateHeaderTextView.setImageTextField(UIImage(named: "calendar-regular")!)
        dateHeaderTextView.setDatePicker()

        indicativeHeaderTextView.setSelectionPicker(["+351", "+041"])

        phoneHeaderTextView.setPlaceholderText(localized("string_phone_number"))
        phoneHeaderTextView.setKeyboardType(.numberPad)

        passwordHeaderTextView.setPlaceholderText(localized("string_password"))
        confirmPasswordHeaderTextView.setPlaceholderText(localized("string_confirm_password"))

        signUpButton.setTitle(localized("string_signup"), for: .normal)
        signUpButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 18)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    func underlineTextLabel() {
        let termsText = localized("string_agree_terms_conditions")

        termsLabel.text = termsText
        termsLabel.numberOfLines = 0
        termsLabel.font = AppFont.with(type: .regular, size: 14.0)
        self.termsLabel.textColor =  UIColor.white

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

    @IBAction func signUpAction() {
        // TEST
        let username = usernameHeaderTextView.text
        let birthDate = dateHeaderTextView.text
        let phone = " \(indicativeHeaderTextView.text) \(phoneHeaderTextView.text)"
        let email = emailHeaderTextView.text
        let password = passwordHeaderTextView.text
        let confirmPassword = confirmPasswordHeaderTextView.text

        if password != confirmPassword {
            passwordHeaderTextView.showErrorOnField(text: localized("string_password_not_match"), color: .systemRed)
        }
        else if password.count < 8 {
            passwordHeaderTextView.showTip(text: localized("string_weak_password"))
        }
    }


    @objc func didTapBackground() {
        self.resignFirstResponder()

        _ = self.usernameHeaderTextView.resignFirstResponder()

        _ = self.dateHeaderTextView.resignFirstResponder()

        _ = self.phoneHeaderTextView.resignFirstResponder()

        _ = self.passwordHeaderTextView.resignFirstResponder()

        _ = self.confirmPasswordHeaderTextView.resignFirstResponder()

    }

    @objc func keyboardWillShow(notification:NSNotification) {

        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification:NSNotification) {

        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
}
