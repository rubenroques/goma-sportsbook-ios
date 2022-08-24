//
//  QuickBetViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 19/08/2022.
//

import UIKit
import Combine

class QuickBetViewController: UIViewController {

    // MARK: Private properties
    private lazy var topSafeAreaView: UIView = Self.createTopSafeAreaView()
    private lazy var bottomSafeAreaView: UIView = Self.createBottomSafeAreaView()
    private lazy var containerStackView: UIStackView = Self.createContainerStackView()
    private lazy var containerView: UIView = Self.createContainerView()
    private lazy var outcomeLabel: UILabel = Self.createOutcomeLabel()
    private lazy var oddBaseView: UIView = Self.createOddBaseView()
    private lazy var oddValueLabel: UILabel = Self.createOddValueLabel()
    private lazy var upOddImageView: UIImageView = Self.createUpOddImageView()
    private lazy var downOddImageView: UIImageView = Self.createDownOddImageView()
    private lazy var closeButton: UIButton = Self.createCloseButton()
    private lazy var separatorView: UIView = Self.createSeparatorView()
    private lazy var marketLabel: UILabel = Self.createMarketLabel()
    private lazy var matchLabel: UILabel = Self.createMatchLabel()
    private lazy var returnLabel: UILabel = Self.createReturnLabel()
    private lazy var betAmountView: UIView = Self.createBetAmountView()
    private lazy var betAmountTextField: UITextField = Self.createBetAmountTextField()
    private lazy var betButtonsStackView: UIStackView = Self.createBetButtonsStackView()
    private lazy var addOneButton: UIButton = Self.createAddOneButton()
    private lazy var addFiveButton: UIButton = Self.createAddFiveButton()
    private lazy var addMaxButton: UIButton = Self.createAddMaxButton()
    private lazy var finalBetButton: UIButton = Self.createFinalBetButton()
    private lazy var lateralErrorView: UIView = Self.createLateralErrorView()
    private lazy var bottomErrorView: UIView = Self.createBottomErrorView()
    private lazy var iconErrorImageView: UIImageView = Self.createIconErrorImageView()
    private lazy var errorLabel: UILabel = Self.createErrorLabel()
    private lazy var closeErrorButton: UIButton = Self.createCloseErrorButton()
    private lazy var bottomErrorIndicatorView: UIView = Self.createBottomErrorIndicatorView()

    private lazy var successContainerView: UIView = Self.createContainerView()
    private lazy var successImageView: UIImageView = Self.createSuccessImageView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()
    private lazy var possibleWinningsTitleLabel: UILabel = Self.createPossibleWinningsTitleLabel()
    private lazy var possibleWinningsValueLabel: UILabel = Self.createPossibleWinningsValueLabel()
    private lazy var continueButton: UIButton = Self.createContinueButton()
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var activityIndicatorView: UIActivityIndicatorView = Self.createActivityIndicatorView()

    private var cancellables = Set<AnyCancellable>()

    // Constraints
    private lazy var containerCenterYConstraint: NSLayoutConstraint = Self.createContainerCenterYConstraint()
    private lazy var containerBottomConstraint: NSLayoutConstraint = Self.createContainerBottomConstraint()

    // MARK: Public Properties
    var viewModel: QuickBetViewModel

    var hasError: Bool = false {
        didSet {
            self.lateralErrorView.isHidden = !hasError
            self.bottomErrorView.isHidden = !hasError
        }
    }

    var isSuccessBet: Bool = false {
        didSet {
            self.containerView.isHidden = isSuccessBet
            self.bottomErrorView.isHidden = isSuccessBet
            self.successContainerView.isHidden = !isSuccessBet
        }
    }

    var isLoading: Bool = false {
        didSet {
            self.loadingBaseView.isHidden = !isLoading
        }
    }

    var oddStatus: OddStatusType = .same {
        didSet {
            self.updateOddStatus(oddStatusType: oddStatus)
        }
    }

    // MARK: - Lifetime and Cycle
    init(viewModel: QuickBetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        self.setupWithTheme()

        self.bind(toViewModel: self.viewModel)

        self.configureTicketInfo()

        self.betAmountTextField.delegate = self
        self.betAmountTextField.keyboardType = .numberPad
        self.addDoneAccessoryView()

        self.closeButton.addTarget(self, action: #selector(didTapCloseButton), for: .primaryActionTriggered)

        self.addOneButton.addTarget(self, action: #selector(didTapAddOneButton), for: .primaryActionTriggered)

        self.addFiveButton.addTarget(self, action: #selector(didTapAddFiveButton), for: .primaryActionTriggered)

        self.addMaxButton.addTarget(self, action: #selector(didTapAddMaxButton), for: .primaryActionTriggered)

        self.finalBetButton.addTarget(self, action: #selector(didTapFinalBetButton), for: .primaryActionTriggered)

        self.closeErrorButton.addTarget(self, action: #selector(didTapCloseErrorButton), for: .primaryActionTriggered)

        self.continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .primaryActionTriggered)

        self.isSuccessBet = false
        self.hasError = false
        self.isLoading = false

        self.oddStatus = .same

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }

    // MARK: - Layout and Theme
    override func viewDidLayoutSubviews() {

        super.viewDidLayoutSubviews()

        self.containerStackView.layer.cornerRadius = CornerRadius.view
        self.containerStackView.layer.masksToBounds = true
        self.containerStackView.clipsToBounds = true

        self.oddBaseView.layer.cornerRadius = 3

        self.betAmountView.layer.cornerRadius = CornerRadius.view

        self.addOneButton.layer.cornerRadius = CornerRadius.view
        self.addOneButton.clipsToBounds = true

        self.addFiveButton.layer.cornerRadius = CornerRadius.view
        self.addFiveButton.clipsToBounds = true

        self.addMaxButton.layer.cornerRadius = CornerRadius.view
        self.addMaxButton.clipsToBounds = true

        self.finalBetButton.layer.cornerRadius = CornerRadius.view
        self.finalBetButton.clipsToBounds = true

        self.successContainerView.layer.cornerRadius = CornerRadius.view
        self.successContainerView.clipsToBounds = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.5)

        self.topSafeAreaView.backgroundColor = .clear

        self.bottomSafeAreaView.backgroundColor = .clear

        self.containerView.backgroundColor = UIColor.App.backgroundSecondary

        self.outcomeLabel.textColor = UIColor.App.textPrimary

        self.oddBaseView.backgroundColor = UIColor.App.backgroundPrimary

        self.oddValueLabel.textColor = UIColor.App.textPrimary

        self.upOddImageView.backgroundColor = .clear

        self.downOddImageView.backgroundColor = .clear

        self.separatorView.backgroundColor = UIColor.App.separatorLine

        self.marketLabel.textColor = UIColor.App.textPrimary

        self.matchLabel.textColor = UIColor.App.textPrimary

        self.returnLabel.textColor = UIColor.App.textPrimary

        self.betAmountView.backgroundColor = UIColor.App.inputBackground

        self.betAmountTextField.textColor = UIColor.App.textPrimary

        self.addOneButton.setBackgroundColor(UIColor.App.inputBackground, for: .normal)
        self.addOneButton.setTitleColor(UIColor.App.textPrimary, for: .normal)

        self.addFiveButton.setBackgroundColor(UIColor.App.inputBackground, for: .normal)
        self.addFiveButton.setTitleColor(UIColor.App.textPrimary, for: .normal)

        self.addMaxButton.setBackgroundColor(UIColor.App.inputBackground, for: .normal)
        self.addMaxButton.setTitleColor(UIColor.App.textPrimary, for: .normal)

        StyleHelper.styleButton(button: self.finalBetButton)

        self.finalBetButton.isEnabled = false

        self.lateralErrorView.backgroundColor = UIColor.App.alertError

        self.bottomErrorView.backgroundColor = UIColor.App.backgroundPrimary

        self.iconErrorImageView.backgroundColor = .clear

        self.errorLabel.textColor = UIColor.App.textPrimary

        self.bottomErrorIndicatorView.backgroundColor = UIColor.App.alertError

        self.successContainerView.backgroundColor = UIColor.App.backgroundPrimary

        self.successImageView.backgroundColor = .clear

        self.titleLabel.textColor = UIColor.App.textPrimary

        self.subtitleLabel.textColor = UIColor.App.textPrimary

        StyleHelper.styleButton(button: self.continueButton)

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundSecondary.withAlphaComponent(0.8)
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: QuickBetViewModel) {

        viewModel.oddValuePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] oddValue in
                self?.oddValueLabel.text = oddValue
            })
            .store(in: &cancellables)

        viewModel.finalBetAmountPublisher
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] finalBetAmount in

                if finalBetAmount <= 0 {
                    self?.finalBetButton.isEnabled = false
                }
                else {
                    self?.finalBetButton.isEnabled = true
                }

                self?.betAmountTextField.text = CurrencyFormater.defaultFormat.string(from: NSNumber(value: finalBetAmount))
            })
            .store(in: &cancellables)

        viewModel.returnAmountValue
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] returnAmount in
                if let returnCurrencyAmount = CurrencyFormater.defaultFormat.string(from: NSNumber(value: returnAmount)) {

                    self?.returnLabel.text = localized("return") + ": \(returnCurrencyAmount)"

                }

            })
            .store(in: &cancellables)

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                self?.isLoading = isLoading
            })
            .store(in: &cancellables)

        viewModel.oddStatusPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] oddStatus in
                self?.oddStatus = oddStatus
            })
            .store(in: &cancellables)

        viewModel.shouldShowBetError = { [weak self] errorMessage in
            self?.showBetError(errorMesage: errorMessage)
        }

        viewModel.shouldShowBetSuccess = { [weak self] in
            self?.showBetSuccessScreen()
        }
    }

    // MARK: Functions
    private func configureTicketInfo() {

        self.outcomeLabel.text = self.viewModel.getOutcome()

        self.marketLabel.text = self.viewModel.getMarket()

        self.matchLabel.text = self.viewModel.getMatch()
    }

    private func showBetError(errorMesage: String) {
        self.errorLabel.text = errorMesage
        self.hasError = true
    }

    private func showBetSuccessScreen() {

        let returnAmount = self.viewModel.returnAmountValue.value

        if let returnCurrencyAmount = CurrencyFormater.defaultFormat.string(from: NSNumber(value: returnAmount)) {

            self.possibleWinningsValueLabel.text  = "\(returnCurrencyAmount)"
            self.isSuccessBet = true

        }

    }

    private func updateOddStatus(oddStatusType: OddStatusType) {

        switch oddStatusType {
        case .up:

            self.highlightOddChangeUp(upChangeOddValueImage: self.upOddImageView, baseView: self.oddBaseView)
        case .down:

            self.highlightOddChangeDown(downChangeOddValueImage: self.downOddImageView, baseView: self.oddBaseView)
        case .same:

            self.upOddImageView.alpha = 0.0
            self.downOddImageView.alpha = 0.0
        }
    }

    func highlightOddChangeUp(animated: Bool = true, upChangeOddValueImage: UIImageView, baseView: UIView) {
        baseView.layer.borderWidth = 1.5
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            upChangeOddValueImage.alpha = 1.0
            self.animateBorderColor(view: baseView, color: UIColor.App.alertSuccess, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            upChangeOddValueImage.alpha = 0.0
            self.animateBorderColor(view: baseView, color: UIColor.clear, duration: animated ? 0.4 : 0.0)
        }, completion: nil)
    }

    func highlightOddChangeDown(animated: Bool = true, downChangeOddValueImage: UIImageView, baseView: UIView) {
        baseView.layer.borderWidth = 1.5
        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 0.0, options: .curveEaseIn, animations: {
            downChangeOddValueImage.alpha = 1.0
            self.animateBorderColor(view: baseView, color: UIColor.App.alertError, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

        UIView.animate(withDuration: animated ? 0.4 : 0.0, delay: 3.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
            downChangeOddValueImage.alpha = 0.0
            self.animateBorderColor(view: baseView, color: UIColor.clear, duration: animated ? 0.4 : 0.0)
        }, completion: nil)

    }

    private func animateBorderColor(view: UIView, color: UIColor, duration: Double) {
        let animation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = view.layer.borderColor
        animation.toValue = color.cgColor
        animation.duration = duration
        view.layer.add(animation, forKey: "borderColor")
        view.layer.borderColor = color.cgColor
    }

    func addDoneAccessoryView() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        self.betAmountTextField.inputAccessoryView = keyboardToolbar
    }

    // MARK: Actions
    @objc func didTapCloseButton() {
        self.dismiss(animated: true)
    }

    @objc func didTapAddOneButton() {
        self.viewModel.updateBetAmountValue(amount: "1")
    }

    @objc func didTapAddFiveButton() {
        self.viewModel.updateBetAmountValue(amount: "5")

    }

    @objc func didTapAddMaxButton() {
        let maxAmountString = "\(self.viewModel.maxBetStake)"

        self.viewModel.updateBetAmountValue(amount: maxAmountString, isMaxStake: true)
    }

    @objc func didTapFinalBetButton() {
        self.viewModel.placeBet()
    }

    @objc func didTapCloseErrorButton() {
        self.hasError = false
    }

    @objc func didTapContinueButton() {
        self.dismiss(animated: true)
    }

    @objc func dismissKeyboard() {
        self.betAmountTextField.endEditing(true)
    }

    @objc func keyboardWillShow(notification: NSNotification) {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = (keyboardSize.height - self.bottomSafeAreaView.frame.height) + 15

            self.containerBottomConstraint =
            NSLayoutConstraint(item: self.containerStackView,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: self.bottomSafeAreaView,
                               attribute: .top,
                               multiplier: 1,
                               constant: -keyboardHeight)
            self.containerCenterYConstraint.isActive = false
            self.containerBottomConstraint.isActive = true
            }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        self.containerBottomConstraint.isActive = false
        self.containerCenterYConstraint.isActive = true
    }
}

extension QuickBetViewController: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.viewModel.updateBetAmountValue(amount: string, isInput: true)
        return false
    }
}

extension QuickBetViewController {
    private static func createTopSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomSafeAreaView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createContainerStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }

    private static func createContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createOutcomeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Outcome"
        label.font = AppFont.with(type: .bold, size: 15)
        label.numberOfLines = 0
        return label
    }

    private static func createOddBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.required, for: .horizontal)
        return view
    }

    private static func createOddValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "-_--"
        label.font = AppFont.with(type: .bold, size: 15)
        return label
    }

    private static func createUpOddImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "odd_up_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createDownOddImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "odd_down_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "small_close_cross_light_icon"), for: .normal)
        return button
    }

    private static func createSeparatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createMarketLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Market"
        label.font = AppFont.with(type: .bold, size: 14)
        return label
    }

    private static func createMatchLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Match"
        label.font = AppFont.with(type: .semibold, size: 12)
        return label
    }

    private static func createReturnLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(localized("return")): "
        label.font = AppFont.with(type: .semibold, size: 12)
        return label
    }

    private static func createBetAmountView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBetAmountTextField() -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString(
            string: localized("amount"),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.App.inputTextTitle,
                         NSAttributedString.Key.font: AppFont.with(type: .semibold, size: 16)])
        return textField
    }

    private static func createBetButtonsStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }

    private static func createAddOneButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("+1", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        return button
    }

    private static func createAddFiveButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("+5", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        return button
    }

    private static func createAddMaxButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Max", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        return button
    }

    private static func createFinalBetButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("bet"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 16)
        return button
    }

    private static func createLateralErrorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBottomErrorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createIconErrorImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "warning_alert_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createErrorLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Error"
        label.font = AppFont.with(type: .semibold, size: 12)
        label.numberOfLines = 0
        return label
    }

    private static func createCloseErrorButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "small_close_cross_light_icon"), for: .normal)
        return button
    }

    private static func createBottomErrorIndicatorView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createContainerCenterYConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createContainerBottomConstraint() -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint()
        return constraint
    }

    private static func createSuccessContainerView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createSuccessImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "like_success_icon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("bet_registered_success")
        label.font = AppFont.with(type: .semibold, size: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("good_luck")
        label.font = AppFont.with(type: .bold, size: 14)
        label.textAlignment = .center
        return label
    }

    private static func createPossibleWinningsTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("possible_winnings")
        label.font = AppFont.with(type: .semibold, size: 14)
        label.textAlignment = .center
        return label
    }

    private static func createPossibleWinningsValueLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("possible_winnings")
        label.font = AppFont.with(type: .bold, size: 18)
        label.textAlignment = .center
        return label
    }

    private static func createContinueButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("continue_"), for: .normal)
        return button
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

    private func setupSubviews() {
        self.view.addSubview(self.topSafeAreaView)

        self.view.addSubview(self.containerStackView)

        self.view.addSubview(self.bottomSafeAreaView)

        self.containerStackView.addArrangedSubview(self.containerView)

        self.containerView.addSubview(self.outcomeLabel)

        self.containerView.addSubview(self.oddBaseView)

        self.oddBaseView.addSubview(self.oddValueLabel)

        self.containerView.addSubview(self.upOddImageView)

        self.containerView.addSubview(self.downOddImageView)

        self.containerView.addSubview(self.closeButton)

        self.containerView.addSubview(self.separatorView)

        self.containerView.addSubview(self.marketLabel)

        self.containerView.addSubview(self.matchLabel)

        self.containerView.addSubview(self.returnLabel)

        self.containerView.addSubview(self.betAmountView)

        self.betAmountView.addSubview(self.betAmountTextField)

        self.containerView.addSubview(self.betButtonsStackView)

        self.betButtonsStackView.addArrangedSubview(self.addOneButton)
        self.betButtonsStackView.addArrangedSubview(self.addFiveButton)
        self.betButtonsStackView.addArrangedSubview(self.addMaxButton)

        self.containerView.addSubview(self.finalBetButton)

        self.containerView.addSubview(self.lateralErrorView)

        self.containerStackView.addArrangedSubview(self.bottomErrorView)

        self.bottomErrorView.addSubview(self.iconErrorImageView)
        self.bottomErrorView.addSubview(self.errorLabel)
        self.bottomErrorView.addSubview(self.closeErrorButton)
        self.bottomErrorView.addSubview(self.bottomErrorIndicatorView)

        self.containerStackView.addArrangedSubview(self.successContainerView)

        self.successContainerView.addSubview(self.successImageView)
        self.successContainerView.addSubview(self.titleLabel)
        self.successContainerView.addSubview(self.subtitleLabel)
        self.successContainerView.addSubview(self.possibleWinningsTitleLabel)
        self.successContainerView.addSubview(self.possibleWinningsValueLabel)
        self.successContainerView.addSubview(self.continueButton)

        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.activityIndicatorView)

        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.activityIndicatorView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top and Bottom Safe Area View
        NSLayoutConstraint.activate([
            self.topSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topSafeAreaView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topSafeAreaView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),

            self.bottomSafeAreaView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.bottomSafeAreaView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.bottomSafeAreaView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.bottomSafeAreaView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        // Container view
        NSLayoutConstraint.activate([
            self.containerStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 9),
            self.containerStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -9),

            self.containerView.leadingAnchor.constraint(equalTo: self.containerStackView.leadingAnchor),
            self.containerView.trailingAnchor.constraint(equalTo: self.containerStackView.trailingAnchor)
        ])

        // Top info
        NSLayoutConstraint.activate([

            self.outcomeLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.outcomeLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 15),
            self.outcomeLabel.trailingAnchor.constraint(equalTo: self.oddBaseView.leadingAnchor, constant: 25),

            self.closeButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: 0),
            self.closeButton.centerYAnchor.constraint(equalTo: self.outcomeLabel.centerYAnchor),
            self.closeButton.widthAnchor.constraint(equalToConstant: 40),
            self.closeButton.heightAnchor.constraint(equalTo: self.closeButton.widthAnchor),

            self.upOddImageView.trailingAnchor.constraint(equalTo: self.oddBaseView.leadingAnchor, constant: -4),
            self.upOddImageView.centerYAnchor.constraint(equalTo: self.oddBaseView.centerYAnchor),
            self.upOddImageView.widthAnchor.constraint(equalToConstant: 11),
            self.upOddImageView.heightAnchor.constraint(equalToConstant: 9),

            self.downOddImageView.trailingAnchor.constraint(equalTo: self.oddBaseView.leadingAnchor, constant: -4),
            self.downOddImageView.centerYAnchor.constraint(equalTo: self.oddBaseView.centerYAnchor),
            self.downOddImageView.widthAnchor.constraint(equalToConstant: 11),
            self.downOddImageView.heightAnchor.constraint(equalToConstant: 9),

            self.oddBaseView.trailingAnchor.constraint(equalTo: self.closeButton.leadingAnchor, constant: -5),
            self.oddBaseView.centerYAnchor.constraint(equalTo: self.outcomeLabel.centerYAnchor),
            self.oddBaseView.heightAnchor.constraint(equalToConstant: 25),

            self.oddValueLabel.leadingAnchor.constraint(equalTo: self.oddBaseView.leadingAnchor, constant: 8),
            self.oddValueLabel.trailingAnchor.constraint(equalTo: self.oddBaseView.trailingAnchor, constant: -8),
            self.oddValueLabel.centerYAnchor.constraint(equalTo: self.oddBaseView.centerYAnchor),

            self.separatorView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.separatorView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.separatorView.heightAnchor.constraint(equalToConstant: 1),
            self.separatorView.topAnchor.constraint(equalTo: self.outcomeLabel.bottomAnchor, constant: 12)
        ])

        // Middle info
        NSLayoutConstraint.activate([
            self.marketLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.marketLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.marketLabel.topAnchor.constraint(equalTo: self.separatorView.bottomAnchor, constant: 12),

            self.matchLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.matchLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.matchLabel.topAnchor.constraint(equalTo: self.marketLabel.bottomAnchor, constant: 5),

            self.returnLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.returnLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.returnLabel.topAnchor.constraint(equalTo: self.matchLabel.bottomAnchor, constant: 5)
        ])

        // Bet info
        NSLayoutConstraint.activate([
            self.betAmountView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.betAmountView.topAnchor.constraint(equalTo: self.returnLabel.bottomAnchor, constant: 9),
            self.betAmountView.heightAnchor.constraint(equalToConstant: 42),

            self.betAmountTextField.leadingAnchor.constraint(equalTo: self.betAmountView.leadingAnchor, constant: 10),
            self.betAmountTextField.trailingAnchor.constraint(equalTo: self.betAmountView.trailingAnchor, constant: -10),
            self.betAmountTextField.centerYAnchor.constraint(equalTo: self.betAmountView.centerYAnchor),
            self.betAmountTextField.widthAnchor.constraint(equalToConstant: 110),

            self.betButtonsStackView.leadingAnchor.constraint(equalTo: self.betAmountView.trailingAnchor, constant: 10),
            self.betButtonsStackView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.betButtonsStackView.heightAnchor.constraint(equalToConstant: 42),
            self.betButtonsStackView.centerYAnchor.constraint(equalTo: self.betAmountView.centerYAnchor),

            self.finalBetButton.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 14),
            self.finalBetButton.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -14),
            self.finalBetButton.heightAnchor.constraint(equalToConstant: 42),
            self.finalBetButton.topAnchor.constraint(equalTo: self.betAmountView.bottomAnchor, constant: 10),
            self.finalBetButton.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor, constant: -12)
        ])

        // Error views
        NSLayoutConstraint.activate([
            self.lateralErrorView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.lateralErrorView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.lateralErrorView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),
            self.lateralErrorView.widthAnchor.constraint(equalToConstant: 6),

            self.bottomErrorView.leadingAnchor.constraint(equalTo: self.containerStackView.leadingAnchor),
            self.bottomErrorView.trailingAnchor.constraint(equalTo: self.containerStackView.trailingAnchor),

            self.iconErrorImageView.leadingAnchor.constraint(equalTo: self.bottomErrorView.leadingAnchor, constant: 14),
            self.iconErrorImageView.widthAnchor.constraint(equalToConstant: 17),
            self.iconErrorImageView.heightAnchor.constraint(equalTo: self.iconErrorImageView.widthAnchor),
            self.iconErrorImageView.centerYAnchor.constraint(equalTo: self.bottomErrorView.centerYAnchor),

            self.errorLabel.leadingAnchor.constraint(equalTo: self.iconErrorImageView.trailingAnchor, constant: 9),
            self.errorLabel.topAnchor.constraint(equalTo: self.bottomErrorView.topAnchor, constant: 13),
            self.errorLabel.bottomAnchor.constraint(equalTo: self.bottomErrorView.bottomAnchor, constant: -13),
            self.errorLabel.trailingAnchor.constraint(equalTo: self.closeErrorButton.leadingAnchor, constant: -9),

            self.closeErrorButton.trailingAnchor.constraint(equalTo: self.bottomErrorView.trailingAnchor, constant: 0),
            self.closeErrorButton.widthAnchor.constraint(equalToConstant: 40),
            self.closeErrorButton.heightAnchor.constraint(equalTo: self.closeErrorButton.widthAnchor),
            self.closeErrorButton.centerYAnchor.constraint(equalTo: self.bottomErrorView.centerYAnchor),

            self.bottomErrorIndicatorView.leadingAnchor.constraint(equalTo: self.bottomErrorView.leadingAnchor),
            self.bottomErrorIndicatorView.topAnchor.constraint(equalTo: self.bottomErrorView.topAnchor),
            self.bottomErrorIndicatorView.bottomAnchor.constraint(equalTo: self.bottomErrorView.bottomAnchor),
            self.bottomErrorIndicatorView.widthAnchor.constraint(equalToConstant: 6)
        ])

        // Success View
        NSLayoutConstraint.activate([
            self.successContainerView.leadingAnchor.constraint(equalTo: self.containerStackView.leadingAnchor, constant: 9),
            self.successContainerView.trailingAnchor.constraint(equalTo: self.containerStackView.trailingAnchor, constant: -9),
            // self.containerView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),

            self.successImageView.widthAnchor.constraint(equalToConstant: 64),
            self.successImageView.heightAnchor.constraint(equalToConstant: 48),
            self.successImageView.centerXAnchor.constraint(equalTo: self.successContainerView.centerXAnchor),
            self.successImageView.topAnchor.constraint(equalTo: self.successContainerView.topAnchor, constant: 25),

            self.titleLabel.leadingAnchor.constraint(equalTo: self.successContainerView.leadingAnchor, constant: 20),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.successContainerView.trailingAnchor, constant: -20),
            self.titleLabel.topAnchor.constraint(equalTo: self.successImageView.bottomAnchor, constant: 11),

            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.successContainerView.leadingAnchor, constant: 20),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.successContainerView.trailingAnchor, constant: -20),
            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 15),

            self.possibleWinningsTitleLabel.leadingAnchor.constraint(equalTo: self.successContainerView.leadingAnchor, constant: 20),
            self.possibleWinningsTitleLabel.trailingAnchor.constraint(equalTo: self.successContainerView.trailingAnchor, constant: -20),
            self.possibleWinningsTitleLabel.topAnchor.constraint(equalTo: self.subtitleLabel.bottomAnchor, constant: 20),

            self.possibleWinningsValueLabel.leadingAnchor.constraint(equalTo: self.successContainerView.leadingAnchor, constant: 20),
            self.possibleWinningsValueLabel.trailingAnchor.constraint(equalTo: self.successContainerView.trailingAnchor, constant: -20),
            self.possibleWinningsValueLabel.topAnchor.constraint(equalTo: self.possibleWinningsTitleLabel.bottomAnchor, constant: 8),

            self.continueButton.leadingAnchor.constraint(equalTo: self.successContainerView.leadingAnchor, constant: 21),
            self.continueButton.trailingAnchor.constraint(equalTo: self.successContainerView.trailingAnchor, constant: -21),
            self.continueButton.heightAnchor.constraint(equalToConstant: 42),
            self.continueButton.topAnchor.constraint(equalTo: self.possibleWinningsValueLabel.bottomAnchor, constant: 20),
            self.continueButton.bottomAnchor.constraint(equalTo: self.successContainerView.bottomAnchor, constant: -22)

        ])

        // Loading Screen
        NSLayoutConstraint.activate([
            self.loadingBaseView.topAnchor.constraint(equalTo: self.containerStackView.topAnchor),
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.containerStackView.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.containerStackView.trailingAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.containerStackView.bottomAnchor),

            self.activityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.activityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor)
        ])

        // Constraints
        self.containerCenterYConstraint = NSLayoutConstraint(item: self.containerStackView, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        self.containerCenterYConstraint.isActive = true

        self.containerBottomConstraint.isActive = false
    }
}

enum OddStatusType {
    case up
    case down
    case same
}
