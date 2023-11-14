//
//  SelfExclusionViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 01/03/2023.
//

import UIKit
import Combine
import HeaderTextField

class SelfExclusionViewController: UIViewController {

    // MARK: Private Properties
    private lazy var topView: UIView = Self.createTopView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var topTitleLabel: UILabel = Self.createTopTitleLabel()
    private lazy var editButton: UIButton = Self.createEditButton()
    private lazy var infoIconImageView: UIImageView = Self.createInfoIconImageView()
    private lazy var infoLabel: UILabel = Self.createInfoLabel()
    private lazy var exclusionSelectTextFieldView: DropDownSelectionView = Self.createExclusionSelectTextFieldView()
    private lazy var periodValuesView: UIView = Self.createPeriodValuesView()
    private lazy var periodTypeSelectTextFieldView: DropDownSelectionView = Self.createPeriodTypeSelectTextFieldView()
    private lazy var periodValueHeaderTextFieldView: HeaderTextField.HeaderTextFieldView = Self.createPeriodValueHeaderTextFieldView()

    private lazy var footerResponsibleGamingView: FooterResponsibleGamingView = Self.createFooterResponsibleGamingView()
    
    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingActivityIndicatorView: UIActivityIndicatorView = Self.createLoadingActivityIndicatorView()

    private var cancellables: Set<AnyCancellable> = []

    // MARK: Public Properties
    var viewModel: SelfExclusionViewModel

    var periodTypeSelected: String?
    var isValidPeriodValue: CurrentValueSubject<Bool, Never> = .init(false)

    var shouldShowPeriodOptions: Bool = false {
        didSet {
            self.periodValuesView.isHidden = !shouldShowPeriodOptions
        }
    }

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

    // MARK: Lifetime and Cycle
    init(viewModel: SelfExclusionViewModel) {

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
        
        self.footerResponsibleGamingView.hideLinksView()
        self.footerResponsibleGamingView.hideSocialView()
        
        self.setupWithTheme()

        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)

        self.editButton.addTarget(self, action: #selector(didTapEditButton), for: .touchUpInside)

        self.bind(toViewModel: self.viewModel)

        self.setupPublishers()

        self.isLoading = false
    }

    // MARK: Layout and Theme
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.topView.backgroundColor = UIColor.App.backgroundPrimary

        self.backButton.backgroundColor = UIColor.App.backgroundPrimary
        self.backButton.setTitleColor(UIColor.App.textPrimary, for: .normal)
        self.backButton.setTitle("", for: .normal)
        self.backButton.tintColor = UIColor.App.textPrimary

        self.topTitleLabel.textColor = UIColor.App.textPrimary

        self.editButton.backgroundColor = UIColor.App.backgroundPrimary
        self.editButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)

        self.exclusionSelectTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        self.exclusionSelectTextFieldView.setTextFieldColor(UIColor.App.inputText)
        self.exclusionSelectTextFieldView.setViewColor(UIColor.App.backgroundPrimary)
        self.exclusionSelectTextFieldView.setViewBorderColor(UIColor.App.inputTextTitle)

        self.periodTypeSelectTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        self.periodTypeSelectTextFieldView.setTextFieldColor(UIColor.App.inputText)
        self.periodTypeSelectTextFieldView.setViewColor(UIColor.App.backgroundPrimary)
        self.periodTypeSelectTextFieldView.setViewBorderColor(UIColor.App.inputTextTitle)

        self.periodValueHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        self.periodValueHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        self.periodValueHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
    }

    // MARK: Binding
    private func bind(toViewModel viewModel: SelfExclusionViewModel) {

        viewModel.isLockedPlayer
            .sink(receiveValue: { [weak self] isLocked in
                if isLocked {
                    self?.dismiss(animated: true)
                }
            })
            .store(in: &cancellables)

        viewModel.shouldShowAlert
            .receive(on: DispatchQueue.main)
            .dropFirst()
            .sink(receiveValue: { [weak self] alertType in

                switch alertType {
                case .success:
                    self?.showAlert(alertType: .success)
                case .error:
                    self?.showAlert(alertType: .error)
                }
            })
            .store(in: &cancellables)
    }

    // MARK: Functions
    private func setupPublishers() {

        self.exclusionSelectTextFieldView.textPublisher
            .sink(receiveValue: { [weak self] textOption in
                if textOption == localized("custom") {
                    self?.shouldShowPeriodOptions = true
                }
                else {
                    self?.shouldShowPeriodOptions = false
                }
            })
            .store(in: &cancellables)

        Publishers.CombineLatest(periodTypeSelectTextFieldView.textPublisher, periodValueHeaderTextFieldView.textPublisher)
            .sink(receiveValue: { [weak self] periodType, periodValue in

                if let periodTypeSelected = self?.periodTypeSelected {

                    if periodType != periodTypeSelected {
                        self?.periodValueHeaderTextFieldView.setText("1")
                        self?.periodTypeSelected = periodType
                        return
                    }
                }
                else {
                    self?.periodTypeSelected = periodType
                    self?.periodValueHeaderTextFieldView.setText("1")
                }

                if let periodNumber = Int(periodValue ?? "") {

                    if periodType == localized("days") {
                        if periodNumber > 0 && periodNumber <= 365 {

                            self?.isValidPeriodValue.send(true)
                        }
                        else if periodNumber <= 0 {
                            self?.periodValueHeaderTextFieldView.setText("1")
                            self?.showPeriodError(periodValueTypeError: .lowValue, periodValue: "1")
                        }
                        else if periodNumber > 365 {
                            self?.periodValueHeaderTextFieldView.setText("365")
                            self?.showPeriodError(periodValueTypeError: .highValue, periodValue: "365")
                        }

                    }
                    else if periodType == localized("weeks") {

                        if periodNumber > 0 && periodNumber <= 52 {

                            self?.isValidPeriodValue.send(true)

                        }
                        else if periodNumber <= 0 {
                            self?.periodValueHeaderTextFieldView.setText("1")
                            self?.showPeriodError(periodValueTypeError: .lowValue, periodValue: "1")
                        }
                        else if periodNumber > 52 {
                            self?.periodValueHeaderTextFieldView.setText("52")
                            self?.showPeriodError(periodValueTypeError: .highValue, periodValue: "52")
                        }
                    }
                    else if periodType == localized("months") {
                        if periodNumber > 0 && periodNumber <= 12 {

                            self?.isValidPeriodValue.send(true)

                        }
                        else if periodNumber <= 0 {
                            self?.periodValueHeaderTextFieldView.setText("1")
                            self?.showPeriodError(periodValueTypeError: .lowValue, periodValue: "1")
                        }
                        else if periodNumber > 12 {
                            self?.periodValueHeaderTextFieldView.setText("12")
                            self?.showPeriodError(periodValueTypeError: .highValue, periodValue: "12")
                        }
                    }
                }
            })
            .store(in: &cancellables)
    }

    private func showAlert(alertType: AlertType) {

        switch alertType {
        case .success:
            let alert = UIAlertController(title: localized("lock_account_success"),
                                          message: localized("lock_account_success_message"),
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in
                
                Env.userSessionStore.logout()
                self?.dismiss(animated: true)
            }))

            self.present(alert, animated: true, completion: nil)
        case .error:
            let alert = UIAlertController(title: localized("lock_account_error"),
                                          message: localized("lock_account_error_message"),
                                          preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: nil))

            self.present(alert, animated: true, completion: nil)
        }

    }

    private func showPeriodError(periodValueTypeError: PeriodValueTypeError, periodValue: String) {

        var message = ""

        switch periodValueTypeError {
        case .lowValue:
            message = localized("value_less_than").replacingFirstOccurrence(of: "{value}", with: periodValue)
        case .highValue:
            message = localized("value_greater_than").replacingFirstOccurrence(of: "{value}", with: periodValue)
        }

        let periodAlert = UIAlertController(title: localized("invalid_period_value"),
                                                 message: message,
                                                 preferredStyle: UIAlertController.Style.alert)

        periodAlert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { _ in
            periodAlert.dismiss(animated: true)
        }))

        self.present(periodAlert, animated: true, completion: nil)

    }

    private func saveSelfExclusionOptions() {
        if self.exclusionSelectTextFieldView.textPublisher.value != localized("not_excluded") {

            let lockPeriodUnit = self.periodTypeSelected ?? ""

            let lockPeriod = self.periodValueHeaderTextFieldView.text

            self.viewModel.lockPlayer(lockPeriodUnit: lockPeriodUnit, lockPeriod: lockPeriod)
        }
    }
}

//
// MARK: - Actions
//
extension SelfExclusionViewController {
    @objc private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func didTapEditButton() {

        var lockPeriodUnit = self.periodTypeSelected ?? ""

        let lockPeriod = self.periodValueHeaderTextFieldView.text

        if lockPeriodUnit == "Days" {
            if lockPeriod == "1" {
                lockPeriodUnit = localized("day").lowercased()
            }
            else{
                lockPeriodUnit = localized("days").lowercased()
            }
        }
        else if lockPeriodUnit == "Weeks" {
            if lockPeriod == "1" {
                lockPeriodUnit = localized("week").lowercased()
            }
            else{
                lockPeriodUnit = localized("weeks").lowercased()
            }        }
        else if lockPeriodUnit == "Months" {
            if lockPeriod == "1" {
                lockPeriodUnit = localized("month").lowercased()
            }
            else{
                lockPeriodUnit = localized("months").lowercased()
            }

        }

        var message = localized("lock_account_alert_text").replacingFirstOccurrence(of: "{value}", with: lockPeriod)
            .replacingFirstOccurrence(of: "{period}", with: lockPeriodUnit)

        if lockPeriod == "1" {
            message = localized("lock_account_alert_text").replacingFirstOccurrence(of: "{value}", with: "")
                .replacingFirstOccurrence(of: "  ", with: " ")
                .replacingFirstOccurrence(of: "{period}", with: lockPeriodUnit)
        }

        let alert = UIAlertController(title: localized("self_exclusion"),
                                      message: message,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: localized("ok"), style: .default, handler: { [weak self] _ in

            self?.saveSelfExclusionOptions()

        }))

        alert.addAction(UIAlertAction(title: localized("cancel"), style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
}

//
// MARK: Subviews initialization and setup
//
extension SelfExclusionViewController {

    private static func createTopView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createBackButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.setImage(UIImage(named: "arrow_back_icon"), for: .normal)
        button.contentMode = .scaleAspectFit
        return button
    }

    private static func createTopTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("self_exclusion")
        label.font = AppFont.with(type: .bold, size: 20)
        label.textAlignment = .center
        return label
    }

    private static func createEditButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(localized("save"), for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 15)
        return button
    }

    private static func createInfoIconImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "info_blue_icon")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }

    private static func createInfoLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = localized("block_account_info")
        label.font = AppFont.with(type: .semibold, size: 14)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }

    private static func createExclusionSelectTextFieldView() -> DropDownSelectionView {
        let dropDownView = DropDownSelectionView()
        dropDownView.translatesAutoresizingMaskIntoConstraints = false
        dropDownView.setSelectionPicker([localized("not_excluded"), localized("custom")])
        return dropDownView
    }

    private static func createPeriodValuesView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createPeriodTypeSelectTextFieldView() -> DropDownSelectionView {
        let dropDownView = DropDownSelectionView()
        dropDownView.translatesAutoresizingMaskIntoConstraints = false
        dropDownView.setSelectionPicker([localized("days"), localized("weeks"), localized("months")])
        return dropDownView
    }

    private static func createPeriodValueHeaderTextFieldView() -> HeaderTextField.HeaderTextFieldView {
        let headerTextFieldView = HeaderTextField.HeaderTextFieldView()
        headerTextFieldView.setPlaceholderText(localized("period_value"))
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setKeyboardType(.numberPad)
        headerTextFieldView.setSecureField(false)
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

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

    
    private static func createInterdictionTitleBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }

    private static func createInterdictionTitleLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.textAlignment = .left
        label.text = localized("voluntary_gambling_ban_title")
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textColor = UIColor.App.highlightPrimary
        return label
    }
    
    private static func createInterdictionDetailsBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }

    private static func createInterdictionDetailsLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        label.text = localized("voluntary_gambling_ban_description")
        label.font = AppFont.with(type: .semibold, size: 12)
        label.textColor = UIColor.App.textPrimary
        return label
    }
    
    private static func createFooterResponsibleGamingView() -> FooterResponsibleGamingView {
        let view = FooterResponsibleGamingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showLinksView()
        view.showSocialView()
        return view
    }
    
    private func setupSubviews() {
        self.view.addSubview(self.topView)

        self.topView.addSubview(self.backButton)
        self.topView.addSubview(self.topTitleLabel)
        self.topView.addSubview(self.editButton)

        self.view.addSubview(self.infoIconImageView)
        self.view.addSubview(self.infoLabel)

        self.view.addSubview(self.exclusionSelectTextFieldView)

        self.view.addSubview(self.periodValuesView)

        self.periodValuesView.addSubview(self.periodTypeSelectTextFieldView)
        self.periodValuesView.addSubview(self.periodValueHeaderTextFieldView)

        self.view.addSubview(self.footerResponsibleGamingView)
        
        self.view.addSubview(self.loadingBaseView)

        self.loadingBaseView.addSubview(self.loadingActivityIndicatorView)

        self.initConstraints()
    }

    private func initConstraints() {

        // Top bar
        NSLayoutConstraint.activate([
            self.topView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.topView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.topView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.topView.heightAnchor.constraint(equalToConstant: 44),

            self.backButton.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor),
            self.backButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),
            self.backButton.heightAnchor.constraint(equalToConstant: 44),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.topTitleLabel.leadingAnchor.constraint(equalTo: self.topView.leadingAnchor, constant: 40),
            self.topTitleLabel.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -40),
            self.topTitleLabel.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor),

            self.editButton.trailingAnchor.constraint(equalTo: self.topView.trailingAnchor, constant: -8),
            self.editButton.heightAnchor.constraint(equalToConstant: 44),
            self.editButton.centerYAnchor.constraint(equalTo: self.topView.centerYAnchor)

        ])

        // Main view
        NSLayoutConstraint.activate([

            self.infoIconImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.infoIconImageView.widthAnchor.constraint(equalToConstant: 28),
            self.infoIconImageView.heightAnchor.constraint(equalTo: self.infoIconImageView.widthAnchor),
            self.infoIconImageView.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 30),

            self.infoLabel.leadingAnchor.constraint(equalTo: self.infoIconImageView.trailingAnchor, constant: 11),
            self.infoLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.infoLabel.topAnchor.constraint(equalTo: self.topView.bottomAnchor, constant: 30),

            self.exclusionSelectTextFieldView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.exclusionSelectTextFieldView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.exclusionSelectTextFieldView.topAnchor.constraint(equalTo: self.infoLabel.bottomAnchor, constant: 33),

            self.periodValuesView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            self.periodValuesView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            self.periodValuesView.topAnchor.constraint(equalTo: self.exclusionSelectTextFieldView.bottomAnchor, constant: 10),

            self.periodTypeSelectTextFieldView.leadingAnchor.constraint(equalTo: self.periodValuesView.leadingAnchor),
            self.periodTypeSelectTextFieldView.trailingAnchor.constraint(equalTo: self.periodValuesView.centerXAnchor, constant: -4),
            self.periodTypeSelectTextFieldView.heightAnchor.constraint(equalToConstant: 60),
            self.periodTypeSelectTextFieldView.topAnchor.constraint(equalTo: self.periodValuesView.topAnchor, constant: 8),
            self.periodTypeSelectTextFieldView.bottomAnchor.constraint(equalTo: self.periodValuesView.bottomAnchor, constant: -20),

            self.periodValueHeaderTextFieldView.leadingAnchor.constraint(equalTo: self.periodValuesView.centerXAnchor, constant: 4),
            self.periodValueHeaderTextFieldView.trailingAnchor.constraint(equalTo: self.periodValuesView.trailingAnchor),
            self.periodValueHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 75),
            self.periodValueHeaderTextFieldView.topAnchor.constraint(equalTo: self.periodTypeSelectTextFieldView.topAnchor, constant: 8)
        ])

        // Loading View
        NSLayoutConstraint.activate([
            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.loadingActivityIndicatorView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.loadingActivityIndicatorView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.footerResponsibleGamingView.leadingAnchor.constraint(equalTo: self.exclusionSelectTextFieldView.leadingAnchor),
            self.footerResponsibleGamingView.trailingAnchor.constraint(equalTo: self.exclusionSelectTextFieldView.trailingAnchor),
            
            self.footerResponsibleGamingView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }

}
