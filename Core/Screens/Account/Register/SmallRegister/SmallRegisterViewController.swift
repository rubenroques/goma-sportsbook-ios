//
//  SmallRegisterViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 15/09/2021.
//

import UIKit

class SmallRegisterViewController: UIViewController {

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var skipView: UIView!
    @IBOutlet private var skipButton: UIButton!
    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private var registerTitleLabel: UILabel!
    @IBOutlet private var emailHeadertextFieldView: HeaderTextFieldView!
    @IBOutlet private var registerButton: RoundButton!
    @IBOutlet private var termsLabel: UILabel!

    // Variables
    var imageGradient: UIImage = UIImage()
    
    init() {
        super.init(nibName: "SmallRegisterViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageGradient = UIImage.init().getGradientColorImage(red: 37, green: 40, blue: 50, alpha: 1.0, bounds: self.view.bounds)
        
        setupWithTheme()
        commonInit()
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)

    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor(patternImage: imageGradient)

        containerView.backgroundColor = UIColor(patternImage: imageGradient)

        skipView.backgroundColor = UIColor(patternImage: imageGradient)

        skipButton.setTitleColor(UIColor.white, for: .normal)
        skipButton.layer.borderColor = .none
        skipButton.layer.backgroundColor = UIColor.white.withAlphaComponent(0).cgColor

        registerTitleLabel.textColor = .white

        emailHeadertextFieldView.backgroundColor = UIColor(patternImage: imageGradient)
        emailHeadertextFieldView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        emailHeadertextFieldView.setTextFieldColor(.white)
        emailHeadertextFieldView.setSecureField(false)

        registerButton.setTitleColor(.white, for: .normal)
        registerButton.setTitleColor(UIColor.white.withAlphaComponent(0.1), for: .disabled)
        //loginButton.backgroundColor = UIColor.Core.backgroundDarkModal
        registerButton.backgroundColor = UIColor.Core.buttonMain
        registerButton.cornerRadius = BorderRadius.button

        underlineTextLabel()
    }

    func commonInit() {
        skipButton.setTitle(localized("string_skip"), for: .normal)

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

    @objc func didTapBackground() {
        self.resignFirstResponder()

        _ = self.emailHeadertextFieldView.resignFirstResponder()

    }

    @IBAction func registerAction() {

        let input = self.emailHeadertextFieldView.text

        if (!input.isValidEmail()) {
            self.emailHeadertextFieldView.showErrorOnField(text: "Invalid Email Address")
        } else {
            let vc = SmallRegisterStep2ViewController()
            vc.emailUser = input

            self.navigationController?.pushViewController(vc, animated: true)
        }

    }

    @IBAction func skipAction() {
        let vc = RootViewController()
        
        self.navigationController?.pushViewController(vc, animated: true)
    }



}
