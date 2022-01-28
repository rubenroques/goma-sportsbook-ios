//
//  DepositViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 17/12/2021.
//

import UIKit
import Combine

class DepositViewController: UIViewController {

    @IBOutlet private var topView: UIView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var navigationView: UIView!
    @IBOutlet private var navigationLabel: UILabel!
    @IBOutlet private var navigationButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var depositHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var amountButtonStackView: UIStackView!
    @IBOutlet private var amount10Button: UIButton!
    @IBOutlet private var amount20Button: UIButton!
    @IBOutlet private var amount50Button: UIButton!
    @IBOutlet private var amount100Button: UIButton!
    @IBOutlet private var nextButton: UIButton!
    @IBOutlet private var paymentsLabel: UILabel!
    @IBOutlet private var paymentsLogosStackView: UIStackView!
    @IBOutlet private var responsibleGamingLabel: UILabel!
    @IBOutlet private var faqLabel: UILabel!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var depositTipLabel: UILabel!

    // Variables
    var currentSelectedButton: UIButton?
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.commonInit()
        self.setupWithTheme()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func commonInit() {

        self.navigationLabel.text = localized("deposit")
        self.navigationLabel.font = AppFont.with(type: .bold, size: 17)

        self.navigationButton.setImage(UIImage(named: "thin_close_cross_icon"), for: .normal)
        self.navigationButton.contentMode = .scaleAspectFit

        self.titleLabel.text = localized("how_much_deposit")
        self.titleLabel.font = AppFont.with(type: .bold, size: 20)
        self.titleLabel.numberOfLines = 0

        self.depositHeaderTextFieldView.setPlaceholderText(localized("deposit_value"))
        self.depositHeaderTextFieldView.setKeyboardType(.decimalPad)
        self.depositHeaderTextFieldView.setRightLabelCustom(title: "€", font: AppFont.with(type: .semibold, size: 20), color: UIColor.App2.inputBackground)

        depositTipLabel.text = localized("minimum_deposit_value")
        depositTipLabel.font = AppFont.with(type: .semibold, size: 12)

        self.setDepositAmountButtonDesign(button: self.amount10Button, title: "€10")
        self.setDepositAmountButtonDesign(button: self.amount20Button, title: "€20")
        self.setDepositAmountButtonDesign(button: self.amount50Button, title: "€50")
        self.setDepositAmountButtonDesign(button: self.amount100Button, title: "€100")

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
        self.view.backgroundColor = UIColor.App2.backgroundPrimary

        self.topView.backgroundColor = UIColor.App2.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App2.backgroundPrimary

        self.navigationView.backgroundColor = .clear

        self.navigationLabel.textColor = UIColor.App2.textPrimary

        self.navigationButton.backgroundColor = .clear
        self.navigationButton.tintColor = UIColor.App2.textPrimary

        self.titleLabel.textColor = UIColor.App2.textPrimary

        self.depositHeaderTextFieldView.backgroundColor = .clear
        self.depositHeaderTextFieldView.setPlaceholderColor(UIColor.App2.textSecond)
        self.depositHeaderTextFieldView.setTextFieldColor(UIColor.App2.textPrimary)

        self.depositTipLabel.textColor = UIColor.App2.textSecond

        self.amountButtonStackView.backgroundColor = .clear

        self.nextButton.setBackgroundColor(UIColor.App2.buttonBackgroundPrimary, for: .normal)
        self.nextButton.setBackgroundColor(UIColor.App2.buttonDisablePrimary, for: .disabled)
        self.nextButton.setTitleColor(UIColor.App2.textPrimary, for: .normal)
        self.nextButton.setTitleColor(UIColor.App2.buttonTextDisablePrimary, for: .disabled)
        self.nextButton.layer.cornerRadius = CornerRadius.button
        self.nextButton.layer.masksToBounds = true

        self.paymentsLabel.textColor = UIColor.App2.textSecond

        self.paymentsLogosStackView.backgroundColor = .clear
    }

    func setupPublishers() {
        self.depositHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkUserInputs()
            })
            .store(in: &cancellables)
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
        responsibleGamingLabel.textColor =  UIColor.App2.textSecond

        let underlineAttriString = NSMutableAttributedString(string: fullString)

        let range1 = (fullString as NSString).range(of: localized("responsible_gaming_clickable"))

        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 10), range: range1)

        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App2.buttonBackgroundPrimary, range: range1)

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
        faqLabel.textColor =  UIColor.App2.textSecond

        let underlineAttriString = NSMutableAttributedString(string: fullString)

        let range1 = (fullString as NSString).range(of: localized("faq_clickable"))
        let range2 = (fullString as NSString).range(of: localized("contact_us"))

        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 10), range: range1)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App2.buttonBackgroundPrimary, range: range1)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)

        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 10), range: range2)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App2.buttonBackgroundPrimary, range: range2)
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

    private func checkUserInputs() {

        let depositText = depositHeaderTextFieldView.text == "" ? false : true

        if depositText {
            self.nextButton.isEnabled = true
            self.checkForHighlightedAmountButton()

            if depositHeaderTextFieldView.text == "10" {
                self.amount10Button.backgroundColor = UIColor.App2.buttonBackgroundPrimary
                self.amount10Button.layer.borderColor = UIColor.App2.buttonBackgroundPrimary.cgColor
                currentSelectedButton = self.amount10Button
            }
            else if depositHeaderTextFieldView.text == "20" {
                self.amount20Button.backgroundColor = UIColor.App2.buttonBackgroundPrimary
                self.amount20Button.layer.borderColor = UIColor.App2.buttonBackgroundPrimary.cgColor
                currentSelectedButton = self.amount20Button

            }
            else if depositHeaderTextFieldView.text == "50" {
                self.amount50Button.backgroundColor = UIColor.App2.buttonBackgroundPrimary
                self.amount50Button.layer.borderColor = UIColor.App2.buttonBackgroundPrimary.cgColor
                currentSelectedButton = self.amount50Button

            }
            else if depositHeaderTextFieldView.text == "100" {
                self.amount100Button.backgroundColor = UIColor.App2.buttonBackgroundPrimary
                self.amount100Button.layer.borderColor = UIColor.App2.buttonBackgroundPrimary.cgColor
                currentSelectedButton = self.amount100Button

            }
            else {
                self.amount10Button.backgroundColor = .clear
                self.amount10Button.layer.borderColor = UIColor.App2.backgroundSecondary.cgColor

                self.amount20Button.backgroundColor = .clear
                self.amount20Button.layer.borderColor = UIColor.App2.backgroundSecondary.cgColor

                self.amount50Button.backgroundColor = .clear
                self.amount50Button.layer.borderColor = UIColor.App2.backgroundSecondary.cgColor

                self.amount100Button.backgroundColor = .clear
                self.amount100Button.layer.borderColor = UIColor.App2.backgroundSecondary.cgColor

            }
        }
        else {
            self.nextButton.isEnabled = false
        }

    }

    func setDepositAmountButtonDesign(button: UIButton, title: String) {

        StyleHelper.styleButton(button: button)

        button.setTitleColor(UIColor.App2.textPrimary, for: .normal)
        button.setBackgroundColor(.clear, for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.App2.backgroundSecondary.cgColor

        button.setTitle(title, for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)

    }

    func checkForHighlightedAmountButton() {
        if currentSelectedButton != nil {
            currentSelectedButton?.backgroundColor = .clear
            currentSelectedButton?.layer.borderColor = UIColor.App2.backgroundSecondary.cgColor
        }
    }

    func showRightLabelCustom() {
        if self.depositHeaderTextFieldView.text != "" {
            self.depositHeaderTextFieldView.showPasswordLabelVisible(visible: true)
        }
    }

    @IBAction private func didTap10Button() {
        self.checkForHighlightedAmountButton()

        self.amount10Button.backgroundColor = UIColor.App2.buttonBackgroundPrimary
        self.amount10Button.layer.borderColor = UIColor.App2.buttonBackgroundPrimary.cgColor

        self.currentSelectedButton = self.amount10Button

        self.depositHeaderTextFieldView.setText("10")
        self.nextButton.isEnabled = true
        self.showRightLabelCustom()
    }
    @IBAction private func didTap20Button() {
        self.checkForHighlightedAmountButton()

        self.amount20Button.backgroundColor = UIColor.App2.buttonBackgroundPrimary
        self.amount20Button.layer.borderColor = UIColor.App2.buttonBackgroundPrimary.cgColor

        self.currentSelectedButton = self.amount20Button

        self.depositHeaderTextFieldView.setText("20")
        self.nextButton.isEnabled = true
        self.showRightLabelCustom()

    }

    @IBAction private func didTap50Button() {
        self.checkForHighlightedAmountButton()

        self.amount50Button.backgroundColor = UIColor.App2.buttonBackgroundPrimary
        self.amount50Button.layer.borderColor = UIColor.App2.buttonBackgroundPrimary.cgColor

        self.currentSelectedButton = self.amount50Button

        self.depositHeaderTextFieldView.setText("50")
        self.nextButton.isEnabled = true
        self.showRightLabelCustom()

    }

    @IBAction private func didTap100Button() {
        self.checkForHighlightedAmountButton()

        self.amount100Button.backgroundColor = UIColor.App2.buttonBackgroundPrimary
        self.amount100Button.layer.borderColor = UIColor.App2.buttonBackgroundPrimary.cgColor

        self.currentSelectedButton = self.amount100Button

        self.depositHeaderTextFieldView.setText("100")
        self.nextButton.isEnabled = true
        self.showRightLabelCustom()

    }

    @IBAction private func didTapNextButton() {
        self.activityIndicatorView.isHidden = false

        let amount = self.depositHeaderTextFieldView.text
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

        Env.everyMatrixClient.getDepositResponse(currency: currency, amount: amount, gamingAccountId: gamingAccountId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in
                self.activityIndicatorView.isHidden = true

            }, receiveValue: { value in
                DispatchQueue.main.async {
                    let depositWebViewController = DepositWebViewController(depositUrl: value.cashierUrl)

                    self.navigationController?.pushViewController(depositWebViewController, animated: true)
                }
            })
            .store(in: &cancellables)
    }

    func showErrorAlert() {
        let alert = UIAlertController(title: localized("wallet_error"),
                                      message: localized("wallet_error_message"),
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction private func didTapCloseButton() {
        if presentingViewController != nil {
                  // foi presented porque tem um presentingViewController
                self.navigationController?.dismiss(animated: true, completion: nil)
              }
              else {
                  // foi pushed
                  self.navigationController?.popViewController(animated: true)
              }
        
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.depositHeaderTextFieldView.resignFirstResponder()

    }

    @objc func keyboardWillShow(notification: NSNotification) {

    }

    @objc func keyboardWillHide(notification: NSNotification) {

        self.checkForHighlightedAmountButton()
        self.currentSelectedButton = nil
    }

}
