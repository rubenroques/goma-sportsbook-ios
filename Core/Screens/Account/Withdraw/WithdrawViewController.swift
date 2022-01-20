//
//  WithdrawViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 21/12/2021.
//

import UIKit
import Combine

class WithdrawViewController: UIViewController {

    @IBOutlet private var topView: UIView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var navigationView: UIView!
    @IBOutlet private var navigationLabel: UILabel!
    @IBOutlet private var navigationButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var withdrawHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var tipLabel: UILabel!
    @IBOutlet private var nextButton: UIButton!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var paymentsLabel: UILabel!
    @IBOutlet private var paymentsLogosStackView: UIStackView!
    @IBOutlet private var responsibleGamingLabel: UILabel!
    @IBOutlet private var faqLabel: UILabel!

    // Variables
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.commonInit()
        self.setupWithTheme()

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func commonInit() {
        self.navigationLabel.text = localized("withdraw")
        self.navigationLabel.font = AppFont.with(type: .bold, size: 17)

        self.navigationButton.setImage(UIImage(named: "thin_close_cross_icon"), for: .normal)
        self.navigationButton.contentMode = .scaleAspectFit

        self.titleLabel.text = localized("how_much_withdraw")
        self.titleLabel.font = AppFont.with(type: .bold, size: 20)
        self.titleLabel.numberOfLines = 0

        self.withdrawHeaderTextFieldView.setPlaceholderText(localized("withdraw_value"))
        self.withdrawHeaderTextFieldView.setKeyboardType(.decimalPad)
        self.withdrawHeaderTextFieldView.setRightLabelCustom(title: "€", font: AppFont.with(type: .semibold, size: 20), color: UIColor.App.headingSecondary)

        tipLabel.text = localized("minimum_withdraw_value")
        tipLabel.font = AppFont.with(type: .semibold, size: 12)

        StyleHelper.styleButton(button: self.nextButton)
        self.nextButton.setTitle(localized("next"), for: .normal)
        self.nextButton.isEnabled = false
        self.nextButton.titleLabel?.font = AppFont.with(type: .bold, size: 16)

        self.paymentsLabel.text = localized("payments_available")
        self.paymentsLabel.font = AppFont.with(type: .medium, size: 12)

        self.createPaymentsLogosImageViews()

        self.setupResponsableGamingUnderlineClickableLabel()
        self.setupFaqUnderlineClickableLabel()

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        self.setupPublishers()

        self.activityIndicatorView.isHidden = true

    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackground

        self.topView.backgroundColor = UIColor.App.mainBackground

        self.containerView.backgroundColor = UIColor.App.mainBackground

        self.navigationView.backgroundColor = .clear

        self.navigationLabel.textColor = UIColor.App.headingMain

        self.navigationButton.backgroundColor = .clear
        self.navigationButton.tintColor = UIColor.App.headingMain

        self.titleLabel.textColor = UIColor.App.headingMain

        self.withdrawHeaderTextFieldView.backgroundColor = .clear
        self.withdrawHeaderTextFieldView.setPlaceholderColor(UIColor.App.headingSecondary)
        self.withdrawHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        self.tipLabel.textColor = UIColor.App.headingSecondary

        self.nextButton.setBackgroundColor(UIColor.App.mainTint, for: .normal)
        self.nextButton.setBackgroundColor(UIColor.App.contentBackground, for: .disabled)
        self.nextButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        self.nextButton.setTitleColor(UIColor.App.headingDisabled, for: .disabled)
        self.nextButton.layer.cornerRadius = CornerRadius.button
        self.nextButton.layer.masksToBounds = true

        self.paymentsLabel.textColor = UIColor.App.headingSecondary

        self.paymentsLogosStackView.backgroundColor = .clear
    }

    func createPaymentsLogosImageViews() {
        let mastercardImageView = UIImageView()
        mastercardImageView.image = UIImage(named: "mastercard_logo")
        mastercardImageView.contentMode = .scaleAspectFit

        let maestroImageView = UIImageView()
        maestroImageView.image = UIImage(named: "maestro_logo")
        maestroImageView.contentMode = .scaleAspectFit

        let visaImageView = UIImageView()
        visaImageView.image = UIImage(named: "visa_logo")
        visaImageView.contentMode = .scaleAspectFit

        let netellerImageView = UIImageView()
        netellerImageView.image = UIImage(named: "neteller_logo")
        netellerImageView.contentMode = .scaleAspectFit

        self.paymentsLogosStackView.addArrangedSubview(mastercardImageView)
        self.paymentsLogosStackView.addArrangedSubview(maestroImageView)
        self.paymentsLogosStackView.addArrangedSubview(visaImageView)
        self.paymentsLogosStackView.addArrangedSubview(netellerImageView)

    }

    func setupResponsableGamingUnderlineClickableLabel() {

        let fullString = localized("responsible_gaming")

        responsibleGamingLabel.text = fullString
        responsibleGamingLabel.numberOfLines = 0
        responsibleGamingLabel.font = AppFont.with(type: .medium, size: 10)
        responsibleGamingLabel.textColor =  UIColor.App.headingSecondary

        let underlineAttriString = NSMutableAttributedString(string: fullString)

        let range1 = (fullString as NSString).range(of: localized("responsible_gaming_clickable"))

        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 10), range: range1)

        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.mainTint, range: range1)

        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.alignment = .left

        underlineAttriString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: underlineAttriString.length))

        responsibleGamingLabel.attributedText = underlineAttriString
        responsibleGamingLabel.isUserInteractionEnabled = true
        responsibleGamingLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapResponsabibleGamingUnderlineLabel(gesture:))))
    }

    @IBAction private func tapResponsabibleGamingUnderlineLabel(gesture: UITapGestureRecognizer) {
        let text = localized("responsible_gaming")

        let stringRange1 = (text as NSString).range(of: localized("responsible_gaming_clickable"))

        if gesture.didTapAttributedTextInLabel(label: self.responsibleGamingLabel, inRange: stringRange1, alignment: .left) {
            // Action
        }

    }

    func setupFaqUnderlineClickableLabel() {

        let fullString = localized("faq")

        faqLabel.text = fullString
        faqLabel.numberOfLines = 0
        faqLabel.font = AppFont.with(type: .medium, size: 10)
        faqLabel.textColor =  UIColor.App.headingSecondary

        let underlineAttriString = NSMutableAttributedString(string: fullString)

        let range1 = (fullString as NSString).range(of: localized("faq_clickable"))
        let range2 = (fullString as NSString).range(of: localized("contact_us"))

        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 10), range: range1)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.mainTint, range: range1)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)

        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 10), range: range2)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.mainTint, range: range2)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range2)

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.alignment = .left

        underlineAttriString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: underlineAttriString.length))

        faqLabel.attributedText = underlineAttriString
        faqLabel.isUserInteractionEnabled = true
        faqLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapFaqUnderlineLabel(gesture:))))
    }

    @IBAction private func tapFaqUnderlineLabel(gesture: UITapGestureRecognizer) {
        let text = localized("faq")

        let stringRange1 = (text as NSString).range(of: localized("faq_clickable"))
        let stringRange2 = (text as NSString).range(of: localized("contact_us"))

        if gesture.didTapAttributedTextInLabel(label: self.faqLabel, inRange: stringRange1, alignment: .left) {
            // Action
        }
        else if gesture.didTapAttributedTextInLabel(label: self.faqLabel, inRange: stringRange2, alignment: .left) {
            // Action
        }

    }

    func setupPublishers() {
        self.withdrawHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkUserInputs()
            })
            .store(in: &cancellables)
    }

    private func checkUserInputs() {

        let withdrawText = withdrawHeaderTextFieldView.text == "" ? false : true

        if withdrawText {
            self.nextButton.isEnabled = true
        }
        else {
            self.nextButton.isEnabled = false
        }

    }

    func showErrorAlert() {
        let alert = UIAlertController(title: localized("wallet_error"),
                                      message: localized("wallet_error_message"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction private func didTapCloseButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func didTapNextButton() {
        self.activityIndicatorView.isHidden = false

        let amount = self.withdrawHeaderTextFieldView.text
        var currency = ""
        var gamingAccountId = ""

        if let walletCurrency = Env.userSessionStore.userBalanceWallet.value?.currency {
            currency = walletCurrency
        }
        else {
            self.showErrorAlert()
            self.activityIndicatorView.isHidden = true
        }

        if let walletGamingAccountId = Env.userSessionStore.userBalanceWallet.value?.id {
            gamingAccountId = "\(walletGamingAccountId)"
        }
        else {
            self.showErrorAlert()
            self.activityIndicatorView.isHidden = true
        }

        Env.everyMatrixClient.getWithdrawResponse(currency: currency, amount: amount, gamingAccountId: gamingAccountId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                self.activityIndicatorView.isHidden = true

            }, receiveValue: { value in
                DispatchQueue.main.async {
                    let withdrawWebViewController = WithdrawWebViewController(withdrawUrl: value.cashierUrl)

                    self.navigationController?.pushViewController(withdrawWebViewController, animated: true)
                }
            })
            .store(in: &cancellables)
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.withdrawHeaderTextFieldView.resignFirstResponder()

    }

}
