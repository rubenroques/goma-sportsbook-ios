//
//  WithdrawViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 21/12/2021.
//

import UIKit
import Combine

class WithdrawViewController: UIViewController {

    // MARK: Private Properties
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
    @IBOutlet private var loadingBaseView: UIView!

    private var cancellables = Set<AnyCancellable>()
    private var viewModel: WithdrawViewModel

    // MARK: Public Properties
    var isLoading: Bool = false {
        didSet {
            if isLoading {
                self.loadingBaseView.isHidden = false
            }
            else {
                self.loadingBaseView.isHidden = true
            }
        }
    }

    var shouldRefreshUserWallet: (() -> Void)?

    // MARK: Lifetime and Cycle
    init() {
        self.viewModel = WithdrawViewModel()
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

    }

    private func commonInit() {
        self.navigationLabel.text = localized("withdraw")
        self.navigationLabel.font = AppFont.with(type: .bold, size: 17)

        self.navigationButton.setTitle(localized("cancel"), for: .normal)
        self.navigationButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.titleLabel.text = localized("how_much_withdraw")
        self.titleLabel.font = AppFont.with(type: .bold, size: 20)
        self.titleLabel.numberOfLines = 0

        self.withdrawHeaderTextFieldView.setPlaceholderText(localized("withdraw_value"))
        self.withdrawHeaderTextFieldView.setKeyboardType(.decimalPad)
        self.withdrawHeaderTextFieldView.setRightLabelCustom(title: "€", font: AppFont.with(type: .semibold, size: 20), color: UIColor.App.textSecondary)

        tipLabel.text = localized("minimum_withdraw_value")
        tipLabel.font = AppFont.with(type: .semibold, size: 12)
        tipLabel.isHidden = true

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

        self.isLoading = false
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.navigationView.backgroundColor = .clear

        self.navigationLabel.textColor = UIColor.App.textPrimary

        self.navigationButton.backgroundColor = .clear
        self.navigationButton.tintColor = UIColor.App.textPrimary

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.withdrawHeaderTextFieldView.backgroundColor = .clear
        self.withdrawHeaderTextFieldView.setPlaceholderColor(UIColor.App.textSecondary)
        self.withdrawHeaderTextFieldView.setTextFieldColor(UIColor.App.textPrimary)

        self.tipLabel.textColor = UIColor.App.textSecondary

        self.nextButton.setBackgroundColor(UIColor.App.highlightPrimary, for: .normal)
        self.nextButton.setBackgroundColor(UIColor.App.buttonDisablePrimary, for: .disabled)
        self.nextButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        self.nextButton.setTitleColor(UIColor.App.textDisablePrimary, for: .disabled)
        self.nextButton.layer.cornerRadius = CornerRadius.button
        self.nextButton.layer.masksToBounds = true

        self.paymentsLabel.textColor = UIColor.App.textSecondary

        self.paymentsLogosStackView.backgroundColor = .clear

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: WithdrawViewModel) {

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
                    self?.showWithdrawWebView(cashierUrl: cashierUrl)
                }
            })
            .store(in: &cancellables)

        viewModel.minimumValue
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] minimumValue in

                if minimumValue != "" {
                    let tipText = localized("minimum_withdraw_value")
                        .replacingOccurrences(of: "{value}", with: minimumValue)
                        .replacingOccurrences(of: "{currency}", with: "€")
                    self?.tipLabel.text = tipText
                    self?.tipLabel.isHidden = false
                }

            })
            .store(in: &cancellables)

        viewModel.showWithdrawalStatus = { [weak self] in

            self?.showAlert()

        }

        viewModel.shouldShowIbanScreen = { [weak self] in
            self?.showIbanScreen()
        }

    }

    // MARK: Functions
    private func createPaymentsLogosImageViews() {
        let visaImageView = UIImageView()
        visaImageView.image = UIImage(named: "payment_visa_icon")
        visaImageView.contentMode = .scaleAspectFit
        visaImageView.layer.masksToBounds = true

        let masterCardImageView = UIImageView()
        masterCardImageView.image = UIImage(named: "payment_mc_icon")
        masterCardImageView.contentMode = .scaleAspectFit
        masterCardImageView.layer.masksToBounds = true

        let carteBancaireImageView = UIImageView()
        carteBancaireImageView.image = UIImage(named: "payment_cartebancaire_icon")
        carteBancaireImageView.contentMode = .scaleAspectFit
        carteBancaireImageView.layer.masksToBounds = true

        let paypalImageView = UIImageView()
        paypalImageView.image = UIImage(named: "payment_paypal_icon")
        paypalImageView.contentMode = .scaleAspectFit
        paypalImageView.layer.masksToBounds = true

        let paysafeImageView = UIImageView()
        paysafeImageView.image = UIImage(named: "payment_paysafecard_icon")
        paysafeImageView.contentMode = .scaleAspectFit
        paysafeImageView.layer.masksToBounds = true

        let sepaImageView = UIImageView()
        sepaImageView.image = UIImage(named: "payment_sepa_icon")
        sepaImageView.contentMode = .scaleAspectFit
        sepaImageView.layer.masksToBounds = true

        self.paymentsLogosStackView.addArrangedSubview(visaImageView)
        self.paymentsLogosStackView.addArrangedSubview(masterCardImageView)
        self.paymentsLogosStackView.addArrangedSubview(carteBancaireImageView)
        self.paymentsLogosStackView.addArrangedSubview(paypalImageView)
        self.paymentsLogosStackView.addArrangedSubview(paysafeImageView)
        self.paymentsLogosStackView.addArrangedSubview(sepaImageView)

    }

    func setupResponsableGamingUnderlineClickableLabel() {

        let fullString = localized("responsible_gaming")

        responsibleGamingLabel.text = fullString
        responsibleGamingLabel.numberOfLines = 0
        responsibleGamingLabel.font = AppFont.with(type: .medium, size: 10)
        responsibleGamingLabel.textColor =  UIColor.App.textSecondary

        let underlineAttriString = NSMutableAttributedString(string: fullString)

        let range1 = (fullString as NSString).range(of: localized("responsible_gambling"))
        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 10), range: range1)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range1)
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
        let stringRange1 = (text as NSString).range(of: localized("responsible_gambling"))
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

        let range1 = (fullString as NSString).range(of: localized("faq"))
        let range2 = (fullString as NSString).range(of: localized("contact_us"))

        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 10), range: range1)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range1)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)

        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .regular, size: 10), range: range2)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.highlightPrimary, range: range2)
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

        let stringRange1 = (text as NSString).range(of: localized("faq"))
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

    private func showErrorAlert(errorType: BalanceErrorType) {
        var errorTitle = ""
        var errorMessage = ""

        switch errorType {
        case .wallet:
            errorTitle = localized("wallet_error")
            errorMessage = localized("wallet_error_message")
        case .withdraw:
            errorTitle = localized("withdraw_error")
            errorMessage = localized("withdraw_error_message")
        case .error(let message):
            errorTitle = localized("withdraw_error")
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

    private func showAlert() {

        let withdrawSuccessViewController = WithdrawSuccessViewController()

        withdrawSuccessViewController.configureInfo(title: localized("withdrawal_request_sent_title"), message: localized("withdrawal_status_message"))

        self.navigationController?.pushViewController(withdrawSuccessViewController, animated: true)
//        let alert = UIAlertController(title: localized("withdrawal_status"),
//                                      message: localized("withdrawal_status_message"),
//                                      preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { _ in
//
//            self.shouldRefreshUserWallet?()
//            self.dismiss(animated: true)
//
//        }))
//        self.present(alert, animated: true, completion: nil)
    }

    private func showWithdrawWebView(cashierUrl: String) {
        let withdrawWebViewController = WithdrawWebViewController(withdrawUrl: cashierUrl)

        self.navigationController?.pushViewController(withdrawWebViewController, animated: true)

    }

    private func showIbanScreen() {
        print("SHOW IBAN")

        let amountText = self.withdrawHeaderTextFieldView.text

        let ibanProofViewModel = IBANProofViewModel(withdrawAmount: amountText)

        let ibanProofViewController = IBANProofViewController(viewModel: ibanProofViewModel)

        self.navigationController?.pushViewController(ibanProofViewController, animated: true)
    }

    @IBAction private func didTapCloseButton() {
        if presentingViewController != nil {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction private func didTapNextButton() {

        let amountText = self.withdrawHeaderTextFieldView.text

        self.viewModel.getWithdrawInfo(amountText: amountText)

    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.withdrawHeaderTextFieldView.resignFirstResponder()

    }

}
