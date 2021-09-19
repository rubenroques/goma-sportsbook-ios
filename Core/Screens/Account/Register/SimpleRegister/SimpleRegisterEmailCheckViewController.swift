//
//  SmallRegisterViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 15/09/2021.
//

import UIKit

class SimpleRegisterEmailCheckViewController: UIViewController {

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var skipView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var skipButton: UIButton!
    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private var registerTitleLabel: UILabel!
    @IBOutlet private var emailHeadertextFieldView: HeaderTextFieldView!
    @IBOutlet private var registerButton: RoundButton!
    @IBOutlet private var termsLabel: UILabel!

    init() {
        super.init(nibName: "SimpleRegisterEmailCheckViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commonInit()
        setupWithTheme()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func commonInit() {
        skipButton.setTitle(localized("string_skip"), for: .normal)
        skipButton.titleLabel?.font = AppFont.with(type: .semibold, size: 18)

        logoImageView.image = UIImage(named: "SPORTSBOOK")
        logoImageView.sizeToFit()

        registerTitleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 26)
        registerTitleLabel.text = localized("string_signup")

        emailHeadertextFieldView.setPlaceholderText("Email Address")

        registerButton.setTitle(localized("string_login"), for: .normal)
        registerButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 18)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackgroundColor

        containerView.backgroundColor = UIColor.App.mainBackgroundColor

        skipView.backgroundColor = UIColor.App.mainBackgroundColor

        skipButton.setTitleColor(UIColor.white, for: .normal)
        skipButton.layer.borderColor = .none
        skipButton.layer.backgroundColor = UIColor.white.withAlphaComponent(0).cgColor

        registerTitleLabel.textColor = .white

        emailHeadertextFieldView.backgroundColor = UIColor.App.mainBackgroundColor
        emailHeadertextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        emailHeadertextFieldView.setTextFieldColor(.white)
        emailHeadertextFieldView.setSecureField(false)

        registerButton.setTitleColor(.white, for: .normal)
        registerButton.setTitleColor(UIColor.white.withAlphaComponent(0.1), for: .disabled)
        registerButton.backgroundColor = UIColor.App.buttonMain
        registerButton.cornerRadius = BorderRadius.button

        underlineTextLabel()
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

        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 14), range: range1)
        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 14), range: range2)
        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 14), range: range3)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.buttonMain, range: range1)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.buttonMain, range: range2)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.buttonMain, range: range3)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range2)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range3)
        underlineAttriString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, underlineAttriString.length))

        termsLabel.attributedText = underlineAttriString
        termsLabel.isUserInteractionEnabled = true
        termsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapUnderlineLabel(gesture:))))
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

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.emailHeadertextFieldView.resignFirstResponder()
    }

    @IBAction private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func didTapRegisterButton() {

        let smallRegisterStep2ViewController = SimpleRegisterDetailsViewController(emailAddress: "rubenroques@outlook.com")
        self.navigationController?.pushViewController(smallRegisterStep2ViewController, animated: true)

//        let input = self.emailHeadertextFieldView.text
//
//        if !self.isValidEmail(input) {
//            self.emailHeadertextFieldView.showErrorOnField(text: "Invalid Email Address")
//        }
//        else {
//            let vc = SimpleRegisterDetailsViewController()
//            vc.emailUser = input
//        }

    }

    @IBAction func skipAction() {
        let vc = RootViewController()
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

}
