//
//  ProfileLimitsManagementViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 22/09/2021.
//

import UIKit
import Combine

class ProfileLimitsManagementViewController: UIViewController {

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private var editButton: UIButton!
    @IBOutlet private var depositView: UIView!
    @IBOutlet private var depositLabel: UILabel!
    @IBOutlet private var depositHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var depositFrequencySelectTextFieldView: SelectTextFieldView!
    @IBOutlet private var depositLineView: UIView!
    @IBOutlet private var bettingView: UIView!
    @IBOutlet private var bettingLabel: UILabel!
    @IBOutlet private var bettingHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var bettingFrequencySelectTextFieldView: SelectTextFieldView!
    @IBOutlet private var bettingLineView: UIView!
    @IBOutlet private var lossView: UIView!
    @IBOutlet private var lossLabel: UILabel!
    @IBOutlet private var lossHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var lossFrequencySelectHeaderTextFieldView: SelectTextFieldView!
    @IBOutlet private var lossLineView: UIView!
    @IBOutlet private var exclusionView: UIView!
    @IBOutlet private var exclusionLabel: UILabel!
    @IBOutlet private var exclusionSelectTextFieldView: SelectTextFieldView!
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    var viewModel: ProfileLimitsManagementViewModel
    private var cancellables: Set<AnyCancellable> = []

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

    var isDepositUpdatable: Bool = true {
        didSet {
            if isDepositUpdatable {
                self.depositHeaderTextFieldView.isDisabled = false
                self.depositFrequencySelectTextFieldView.isDisabled = false
            }
            else {
                self.depositHeaderTextFieldView.isDisabled = true
                self.depositFrequencySelectTextFieldView.isDisabled = true
            }
        }
    }

    var isWageringUpdatable: Bool = true {
        didSet {
            if isWageringUpdatable {
                self.bettingHeaderTextFieldView.isDisabled = false
                self.bettingFrequencySelectTextFieldView.isDisabled = false
            }
            else {
                self.bettingHeaderTextFieldView.isDisabled = true
                self.bettingFrequencySelectTextFieldView.isDisabled = true
            }
        }
    }

    var isLossUpdatable: Bool = true {
        didSet {
            if isLossUpdatable {
                self.lossHeaderTextFieldView.isDisabled = false
                self.lossFrequencySelectHeaderTextFieldView.isDisabled = false
            }
            else {
                self.lossHeaderTextFieldView.isDisabled = true
                self.lossFrequencySelectHeaderTextFieldView.isDisabled = true
            }
        }
    }

    init() {
        self.viewModel = ProfileLimitsManagementViewModel()

        super.init(nibName: "ProfileLimitsManagementViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupSubviews()
        commonInit()
        setupWithTheme()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        containerView.backgroundColor = UIColor.App.backgroundPrimary

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)

        headerView.backgroundColor = UIColor.App.backgroundPrimary

        backButton.backgroundColor = UIColor.App.backgroundPrimary
        backButton.setTitleColor(UIColor.App.textPrimary, for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.tintColor = UIColor.App.textPrimary

        headerLabel.textColor = UIColor.App.textPrimary

        editButton.backgroundColor = UIColor.App.backgroundPrimary

        depositView.backgroundColor = UIColor.App.backgroundPrimary

        depositLabel.textColor = UIColor.App.textPrimary

        depositHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        depositHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        depositHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
        depositHeaderTextFieldView.setSecureField(false)
        depositHeaderTextFieldView.setRemoveTextField()

        depositLineView.backgroundColor = UIColor.App.inputTextTitle.withAlphaComponent(0.2)

        bettingView.backgroundColor = UIColor.App.backgroundPrimary

        bettingLabel.textColor = UIColor.App.textPrimary

        bettingHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        bettingHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        bettingHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
        bettingHeaderTextFieldView.setSecureField(false)
        bettingHeaderTextFieldView.setRemoveTextField()

        bettingLineView.backgroundColor = UIColor.App.inputTextTitle.withAlphaComponent(0.2)

        lossView.backgroundColor = UIColor.App.backgroundPrimary

        lossLabel.textColor = UIColor.App.textPrimary

        lossHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        lossHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        lossHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
        lossHeaderTextFieldView.setSecureField(false)
        lossHeaderTextFieldView.setRemoveTextField()

        lossLineView.backgroundColor = UIColor.App.inputTextTitle.withAlphaComponent(0.2)

        exclusionView.backgroundColor = UIColor.App.backgroundPrimary

        exclusionLabel.textColor = UIColor.App.textPrimary

    }

    func commonInit() {

        self.isLoading = false

        headerLabel.font = AppFont.with(type: .semibold, size: 17)
        headerLabel.text = localized("limits_management")

        editButton.underlineButtonTitleLabel(title: localized("save"))

        depositLabel.text = localized("deposit_limit")
        depositLabel.font = AppFont.with(type: .semibold, size: 17)

        depositHeaderTextFieldView.setPlaceholderText(localized("deposit_limit"))
        if let infoImage = UIImage(named: "question_circle_icon") {
            depositHeaderTextFieldView.setImageTextField(infoImage)
        }
        depositHeaderTextFieldView.setKeyboardType(.decimalPad)
        depositHeaderTextFieldView.isCurrency = true
        depositHeaderTextFieldView.didTapIcon = { [weak self] in
            self?.setLimitAlertInfo(alertType: "deposit")

        }
        depositHeaderTextFieldView.didTapRemoveIcon = { [weak self] in
            if let period = self?.depositFrequencySelectTextFieldView.getPickerOption() {
                self?.showRemoveAlert(limitType: "Deposit", period: period)
            }

        }

        depositFrequencySelectTextFieldView.setSelectionPicker([localized("daily"), localized("weekly"), localized("monthly")])

        bettingLabel.text = localized("betting_limit")
        bettingLabel.font = AppFont.with(type: .semibold, size: 17)

        bettingHeaderTextFieldView.setPlaceholderText(localized("betting_limit"))
        if let infoImage = UIImage(named: "question_circle_icon") {
            bettingHeaderTextFieldView.setImageTextField(infoImage)
        }
        bettingHeaderTextFieldView.setKeyboardType(.numberPad)
        bettingHeaderTextFieldView.isCurrency = true
        bettingHeaderTextFieldView.didTapIcon = { [weak self] in
            self?.setLimitAlertInfo(alertType: "wagering")
        }

        bettingHeaderTextFieldView.didTapRemoveIcon = { [weak self] in
            if let period = self?.bettingFrequencySelectTextFieldView.getPickerOption() {
                self?.showRemoveAlert(limitType: "Wagering", period: period)
            }

        }

        bettingFrequencySelectTextFieldView.setSelectionPicker([localized("daily"), localized("weekly"), localized("monthly")])

        lossLabel.text = localized("loss_limit")
        lossLabel.font = AppFont.with(type: .semibold, size: 17)

        lossHeaderTextFieldView.setPlaceholderText(localized("loss_limit"))
        if let infoImage = UIImage(named: "question_circle_icon") {
            lossHeaderTextFieldView.setImageTextField(infoImage)
        }
        lossHeaderTextFieldView.setKeyboardType(.numberPad)
        lossHeaderTextFieldView.isCurrency = true
        lossHeaderTextFieldView.didTapIcon = { [weak self] in
            self?.setLimitAlertInfo(alertType: "loss")
        }

        lossHeaderTextFieldView.didTapRemoveIcon = { [weak self] in
            if let period = self?.lossFrequencySelectHeaderTextFieldView.getPickerOption() {
                self?.showRemoveAlert(limitType: "Loss", period: period)
            }

        }

        lossFrequencySelectHeaderTextFieldView.setSelectionPicker([localized("daily"), localized("weekly"), localized("monthly")])

        exclusionLabel.text = localized("auto_exclusion")
        exclusionLabel.font = AppFont.with(type: .semibold, size: 17)

        exclusionSelectTextFieldView.isIconArray = true
        exclusionSelectTextFieldView.setSelectionPicker([localized("active"), localized("limited"), localized("permanent")],
                                                        iconArray: [UIImage(named: "icon_active")!,
                                                                    UIImage(named: "icon_limited")!,
                                                                    UIImage(named: "icon_excluded")!])
        exclusionSelectTextFieldView.isDisabled = true

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        self.setupPublishers()
    }

    private func setupPublishers() {

        self.viewModel.limitsLoadedPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] loaded in
                if loaded {
                    self?.setupLimitsInfo()
                }
                else {
                    self?.isLoading = true
                }
            })
            .store(in: &cancellables)

        self.viewModel.limitOptionsCheckPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] limitOptions in
                if let viewModel = self?.viewModel {
                    if limitOptions == viewModel.limitOptionsSet && viewModel.limitOptionsSet.isNotEmpty {
                        self?.isLoading = false
                        self?.showAlert(type: .success)
                    }
                }
            })
            .store(in: &cancellables)

        self.viewModel.limitOptionsErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] errorText in
                if errorText != "" {
                    self?.showAlert(type: .error, errorText: errorText)
                }
            })
            .store(in: &cancellables)

    }

    private func setLimitAlertInfo(alertType: String) {

        if alertType == "deposit" {
            let alertText = self.viewModel.getAlertInfoText(alertType: alertType)
            let alertTitle = localized("deposit_limit")
            self.showFieldInfo(view: self.depositView, alertTitle: alertTitle, alertText: alertText)
        }
        else if alertType == "wagering" {
            let alertText = self.viewModel.getAlertInfoText(alertType: alertType)
            let alertTitle = localized("betting_limit")
            self.showFieldInfo(view: self.bettingView, alertTitle: alertTitle, alertText: alertText)
        }
        else if alertType == "loss" {
            let alertText = self.viewModel.getAlertInfoText(alertType: alertType)
            let alertTitle = localized("loss_limit")
            self.showFieldInfo(view: self.lossView, alertTitle: alertTitle, alertText: alertText)
        }

    }

    private func setupLimitsInfo() {

        // Check deposit infot
        if let depositLimit = self.viewModel.depositLimit {
            if let limitAmount = depositLimit.current?.amount {
                let amountString = "\(limitAmount)"
                self.depositHeaderTextFieldView.setText(amountString.currencyTypeFormatting())
            }

            if let limitPeriod = depositLimit.current?.period {
                self.depositFrequencySelectTextFieldView.setDefaultPickerOption(option: limitPeriod, lowerCasedString: true)
            }

            if depositLimit.updatable {
                self.isDepositUpdatable = true
            }
            else {
                self.isDepositUpdatable = false
            }
        }

        // Check wagering info
        if let wageringLimit = self.viewModel.getWageringOption() {
            if let wageringAmount = wageringLimit.current?.amount {
                let amountString = "\(wageringAmount)"
                self.bettingHeaderTextFieldView.setText(amountString.currencyTypeFormatting())
            }

            if let wageringPeriod = wageringLimit.current?.period {
                self.bettingFrequencySelectTextFieldView.setDefaultPickerOption(option: wageringPeriod, lowerCasedString: true)
            }

            if wageringLimit.updatable {
                self.isWageringUpdatable = true
            }
            else {
                self.isWageringUpdatable = false
            }
        }

        if let lossLimit = self.viewModel.getLossOption() {
            if let lossAmount = lossLimit.current?.amount {
                let amountString = "\(lossAmount)"
                self.lossHeaderTextFieldView.setText(amountString.currencyTypeFormatting())
            }

            if let lossPeriod = lossLimit.current?.period {
                self.lossFrequencySelectHeaderTextFieldView.setDefaultPickerOption(option: lossPeriod, lowerCasedString: true)
            }

            if lossLimit.updatable {
                self.isLossUpdatable = true
            }
            else {
                self.isLossUpdatable = false
            }
        }

        self.isLoading = false
    }

    func showFieldInfo(view: UIView, alertTitle: String = "", alertText: String = "") {
        let infoView = EditAlertView()
        infoView.alertState = .info

        if alertTitle != "" {
            infoView.setAlertTitle(alertTitle)
        }

        if alertText != "" {
            infoView.setAlertText(alertText)
        }

        infoView.hasBorder = true

        view.addSubview(infoView)
        NSLayoutConstraint.activate([
            infoView.topAnchor.constraint(equalTo: view.topAnchor),
            infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            infoView.widthAnchor.constraint(lessThanOrEqualToConstant: 300)
        ])

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
            infoView.alpha = 1
        } completion: { _ in
        }

        infoView.onClose = {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) {
                infoView.alpha = 0
            } completion: { _ in
                infoView.removeFromSuperview()
            }
        }
    }

    private func showRemoveAlert(limitType: String, period: String) {
        let removeLimitAlert = UIAlertController(title: localized("remove_limit"), message: localized("remove_limit_warning"), preferredStyle: UIAlertController.Style.alert)

        removeLimitAlert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { _ in
            self.viewModel.removeLimit(limitType: limitType, period: period)
        }))

        removeLimitAlert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel))

        self.present(removeLimitAlert, animated: true, completion: nil)
    }

    private func saveLimitsOptions() {
        self.isLoading = true

        let acceptedInputs = Set("0123456789.,")

        if self.viewModel.canUpdateDeposit {
            let period = self.depositFrequencySelectTextFieldView.getPickerOption()
            let amountString = self.depositHeaderTextFieldView.text
            let amountFiltered = String( amountString.filter{acceptedInputs.contains($0)} )
            let amount = amountFiltered.replacingOccurrences(of: ",", with: ".")

            let currency = Env.userSessionStore.userBalanceWallet.value?.currency ?? ""

            self.viewModel.sendLimit(limitType: "Deposit", period: period, amount: amount, currency: currency)

        }
        else if self.viewModel.canUpdateWagering {
            let period = self.bettingFrequencySelectTextFieldView.getPickerOption()
            let amountString = self.bettingHeaderTextFieldView.text
            let amountFiltered = String( amountString.filter{acceptedInputs.contains($0)} )
            let amount = amountFiltered.replacingOccurrences(of: ",", with: ".")

            let currency = Env.userSessionStore.userBalanceWallet.value?.currency ?? ""

            self.viewModel.sendLimit(limitType: "Wagering", period: period, amount: amount, currency: currency)

        }
        else if self.viewModel.canUpdateLoss {
            let period = self.lossFrequencySelectHeaderTextFieldView.getPickerOption()
            let amountString = self.lossHeaderTextFieldView.text
            let amountFiltered = String( amountString.filter{acceptedInputs.contains($0)} )
            let amount = amountFiltered.replacingOccurrences(of: ",", with: ".")

            let currency = Env.userSessionStore.userBalanceWallet.value?.currency ?? ""

            self.viewModel.sendLimit(limitType: "Loss", period: period, amount: amount, currency: currency)

        }
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.depositHeaderTextFieldView.resignFirstResponder()
        self.bettingHeaderTextFieldView.resignFirstResponder()
        self.lossHeaderTextFieldView.resignFirstResponder()
    }

    @IBAction private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func editAction() {

        self.viewModel.checkLimitUpdatableStatus(limitType: "deposit",
                                                 limitAmount: self.depositHeaderTextFieldView.text,
                                                 limitPeriod: self.depositFrequencySelectTextFieldView.getPickerOption(),
                                                 isLimitUpdatable: isDepositUpdatable)

        self.viewModel.checkLimitUpdatableStatus(limitType: "wagering",
                                                 limitAmount: self.bettingHeaderTextFieldView.text,
                                                 limitPeriod: self.bettingFrequencySelectTextFieldView.getPickerOption(),
                                                 isLimitUpdatable: isWageringUpdatable)

        self.viewModel.checkLimitUpdatableStatus(limitType: "loss",
                                                 limitAmount: self.lossHeaderTextFieldView.text,
                                                 limitPeriod: self.lossFrequencySelectHeaderTextFieldView.getPickerOption(),
                                                 isLimitUpdatable: isLossUpdatable)

        self.saveLimitsOptions()

    }

    @objc func keyboardWillShow(notification: NSNotification) {

        guard
            let userInfo = notification.userInfo,
            var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        else {
            return
        }
        
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 20
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: NSNotification) {

        let contentInset: UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }

}

extension ProfileLimitsManagementViewController {
    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingActivityIndicatorView() -> UIActivityIndicatorView {
        let activityIndicatorView = UIActivityIndicatorView.init(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }

    private func setupSubviews() {
        self.containerView.addSubview(self.loadingBaseView)
        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.containerView.bringSubviewToFront(self.loadingBaseView)

        self.initConstraints()
    }

    private func initConstraints() {
        NSLayoutConstraint.activate([
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor),
            self.loadingBaseView.topAnchor.constraint(equalTo: self.containerView.topAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.containerView.bottomAnchor),

            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor),
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor)
        ])
    }
}
