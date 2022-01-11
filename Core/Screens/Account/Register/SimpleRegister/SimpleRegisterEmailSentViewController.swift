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

        commonInit()
        setupWithTheme()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackground
        containerView.backgroundColor = UIColor.App.mainBackground
        backView.backgroundColor = UIColor.App.mainBackground
        titleLabel.textColor = UIColor.App.headingMain
        textLabel.textColor = UIColor.App.headingMain

        openEmailButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        openEmailButton.backgroundColor = UIColor.App.primaryButtonNormal
        openEmailButton.cornerRadius = CornerRadius.button

        resendEmailButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        resendEmailButton.backgroundColor = UIColor.App.mainBackground

        openEmailButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        openEmailButton.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .highlighted)
        openEmailButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)

        openEmailButton.backgroundColor = .clear
        openEmailButton.setBackgroundColor(UIColor.App.primaryButtonNormal, for: .normal)
        openEmailButton.setBackgroundColor(UIColor.App.primaryButtonPressed, for: .highlighted)
        openEmailButton.layer.cornerRadius = CornerRadius.button
        openEmailButton.layer.masksToBounds = true

    }

    func commonInit() {

        logoImageView.image = UIImage(named: "check_email_box_icon")
        logoImageView.sizeToFit()

        titleLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 26)
        titleLabel.text = localized("string_check_email")

        textLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 15)
        textLabel.text = "\(localized("string_check_email_text1")) \(emailUser) \(localized("string_check_email_text2"))"
        textLabel.numberOfLines = 0

        openEmailButton.setTitle(localized("string_continue_"), for: .normal)
        openEmailButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 18)

        resendEmailButton.setTitle(localized("string_resend_email"), for: .normal)
        resendEmailButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 15)

    }

    @IBAction private func openEmailAppAction() {

        if self.isModal {
            self.dismiss(animated: true, completion: nil)
        }
        else {
            let mainScreenViewController = Router.mainScreenViewController()
            self.navigationController?.pushViewController(mainScreenViewController, animated: true)
        }
    }

    @IBAction private func resendEmailAction() {
        // TO-DO: Resend email
    }

}
