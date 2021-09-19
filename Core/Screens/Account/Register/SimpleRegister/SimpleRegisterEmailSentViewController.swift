//
//  SimpleRegisterEmailSentViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 15/09/2021.
//

import UIKit

class SimpleRegisterEmailSentViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var backView: UIView!
    @IBOutlet private var logoImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var openEmailButton: RoundButton!
    @IBOutlet private var resendEmailButton: UIButton!

    //
    var emailUser: String = ""

    init() {
        super.init(nibName: "SimpleRegisterEmailSentViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupWithTheme()
        commonInit()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackgroundColor
        containerView.backgroundColor = UIColor.App.mainBackgroundColor
        backView.backgroundColor = UIColor.App.mainBackgroundColor
        titleLabel.textColor = UIColor.App.headingMain
        textLabel.textColor = UIColor.App.headingMain

        openEmailButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        openEmailButton.backgroundColor = UIColor.App.primaryButtonNormalColor
        openEmailButton.cornerRadius = BorderRadius.button

        resendEmailButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        resendEmailButton.backgroundColor = UIColor.App.mainBackgroundColor
    }

    func commonInit() {

        logoImageView.image = UIImage(named: "Check_Email")
        logoImageView.sizeToFit()

        titleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 26)
        titleLabel.text = localized("string_check_email")

        textLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 15)
        textLabel.text = "\(localized("string_check_email_text1")) \(emailUser) \(localized("string_check_email_text2"))"
        textLabel.numberOfLines = 0

        openEmailButton.setTitle(localized("string_insert_email_code"), for: .normal)
        openEmailButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 18)

        resendEmailButton.setTitle(localized("string_resend_email"), for: .normal)
        resendEmailButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 18)

    }

    @IBAction private func openEmailAppAction() {

        let mailURL = URL(string: "message://")!

        if UIApplication.shared.canOpenURL(mailURL) {
            UIApplication.shared.open(mailURL, options: [:], completionHandler: nil)
        }

        let vc = SimpleRegisterSendEmailCodeViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction private func resendEmailAction() {
        // TO-DO: Resend email
    }

}
