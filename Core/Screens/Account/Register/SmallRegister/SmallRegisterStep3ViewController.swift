//
//  SmallRegisterStep3ViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 15/09/2021.
//

import UIKit

class SmallRegisterStep3ViewController: UIViewController {

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var backView: UIView!
    @IBOutlet private var backImageView: UIImageView!
    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var openEmailButton: RoundButton!
    @IBOutlet private var resendEmailButton: UIButton!


    // Variables
    var imageGradient: UIImage = UIImage()
    var emailUser: String = ""

    init() {
        super.init(nibName: "SmallRegisterStep3ViewController", bundle: nil)
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

    func setupWithTheme() {

        self.view.backgroundColor = UIColor(patternImage: imageGradient)

        containerView.backgroundColor = UIColor(patternImage: imageGradient)

        backView.backgroundColor = UIColor(patternImage: imageGradient)

        titleLabel.textColor = .white

        textLabel.textColor = .white

        openEmailButton.setTitleColor(.white, for: .normal)
        openEmailButton.backgroundColor = UIColor.Core.buttonMain
        openEmailButton.cornerRadius = BorderRadius.button

        resendEmailButton.setTitleColor(.white, for: .normal)
        resendEmailButton.backgroundColor = UIColor(patternImage: imageGradient)
    }

    func commonInit() {

        backImageView.image = UIImage(named: "caret-left")
        backImageView.sizeToFit()

        logoImageView.image = UIImage(named: "Check_Email")
        logoImageView.sizeToFit()

        titleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 26)
        titleLabel.text = localized("string_check_email")

        textLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 15)
        textLabel.text = "\(localized("string_check_email_text1")) \(emailUser) \(localized("string_check_email_text2"))"
        textLabel.numberOfLines = 0

        openEmailButton.setTitle(localized("string_open_email_app"), for: .normal)
        openEmailButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 18)

        resendEmailButton.setTitle(localized("string_resend_email"), for: .normal)
        resendEmailButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 18)

        let tapBackImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapBackImageGestureRecognizer:)))
            backImageView.isUserInteractionEnabled = true
        backImageView.addGestureRecognizer(tapBackImageGestureRecognizer)
    }

    @objc func imageTapped(tapBackImageGestureRecognizer: UITapGestureRecognizer)
    {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func openEmailAppAction() {

        let mailURL = URL(string: "message://")!

        if UIApplication.shared.canOpenURL(mailURL) {
            UIApplication.shared.open(mailURL, options: [:], completionHandler: nil)
        }

        let vc = SmallRegisterStep4ViewController()

        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func resendEmailAction() {
        // TO-DO: Resend email
    }


}
