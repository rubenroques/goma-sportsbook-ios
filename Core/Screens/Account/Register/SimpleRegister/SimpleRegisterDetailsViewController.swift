//
//  SimpleRegisterDetailsViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 15/09/2021.
//

import UIKit

class SimpleRegisterDetailsViewController: UIViewController {

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
    var emailAddress: String

    init(emailAddress: String) {
        self.emailAddress = emailAddress

        super.init(nibName: "SimpleRegisterDetailsViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupWithTheme()
        commonInit()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }


    func commonInit() {
        backImageView.image = UIImage(named: "caret-left")
        backImageView.sizeToFit()

        registerTitleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 26)
        registerTitleLabel.text = localized("string_signup")

        usernameHeaderTextView.setPlaceholderText(localized("string_username"))

        emailHeaderTextView.setPlaceholderText(localized("string_email"))
        emailHeaderTextView.setSecureField(false)
        emailHeaderTextView.setTextFieldDefaultValue(self.emailAddress)
        emailHeaderTextView.isDisabled = true

        dateHeaderTextView.setPlaceholderText(localized("string_birth_date"))
        dateHeaderTextView.setImageTextField(UIImage(named: "calendar-regular")!)
        dateHeaderTextView.setDatePicker()

        indicativeHeaderTextView.setSelectionPicker(["🇵🇹 +351", "🇨🇭 +041"])
        indicativeHeaderTextView.setImageTextField(UIImage(named: "Arrow_Down")!, size: 10)
        indicativeHeaderTextView.setTextFieldFont(AppFont.with(type: .regular, size: 16))

        phoneHeaderTextView.setPlaceholderText(localized("string_phone_number"))
        phoneHeaderTextView.setKeyboardType(.numberPad)

        passwordHeaderTextView.setPlaceholderText(localized("string_password"))
        confirmPasswordHeaderTextView.setPlaceholderText(localized("string_confirm_password"))

        signUpButton.setTitle(localized("string_signup"), for: .normal)
        signUpButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 18)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        let tapBackImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapBackImageButton))
        backImageView.isUserInteractionEnabled = true
        backImageView.addGestureRecognizer(tapBackImageGestureRecognizer)
    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.mainBackgroundColor

        containerView.backgroundColor = UIColor.App.mainBackgroundColor
        backView.backgroundColor = UIColor.App.mainBackgroundColor
        registerTitleLabel.textColor = UIColor.App.headingMain
        topSignUpView.backgroundColor = UIColor.App.mainBackgroundColor

        usernameHeaderTextView.backgroundColor = UIColor.App.mainBackgroundColor
        usernameHeaderTextView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        usernameHeaderTextView.setTextFieldColor(UIColor.App.headingMain)
        usernameHeaderTextView.setSecureField(false)

        dateHeaderTextView.backgroundColor = UIColor.App.mainBackgroundColor
        dateHeaderTextView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        dateHeaderTextView.setTextFieldColor(UIColor.App.headingMain)
        dateHeaderTextView.setSecureField(false)

        phoneView.backgroundColor = UIColor.App.mainBackgroundColor

        indicativeHeaderTextView.backgroundColor = UIColor.App.mainBackgroundColor
        indicativeHeaderTextView.setTextFieldColor(UIColor.App.headingMain)
        indicativeHeaderTextView.setViewColor(UIColor.App.mainBackgroundColor)
        indicativeHeaderTextView.setViewBorderColor(UIColor.App.headerTextFieldGray)
        indicativeHeaderTextView.setSecureField(false)

        phoneHeaderTextView.backgroundColor = UIColor.App.mainBackgroundColor
        phoneHeaderTextView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        phoneHeaderTextView.setTextFieldColor(UIColor.App.headingMain)
        phoneHeaderTextView.setSecureField(false)

        lineView.backgroundColor = UIColor.App.headerTextFieldGray.withAlphaComponent(0.2)

        emailHeaderTextView.backgroundColor = UIColor.App.mainBackgroundColor
        emailHeaderTextView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        emailHeaderTextView.setTextFieldColor(UIColor.App.headingMain)

        passwordHeaderTextView.backgroundColor = UIColor.App.mainBackgroundColor
        passwordHeaderTextView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        passwordHeaderTextView.setTextFieldColor(UIColor.App.headingMain)
        passwordHeaderTextView.setSecureField(true)

        confirmPasswordHeaderTextView.backgroundColor = UIColor.App.mainBackgroundColor
        confirmPasswordHeaderTextView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        confirmPasswordHeaderTextView.setTextFieldColor(UIColor.App.headingMain)
        confirmPasswordHeaderTextView.setSecureField(true)

        underlineTextLabel()

        signUpButton.backgroundColor = UIColor.App.buttonMain
        signUpButton.cornerRadius = BorderRadius.button
    }

    @objc func didTapBackImageButton() {
        self.navigationController?.popViewController(animated: true)
    }

    func underlineTextLabel() {
        let termsText = localized("string_agree_terms_conditions")

        termsLabel.text = termsText
        termsLabel.numberOfLines = 0
        termsLabel.font = AppFont.with(type: .regular, size: 14.0)
        self.termsLabel.textColor = UIColor.App.headingMain

        let underlineAttriString = NSMutableAttributedString(string: termsText)

        let range1 = (termsText as NSString).range(of: localized("string_terms"))
        let range2 = (termsText as NSString).range(of: localized("string_privacy_policy"))
        let range3 = (termsText as NSString).range(of: localized("string_eula"))

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.alignment = .center

        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 14), range: range1)
        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 14), range: range2)
        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 14), range: range3)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.buttonMain, range: range1)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.buttonMain, range: range2)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.buttonMain, range: range3)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range2)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range3)
        underlineAttriString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, underlineAttriString.length))

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

        let vc = SimpleRegisterEmailSentViewController()
        self.navigationController?.pushViewController(vc, animated: true)

        return
        
        var validFields = true

        // TEST
        let username = usernameHeaderTextView.text
        let birthDate = dateHeaderTextView.text
        let phone = "\(indicativeHeaderTextView.text)\(phoneHeaderTextView.text)"
        let email = emailHeaderTextView.text
        let password = passwordHeaderTextView.text
        let confirmPassword = confirmPasswordHeaderTextView.text


        //TO-DO: Username verification
        if password != confirmPassword {
            passwordHeaderTextView.showErrorOnField(text: localized("string_password_not_match"), color: UIColor.App.alertError)
            validFields = false
        }
        else if password.count < 8 {
            passwordHeaderTextView.showTip(text: localized("string_weak_password"))
            validFields = false
        }

        if validFields {
            let vc = SimpleRegisterEmailSentViewController()
            vc.emailUser = email
           
            self.navigationController?.pushViewController(vc, animated: true)
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
