//
//  LimitsOnRegisterViewController.swift
//  
//
//  Created by Ruben Roques on 27/01/2023.
//

import Foundation
import Foundation
import UIKit
import Theming
import ServicesProvider
import Combine
import HeaderTextField
import Extensions

public class LimitsOnRegisterViewModel {

    public enum LimitsOnRegisterError: Error {
        case depositFormatError
        case bettingFormatError
        case autoPayoutFormatError
        case depositServerError
        case bettingServerError
        case autoPayoutServerError
    }

    let servicesProvider: ServicesProviderClient

    private var isLoadingSubject: CurrentValueSubject<Bool, Never> = .init(false)
    var isLoading: AnyPublisher<Bool, Never> {
        return self.isLoadingSubject.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()

    public init(servicesProvider: ServicesProviderClient) {
        self.servicesProvider = servicesProvider
    }

    public func updateLimits(depositLimitString: String?, bettingLimitString: String?, autoPayoutLimitString: String?)
    -> AnyPublisher<Bool, LimitsOnRegisterError> {

        self.isLoadingSubject.send(true)

        var clearDepositLimitString = (depositLimitString ?? "").replacingOccurrences(of: "€", with: "")
        clearDepositLimitString = clearDepositLimitString.replacingOccurrences(of: "$", with: "")

        var clearBettingLimitString = (bettingLimitString ?? "").replacingOccurrences(of: "€", with: "")
        clearBettingLimitString = clearBettingLimitString.replacingOccurrences(of: "$", with: "")

        var clearAutoPayoutLimitString = (autoPayoutLimitString ?? "").replacingOccurrences(of: "€", with: "")
        clearAutoPayoutLimitString = clearAutoPayoutLimitString.replacingOccurrences(of: "$", with: "")

        guard
            let depositLimit = Double(clearDepositLimitString)
        else {
            self.isLoadingSubject.send(false)
            return Fail(error: LimitsOnRegisterError.depositFormatError).eraseToAnyPublisher()
        }

        guard
            let bettingLimit = Double(clearBettingLimitString)
        else {
            self.isLoadingSubject.send(false)
            return Fail(error: LimitsOnRegisterError.bettingFormatError).eraseToAnyPublisher()
        }

        guard
            let autoPayoutLimit = Double(clearAutoPayoutLimitString)
        else {
            self.isLoadingSubject.send(false)
            return Fail(error: LimitsOnRegisterError.autoPayoutFormatError).eraseToAnyPublisher()
        }

        let depositPublisher = servicesProvider.updateWeeklyDepositLimits(newLimit: depositLimit)
            .mapError { error in
                print("Error \(error)")
                return LimitsOnRegisterError.depositServerError
            }

        let bettingPublisher = servicesProvider.updateWeeklyBettingLimits(newLimit: bettingLimit)
            .mapError { error in
                print("Error \(error)")
                return LimitsOnRegisterError.bettingServerError
            }

        let autoPayoutPublisher = servicesProvider.updateResponsibleGamingLimits(newLimit: autoPayoutLimit)
            .mapError { error in
                print("Error \(error)")
                return LimitsOnRegisterError.autoPayoutServerError
            }

        return Publishers.Zip3(depositPublisher, bettingPublisher, autoPayoutPublisher)
            .map { (depositSuccess, bettingSuccess, autoPayoutSuccess) in
                return depositSuccess && bettingSuccess && autoPayoutSuccess
            }
            .handleEvents(receiveCompletion: { [weak self] _ in
                self?.isLoadingSubject.send(false)
            })
            .eraseToAnyPublisher()
    }

}

public class LimitsOnRegisterViewController: UIViewController {

    enum SelectedProfile {
        case none
        case beginner
        case intermediate
        case advanced
    }

    public var triggeredContinueAction: () -> Void = { }

    public var didTapBackButtonAction: () -> Void = { }
    public var didTapCancelButtonAction: () -> Void = { }

    private lazy var headerBaseView: UIView = Self.createHeaderBaseView()
    private lazy var backButton: UIButton = Self.createBackButton()
    private lazy var cancelButton: UIButton = Self.createCancelButton()

    private lazy var contentScrollView: UIScrollView = Self.createContentScrollView()
    private lazy var contentBaseView: UIView = Self.createContentBaseView()
    private lazy var titleLabel: UILabel = Self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = Self.createSubtitleLabel()

    private lazy var stackView: UIStackView = Self.createStackView()

    private lazy var playerTypeStackView: UIStackView = Self.createPlayerTypeStackView()

    private lazy var beginnerBaseView: UIView = Self.createPlayerTypeBaseView()
    private lazy var beginnerImageView: UIImageView = Self.createPlayerTypeImageView()
    private lazy var beginnerLabel: UILabel = Self.createPlayerTypeLabel()

    private lazy var intermediateBaseView: UIView = Self.createPlayerTypeBaseView()
    private lazy var intermediateImageView: UIImageView = Self.createPlayerTypeImageView()
    private lazy var intermediateLabel: UILabel = Self.createPlayerTypeLabel()

    private lazy var advancedBaseView: UIView = Self.createPlayerTypeBaseView()
    private lazy var advancedImageView: UIImageView = Self.createPlayerTypeImageView()
    private lazy var advancedLabel: UILabel = Self.createPlayerTypeLabel()

    private lazy var depositLimitHeaderTextFieldView: HeaderTextFieldView = Self.createHeaderTextFieldView()
    private lazy var bettingLimitHeaderTextFieldView: HeaderTextFieldView = Self.createHeaderTextFieldView()
    private lazy var autoPayoutHeaderTextFieldView: HeaderTextFieldView = Self.createHeaderTextFieldView()

    private lazy var footerBaseView: UIView = Self.createFooterBaseView()
    private lazy var continueButton: UIButton = Self.createContinueButton()

    private lazy var loadingBaseView: UIView = Self.createLoadingBaseView()
    private lazy var loadingView: UIActivityIndicatorView = Self.createLoadingView()

    var selectedProfile: SelectedProfile = .none {
        didSet {
            self.updateSelectedProfileBorders()
        }
    }

    private let viewModel: LimitsOnRegisterViewModel
    private var cancellables = Set<AnyCancellable>()

    public init(viewModel: LimitsOnRegisterViewModel) {
        self.viewModel = viewModel

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

        self.titleLabel.text = Localization.localized("limits_management")
        self.subtitleLabel.text = Localization.localized("limits_management_subtitle")

        self.beginnerImageView.image = UIImage(named: "level_beginner", in: Bundle.module, with: nil)
        self.intermediateImageView.image = UIImage(named: "level_intermediate", in: Bundle.module, with: nil)
        self.advancedImageView.image = UIImage(named: "level_advanced", in: Bundle.module, with: nil)

        self.beginnerLabel.text = Localization.localized("beginner")
        self.intermediateLabel.text = Localization.localized("intermediate")
        self.advancedLabel.text = Localization.localized("advanced")

        self.beginnerBaseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapBeginnerButton)))
        self.intermediateBaseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapIntermediateButton)))
        self.advancedBaseView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapAdvancedButton)))

        self.continueButton.setTitle(Localization.localized("continue_"), for: .normal)

        self.continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .primaryActionTriggered)

        self.cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .primaryActionTriggered)
        self.backButton.addTarget(self, action: #selector(didTapBackButton), for: .primaryActionTriggered)

        self.depositLimitHeaderTextFieldView.setPlaceholderText(Localization.localized("weekly_deposit_limit"))
        self.bettingLimitHeaderTextFieldView.setPlaceholderText(Localization.localized("weekly_betting_limit"))
        self.autoPayoutHeaderTextFieldView.setPlaceholderText(Localization.localized("auto_payout"))

        self.depositLimitHeaderTextFieldView.setKeyboardType(.numbersAndPunctuation)
        self.bettingLimitHeaderTextFieldView.setKeyboardType(.numbersAndPunctuation)
        self.autoPayoutHeaderTextFieldView.setKeyboardType(.numbersAndPunctuation)

        self.depositLimitHeaderTextFieldView.setCurrencyMode(true, currencySymbol: "€")
        self.bettingLimitHeaderTextFieldView.setCurrencyMode(true, currencySymbol: "€")
        self.autoPayoutHeaderTextFieldView.setCurrencyMode(true, currencySymbol: "€")

        self.depositLimitHeaderTextFieldView.setReturnKeyType(.next)
        self.depositLimitHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.bettingLimitHeaderTextFieldView.becomeFirstResponder()
        }

        self.bettingLimitHeaderTextFieldView.setReturnKeyType(.next)
        self.bettingLimitHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.autoPayoutHeaderTextFieldView.becomeFirstResponder()
        }

        self.autoPayoutHeaderTextFieldView.setReturnKeyType(.done)
        self.autoPayoutHeaderTextFieldView.didTapReturn = { [weak self] in
            self?.autoPayoutHeaderTextFieldView.resignFirstResponder()
        }

        self.backButton.isHidden = true
        self.cancelButton.isHidden = true
        
        self.viewModel.isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                self?.loadingBaseView.isHidden = !loading

                if loading {
                    self?.loadingView.startAnimating()
                }
                else {
                    self?.loadingView.stopAnimating()
                }
            }
            .store(in: &self.cancellables)

    }

    public override func viewDidLayoutSubviews() {
        self.beginnerImageView.layer.cornerRadius = self.beginnerImageView.frame.height/2
        self.intermediateImageView.layer.cornerRadius = self.intermediateImageView.frame.height/2
        self.advancedImageView.layer.cornerRadius = self.advancedImageView.frame.height/2
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.setupWithTheme()
    }

    private func setupWithTheme() {
        self.view.backgroundColor = AppColor.backgroundPrimary
        self.contentBaseView.backgroundColor = AppColor.backgroundPrimary

        self.titleLabel.textColor = AppColor.textPrimary
        self.subtitleLabel.textColor = AppColor.textPrimary

        // Continue button styling
        self.continueButton.setTitleColor(AppColor.buttonTextPrimary, for: .normal)
        self.continueButton.setTitleColor(AppColor.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        self.continueButton.setTitleColor(AppColor.buttonTextDisablePrimary, for: .disabled)

        self.continueButton.setBackgroundColor(AppColor.buttonBackgroundPrimary, for: .normal)
        self.continueButton.setBackgroundColor(AppColor.buttonBackgroundSecondary, for: .highlighted)

        self.continueButton.layer.cornerRadius = 8
        self.continueButton.layer.masksToBounds = true
        self.continueButton.backgroundColor = .clear

        self.depositLimitHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.depositLimitHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.depositLimitHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.bettingLimitHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.bettingLimitHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.bettingLimitHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

        self.autoPayoutHeaderTextFieldView.setViewColor(AppColor.inputBackground)
        self.autoPayoutHeaderTextFieldView.setHeaderLabelColor(AppColor.inputTextTitle)
        self.autoPayoutHeaderTextFieldView.setTextFieldColor(AppColor.inputText)

    }

    @objc func didTapBackButton() {
        self.didTapBackButtonAction()
    }

    @objc func didTapCancelButton() {
        self.didTapCancelButtonAction()
    }

    @objc func didTapContinueButton() {
        self.saveNewLimits()
    }

    @objc func didTapBeginnerButton() {
        self.selectedProfile = .beginner
        self.depositLimitHeaderTextFieldView.setText("200")
        self.bettingLimitHeaderTextFieldView.setText("500")
        self.autoPayoutHeaderTextFieldView.setText("251")
    }

    @objc func didTapIntermediateButton() {
        self.selectedProfile = .intermediate
        self.depositLimitHeaderTextFieldView.setText("500")
        self.bettingLimitHeaderTextFieldView.setText("1000")
        self.autoPayoutHeaderTextFieldView.setText("1001")
    }

    @objc func didTapAdvancedButton() {
        self.selectedProfile = .advanced
        self.depositLimitHeaderTextFieldView.setText("5000")
        self.bettingLimitHeaderTextFieldView.setText("10000")
        self.autoPayoutHeaderTextFieldView.setText("10001")
    }

    private func updateSelectedProfileBorders() {
        let borderColor = AppColor.highlightPrimary.cgColor
        let borderWidth: CGFloat = 2

        self.beginnerImageView.layer.borderWidth = (selectedProfile == .beginner) ? borderWidth : 0
        self.beginnerImageView.layer.borderColor = borderColor

        self.intermediateImageView.layer.borderWidth = (selectedProfile == .intermediate) ? borderWidth : 0
        self.intermediateImageView.layer.borderColor = borderColor

        self.advancedImageView.layer.borderWidth = (selectedProfile == .advanced) ? borderWidth : 0
        self.advancedImageView.layer.borderColor = borderColor
    }

    func saveNewLimits() {
        self.viewModel.updateLimits(depositLimitString: self.depositLimitHeaderTextFieldView.text,
                                    bettingLimitString: self.bettingLimitHeaderTextFieldView.text,
                                    autoPayoutLimitString: self.autoPayoutHeaderTextFieldView.text)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            switch completion {
            case .failure(let limitsOnRegisterError):
                switch limitsOnRegisterError {
                case .depositFormatError:
                    self?.depositLimitHeaderTextFieldView.showError(withMessage: Localization.localized("value_not_valid"))
                case .bettingFormatError:
                    self?.bettingLimitHeaderTextFieldView.showError(withMessage: Localization.localized("value_not_valid"))
                case .autoPayoutFormatError:
                    self?.bettingLimitHeaderTextFieldView.showError(withMessage: Localization.localized("value_not_valid"))
                case .depositServerError:
                    self?.depositLimitHeaderTextFieldView.showError(withMessage: Localization.localized("problem_setting_value"))
                case .bettingServerError:
                    self?.bettingLimitHeaderTextFieldView.showError(withMessage: Localization.localized("problem_setting_value"))
                case .autoPayoutServerError:
                    self?.bettingLimitHeaderTextFieldView.showError(withMessage: Localization.localized("problem_setting_value"))
                }
            case .finished:
                ()
            }
        } receiveValue: { [weak self] success in
            if success {
                self?.triggeredContinueAction()
            }
        }
        .store(in: &self.cancellables)

    }

}

public extension LimitsOnRegisterViewController {

    private static func createHeaderBaseView() -> UIView {
        let view = UIView()
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
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createSubtitleLabel() -> UILabel {
        let label = UILabel()
        label.font = AppFont.with(type: .bold, size: 16)
        label.textAlignment = .left
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }

    private static func createStackView() -> UIStackView {
        let stackview = UIStackView()
        stackview.distribution = .fill
        stackview.axis = .vertical
        stackview.spacing = 22
        stackview.translatesAutoresizingMaskIntoConstraints = false
        return stackview
    }

    private static func createPlayerTypeStackView() -> UIStackView {
        let stackview = UIStackView()
        stackview.distribution = .fillEqually
        stackview.axis = .horizontal
        stackview.spacing = 0
        stackview.translatesAutoresizingMaskIntoConstraints = false
        return stackview
    }

    private static func createPlayerTypeBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createPlayerTypeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private static func createPlayerTypeLabel() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 1
        label.font = AppFont.with(type: .bold, size: 14.0)
        return label
    }

    private static func createHeaderTextFieldView() -> HeaderTextFieldView {
        let headerTextFieldView = HeaderTextFieldView()
        headerTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        headerTextFieldView.translatesAutoresizingMaskIntoConstraints = false
        return headerTextFieldView
    }

    private static func createFooterBaseView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createContinueButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = AppFont.with(type: .bold, size: 18)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 8
        return button
    }

    private static func createLoadingBaseView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private static func createLoadingView() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func setupSubviews() {

        self.view.addSubview(self.headerBaseView)
        self.headerBaseView.addSubview(self.backButton)
        self.headerBaseView.addSubview(self.cancelButton)

        self.view.addSubview(self.contentScrollView)
        self.contentScrollView.addSubview(self.contentBaseView)

        self.contentBaseView.addSubview(self.titleLabel)
        self.contentBaseView.addSubview(self.subtitleLabel)

        let topPlaceholderView = UIView()
        topPlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        topPlaceholderView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            topPlaceholderView.heightAnchor.constraint(equalToConstant: 32)
        ])

        self.cancelButton.setTitleColor(AppColor.highlightPrimary, for: .normal)

        self.beginnerBaseView.addSubview(self.beginnerImageView)
        self.beginnerBaseView.addSubview(self.beginnerLabel)

        self.intermediateBaseView.addSubview(self.intermediateImageView)
        self.intermediateBaseView.addSubview(self.intermediateLabel)

        self.advancedBaseView.addSubview(self.advancedImageView)
        self.advancedBaseView.addSubview(self.advancedLabel)

        NSLayoutConstraint.activate([
            self.beginnerImageView.topAnchor.constraint(equalTo: self.beginnerBaseView.topAnchor),
            self.beginnerImageView.centerXAnchor.constraint(equalTo: self.beginnerBaseView.centerXAnchor),
            self.beginnerImageView.widthAnchor.constraint(equalTo: self.beginnerImageView.heightAnchor),
            self.beginnerImageView.widthAnchor.constraint(equalToConstant: 80),

            self.beginnerLabel.topAnchor.constraint(equalTo: self.beginnerImageView.bottomAnchor, constant: 8),
            self.beginnerLabel.leadingAnchor.constraint(equalTo: self.beginnerBaseView.leadingAnchor),
            self.beginnerLabel.centerXAnchor.constraint(equalTo: self.beginnerBaseView.centerXAnchor),
            self.beginnerLabel.bottomAnchor.constraint(equalTo: self.beginnerBaseView.bottomAnchor, constant: -10),
            self.beginnerLabel.heightAnchor.constraint(equalToConstant: 18),

            self.intermediateImageView.topAnchor.constraint(equalTo: self.intermediateBaseView.topAnchor),
            self.intermediateImageView.centerXAnchor.constraint(equalTo: self.intermediateBaseView.centerXAnchor),
            self.intermediateImageView.widthAnchor.constraint(equalTo: self.intermediateImageView.heightAnchor),
            self.intermediateImageView.widthAnchor.constraint(equalToConstant: 80),

            self.intermediateLabel.topAnchor.constraint(equalTo: self.intermediateImageView.bottomAnchor, constant: 8),
            self.intermediateLabel.leadingAnchor.constraint(equalTo: self.intermediateBaseView.leadingAnchor),
            self.intermediateLabel.centerXAnchor.constraint(equalTo: self.intermediateBaseView.centerXAnchor),
            self.intermediateLabel.bottomAnchor.constraint(equalTo: self.intermediateBaseView.bottomAnchor, constant: -10),
            self.intermediateLabel.heightAnchor.constraint(equalToConstant: 18),

            self.advancedImageView.topAnchor.constraint(equalTo: self.advancedBaseView.topAnchor),
            self.advancedImageView.centerXAnchor.constraint(equalTo: self.advancedBaseView.centerXAnchor),
            self.advancedImageView.widthAnchor.constraint(equalTo: self.advancedImageView.heightAnchor),
            self.advancedImageView.widthAnchor.constraint(equalToConstant: 80),

            self.advancedLabel.topAnchor.constraint(equalTo: self.advancedImageView.bottomAnchor, constant: 8),
            self.advancedLabel.leadingAnchor.constraint(equalTo: self.advancedBaseView.leadingAnchor),
            self.advancedLabel.centerXAnchor.constraint(equalTo: self.advancedBaseView.centerXAnchor),
            self.advancedLabel.bottomAnchor.constraint(equalTo: self.advancedBaseView.bottomAnchor, constant: -10),
            self.advancedLabel.heightAnchor.constraint(equalToConstant: 18),
        ])

        self.playerTypeStackView.addArrangedSubview(self.beginnerBaseView)
        self.playerTypeStackView.addArrangedSubview(self.intermediateBaseView)
        self.playerTypeStackView.addArrangedSubview(self.advancedBaseView)

        self.stackView.addArrangedSubview(topPlaceholderView)

        self.stackView.addArrangedSubview(self.playerTypeStackView)

        self.stackView.addArrangedSubview(self.depositLimitHeaderTextFieldView)
        self.stackView.addArrangedSubview(self.bettingLimitHeaderTextFieldView)
        self.stackView.addArrangedSubview(self.autoPayoutHeaderTextFieldView)

        self.contentBaseView.addSubview(self.stackView)

        self.view.addSubview(self.footerBaseView)
        self.footerBaseView.addSubview(self.continueButton)

        self.loadingBaseView.addSubview(self.loadingView)
        self.view.addSubview(self.loadingBaseView)

        self.initConstraints()
    }

    private func initConstraints() {

        NSLayoutConstraint.activate([
            self.headerBaseView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.headerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.headerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.headerBaseView.heightAnchor.constraint(equalToConstant: 68),

            self.headerBaseView.bottomAnchor.constraint(equalTo: self.contentScrollView.topAnchor),
            self.view.leadingAnchor.constraint(equalTo: self.contentScrollView.leadingAnchor),
            self.view.trailingAnchor.constraint(equalTo: self.contentScrollView.trailingAnchor),
            self.footerBaseView.topAnchor.constraint(equalTo: self.contentScrollView.bottomAnchor),

            self.contentBaseView.leadingAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.leadingAnchor),
            self.contentBaseView.topAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.topAnchor),
            self.contentBaseView.trailingAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.trailingAnchor),
            self.contentBaseView.bottomAnchor.constraint(equalTo: self.contentScrollView.contentLayoutGuide.bottomAnchor),

            self.contentBaseView.widthAnchor.constraint(equalTo: self.contentScrollView.frameLayoutGuide.widthAnchor),

            self.backButton.leadingAnchor.constraint(equalTo: self.headerBaseView.leadingAnchor, constant: 18),
            self.backButton.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.backButton.widthAnchor.constraint(equalTo: self.backButton.heightAnchor),
            self.backButton.widthAnchor.constraint(equalToConstant: 40),

            self.cancelButton.centerYAnchor.constraint(equalTo: self.headerBaseView.centerYAnchor),
            self.cancelButton.trailingAnchor.constraint(equalTo: self.headerBaseView.trailingAnchor, constant: -34),

            self.titleLabel.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor, constant: 8),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 34),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),

            self.subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 28),
            self.subtitleLabel.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 34),
            self.subtitleLabel.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),

            self.depositLimitHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.bettingLimitHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),
            self.autoPayoutHeaderTextFieldView.heightAnchor.constraint(equalToConstant: 80),

            self.stackView.topAnchor.constraint(equalTo: self.subtitleLabel.bottomAnchor, constant: -12),
            self.stackView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor, constant: 34),
            self.stackView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor, constant: -34),
            self.stackView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor, constant: -8),

            self.footerBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.footerBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.footerBaseView.heightAnchor.constraint(equalToConstant: 70),
            self.footerBaseView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),

            self.continueButton.centerXAnchor.constraint(equalTo: self.footerBaseView.centerXAnchor),
            self.continueButton.centerYAnchor.constraint(equalTo: self.footerBaseView.centerYAnchor),
            self.continueButton.leadingAnchor.constraint(equalTo: self.footerBaseView.leadingAnchor, constant: 34),
            self.continueButton.heightAnchor.constraint(equalToConstant: 50),

            self.loadingBaseView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.loadingBaseView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.loadingBaseView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.loadingBaseView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),

            self.loadingView.centerXAnchor.constraint(equalTo: self.loadingBaseView.centerXAnchor),
            self.loadingView.centerYAnchor.constraint(equalTo: self.loadingBaseView.centerYAnchor),
        ])

    }

}


/*
 self.stepsScrollView.topAnchor.constraint(equalTo: self.contentBaseView.topAnchor),
 self.stepsScrollView.bottomAnchor.constraint(equalTo: self.contentBaseView.bottomAnchor),
 self.stepsScrollView.leadingAnchor.constraint(equalTo: self.contentBaseView.leadingAnchor),
 self.stepsScrollView.trailingAnchor.constraint(equalTo: self.contentBaseView.trailingAnchor),

 */
