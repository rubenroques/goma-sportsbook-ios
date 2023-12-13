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
    @IBOutlet private var depositFrequencySelectTextFieldView: DropDownSelectionView!
    @IBOutlet private var depositQueuedInfoLabel: UILabel!
    @IBOutlet private var depositLineView: UIView!

    @IBOutlet private var bettingView: UIView!
    @IBOutlet private var bettingLabel: UILabel!
    @IBOutlet private var bettingHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var bettingFrequencySelectTextFieldView: DropDownSelectionView!
    @IBOutlet private var bettingQueuedInfoLabel: UILabel!
    @IBOutlet private var bettingLineView: UIView!

    @IBOutlet private var lossView: UIView!
    @IBOutlet private var lossLabel: UILabel!
    @IBOutlet private var lossHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var lossFrequencySelectHeaderTextFieldView: DropDownSelectionView!
    @IBOutlet private var lossQueuedInfoLabel: UILabel!
    @IBOutlet private var lossLineView: UIView!

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

    var shouldShowDepositPeriods: Bool = true {
        didSet {
            if shouldShowDepositPeriods {
                self.depositFrequencySelectTextFieldView.isHidden = false
                self.bettingFrequencySelectTextFieldView.isHidden = false
                self.lossFrequencySelectHeaderTextFieldView.isHidden = false
            }
            else {
                self.depositFrequencySelectTextFieldView.isHidden = true
                self.bettingFrequencySelectTextFieldView.isHidden = true
                self.lossFrequencySelectHeaderTextFieldView.isHidden = true
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

        self.shouldShowDepositPeriods = false

        self.lossLineView.isHidden = true

        self.depositQueuedInfoLabel.isHidden = true
        self.bettingQueuedInfoLabel.isHidden = true
        self.lossQueuedInfoLabel.isHidden = true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
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
        //depositHeaderTextFieldView.setRemoveTextField()

        depositLineView.backgroundColor = UIColor.App.inputTextTitle.withAlphaComponent(0.2)

        bettingView.backgroundColor = UIColor.App.backgroundPrimary

        bettingLabel.textColor = UIColor.App.textPrimary

        bettingHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        bettingHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        bettingHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
        bettingHeaderTextFieldView.setSecureField(false)
        //bettingHeaderTextFieldView.setRemoveTextField()

        bettingLineView.backgroundColor = UIColor.App.inputTextTitle.withAlphaComponent(0.2)

        lossView.backgroundColor = UIColor.App.backgroundPrimary

        lossLabel.textColor = UIColor.App.textPrimary

        lossHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        lossHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        lossHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
        lossHeaderTextFieldView.setSecureField(false)
        //lossHeaderTextFieldView.setRemoveTextField()

        lossLineView.backgroundColor = UIColor.App.inputTextTitle.withAlphaComponent(0.2)

        depositFrequencySelectTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        depositFrequencySelectTextFieldView.setTextFieldColor(UIColor.App.inputText)
        depositFrequencySelectTextFieldView.setViewColor(UIColor.App.backgroundPrimary)
        depositFrequencySelectTextFieldView.setViewBorderColor(UIColor.App.inputTextTitle)

        bettingFrequencySelectTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        bettingFrequencySelectTextFieldView.setTextFieldColor(UIColor.App.inputText)
        bettingFrequencySelectTextFieldView.setViewColor(UIColor.App.backgroundPrimary)
        bettingFrequencySelectTextFieldView.setViewBorderColor(UIColor.App.inputTextTitle)

        lossFrequencySelectHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        lossFrequencySelectHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
        lossFrequencySelectHeaderTextFieldView.setViewColor(UIColor.App.backgroundPrimary)
        lossFrequencySelectHeaderTextFieldView.setViewBorderColor(UIColor.App.inputTextTitle)

        self.depositQueuedInfoLabel.textColor = UIColor.App.textPrimary

        self.bettingQueuedInfoLabel.textColor = UIColor.App.textPrimary

        self.lossQueuedInfoLabel.textColor = UIColor.App.textPrimary

    }

    func commonInit() {

        self.isLoading = false

        headerLabel.font = AppFont.with(type: .bold, size: 20)
        headerLabel.text = localized("limits_management")

        editButton.titleLabel?.font = AppFont.with(type: .bold, size: 15)
        editButton.setTitle(localized("save"), for: .normal)

        //
        //
        depositLabel.text = localized("weekly_deposit_limit")
        depositLabel.font = AppFont.with(type: .semibold, size: 17)

        depositHeaderTextFieldView.setPlaceholderText(localized("weekly_deposit_limit"))
        if let infoImage = UIImage(named: "info_blue_icon") {
            depositHeaderTextFieldView.setImageTextField(infoImage)
        }
        depositHeaderTextFieldView.setKeyboardType(.decimalPad)
        depositHeaderTextFieldView.isCurrency = true
        depositHeaderTextFieldView.hasSeparatorSpace = true
        depositHeaderTextFieldView.didTapIcon = { [weak self] in
            self?.setLimitAlertInfo(alertType: LimitType.deposit.identifier.lowercased())

        }
        depositHeaderTextFieldView.didTapRemoveIcon = { [weak self] in
            if let period = self?.depositFrequencySelectTextFieldView.text {
                self?.showRemoveAlert(limitType: LimitType.deposit.identifier, period: period)
            }
        }

        depositFrequencySelectTextFieldView.setSelectionPicker([localized("daily"), localized("weekly"), localized("monthly")])

        //
        //
        bettingLabel.text = localized("weekly_betting_limit")
        bettingLabel.font = AppFont.with(type: .semibold, size: 17)

        bettingHeaderTextFieldView.setPlaceholderText(localized("weekly_betting_limit"))
        if let infoImage = UIImage(named: "info_blue_icon") {
            bettingHeaderTextFieldView.setImageTextField(infoImage)
        }
        bettingHeaderTextFieldView.setKeyboardType(.numberPad)
        bettingHeaderTextFieldView.isCurrency = true
        bettingHeaderTextFieldView.hasSeparatorSpace = true
        bettingHeaderTextFieldView.didTapIcon = { [weak self] in
            self?.setLimitAlertInfo(alertType: LimitType.wagering.identifier.lowercased())
        }

        bettingHeaderTextFieldView.didTapRemoveIcon = { [weak self] in
            if let period = self?.bettingFrequencySelectTextFieldView.text {
                self?.showRemoveAlert(limitType: LimitType.wagering.identifier, period: period)
            }
        }
        bettingFrequencySelectTextFieldView.setSelectionPicker([localized("daily"), localized("weekly"), localized("monthly")])

        //
        //
        lossLabel.text = localized("auto_payout")
        lossLabel.font = AppFont.with(type: .semibold, size: 17)

        lossHeaderTextFieldView.setPlaceholderText(localized("auto_payout"))
        if let infoImage = UIImage(named: "info_blue_icon") {
            lossHeaderTextFieldView.setImageTextField(infoImage)
        }
        lossHeaderTextFieldView.setKeyboardType(.numberPad)
        lossHeaderTextFieldView.isCurrency = true
        lossHeaderTextFieldView.hasSeparatorSpace = true
        lossHeaderTextFieldView.didTapIcon = { [weak self] in
            self?.setLimitAlertInfo(alertType: LimitType.loss.identifier.lowercased())
        }

        lossHeaderTextFieldView.didTapRemoveIcon = { [weak self] in
            if let period = self?.lossFrequencySelectHeaderTextFieldView.text {
                self?.showRemoveAlert(limitType: LimitType.loss.identifier, period: period)
            }
        }
        lossFrequencySelectHeaderTextFieldView.setSelectionPicker([localized("daily"), localized("weekly"), localized("monthly")])

        self.depositQueuedInfoLabel.font = AppFont.with(type: .bold, size: 14)
        self.depositQueuedInfoLabel.numberOfLines = 0

        self.bettingQueuedInfoLabel.font = AppFont.with(type: .bold, size: 14)
        self.bettingQueuedInfoLabel.numberOfLines = 0

        self.lossQueuedInfoLabel.font = AppFont.with(type: .bold, size: 14)
        self.lossQueuedInfoLabel.numberOfLines = 0

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
                        self?.viewModel.isLoadingPublisher.send(false)
                        if viewModel.limitOptionsErrorPublisher.value == "" {
                            self?.showAlert(type: .success)

                        }
                        self?.viewModel.refetchLimits()
                    }

                }
            })
            .store(in: &cancellables)

        self.viewModel.isDepositLimitUpdated
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isUpdated in
                if isUpdated {
                    self?.saveBettingLimit()
                }
            })
            .store(in: &cancellables)

        self.viewModel.isBettingLimitUpdated
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isUpdated in
                if isUpdated {
                    self?.saveAutoPayoutLimit()
                }
            })
            .store(in: &cancellables)

        self.viewModel.limitOptionsErrorPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] errorText in
                if errorText != "" {
                    self?.viewModel.isLoadingPublisher.send(false)
                    self?.showAlert(type: .error, alertText: errorText)
                    // self?.viewModel.getLimits()
                }
            })
            .store(in: &cancellables)

        self.viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in

                self?.isLoading = isLoading
            })
            .store(in: &cancellables)

    }

    private func setLimitAlertInfo(alertType: String) {

        if alertType == LimitType.deposit.identifier.lowercased() {
            let alertText = self.viewModel.getAlertInfoText(alertType: alertType)
            let alertTitle = localized("deposit_limit")
            self.showFieldInfo(view: self.depositView, alertTitle: alertTitle, alertText: alertText)
        }
        else if alertType == LimitType.wagering.identifier.lowercased() {
            let alertText = self.viewModel.getAlertInfoText(alertType: alertType)
            let alertTitle = localized("betting_limit")
            self.showFieldInfo(view: self.bettingView, alertTitle: alertTitle, alertText: alertText)

        }
        else if alertType == LimitType.loss.identifier.lowercased() {
            let alertText = self.viewModel.getAlertInfoText(alertType: alertType)
            let alertTitle = localized("auto_payout_limit")
            self.showFieldInfo(view: self.lossView, alertTitle: alertTitle, alertText: alertText)

        }

    }

    private func setupLimitsInfo() {
        let currencyFormatter = CurrencyFormater()

        // Check deposit infot
        if let depositLimit = self.viewModel.depositLimit {
            if let limitAmount = depositLimit.current?.amount {
                let amountString = "\(limitAmount)"
                let amountFormatted = currencyFormatter.currencyTypeWithSeparatorFormatting(string: amountString)
                self.depositHeaderTextFieldView.setText(amountFormatted)
            }

            if depositLimit.updatable {
                self.isDepositUpdatable = true
            }
            else {
                self.isDepositUpdatable = false
            }

            if let pendingDepositLimitMessage = self.viewModel.pendingDepositLimitMessage {
                self.depositQueuedInfoLabel.text = pendingDepositLimitMessage
                self.depositQueuedInfoLabel.isHidden = false
            }
        }

        // Check wagering info
        if let wageringLimit = self.viewModel.wageringLimit {
            if let wageringAmount = wageringLimit.current?.amount {
                let amountString = "\(wageringAmount)"
                let amountFormatted = currencyFormatter.currencyTypeWithSeparatorFormatting(string: amountString)
                self.bettingHeaderTextFieldView.setText(amountFormatted)
            }

            if wageringLimit.updatable {
                self.isWageringUpdatable = true
            }
            else {
                self.isWageringUpdatable = false
            }

            if let pendingBettingLimitMessage = self.viewModel.pendingWageringLimitMessage {
                self.bettingQueuedInfoLabel.text = pendingBettingLimitMessage
                self.bettingQueuedInfoLabel.isHidden = false
            }
        }

        // Auto payout limit
        if let autoPayoutLimit = self.viewModel.autoPayoutLimit {
            if let autoPayoutAmount = autoPayoutLimit.current?.amount {
                let amountString = "\(autoPayoutAmount)"
                let amountFormatted = currencyFormatter.currencyTypeWithSeparatorFormatting(string: amountString)
                self.lossHeaderTextFieldView.setText(amountFormatted)
            }

            if autoPayoutLimit.updatable {
                self.isLossUpdatable = true
            }
            else {
                self.isLossUpdatable = false
            }

            if let pendingAutoPayoutLimitMessage = self.viewModel.pendingLossLimitMessage {
                self.lossQueuedInfoLabel.text = pendingAutoPayoutLimitMessage
                self.lossQueuedInfoLabel.isHidden = false
            }
        }

        self.viewModel.isLoadingPublisher.send(false)
    }

//    private func setupLimitsInfo() {
//        let currencyFormatter = CurrencyFormater()
//        // Check deposit infot
//        if let depositLimit = self.viewModel.depositLimit {
//            if let limitAmount = depositLimit.current?.amount {
//                let amountString = "\(limitAmount)"
//                let amountFormatted = currencyFormatter.currencyTypeFormatting(string: amountString)
//                self.depositHeaderTextFieldView.setText(amountFormatted)
//            }
//
//            if let limitPeriod = depositLimit.current?.period {
//                self.depositFrequencySelectTextFieldView.setText(limitPeriod.lowercased())
//            }
//
//            if depositLimit.updatable {
//                self.isDepositUpdatable = true
//            }
//            else {
//                self.isDepositUpdatable = false
//            }
//        }
//
//        // Check wagering info
//        if let wageringLimit = self.viewModel.getWageringOption() {
//            if let wageringAmount = wageringLimit.current?.amount {
//                let amountString = "\(wageringAmount)"
//                let amountFormatted = currencyFormatter.currencyTypeFormatting(string: amountString)
//                self.bettingHeaderTextFieldView.setText(amountFormatted)
//            }
//
//            if let wageringPeriod = wageringLimit.current?.period {
//                self.bettingFrequencySelectTextFieldView.setText(wageringPeriod.lowercased())
//            }
//
//            if wageringLimit.updatable {
//                self.isWageringUpdatable = true
//            }
//            else {
//                self.isWageringUpdatable = false
//            }
//        }
//
//        if let lossLimit = self.viewModel.getLossOption() {
//            if let lossAmount = lossLimit.current?.amount {
//                let amountString = "\(lossAmount)"
//                let amountFormatted = currencyFormatter.currencyTypeFormatting(string: amountString)
//                self.lossHeaderTextFieldView.setText(amountFormatted)
//            }
//
//            if let lossPeriod = lossLimit.current?.period {
//                self.lossFrequencySelectHeaderTextFieldView.setText(lossPeriod.lowercased())
//            }
//
//            if lossLimit.updatable {
//                self.isLossUpdatable = true
//            }
//            else {
//                self.isLossUpdatable = false
//            }
//        }
//
//        self.isLoading = false
//    }

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
        let removeLimitAlert = UIAlertController(title: localized("remove_limit"),
                                                 message: localized("remove_limit_warning"),
                                                 preferredStyle: UIAlertController.Style.alert)

        removeLimitAlert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { _ in
            self.viewModel.removeLimit(limitType: limitType, period: period)
        }))

        removeLimitAlert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel))

        self.present(removeLimitAlert, animated: true, completion: nil)
    }

    private func saveDepositLimit() {

        let acceptedInputs = Set("0123456789.,")

        if self.viewModel.canUpdateDeposit {
            self.viewModel.isLoadingPublisher.send(true)

            let period = self.depositFrequencySelectTextFieldView.text
            let amountString = self.depositHeaderTextFieldView.text
            let amountFiltered = String( amountString.filter { acceptedInputs.contains($0)
            })
            let amount = amountFiltered.replacingOccurrences(of: ",", with: ".").replacingOccurrences(of: " ", with: "")

            if let depositAmount = self.viewModel.depositLimit?.current?.amount,
               let currentAmount = Double(amount),
               currentAmount > depositAmount {
                let title = localized("increasing_limit_warning_title").replacingFirstOccurrence(of: "{depositOrBetting}", with: localized("deposit_text"))
                let message = localized("increasing_limit_warning_text").replacingFirstOccurrence(of: "{depositOrBetting}", with: localized("deposit_text"))

                let alert = UIAlertController(title: title,
                                              message: message,
                                              preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in

                    self?.viewModel.updateDepositLimit(amount: amount)

                }))

                alert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel, handler: { [weak self] _ in
                    self?.viewModel.isLoadingPublisher.send(false)
                }))

                self.present(alert, animated: true, completion: nil)
            }
            else {
                self.viewModel.updateDepositLimit(amount: amount)

            }
        }
        else {
            self.saveBettingLimit()
        }
    }

    private func saveBettingLimit() {

        let acceptedInputs = Set("0123456789.,")

        if self.viewModel.canUpdateWagering {
            self.viewModel.isLoadingPublisher.send(true)
            let period = self.bettingFrequencySelectTextFieldView.text
            let amountString = self.bettingHeaderTextFieldView.text
            let amountFiltered = String( amountString.filter { acceptedInputs.contains($0)
            })
            let amount = amountFiltered.replacingOccurrences(of: ",", with: ".").replacingOccurrences(of: " ", with: "")

            if let bettingAmount = self.viewModel.wageringLimit?.current?.amount,
               let currentAmount = Double(amount),
               currentAmount > bettingAmount {
                let title = localized("increasing_limit_warning_title").replacingFirstOccurrence(of: "{depositOrBetting}", with: localized("betting"))
                let message = localized("increasing_limit_warning_text").replacingFirstOccurrence(of: "{depositOrBetting}", with: localized("betting"))

                let alert = UIAlertController(title: title,
                                              message: message,
                                              preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in

                    self?.viewModel.updateBettingLimit(amount: amount)

                }))

                alert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel, handler: { [weak self] _ in
                    self?.viewModel.isLoadingPublisher.send(false)
                }))

                self.present(alert, animated: true, completion: nil)
            }
            else {
                self.viewModel.updateBettingLimit(amount: amount)

            }

        }
        else {
            self.saveAutoPayoutLimit()
        }
    }

    private func saveAutoPayoutLimit() {

        let acceptedInputs = Set("0123456789.,")

        if self.viewModel.canUpdateLoss {
            self.viewModel.isLoadingPublisher.send(true)

            let period = self.lossFrequencySelectHeaderTextFieldView.text
            let amountString = self.lossHeaderTextFieldView.text
            let amountFiltered = String( amountString.filter{ acceptedInputs.contains($0)} )
            let amount = amountFiltered.replacingOccurrences(of: ",", with: ".").replacingOccurrences(of: " ", with: "")

            self.viewModel.updateResponsibleGamingLimit(amount: amount)

        }
        else {
            self.viewModel.isLoadingPublisher.send(false)
        }
    }

//    private func saveLimitsOptions() {
//        self.viewModel.isLoadingPublisher.send(true)
//
//        let acceptedInputs = Set("0123456789.,")
//
//        var updatedLimits = false
//
//        if self.viewModel.canUpdateDeposit {
//            let period = self.depositFrequencySelectTextFieldView.text
//            let amountString = self.depositHeaderTextFieldView.text
//            let amountFiltered = String( amountString.filter { acceptedInputs.contains($0)
//            })
//            let amount = amountFiltered.replacingOccurrences(of: ",", with: ".")
//
//            if let depositAmount = self.viewModel.depositLimit?.current?.amount,
//               let currentAmount = Double(amount),
//               currentAmount > depositAmount {
//                let title = localized("increasing_limit_warning_title").replacingFirstOccurrence(of: "{}", with: localized("deposit"))
//                let message = localized("increasing_limit_warning_text").replacingFirstOccurrence(of: "{}", with: localized("deposit"))
//
//                let alert = UIAlertController(title: title,
//                                              message: message,
//                                              preferredStyle: .alert)
//
//                alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in
//
//                    self?.viewModel.updateDepositLimit(amount: amount)
//
//                    updatedLimits = true
//                }))
//
//                alert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel, handler: nil))
//
//                self.present(alert, animated: true, completion: nil)
//            }
//            else {
//                self.viewModel.updateDepositLimit(amount: amount)
//
//                updatedLimits = true
//            }
//        }
//
//        if self.viewModel.canUpdateWagering {
//            let period = self.bettingFrequencySelectTextFieldView.text
//            let amountString = self.bettingHeaderTextFieldView.text
//            let amountFiltered = String( amountString.filter { acceptedInputs.contains($0)
//            })
//            let amount = amountFiltered.replacingOccurrences(of: ",", with: ".")
//
//            if let bettingAmount = self.viewModel.wageringLimit?.current?.amount,
//               let currentAmount = Double(amount),
//               currentAmount > bettingAmount {
//                let title = localized("increasing_limit_warning_title").replacingFirstOccurrence(of: "{}", with: localized("betting"))
//                let message = localized("increasing_limit_warning_text").replacingFirstOccurrence(of: "{}", with: localized("betting"))
//
//                let alert = UIAlertController(title: title,
//                                              message: message,
//                                              preferredStyle: .alert)
//
//                alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in
//
//                    self?.viewModel.updateBettingLimit(amount: amount)
//
//                    updatedLimits = true
//                }))
//
//                alert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel, handler: nil))
//
//                self.present(alert, animated: true, completion: nil)
//            }
//            else {
//                self.viewModel.updateBettingLimit(amount: amount)
//
//                updatedLimits = true
//            }
//
//        }
//
//        if self.viewModel.canUpdateLoss {
//            let period = self.lossFrequencySelectHeaderTextFieldView.text
//            let amountString = self.lossHeaderTextFieldView.text
//            let amountFiltered = String( amountString.filter{ acceptedInputs.contains($0)} )
//            let amount = amountFiltered.replacingOccurrences(of: ",", with: ".")
//
//            self.viewModel.updateResponsibleGamingLimit(amount: amount)
//
//            updatedLimits = true
//
//        }
//
//        if !updatedLimits {
//            self.viewModel.isLoadingPublisher.send(false)
//        }
//    }

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

        self.viewModel.cleanLimitOptions()

        self.viewModel.checkLimitUpdatableStatus(limitType: LimitType.deposit.identifier.lowercased(),
                                                 limitAmount: self.depositHeaderTextFieldView.text,
                                                 isLimitUpdatable: isDepositUpdatable)

        self.viewModel.checkLimitUpdatableStatus(limitType: LimitType.wagering.identifier.lowercased(),
                                                 limitAmount: self.bettingHeaderTextFieldView.text,
                                                 isLimitUpdatable: isWageringUpdatable)

        self.viewModel.checkLimitUpdatableStatus(limitType: LimitType.loss.identifier.lowercased(),
                                                 limitAmount: self.lossHeaderTextFieldView.text,
                                                 isLimitUpdatable: isLossUpdatable)

        self.saveDepositLimit()

//        self.viewModel.checkLimitUpdatableStatus(limitType: LimitType.deposit.identifier.lowercased(),
//                                                 limitAmount: self.depositHeaderTextFieldView.text,
//                                                 limitPeriod: self.depositFrequencySelectTextFieldView.text,
//                                                 isLimitUpdatable: isDepositUpdatable)
//
//        self.viewModel.checkLimitUpdatableStatus(limitType: LimitType.wagering.identifier.lowercased(),
//                                                 limitAmount: self.bettingHeaderTextFieldView.text,
//                                                 limitPeriod: self.bettingFrequencySelectTextFieldView.text,
//                                                 isLimitUpdatable: isWageringUpdatable)
//
//        self.viewModel.checkLimitUpdatableStatus(limitType: LimitType.loss.identifier.lowercased(),
//                                                 limitAmount: self.lossHeaderTextFieldView.text,
//                                                 limitPeriod: self.lossFrequencySelectHeaderTextFieldView.text,
//                                                 isLimitUpdatable: isLossUpdatable)

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

enum PeriodValueTypeError {
    case lowValue
    case highValue
}
