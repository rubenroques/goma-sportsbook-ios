//
//  DepositOnRegisterViewController.swift
//  
//
//  Created by Ruben Roques on 27/01/2023.
//

import Foundation
import UIKit
import Theming
import HeaderTextField
import Extensions
import Combine
import ServicesProvider
import Lottie

public class DepositOnRegisterViewController: UIViewController {

    public var didTapDepositButtonAction: (String) -> Void = { amount in }

    public var didTapBackButtonAction: () -> Void = { }
    public var didTapCancelButtonAction: () -> Void = { }

    public var didTapBonusDetailAction: ((AvailableBonus) -> Void)?

    public var getOptInBonus : ( () -> Void)?

    public var availableBonuses: CurrentValueSubject<[AvailableBonus], Never> = .init([])

    public var bonusState: BonusState = .declined

    private lazy var headerBaseView: GradientView = Self.createHeaderBaseView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var cancelButton: UIButton = Self.createCancelButton()

    // private lazy var promoImageView: UIImageView = Self.createPromoImageView()
    private lazy var backgroundGradientView: GradientView = Self.createBackgroundGradientView()
    private lazy var depositAnimationView: LottieAnimationView = Self.createDepositAnimationView()
    private lazy var shapeView: UIView = Self.createShapeView()

    private lazy var contentScrollView: UIScrollView = Self.createContentScrollView()
    private lazy var contentBaseView: UIView = Self.createContentBaseView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()

    private lazy var depositHeaderTextFieldView: HeaderTextFieldView = Self.createHeaderTextFieldView()
    private lazy var depositSubtitleLabel: UILabel = Self.createDepositSubtitleLabel()

    private lazy var amountButtonsStackView: UIStackView = Self.createAmountButtonsStackView()
    private lazy var amountButton1: UIButton = Self.createAmountButton()
    private lazy var amountButton2: UIButton = Self.createAmountButton()
    private lazy var amountButton3: UIButton = Self.createAmountButton()
    private lazy var amountButton4: UIButton = Self.createAmountButton()

    private lazy var footerBaseView: UIView = Self.createFooterBaseView()
    private lazy var depositButton: UIButton = Self.createDepositButton()

    private lazy var bonusBaseView: UIView = Self.createBonusBaseView()
    private lazy var bonusIconImageView: UIImageView = Self.createBonusIconImageView()
    private lazy var bonusTitleLabel: UILabel = Self.createBonusTitleLabel()
    private lazy var bonusInfoLabel: UILabel = Self.createBonusInfoLabel()
    private lazy var bonusDetailLabel: UILabel = Self.createBonusDetailLabel()
    private lazy var acceptBonusView: OptionRadioView = Self.createAcceptBonusView()
    private lazy var declineBonusView: OptionRadioView = Self.createDeclineBonusView()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()

    // Constraints
    private lazy var footerBottomConstraint: NSLayoutConstraint = Self.createFooterBottomConstraint()
    private lazy var bonusBottomConstraint: NSLayoutConstraint = Self.createBonusBottomConstraint()

    private var disableAmountButtons: Bool = false {
        didSet {
            self.amountButton1.isEnabled = !disableAmountButtons
            self.amountButton2.isEnabled = !disableAmountButtons
            self.amountButton3.isEnabled = !disableAmountButtons
            self.amountButton4.isEnabled = !disableAmountButtons
        }
    }

    private var cancellables = Set<AnyCancellable>()

    var currentSelectedButton: UIButton?

    public var isLoading: Bool = false {
        didSet {
            self.loadingBaseView.isHidden = !isLoading
        }
    }

    var hasBonus: Bool = false {
        didSet {
            self.bonusBaseView.isHidden = !hasBonus
            self.footerBottomConstraint.isActive = !hasBonus
            self.bonusBottomConstraint.isActive = hasBonus
        }
    }

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.titleLabel.text = Localization.localized("first_deposit")
        self.subtitleLabel.text = Localization.localized("first_deposit_subtitle")

        self.depositButton.setTitle(Localization.localized("deposit"), for: .normal)

        self.depositButton.addTarget(self, action: #selector(didTapDepositButton), for: .primaryActionTriggered)

        self.cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .primaryActionTriggered)
        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.backButton.isHidden = true

        self.amountButton1.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        self.amountButton2.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        self.amountButton3.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        self.amountButton4.titleLabel?.font = AppFont.with(type: .bold, size: 16)

        self.depositHeaderTextFieldView.setCurrencyMode(true, currencySymbol: "€")

        self.amountButton1.setTitle("20€", for: .normal)
        self.amountButton2.setTitle("50€", for: .normal)
        self.amountButton3.setTitle("100€", for: .normal)
        self.amountButton4.setTitle("200€", for: .normal)

        self.amountButton1.addTarget(self, action: #selector(didTapAmountButton1), for: .primaryActionTriggered)
        self.amountButton2.addTarget(self, action: #selector(didTapAmountButton2), for: .primaryActionTriggered)
        self.amountButton3.addTarget(self, action: #selector(didTapAmountButton3), for: .primaryActionTriggered)
        self.amountButton4.addTarget(self, action: #selector(didTapAmountButton4), for: .primaryActionTriggered)


        self.depositHeaderTextFieldView.setPlaceholderText(Localization.localized("deposit_value"))
        self.depositHeaderTextFieldView.setKeyboardType(.decimalPad)


        let depositSubtitleText = Localization.localized("minimum_deposit_value")
            .replacingOccurrences(of: "{value}", with: "10")
            .replacingOccurrences(of: "{currency}", with: "€")
        self.depositSubtitleLabel.text = depositSubtitleText

        self.isLoading = false

        self.depositButton.isEnabled = false

        self.depositHeaderTextFieldView.textPublisher
            .sink(receiveValue: { [weak self] text in

                guard let self = self else { return }

                self.checkUserInputs()

            })
            .store(in: &cancellables)

        self.availableBonuses
            .dropFirst()
            .sink(receiveValue: { [weak self] availableBonuses in

                print("RECEIVED BONUS: \(availableBonuses)")

                self?.hasBonus = !availableBonuses.isEmpty

                self?.bonusInfoLabel.text = Localization.localized("bonus_deposit_name").replacingOccurrences(of: "{bonusName}", with: availableBonuses.first?.name ?? "")

                self?.declineBonusView.isChecked = true

                if availableBonuses.isEmpty {
                    self?.bonusState = .nonExistent
                }
                else {
                    self?.bonusState = .declined
                }

            })
            .store(in: &cancellables)

        self.getOptInBonus?()

        self.bonusTitleLabel.text = Localization.localized("bonus_deposit_title")

        self.setupBonusDetailUnderlineClickableLabel()

        self.acceptBonusView.setTitle(title: Localization.localized("yes"))

        self.acceptBonusView.didTapView = { [weak self] isChecked in

            if isChecked {
                self?.declineBonusView.isChecked = false
                self?.bonusState = .accepted
            }
        }

        self.declineBonusView.setTitle(title: Localization.localized("no"))

        self.declineBonusView.didTapView = { [weak self] isChecked in

            if isChecked {
                self?.acceptBonusView.isChecked = false
                self?.bonusState = .declined
            }
        }

    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.depositAnimationView.play()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

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
        shapeLayer.fillColor = AppColor.backgroundPrimary.cgColor

        self.shapeView.layer.mask = shapeLayer
        self.shapeView.layer.masksToBounds = true

        self.bonusBaseView.layer.cornerRadius = 14

        self.headerBaseView.startPoint = CGPoint(x: 0.0, y: 0.0)
        self.headerBaseView.endPoint = CGPoint(x: 2.0, y: 0.0)

        self.backgroundGradientView.startPoint = CGPoint(x: 0.0, y: 0.0)
        self.backgroundGradientView.endPoint = CGPoint(x: 2.0, y: 0.0)
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = AppColor.backgroundPrimary

        self.contentScrollView.backgroundColor = .clear

        self.contentBaseView.backgroundColor = AppColor.backgroundPrimary

        //self.headerBaseView.backgroundColor = .clear
        self.headerBaseView.colors = [(UIColor(red: 1.0 / 255.0, green: 2.0 / 255.0, blue: 91.0 / 255.0, alpha: 1), NSNumber(0.0)),
                                              (UIColor(red: 64.0 / 255.0, green: 76.0 / 255.0, blue: 255.0 / 255.0, alpha: 1), NSNumber(1.0))]

        self.backgroundGradientView.colors = [(UIColor(red: 1.0 / 255.0, green: 2.0 / 255.0, blue: 91.0 / 255.0, alpha: 1), NSNumber(0.0)),
                                              (UIColor(red: 64.0 / 255.0, green: 76.0 / 255.0, blue: 255.0 / 255.0, alpha: 1), NSNumber(1.0))]

        self.cancelButton.setTitleColor(AppColor.highlightPrimary, for: .normal)

        self.titleLabel.textColor = AppColor.buttonTextPrimary
        self.subtitleLabel.textColor = AppColor.buttonTextPrimary

        self.shapeView.backgroundColor = AppColor.backgroundPrimary

        self.depositHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.depositHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.depositHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.depositSubtitleLabel.textColor = AppColor.textSecondary

        self.configureStyleOnButton(self.depositButton)
        self.configureStyleOnButton(self.amountButton1)
        self.configureStyleOnButton(self.amountButton2)
        self.configureStyleOnButton(self.amountButton3)
        self.configureStyleOnButton(self.amountButton4)

        self.loadingBaseView.backgroundColor = AppColor.backgroundPrimary.withAlphaComponent(0.7)

        self.bonusBaseView.backgroundColor = AppColor.backgroundSecondary

        self.bonusTitleLabel.textColor = AppColor.textPrimary

        self.bonusInfoLabel.textColor = AppColor.textSecondary

        self.bonusDetailLabel.textColor = AppColor.highlightSecondary

        self.acceptBonusView.backgroundColor = .clear

        self.declineBonusView.backgroundColor = .clear

    }

    private func checkUserInputs() {

        let depositText = depositHeaderTextFieldView.text == "" ? false : true

        if depositText {
            self.depositButton.isEnabled = true
            self.checkForHighlightedAmountButton()

            if depositHeaderTextFieldView.text == "20" {
                self.amountButton1.setBackgroundColor(AppColor.buttonBackgroundPrimary, for: .normal)
                self.amountButton1.layer.borderColor = AppColor.buttonBackgroundPrimary.cgColor
                currentSelectedButton = self.amountButton1
            }
            else if depositHeaderTextFieldView.text == "50" {
                self.amountButton2.setBackgroundColor(AppColor.buttonBackgroundPrimary, for: .normal)
                self.amountButton2.layer.borderColor = AppColor.buttonBackgroundPrimary.cgColor
                currentSelectedButton = self.amountButton2
            }
            else if depositHeaderTextFieldView.text == "100" {
                self.amountButton3.setBackgroundColor(AppColor.buttonBackgroundPrimary, for: .normal)
                self.amountButton3.layer.borderColor = AppColor.buttonBackgroundPrimary.cgColor
                currentSelectedButton = self.amountButton3
            }
            else if depositHeaderTextFieldView.text == "200" {
                self.amountButton4.setBackgroundColor(AppColor.buttonBackgroundPrimary, for: .normal)
                self.amountButton4.layer.borderColor = AppColor.buttonBackgroundPrimary.cgColor
                currentSelectedButton = self.amountButton4
            }
            else {
                self.amountButton1.setBackgroundColor(AppColor.navBanner, for: .normal)
                self.amountButton1.layer.borderColor = AppColor.navBanner.cgColor

                self.amountButton2.setBackgroundColor(AppColor.navBanner, for: .normal)
                self.amountButton2.layer.borderColor = AppColor.navBanner.cgColor

                self.amountButton3.setBackgroundColor(AppColor.navBanner, for: .normal)
                self.amountButton3.layer.borderColor = AppColor.navBanner.cgColor

                self.amountButton4.setBackgroundColor(AppColor.navBanner, for: .normal)
                self.amountButton4.layer.borderColor = AppColor.navBanner.cgColor
            }

            if self.depositHeaderTextFieldView.isManualInput {
                self.disableAmountButtons = true
            }
            else {
                self.disableAmountButtons = false
            }

        }
        else {
            self.depositButton.isEnabled = false
            self.disableAmountButtons = false
        }
    }

    private func checkForHighlightedAmountButton() {
        if currentSelectedButton != nil {
            currentSelectedButton?.setBackgroundColor(AppColor.navBanner, for: .normal)
            currentSelectedButton?.layer.borderColor = AppColor.navBanner.cgColor
        }
    }

    @objc func didTapBackButton() {
        self.didTapBackButtonAction()
    }

    @objc func didTapCancelButton() {
        self.didTapCancelButtonAction()
    }

    @objc func didTapDepositButton() {

        let amount = self.depositHeaderTextFieldView.text

        if self.bonusState == .declined {
            self.showBonusAlert(bonusAmount: amount)
        }
        else {
            self.didTapDepositButtonAction(amount)
        }

    }

    @objc func didTapAmountButton1() {

        self.depositHeaderTextFieldView.isManualInput = false

        self.checkForHighlightedAmountButton()

        self.amountButton1.setBackgroundColor(AppColor.buttonBackgroundPrimary, for: .normal)
        self.amountButton1.layer.borderColor = AppColor.buttonBackgroundPrimary.cgColor

        self.currentSelectedButton = self.amountButton1

        self.depositHeaderTextFieldView.setText("20")
        self.depositButton.isEnabled = true
    }

    @objc func didTapAmountButton2() {

        self.depositHeaderTextFieldView.isManualInput = false

        self.checkForHighlightedAmountButton()

        self.amountButton2.setBackgroundColor(AppColor.buttonBackgroundPrimary, for: .normal)
        self.amountButton2.layer.borderColor = AppColor.buttonBackgroundPrimary.cgColor

        self.currentSelectedButton = self.amountButton2

        self.depositHeaderTextFieldView.setText("50")
        self.depositButton.isEnabled = true
    }

    @objc func didTapAmountButton3() {

        self.depositHeaderTextFieldView.isManualInput = false

        self.checkForHighlightedAmountButton()

        self.amountButton3.setBackgroundColor(AppColor.buttonBackgroundPrimary, for: .normal)
        self.amountButton3.layer.borderColor = AppColor.buttonBackgroundPrimary.cgColor

        self.currentSelectedButton = self.amountButton3

        self.depositHeaderTextFieldView.setText("100")
        self.depositButton.isEnabled = true
    }

    @objc func didTapAmountButton4() {

        self.depositHeaderTextFieldView.isManualInput = false

        self.checkForHighlightedAmountButton()

        self.amountButton4.setBackgroundColor(AppColor.buttonBackgroundPrimary, for: .normal)
        self.amountButton4.layer.borderColor = AppColor.buttonBackgroundPrimary.cgColor

        self.currentSelectedButton = self.amountButton4

        self.depositHeaderTextFieldView.setText("200")
        self.depositButton.isEnabled = true
    }

    private func configureStyleOnButton(_ button: UIButton) {

        button.setTitleColor(AppColor.buttonTextPrimary, for: .normal)
        button.setTitleColor(AppColor.navBannerActive, for: .disabled)

        button.setBackgroundColor(AppColor.navBanner, for: .normal)

        button.layer.borderWidth = 2
        button.layer.borderColor = AppColor.navBanner.cgColor
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.backgroundColor = .clear

    }

    public func showErrorAlert(errorTitle: String, errorMessage: String) {

        let errorTitle = errorTitle
        let errorMessage = errorMessage

        let alert = UIAlertController(title: errorTitle,
                                      message: errorMessage,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: Localization.localized("ok"), style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    private func showBonusAlert(bonusAmount: String) {

        let message = Localization.localized("bonus_dialog_message").replacingOccurrences(of: "{bonusName}", with: self.bonusInfoLabel.text ?? "")

        let alert = UIAlertController(title: Localization.localized("bonus_dialog_title"),
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: Localization.localized("ok"), style: .default, handler: { [weak self] _ in
            self?.didTapDepositButtonAction(bonusAmount)
        }))

        alert.addAction(UIAlertAction(title: Localization.localized("cancel"), style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }

    private func setupBonusDetailUnderlineClickableLabel() {

        let fullString = Localization.localized("bonus_deposit_detail")

        self.bonusDetailLabel.text = fullString

        let underlineAttriString = NSMutableAttributedString(string: fullString)

        let range = (fullString as NSString).range(of: fullString)

        underlineAttriString.addAttribute(.font, value: AppFont.with(type: .semibold, size: 12), range: range)
        underlineAttriString.addAttribute(.foregroundColor, value: AppColor.highlightSecondary, range: range)
        underlineAttriString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)

        self.bonusDetailLabel.attributedText = underlineAttriString
        self.bonusDetailLabel.isUserInteractionEnabled = true
        self.bonusDetailLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBonusDetailUnderlineLabel)))
    }

    @objc private func tapBonusDetailUnderlineLabel() {
        print("TAPPED BONUS DETAIL")
        if let bonus = self.availableBonuses.value.first {
            self.didTapBonusDetailAction?(bonus)
        }
    }

}

public extension DepositOnRegisterViewController {

    private static func createHeaderBaseView() -> GradientView {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        let image = UIImage(named: "back_icon", in: Bundle.module, with: nil)
        button.setImage(image, for: .normal)
        button.setTitle(nil, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private static func createCancelButton() -> UIButton {
        let button = UIButton()
        button.setTitle(Localization.localized("close"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private static func createPromoImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .clear
        imageView.image = UIImage(named: "first_deposit_promo_banner", in: Bundle.module, compatibleWith: nil)
        return imageView
    }

    private static func createBackgroundGradientView() -> GradientView {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createShapeView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createContentScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }

    private static func createContentBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createFeedbackImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 30)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createFooterBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

    private static func createDepositSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createAmountButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }

    private static func createAmountButtonsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }

    private static func createDepositButton() -> UIButton {
        let button = UIButton()
        button.setTitle(Localization.localized("continue_"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        return button
    }

    private static func createBonusBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBonusIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "bonus_sparkle_icon", in: Bundle.module, compatibleWith: nil)
        return imageView

    }

    private static func createBonusTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createBonusInfoLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createBonusDetailLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .left
        return label
    }

    private static func createAcceptBonusView() -> OptionRadioView {
        let view = OptionRadioView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createDeclineBonusView() -> OptionRadioView {
        let view = OptionRadioView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createNotNowBonusView() -> OptionRadioView {
        let view = OptionRadioView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }

    private static func createDepositAnimationView() -> LottieAnimationView {
        let animationView = LottieAnimationView()

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.contentMode = .scaleAspectFit

        let starAnimation = LottieAnimation.named("first_deposit")

        animationView.animation = starAnimation
        animationView.loopMode = .loop

        return animationView
    }

    private static func createFooterBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createBonusBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private func setupSubviews() {

        self.view.addSubview(self.headerBaseView)

        self.view.addSubview(self.contentScrollView)
        self.contentScrollView.addSubview(self.contentBaseView)

        self.contentBaseView.addSubview(self.backgroundGradientView)

        self.headerBaseView.addSubview(self.backButton)
        self.headerBaseView.addSubview(self.cancelButton)

        self.backgroundGradientView.addSubview(self.depositAnimationView)

        self.backgroundGradientView.addSubview(self.titleLabel)
        self.backgroundGradientView.addSubview(self.subtitleLabel)

        self.backgroundGradientView.addSubview(self.shapeView)

        self.contentBaseView.addSubview(self.depositHeaderTextFieldView)
        self.contentBaseView.addSubview(self.depositSubtitleLabel)

        self.amountButtonsStackView.addArrangedSubview(self.amountButton1)
        self.amountButtonsStackView.addArrangedSubview(self.amountButton2)
        self.amountButtonsStackView.addArrangedSubview(self.amountButton3)
        self.amountButtonsStackView.addArrangedSubview(self.amountButton4)
        self.contentBaseView.addSubview(self.amountButtonsStackView)

        self.contentBaseView.addSubview(self.footerBaseView)
        self.footerBaseView.addSubview(self.depositButton)

        self.contentBaseView.addSubview(self.bonusBaseView)

        self.bonusBaseView.addSubview(self.bonusIconImageView)
        self.bonusBaseView.addSubview(self.bonusTitleLabel)
        self.bonusBaseView.addSubview(self.bonusInfoLabel)
        self.bonusBaseView.addSubview(self.bonusDetailLabel)
        self.bonusBaseView.addSubview(self.acceptBonusView)
        self.bonusBaseView.addSubview(self.declineBonusView)

        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.activityIndicatorView)

        self.initConstraints()

        self.bonusBaseView.setNeedsLayout()
        self.bonusBaseView.layoutIfNeeded()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.contentScrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.contentScrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.contentScrollView.topAnchor.constraint(equalTo: self.headerBaseView.bottomAnchor),
            self.contentScrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.contentBaseView.leadingAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.leadingAnchor),
            self.contentBaseView.topAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.topAnchor),
            self.contentBaseView.trailingAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.trailingAnchor),
            self.contentBaseView.bottomAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.bottomAnchor),
            self.contentBaseView.widthAnchor.constraint(equalTo: self.contentScrollView.frameLayoutGuide.widthAnchor),

            self.backgroundGradientView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
            self.backgroundGradientView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),
            self.backgroundGradientView.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor),

            self.headerBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.headerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerBaseView.heightAnchor.constraint(equalToConstant: 60),

            self.backButton.leadingAnchor.constraint(equalTo: self.headerBaseView.leadingAnchor, constant: 18),
            self.backButton.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.backButton.widthAnchor.constraint(equalTo: self.backButton.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.cancelButton.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.cancelButton.trailingAnchor.constraint(equalTo: self.headerBaseView.trailingAnchor, constant: -34),

//            self.promoImageView.topAnchor.constraint(equalTo: self.headerBaseView.bottomAnchor, constant: 8),
//            self.promoImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 34),
//            self.promoImageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -34),
//            self.promoImageView.heightAnchor.constraint(equalTo: self.promoImageView.widthAnchor, multiplier: 0.32),

            self.depositAnimationView.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor),
            self.depositAnimationView.leadingAnchor.constraint(equalTo: self.backgroundGradientView.leadingAnchor, constant: 34),
            self.depositAnimationView.trailingAnchor.constraint(equalTo: self.backgroundGradientView.trailingAnchor, constant: -34),
            self.depositAnimationView.heightAnchor.constraint(equalTo: self.depositAnimationView.widthAnchor, multiplier: 0.5),

            self.titleLabel.topAnchor.constraint(equalTo: self.depositAnimationView.bottomAnchor, constant: 25),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.backgroundGradientView.leadingAnchor, constant: 30),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.backgroundGradientView.trailingAnchor, constant: -30),

            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 15),
            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.backgroundGradientView.leadingAnchor, constant: 30),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.backgroundGradientView.trailingAnchor, constant: -30),
            self.subtitleLabel.bottomAnchor.constraint(equalTo: self.backgroundGradientView.bottomAnchor, constant: -50),

            self.shapeView.leadingAnchor.constraint(equalTo: self.backgroundGradientView.leadingAnchor),
            self.shapeView.trailingAnchor.constraint(equalTo: self.backgroundGradientView.trailingAnchor),
            self.shapeView.bottomAnchor.constraint(equalTo: self.backgroundGradientView.bottomAnchor),
            self.shapeView.heightAnchor.constraint(equalToConstant: 40),

            self.depositHeaderTextFieldView.topAnchor.constraint(equalTo: self.backgroundGradientView.bottomAnchor, constant: 32),
            self.depositHeaderTextFieldView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 30),
            self.depositHeaderTextFieldView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -30),
            self.depositHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),

            self.depositSubtitleLabel.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 30),
            self.depositSubtitleLabel.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -30),
            self.depositSubtitleLabel.topAnchor.constraint(equalTo: self.depositHeaderTextFieldView.bottomAnchor, constant: -13),
            self.depositSubtitleLabel.heightAnchor.constraint(equalToConstant: 14),

            self.amountButtonsStackView.topAnchor.constraint(equalTo: self.depositHeaderTextFieldView.bottomAnchor, constant: 26),
            self.amountButtonsStackView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 30),
            self.amountButtonsStackView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -30),
            self.amountButtonsStackView.heightAnchor.constraint(equalToConstant: 46),

            self.footerBaseView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
            self.footerBaseView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),
            self.footerBaseView.heightAnchor.constraint(equalToConstant: 70),
            self.footerBaseView.topAnchor.constraint(equalTo: self.amountButtonsStackView.bottomAnchor, constant: 30),
            //self.footerBaseView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor),

            self.depositButton.centerXAnchor.constraint(equalTo: self.footerBaseView.centerXAnchor),
            self.depositButton.centerYAnchor.constraint(equalTo: self.footerBaseView.centerYAnchor),
            self.depositButton.leadingAnchor.constraint(equalTo: self.footerBaseView.leadingAnchor, constant: 34),
            self.depositButton.heightAnchor.constraint(equalToConstant: 50),

        ])

        // Bonus View
        NSLayoutConstraint.activate([
            self.bonusBaseView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 30),
            self.bonusBaseView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -30),
            self.bonusBaseView.topAnchor.constraint(equalTo: self.footerBaseView.bottomAnchor, constant: 20),

            self.bonusIconImageView.leadingAnchor.constraint(equalTo: self.bonusBaseView.leadingAnchor, constant: 12),
            self.bonusIconImageView.topAnchor.constraint(equalTo: self.bonusBaseView.topAnchor, constant: 14),
            self.bonusIconImageView.widthAnchor.constraint(equalToConstant: 28),
            self.bonusIconImageView.heightAnchor.constraint(equalTo: self.bonusIconImageView.widthAnchor),

            self.bonusTitleLabel.leadingAnchor.constraint(equalTo: self.bonusIconImageView.trailingAnchor, constant: 8),
            self.bonusTitleLabel.topAnchor.constraint(equalTo: self.bonusIconImageView.topAnchor),
            self.bonusTitleLabel.trailingAnchor.constraint(equalTo: self.bonusBaseView.trailingAnchor, constant: -12),

            self.bonusInfoLabel.leadingAnchor.constraint(equalTo: self.bonusTitleLabel.leadingAnchor),
            self.bonusInfoLabel.topAnchor.constraint(equalTo: self.bonusTitleLabel.bottomAnchor, constant: 15),
            self.bonusInfoLabel.trailingAnchor.constraint(equalTo: self.bonusBaseView.trailingAnchor, constant: -12),
            self.bonusDetailLabel.leadingAnchor.constraint(equalTo: self.bonusTitleLabel.leadingAnchor),
            self.bonusDetailLabel.topAnchor.constraint(equalTo: self.bonusInfoLabel.bottomAnchor, constant: 5),
            self.bonusDetailLabel.trailingAnchor.constraint(equalTo: self.bonusBaseView.trailingAnchor, constant: -12),
            //self.bonusDetailLabel.bottomAnchor.constraint(equalTo: self.bonusBaseView.bottomAnchor, constant: -14)

            self.acceptBonusView.leadingAnchor.constraint(equalTo: self.bonusTitleLabel.leadingAnchor),
            self.acceptBonusView.topAnchor.constraint(equalTo: self.bonusDetailLabel.bottomAnchor, constant: 15),
            self.acceptBonusView.bottomAnchor.constraint(equalTo: self.bonusBaseView.bottomAnchor, constant: -14),

            self.declineBonusView.leadingAnchor.constraint(equalTo: self.acceptBonusView.trailingAnchor, constant: 25),
            self.declineBonusView.centerYAnchor.constraint(equalTo: self.acceptBonusView.centerYAnchor)
        ])

        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor)
        ])

        self.footerBottomConstraint =             self.footerBaseView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor, constant: -20)

        self.footerBottomConstraint.isActive = true

        self.bonusBottomConstraint = self.bonusBaseView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor, constant: -20)
        self.bonusBottomConstraint.isActive = false
    }

}
