//
//  PasswordUpdateViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 20/09/2021.
//

import UIKit
import Combine

class PasswordUpdateViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private var editButton: UIButton!
    @IBOutlet private var oldPasswordHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var newPasswordHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var confirmPasswordHeaderTextFieldView: HeaderTextFieldView!

    @IBOutlet private var tipTitleLabel: UILabel!
    @IBOutlet private var lengthTipLabel: UILabel!
    @IBOutlet private var uppercaseTipLabel: UILabel!
    @IBOutlet private var lowercaseTipLabel: UILabel!
    @IBOutlet private var numbersTipLabel: UILabel!
    @IBOutlet private var symbolsTipLabel: UILabel!

    @IBOutlet private var separatorLineView: UIView!
    @IBOutlet private var securityQuestionLabel: UILabel!
    @IBOutlet private var securityQuestionHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var securityAnswerHeaderTextFieldView: HeaderTextFieldView!

    @IBOutlet private var loadingBaseView: UIView!
    @IBOutlet private var loadingActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var scrollView: UIScrollView!

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

    private var canSavePassword: Bool = false

    var cancellables = Set<AnyCancellable>()
    var passwordRegex: String = ""
    var passwordRegexMessage: String = ""

    var viewModel: PasswordUpdateViewModel

    init() {
        self.viewModel = PasswordUpdateViewModel()

        super.init(nibName: "PasswordUpdateViewController", bundle: nil)
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

        if !Env.servicesProvider.hasSecurityQuestions() {
            self.hideSecurityQuestionLayout()
        }

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func commonInit() {
        self.headerLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 17)
        self.headerLabel.text = localized("account_security")

        self.self.editButton.setTitle(localized("save"), for: .normal)
        editButton.titleLabel?.font = AppFont.with(type: .bold, size: 16)

        self.tipTitleLabel.text = localized("protect_account")
        self.numbersTipLabel.text = "• \(localized("fourth_password_requirement"))"
        self.uppercaseTipLabel.text = "• \(localized("second_password_requirement"))"
        self.lowercaseTipLabel.text = "• \(localized("third_password_requirement"))"
        let symbols = "-!@^$&*+"
        self.symbolsTipLabel.text = "• \(localized("fifth_password_requirement").replacingOccurrences(of: "{symbols}", with: symbols))"
        self.lengthTipLabel.text = "• \(localized("first_password_requirement"))"

        self.tipTitleLabel.font = AppFont.with(type: .semibold, size: 13)
        self.numbersTipLabel.font = AppFont.with(type: .semibold, size: 12)
        self.uppercaseTipLabel.font = AppFont.with(type: .semibold, size: 12)
        self.lowercaseTipLabel.font = AppFont.with(type: .semibold, size: 12)
        self.symbolsTipLabel.font = AppFont.with(type: .semibold, size: 12)
        self.lengthTipLabel.font = AppFont.with(type: .semibold, size: 12)

        self.tipTitleLabel.numberOfLines = 2
        self.numbersTipLabel.numberOfLines = 2
        self.uppercaseTipLabel.numberOfLines = 2
        self.lowercaseTipLabel.numberOfLines = 2
        self.symbolsTipLabel.numberOfLines = 2
        self.lengthTipLabel.numberOfLines = 2

        self.oldPasswordHeaderTextFieldView.setPlaceholderText(localized("old_password"))
        self.newPasswordHeaderTextFieldView.setPlaceholderText(localized("new_password"))
        self.confirmPasswordHeaderTextFieldView.setPlaceholderText(localized("confirm_password"))

        self.oldPasswordHeaderTextFieldView.setSecureField(true)
        self.oldPasswordHeaderTextFieldView.showPasswordLabelVisible(visible: false)

        self.newPasswordHeaderTextFieldView.setSecureField(true)

        self.confirmPasswordHeaderTextFieldView.setSecureField(true)

        
        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        self.editButton.isEnabled = false

        self.securityQuestionLabel.text = localized("security_question")
        self.securityQuestionLabel.font = AppFont.with(type: .bold, size: 17)

        self.securityQuestionHeaderTextFieldView.setPlaceholderText(localized("security_question"))

        self.securityAnswerHeaderTextFieldView.setPlaceholderText(localized("security_answer"))



    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        self.containerView.backgroundColor = UIColor.App.backgroundPrimary
        
        self.headerView.backgroundColor = UIColor.App.backgroundPrimary
        self.headerLabel.textColor = UIColor.App.textPrimary

        self.editButton.backgroundColor = .clear
        self.editButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        self.editButton.setTitleColor(UIColor.App.highlightPrimary, for: .highlighted)
        self.editButton.setTitleColor(UIColor.App.textDisablePrimary, for: .disabled)

        self.oldPasswordHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        self.oldPasswordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        self.oldPasswordHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        self.newPasswordHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        self.newPasswordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        self.newPasswordHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        self.confirmPasswordHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        self.confirmPasswordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        self.confirmPasswordHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        self.separatorLineView.backgroundColor = UIColor.App.separatorLine

        self.securityQuestionLabel.textColor = UIColor.App.textPrimary

        self.securityQuestionHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        self.securityQuestionHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        self.securityQuestionHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        self.securityAnswerHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        self.securityAnswerHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        self.securityAnswerHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        self.loadingBaseView.backgroundColor = UIColor.App.backgroundPrimary.withAlphaComponent(0.7)

        self.scrollView.backgroundColor = UIColor.App.backgroundPrimary

        self.tipTitleLabel.textColor = UIColor.App.textPrimary
        self.lengthTipLabel.textColor = UIColor.App.textPrimary
        self.uppercaseTipLabel.textColor = UIColor.App.textPrimary
        self.lowercaseTipLabel.textColor = UIColor.App.textPrimary
        self.numbersTipLabel.textColor = UIColor.App.textPrimary
        self.symbolsTipLabel.textColor = UIColor.App.textPrimary

    }

    private func bind(toViewModel viewModel: PasswordUpdateViewModel) {

        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isLoading in
                if isLoading {
                    self?.isLoading = true
                }
                else {
                    self?.isLoading = false
                }
            })
            .store(in: &cancellables)

        viewModel.shouldShowAlertPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] alertInfo in
                if let alertInfo = alertInfo {
                    self?.showAlert(type: alertInfo.alertType, text: alertInfo.message)
                }
            })
            .store(in: &cancellables)

        let validNewPasswordPublisher = self.viewModel.passwordState
            .map { states in
                return states.count == 1 && states.contains(.valid)
            }

        let validConfirmPasswordPublisher = Publishers.CombineLatest(self.newPasswordHeaderTextFieldView.textPublisher,
                                                                     self.confirmPasswordHeaderTextFieldView.textPublisher)
            .map { newPassword, confirmPassword in
                if let newPassword, let confirmPassword, confirmPassword != newPassword {
                    return false
                }
                return true
            }

        self.newPasswordHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newPassword in
                self?.newPasswordHeaderTextFieldView.hideTipAndError()
                self?.viewModel.setPassword(newPassword ?? "")
            }
            .store(in: &self.cancellables)

        let editButtonEnabledPublisher = Publishers.CombineLatest(validConfirmPasswordPublisher, validNewPasswordPublisher).map { return $0 && $1 }

        self.viewModel.passwordState
            .sink { passwordStates in

                let allLabels = [self.lengthTipLabel,
                                 self.uppercaseTipLabel,
                                 self.lowercaseTipLabel,
                                 self.numbersTipLabel,
                                 self.symbolsTipLabel].compactMap({ $0 })

                if passwordStates.contains(.empty) {
                    for label in allLabels {
                        self.resetTipLabel(label: label)
                    }
                }

                var errorLabels: Set<UILabel> = []

                if passwordStates.contains(.short) || passwordStates.contains(.long) {
                    errorLabels.insert(self.lengthTipLabel)
                }

                if passwordStates.contains(.invalidChars) {
                    errorLabels.insert(self.symbolsTipLabel)
                }

                if passwordStates.contains(.onlyNumbers) {
                    errorLabels.insert(self.lowercaseTipLabel)
                    errorLabels.insert(self.uppercaseTipLabel)
                    errorLabels.insert(self.symbolsTipLabel)
                }

                if passwordStates.contains(.needLowercase) {
                    errorLabels.insert(self.lowercaseTipLabel)
                }
                if passwordStates.contains(.needUppercase) {
                    errorLabels.insert(self.uppercaseTipLabel)
                }
                if passwordStates.contains(.needNumber) {
                    errorLabels.insert(self.numbersTipLabel)
                }
                if passwordStates.contains(.needSpecial) {
                    errorLabels.insert(self.symbolsTipLabel)
                }

                for label in allLabels where !errorLabels.contains(label) {
                    self.markTipLabelCompleted(label: label)
                }

                for label in errorLabels {
                    self.markTipLabelError(label: label)
                }

                if errorLabels.isEmpty {
                    self.markTipLabelCompleted(label: self.tipTitleLabel)
                }
                else {
                    self.resetTipLabel(label: self.tipTitleLabel)
                }

            }
            .store(in: &self.cancellables)

        validConfirmPasswordPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] validConfirmPassword in
                if validConfirmPassword {
                    self?.confirmPasswordHeaderTextFieldView.hideTipAndError()
                }
                else {
                    self?.confirmPasswordHeaderTextFieldView.showErrorOnField(text: localized("password_not_match"))
                }
            }
            .store(in: &self.cancellables)

        editButtonEnabledPublisher.sink(receiveValue: { [weak self] enabled in
            self?.editButton.isEnabled = enabled
        })
        .store(in: &self.cancellables)

    }

    func showAlert(type: EditAlertView.AlertState, text: String = "") {

        let popup = EditAlertView()
        popup.alertState = type
        if text != "" {
            popup.setAlertText(text)
        }
        
        popup.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(popup)

        NSLayoutConstraint.activate([
            popup.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            popup.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            popup.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])

        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            popup.alpha = 1
        }, completion: { _ in
        })

        popup.onClose = {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
                popup.alpha = 0
            }, completion: { _ in
                popup.removeFromSuperview()
            })

        }
        self.view.bringSubviewToFront(popup)
    }

    private func hideSecurityQuestionLayout() {
        self.separatorLineView.isHidden = true
        self.securityQuestionLabel.isHidden = true
        self.securityQuestionHeaderTextFieldView.isHidden = true
        self.securityAnswerHeaderTextFieldView.isHidden = true
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.oldPasswordHeaderTextFieldView.resignFirstResponder()
        self.newPasswordHeaderTextFieldView.resignFirstResponder()
        self.confirmPasswordHeaderTextFieldView.resignFirstResponder()
        self.securityQuestionHeaderTextFieldView.resignFirstResponder()
        self.securityAnswerHeaderTextFieldView.resignFirstResponder()
    }

    @IBAction private func editAction() {
        self.newPasswordHeaderTextFieldView.hideTipAndError()
        self.confirmPasswordHeaderTextFieldView.hideTipAndError()

        self.viewModel.savePassword(oldPassword: oldPasswordHeaderTextFieldView.text,
                                    newPassword: newPasswordHeaderTextFieldView.text)
    }

    @IBAction private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    private func resetTipLabel(label: UILabel) {
        label.alpha = 1.0
        label.textColor = UIColor.App.textPrimary
    }

    private func markTipLabelCompleted(label: UILabel) {
        label.textColor = UIColor.App.alertSuccess
        UIView.animate(withDuration: 0.2) {
            label.alpha = 0.37
        }
    }

    private func markTipLabelError(label: UILabel) {
        label.textColor = UIColor.App.textPrimary
        UIView.animate(withDuration: 0.2) {
            label.alpha = 1.0
        }
    }

}
