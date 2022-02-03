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

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App2.backgroundPrimary
        containerView.backgroundColor = UIColor.App2.backgroundPrimary
        backView.backgroundColor = UIColor.App2.backgroundPrimary
        titleLabel.textColor = UIColor.App2.textPrimary
        textLabel.textColor = UIColor.App2.textPrimary

        openEmailButton.setTitleColor(UIColor.App2.textPrimary, for: .normal)
        openEmailButton.backgroundColor = UIColor.App2.buttonBackgroundPrimary
        openEmailButton.cornerRadius = CornerRadius.button


        openEmailButton.setTitleColor(UIColor.App2.textPrimary, for: .normal)
        openEmailButton.setTitleColor(UIColor.white.withAlphaComponent(0.7), for: .highlighted)
        openEmailButton.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .disabled)

        openEmailButton.backgroundColor = .clear
        openEmailButton.setBackgroundColor(UIColor.App2.buttonBackgroundPrimary, for: .normal)
        openEmailButton.setBackgroundColor(UIColor.App2.buttonBackgroundPrimary, for: .highlighted)
        openEmailButton.layer.cornerRadius = CornerRadius.button
        openEmailButton.layer.masksToBounds = true

    }

    func commonInit() {

        logoImageView.image = UIImage(named: "check_email_box_icon")
        logoImageView.sizeToFit()

        titleLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 26)
        titleLabel.text = localized("check_email")

        textLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 15)
        textLabel.text = "\(localized("check_email_text1")) \(emailUser) \(localized("check_email_text2"))"
        textLabel.numberOfLines = 0

        openEmailButton.setTitle(localized("continue_"), for: .normal)
        openEmailButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.bold, size: 18)
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
