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
import Lottie

class DepositViewController: UIViewController {

    @IBOutlet private var topView: UIView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var navigationView: GradientView!
    @IBOutlet private var navigationLabel: UILabel!
    @IBOutlet private var navigationButton: UIButton!

    @IBOutlet private var backgroundGradientView: GradientView!
    @IBOutlet private var animationBaseView: UIView!
    @IBOutlet private var shapeView: UIView!
    @IBOutlet private var titleLabel: UILabel!

    @IBOutlet private var bonusContentView: UIView!
    @IBOutlet private var bonusIconImageView: UIImageView!
    @IBOutlet private var bonusTitleLabel: UILabel!
    @IBOutlet private var bonusInfoLabel: UILabel!
    @IBOutlet private var bonusDetailLabel: UILabel!
    @IBOutlet private var acceptBonusView: OptionRadioView!
    @IBOutlet private var declineBonusView: OptionRadioView!

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

    @IBOutlet private var bonusHeightConstraint: NSLayoutConstraint!

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

    private var disableAmountButtons: Bool = false {
        didSet {
            self.amount10Button.isEnabled = !disableAmountButtons
            self.amount20Button.isEnabled = !disableAmountButtons
            self.amount50Button.isEnabled = !disableAmountButtons
            self.amount100Button.isEnabled = !disableAmountButtons
        }
    }

    private var viewModel: DepositViewModel

    // MARK: Public Properties
    var currentSelectedButton: UIButton?
    var cancellables = Set<AnyCancellable>()

    var dropInComponent: DropInComponent?

    var shouldRefreshUserWallet: (() -> Void)?

    var hasBonus: Bool = false {
        didSet {
            self.bonusContentView.isHidden = !hasBonus

            if !hasBonus {
                self.bonusHeightConstraint.isActive = true
                self.bonusContentView.layoutIfNeeded()
            }

        }
    }

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

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        self.bonusContentView.layer.cornerRadius = CornerRadius.view

        self.bonusContentView.setNeedsLayout()
        self.bonusContentView.layoutIfNeeded()

        self.navigationView.startPoint = CGPoint(x: 0.0, y: 0.0)
        self.navigationView.endPoint = CGPoint(x: 2.0, y: 0.0)

        self.backgroundGradientView.startPoint = CGPoint(x: 0.0, y: 0.0)
        self.backgroundGradientView.endPoint = CGPoint(x: 2.0, y: 0.0)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.0, y: self.shapeView.frame.size.height))
        path.addCurve(to: CGPoint(x: self.shapeView.frame.size.width, y: self.shapeView.frame.size.height),
                      controlPoint1: CGPoint(x: self.shapeView.frame.size.width*0.40, y: 0),
                      controlPoint2: CGPoint(x:self.shapeView.frame.size.width*0.60, y: 20))
        path.addLine(to: CGPoint(x: self.shapeView.frame.size.width, y: self.shapeView.frame.size.height))
        path.addLine(to: CGPoint(x: 0.0, y: self.shapeView.frame.size.height))
        path.close()

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.App.backgroundPrimary.cgColor

        self.shapeView.layer.mask = shapeLayer
        self.shapeView.layer.masksToBounds = true

    }

    func commonInit() {

        self.navigationLabel.text = localized("deposit")
        self.navigationLabel.font = AppFont.with(type: .bold, size: 17)

        self.navigationButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.navigationButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 17)
        self.navigationButton.setTitle(localized("cancel"), for: .normal)

        self.depositHeaderTextFieldView.setPlaceholderText(localized("deposit_value"))
        self.depositHeaderTextFieldView.setKeyboardType(.decimalPad)
        self.depositHeaderTextFieldView.setRightLabelCustom(title: "€", font: AppFont.with(type: .semibold, size: 20), color: UIColor.App.textSecondary)

        depositTipLabel.text = localized("minimum_deposit_value")
        depositTipLabel.font = AppFont.with(type: .semibold, size: 12)
        depositTipLabel.isHidden = true

        self.setDepositAmountButtonDesign(button: self.amount10Button, title: "€20")
        self.setDepositAmountButtonDesign(button: self.amount20Button, title: "€50")
        self.setDepositAmountButtonDesign(button: self.amount50Button, title: "€100")
        self.setDepositAmountButtonDesign(button: self.amount100Button, title: "€200")

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

        let animationView = LottieAnimationView()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit

        self.animationBaseView.addSubview(animationView)

        let starAnimation = LottieAnimation.named("deposit_animation")

        animationView.animation = starAnimation
        animationView.loopMode = .loop

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: self.animationBaseView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: self.animationBaseView.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: self.animationBaseView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: self.animationBaseView.bottomAnchor)
        ])

        animationView.play()

        self.titleLabel.text = localized("how_much_deposit")

        self.bonusIconImageView.image = UIImage(named: "bonus_sparkle_icon")
        self.bonusIconImageView.contentMode = .scaleAspectFit

        self.bonusTitleLabel.text = localized("bonus_deposit_title")

        self.setupBonusDetailUnderlineClickableLabel()

        self.acceptBonusView.setTitle(title: localized("yes"))

        self.acceptBonusView.didTapView = { [weak self] isChecked in

            if isChecked {
                self?.declineBonusView.isChecked = false
                self?.viewModel.bonusState = .accepted
            }
        }

        self.declineBonusView.setTitle(title: localized("no"))

        self.declineBonusView.didTapView = { [weak self] isChecked in

            if isChecked {
                self?.acceptBonusView.isChecked = false
                self?.viewModel.bonusState = .declined
            }
        }

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

        self.navigationView.colors = [(UIColor(red: 1.0 / 255.0, green: 2.0 / 255.0, blue: 91.0 / 255.0, alpha: 1), NSNumber(0.0)),
                                              (UIColor(red: 64.0 / 255.0, green: 76.0 / 255.0, blue: 255.0 / 255.0, alpha: 1), NSNumber(1.0))]

        self.navigationLabel.textColor = UIColor.App.textPrimary

        self.navigationButton.backgroundColor = .clear
        self.navigationButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.backgroundGradientView.colors = [(UIColor(red: 1.0 / 255.0, green: 2.0 / 255.0, blue: 91.0 / 255.0, alpha: 1), NSNumber(0.0)),
                                              (UIColor(red: 64.0 / 255.0, green: 76.0 / 255.0, blue: 255.0 / 255.0, alpha: 1), NSNumber(1.0))]

        self.animationBaseView.backgroundColor = .clear

        self.shapeView.backgroundColor = UIColor.App.backgroundPrimary

        self.titleLabel.textColor = UIColor.App.buttonTextPrimary

        self.bonusContentView.backgroundColor = UIColor.App.backgroundSecondary

        self.bonusIconImageView.backgroundColor = .clear

        self.bonusTitleLabel.textColor = UIColor.App.textPrimary

        self.bonusInfoLabel.textColor = UIColor.App.textSecondary

        self.bonusDetailLabel.textColor = UIColor.App.highlightSecondary

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

            if paymentStatus == .authorised {
                Env.userSessionStore.refreshUserWalletAfterDelay()
            }

            self?.showPaymentStatusAlert(paymentStatus: paymentStatus)
        }

        viewModel.minimumValue
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] minimumValue in
                let depositTipText = localized("minimum_deposit_value")
                    .replacingOccurrences(of: "{value}", with: minimumValue)
                    .replacingOccurrences(of: "{currency}", with: "€")
                self?.depositTipLabel.text = depositTipText
                self?.depositTipLabel.isHidden = false
            })
            .store(in: &cancellables)

        viewModel.availableBonuses
            .dropFirst()
            .sink(receiveValue: { [weak self] availableBonuses in

                self?.hasBonus = !availableBonuses.isEmpty

                self?.bonusInfoLabel.text = localized("bonus_deposit_name").replacingOccurrences(of: "{bonusName}", with: availableBonuses.first?.name ?? "")

                self?.declineBonusView.isChecked = true

                if availableBonuses.isEmpty {
                    self?.viewModel.bonusState = .nonExistent
                }
                else {
                    self?.viewModel.bonusState = .declined
                }
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

    private func setupBonusDetailUnderlineClickableLabel() {

        let fullString = localized("bonus_deposit_detail")

        self.bonusDetailLabel.text = fullString

        let underlineAttriString = NSMutableAttributedString(string: fullString)

        let range = (fullString as NSString).range(of: fullString)

        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 12), range: range)
        underlineAttriString.addAttribute(.foregroundColor, value: UIColor.App.highlightSecondary, range: range)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)

        self.bonusDetailLabel.attributedText = underlineAttriString
        self.bonusDetailLabel.isUserInteractionEnabled = true
        self.bonusDetailLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBonusDetailUnderlineLabel)))
    }

    @objc private func tapBonusDetailUnderlineLabel() {
        print("TAPPED BONUS DETAIL")
        if let bonus = self.viewModel.availableBonuses.value.first {

            let bonus = ServiceProviderModelMapper.applicableBonus(fromServiceProviderAvailableBonus: bonus)

            let bonusDetailViewModel = BonusDetailViewModel(bonus: bonus)
            let bonusDetailViewController = BonusDetailViewController(viewModel: bonusDetailViewModel)

            self.navigationController?.pushViewController(bonusDetailViewController, animated: true)
        }
    }

    private func showBonusAlert(bonusAmount: String) {

        let message = localized("bonus_dialog_message").replacingOccurrences(of: "{bonusName}", with: self.bonusInfoLabel.text ?? "")

        let alert = UIAlertController(title: localized("bonus_dialog_title"),
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in

            self?.viewModel.getDepositInfo(amountText: bonusAmount)

        }))

        alert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    private func setupResponsableGamingUnderlineClickableLabel() {

        let fullString = localized("responsible_gaming")

        responsibleGamingLabel.text = fullString
        responsibleGamingLabel.numberOfLines = 0
        responsibleGamingLabel.font = AppFont.with(type: .medium, size: 10)
        responsibleGamingLabel.textColor =  UIColor.App.textSecondary

        let underlineAttriString = NSMutableAttributedString(string: fullString)

        let range1 = (fullString as NSString).range(of: localized("responsible_gambling"))

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

            self.shouldRefreshUserWallet?()

            let depositSuccessViewController = GenericAvatarSuccessViewController()

            depositSuccessViewController.didTapContinueAction = { [weak self] in
                self?.dismiss(animated: true)
            }

            depositSuccessViewController.didTapCloseAction = { [weak self] in
                self?.dismiss(animated: true)
            }

            depositSuccessViewController.setTextInfo(title: "\(localized("success"))!", subtitle: localized("deposit_success_message"))

            self.navigationController?.pushViewController(depositSuccessViewController, animated: true)

        case .refused:

            alertTitle = localized("payment_refused")
            alertMessage = localized("payment_refused_message")

            let genericAvatarErrorViewController = GenericAvatarErrorViewController()

            genericAvatarErrorViewController.setTextInfo(title: alertTitle, subtitle: alertMessage)

            genericAvatarErrorViewController.didTapCloseAction = { [weak self] in

                genericAvatarErrorViewController.dismiss(animated: true)
            }

            genericAvatarErrorViewController.didTapBackAction = { [weak self] in

                genericAvatarErrorViewController.dismiss(animated: true)
            }

            self.present(genericAvatarErrorViewController, animated: true)
        }

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

        let stringRange1 = (text as NSString).range(of: localized("faq"))
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

            if depositHeaderTextFieldView.text == "20" {
                self.amount10Button.backgroundColor = UIColor.App.buttonBackgroundPrimary
                self.amount10Button.layer.borderColor = UIColor.App.buttonBackgroundPrimary.cgColor
                currentSelectedButton = self.amount10Button
            }
            else if depositHeaderTextFieldView.text == "50" {
                self.amount20Button.backgroundColor = UIColor.App.buttonBackgroundPrimary
                self.amount20Button.layer.borderColor = UIColor.App.buttonBackgroundPrimary.cgColor
                currentSelectedButton = self.amount20Button
            }
            else if depositHeaderTextFieldView.text == "100" {
                self.amount50Button.backgroundColor = UIColor.App.buttonBackgroundPrimary
                self.amount50Button.layer.borderColor = UIColor.App.buttonBackgroundPrimary.cgColor
                currentSelectedButton = self.amount50Button
            }
            else if depositHeaderTextFieldView.text == "200" {
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

            if self.depositHeaderTextFieldView.isManualInput {
                self.disableAmountButtons = true
            }
            else {
                self.disableAmountButtons = false
            }

        }
        else {
            self.nextButton.isEnabled = false
            self.disableAmountButtons = false
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
        self.depositHeaderTextFieldView.isManualInput = false

        self.checkForHighlightedAmountButton()

        self.amount10Button.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.amount10Button.layer.borderColor = UIColor.App.buttonBackgroundPrimary.cgColor

        self.currentSelectedButton = self.amount10Button

        self.depositHeaderTextFieldView.setText("20")
        self.nextButton.isEnabled = true
        self.showRightLabelCustom()
    }
    @IBAction private func didTap20Button() {
        self.depositHeaderTextFieldView.isManualInput = false

        self.checkForHighlightedAmountButton()

        self.amount20Button.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.amount20Button.layer.borderColor = UIColor.App.buttonBackgroundPrimary.cgColor

        self.currentSelectedButton = self.amount20Button

        self.depositHeaderTextFieldView.setText("50")
        self.nextButton.isEnabled = true
        self.showRightLabelCustom()

    }

    @IBAction private func didTap50Button() {
        self.depositHeaderTextFieldView.isManualInput = false

        self.checkForHighlightedAmountButton()

        self.amount50Button.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.amount50Button.layer.borderColor = UIColor.App.buttonBackgroundPrimary.cgColor

        self.currentSelectedButton = self.amount50Button

        self.depositHeaderTextFieldView.setText("100")
        self.nextButton.isEnabled = true
        self.showRightLabelCustom()
    }

    @IBAction private func didTap100Button() {
        self.depositHeaderTextFieldView.isManualInput = false

        self.checkForHighlightedAmountButton()

        self.amount100Button.backgroundColor = UIColor.App.buttonBackgroundPrimary
        self.amount100Button.layer.borderColor = UIColor.App.buttonBackgroundPrimary.cgColor

        self.currentSelectedButton = self.amount100Button

        self.depositHeaderTextFieldView.setText("200")
        self.nextButton.isEnabled = true
        self.showRightLabelCustom()
    }

    @IBAction private func didTapNextButton() {
        let amountText = self.depositHeaderTextFieldView.text

        if self.viewModel.bonusState == .declined {
            self.showBonusAlert(bonusAmount: amountText)
        }
        else {
            self.viewModel.getDepositInfo(amountText: amountText)
        }

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
        case .bonus:
            errorTitle = localized("error")
            errorMessage = localized("bonus_dialog_error")
        default:
            ()
        }

//        let alert = UIAlertController(title: errorTitle,
//                                      message: errorMessage,
//                                      preferredStyle: .alert)
//
//        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))
//        self.present(alert, animated: true, completion: nil)

        let genericErrorViewController = GenericErrorViewController()

        genericErrorViewController.setTextInfo(title: errorTitle, subtitle: errorMessage)

        self.present(genericErrorViewController, animated: true)
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
    case bonus
}
