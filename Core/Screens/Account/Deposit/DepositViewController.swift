//
//  DepositViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 17/12/2021.
//

import UIKit
import Combine
import ServicesProvider
import Adyen
import AdyenDropIn
import AdyenComponents

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
    @IBOutlet private var depositTipLabel: UILabel!
    @IBOutlet private var loadingBaseView: UIView!
    @IBOutlet private var activityIndicatorView: UIActivityIndicatorView!

    private var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.loadingBaseView.isHidden = false
            }
            else {
                self.loadingBaseView.isHidden = true
            }
        }
    }

    private var viewModel: DepositViewModel

    // MARK: Public Properties
    var currentSelectedButton: UIButton?
    var cancellables = Set<AnyCancellable>()

    var dropInComponent: DropInComponent?

    // MARK: Lifetime and Cycle
    init() {
        self.viewModel = DepositViewModel()
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.commonInit()
        self.setupWithTheme()

        self.bind(toViewModel: self.viewModel)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

    }

    func commonInit() {

        self.navigationLabel.text = localized("deposit")
        self.navigationLabel.font = AppFont.with(type: .bold, size: 17)

        self.navigationButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.navigationButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 17)
        self.navigationButton.setTitle(localized("cancel"), for: .normal)

        self.titleLabel.text = localized("how_much_deposit")
        self.titleLabel.font = AppFont.with(type: .bold, size: 20)
        self.titleLabel.numberOfLines = 0

        self.depositHeaderTextFieldView.setPlaceholderText(localized("deposit_value"))
        self.depositHeaderTextFieldView.setKeyboardType(.decimalPad)
        self.depositHeaderTextFieldView.setRightLabelCustom(title: "€", font: AppFont.with(type: .semibold, size: 20), color: UIColor.App.textSecondary)

        depositTipLabel.text = localized("minimum_deposit_value")
        depositTipLabel.font = AppFont.with(type: .semibold, size: 12)
        depositTipLabel.isHidden = true

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

        self.isLoading = false
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = .clear

        self.navigationLabel.textColor = UIColor.App.textPrimary

        self.navigationButton.backgroundColor = .clear
        self.navigationButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.depositHeaderTextFieldView.backgroundColor = .clear
        self.depositHeaderTextFieldView.setPlaceholderColor(UIColor.App.textSecondary)
        self.depositHeaderTextFieldView.setTextFieldColor(UIColor.App.textPrimary)

        self.depositTipLabel.textColor = UIColor.App.textSecondary

        self.amountButtonStackView.backgroundColor = .clear

        self.nextButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        self.nextButton.setBackgroundColor(UIColor.App.buttonDisablePrimary, for: .disabled)
        self.nextButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.nextButton.setTitleColor(UIColor.App.buttonTextDisablePrimary, for: .disabled)
        self.nextButton.layer.cornerRadius = CornerRadius.button
        self.nextButton.layer.masksToBounds = true

        self.paymentsLabel.textColor = UIColor.App.textSecondary

        self.paymentsLogosStackView.backgroundColor = .clear

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: DepositViewModel) {

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                self?.isLoading = isLoading
            })
            .store(in: &cancellables)

        viewModel.showErrorAlertTypePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] errorAlertType in
                if let errorAlertType = errorAlertType {
                    self?.showErrorAlert(errorType: errorAlertType)
                }
            })
            .store(in: &cancellables)

        viewModel.cashierUrlPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] cashierUrl in
                if let cashierUrl = cashierUrl {
                    self?.showDepositWebView(cashierUrl: cashierUrl)
                }
            })
            .store(in: &cancellables)

        viewModel.shouldShowPaymentDropIn
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] shouldShow in
                if shouldShow {
                    self?.getPaymentDropIn()
                }
            })
            .store(in: &cancellables)

        viewModel.paymentsDropIn.showPaymentStatus = { [weak self] paymentStatus in
            
            self?.showPaymentStatusAlert(paymentStatus: paymentStatus)
        }

        viewModel.minimumValue
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] minimumValue in
                let depositTipText = localized("minimum_deposit_value").replacingFirstOccurrence(of: "%s", with: minimumValue)
                self?.depositTipLabel.text = depositTipText
                self?.depositTipLabel.isHidden = false
            })
            .store(in: &cancellables)
    }

    // MARK: Functions
    private func setupPublishers() {
        self.depositHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkUserInputs()
            })
            .store(in: &cancellables)

    }

    private func getPaymentDropIn() {

        if let paymentDropIn = self.viewModel.paymentsDropIn.setupPaymentDropIn() {

            self.dropInComponent = paymentDropIn

            present(paymentDropIn.viewController, animated: true)
        }

    }

    private func createPaymentsLogosImageViews() {
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

    private func setupResponsableGamingUnderlineClickableLabel() {

        let fullString = localized("responsible_gaming")

        responsibleGamingLabel.text = fullString
        responsibleGamingLabel.numberOfLines = 0
        responsibleGamingLabel.font = AppFont.with(type: .medium, size: 10)
        responsibleGamingLabel.textColor =  UIColor.App.textSecondary

        let underlineAttriString = NSMutableAttributedString(string: fullString)

        let range1 = (fullString as NSString).range(of: localized("responsible_gaming_clickable"))

        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 10), range: range1)

        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.buttonBackgroundPrimary, range: range1)

        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)

        let paragraphStyle = NSMutableParagraphStyle()

        paragraphStyle.lineHeightMultiple = TextSpacing.subtitle
        paragraphStyle.alignment = .left

        underlineAttriString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: underlineAttriString.length))

        responsibleGamingLabel.attributedText = underlineAttriString
        responsibleGamingLabel.isUserInteractionEnabled = true
        responsibleGamingLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapResponsabibleGamingUnderlineLabel(gesture:))))
    }

    private func showPaymentStatusAlert(paymentStatus: PaymentStatus) {
        var alertTitle = ""
        var alertMessage = ""

        switch paymentStatus {
        case .authorised:
            alertTitle = "Payment Authorized"
            alertMessage = "Your payment was authorized. Your deposit should be available in your account."
        case .refused:
            alertTitle = "Payment Refused"
            alertMessage = "Your payment was refused. Please try again later. If the problem persists contact our Customer Support."
        }

        let alert = UIAlertController(title: alertTitle,
                                      message: alertMessage,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in

            if paymentStatus == .authorised {
                self.dismiss(animated: true)
            }
        }))
        self.present(alert, animated: true, completion: nil)
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
        faqLabel.textColor =  UIColor.App.textSecondary

        let underlineAttriString = NSMutableAttributedString(string: fullString)

        let range1 = (fullString as NSString).range(of: localized("faq_clickable"))
        let range2 = (fullString as NSString).range(of: localized("contact_us"))

        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 10), range: range1)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.buttonBackgroundPrimary, range: range1)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)

        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 10), range: range2)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.buttonBackgroundPrimary, range: range2)
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
                self.amount10Button.backgroundColor = UIColor.App.buttonBackgroundPrimary
                self.amount10Button.layer.borderColor = UIColor.App.buttonBackgroundPrimary.cgColor
                currentSelectedButton = self.amount10Button
            }
            else if depositHeaderTextFieldView.text == "20" {
                self.amount20Button.backgroundColor = UIColor.App.buttonBackgroundPrimary
                self.amount20Button.layer.borderColor = UIColor.App.buttonBackgroundPrimary.cgColor
                currentSelectedButton = self.amount20Button
            }
            else if depositHeaderTextFieldView.text == "50" {
                self.amount50Button.backgroundColor = UIColor.App.buttonBackgroundPrimary
                self.amount50Button.layer.borderColor = UIColor.App.buttonBackgroundPrimary.cgColor
                currentSelectedButton = self.amount50Button
            }
            else if depositHeaderTextFieldView.text == "100" {
                self.amount100Button.backgroundColor = UIColor.App.buttonBackgroundPrimary
                self.amount100Button.layer.borderColor = UIColor.App.buttonBackgroundPrimary.cgColor
                currentSelectedButton = self.amount100Button
            }
            else {
                self.amount10Button.backgroundColor = .clear
                self.amount10Button.layer.borderColor = UIColor.App.backgroundSecondary.cgColor

                self.amount20Button.backgroundColor = .clear
                self.amount20Button.layer.borderColor = UIColor.App.backgroundSecondary.cgColor

                self.amount50Button.backgroundColor = .clear
                self.amount50Button.layer.borderColor = UIColor.App.backgroundSecondary.cgColor

                self.amount100Button.backgroundColor = .clear
                self.amount100Button.layer.borderColor = UIColor.App.backgroundSecondary.cgColor
            }
        }
        else {
            self.nextButton.isEnabled = false
        }
    }

    func setDepositAmountButtonDesign(button: UIButton, title: String) {

        StyleHelper.styleButton(button: button)

        button.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        button.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.App.backgroundSecondary.cgColor

        button.setTitle(title, for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)

    }

    private func checkForHighlightedAmountButton() {
        if currentSelectedButton != nil {
            currentSelectedButton?.backgroundColor = .clear
            currentSelectedButton?.layer.borderColor = UIColor.App.backgroundSecondary.cgColor
        }
    }

    private func showRightLabelCustom() {
        if self.depositHeaderTextFieldView.text != "" {
            self.depositHeaderTextFieldView.showPasswordLabelVisible(visible: true)
        }
    }

    private func showDepositWebView(cashierUrl: String) {
        let depositWebViewController = DepositWebViewController(depositUrl: cashierUrl)
        self.navigationController?.pushViewController(depositWebViewController, animated: true)
    }

    @IBAction private func didTap10Button() {
        self.checkForHighlightedAmountButton()

        self.amount10Button.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.amount10Button.layer.borderColor = UIColor.App.buttonBackgroundPrimary.cgColor

        self.currentSelectedButton = self.amount10Button

        self.depositHeaderTextFieldView.setText("10")
        self.nextButton.isEnabled = true
        self.showRightLabelCustom()
    }
    @IBAction private func didTap20Button() {
        self.checkForHighlightedAmountButton()

        self.amount20Button.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.amount20Button.layer.borderColor = UIColor.App.buttonBackgroundPrimary.cgColor

        self.currentSelectedButton = self.amount20Button

        self.depositHeaderTextFieldView.setText("20")
        self.nextButton.isEnabled = true
        self.showRightLabelCustom()

    }

    @IBAction private func didTap50Button() {
        self.checkForHighlightedAmountButton()

        self.amount50Button.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.amount50Button.layer.borderColor = UIColor.App.buttonBackgroundPrimary.cgColor

        self.currentSelectedButton = self.amount50Button

        self.depositHeaderTextFieldView.setText("50")
        self.nextButton.isEnabled = true
        self.showRightLabelCustom()
    }

    @IBAction private func didTap100Button() {
        self.checkForHighlightedAmountButton()

        self.amount100Button.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.amount100Button.layer.borderColor = UIColor.App.buttonBackgroundPrimary.cgColor

        self.currentSelectedButton = self.amount100Button

        self.depositHeaderTextFieldView.setText("100")
        self.nextButton.isEnabled = true
        self.showRightLabelCustom()
    }

    @IBAction private func didTapNextButton() {
        let amountText = self.depositHeaderTextFieldView.text

        self.viewModel.getDepositInfo(amountText: amountText)
    }

    func showErrorAlert(errorType: BalanceErrorType) {

        var errorTitle = ""
        var errorMessage = ""

        switch errorType {
        case .wallet:
            errorTitle = localized("wallet_error")
            errorMessage = localized("wallet_error_message")
        case .deposit:
            errorTitle = localized("deposit_error")
            errorMessage = localized("deposit_error_message")
        case .error(let message):
            errorTitle = localized("deposit_error")
            errorMessage = message
        default:
            ()
        }

        let alert = UIAlertController(title: errorTitle,
                                      message: errorMessage,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction private func didTapCloseButton() {
        if presentingViewController != nil {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        else {
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

enum BalanceErrorType {
    case wallet
    case deposit
    case withdraw
    case error(message: String)
}
