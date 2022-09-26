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
    @IBOutlet private var separatorLineView: UIView!
    @IBOutlet private var securityQuestionLabel: UILabel!
    @IBOutlet private var securityQuestionHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var securityAnswerHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var loadingBaseView: UIView!
    @IBOutlet private var loadingActivityIndicatorView: UIActivityIndicatorView!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var passwordPolicyLabel: UILabel!

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
    private var canSaveSecurityInfo: Bool = false

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

        commonInit()
        setupWithTheme()

        self.bind(toViewModel: self.viewModel)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupWithTheme()
    }

    func commonInit() {
        headerLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 17)
        headerLabel.text = localized("account_security")

        editButton.setTitle(localized("save"), for: .normal)
        editButton.titleLabel?.font = AppFont.with(type: .bold, size: 16)

        oldPasswordHeaderTextFieldView.setPlaceholderText(localized("old_password"))
        newPasswordHeaderTextFieldView.setPlaceholderText(localized("new_password"))
        confirmPasswordHeaderTextFieldView.setPlaceholderText(localized("confirm_password"))

        oldPasswordHeaderTextFieldView.setSecureField(true)
        oldPasswordHeaderTextFieldView.showPasswordLabelVisible(visible: false)

        newPasswordHeaderTextFieldView.setSecureField(true)


        confirmPasswordHeaderTextFieldView.setSecureField(true)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        editButton.isEnabled = false

        self.securityQuestionLabel.text = localized("security_question")
        self.securityQuestionLabel.font = AppFont.with(type: .bold, size: 17)

        self.securityQuestionHeaderTextFieldView.setPlaceholderText(localized("security_question"))

        self.securityAnswerHeaderTextFieldView.setPlaceholderText(localized("security_answer"))

        self.passwordPolicyLabel.text = localized("empty_value")
        self.passwordPolicyLabel.font = AppFont.with(type: .semibold, size: 12)
        self.passwordPolicyLabel.numberOfLines = 0

        Publishers.CombineLatest3(self.oldPasswordHeaderTextFieldView.textPublisher,
                                  self.newPasswordHeaderTextFieldView.textPublisher,
                                  self.confirmPasswordHeaderTextFieldView.textPublisher)
            .map { oldPassword, new, confirm in
                if self.passwordRegex == "" {

                    self.canSavePassword = false

                    return false
                }
                if oldPassword == "" ||
                    new?.range(of: self.passwordRegex, options: .regularExpression) == nil ||
                    confirm?.range(of: self.passwordRegex, options: .regularExpression) == nil {

                    self.canSavePassword = false

                    return false
                }
                if (new ?? "") != (confirm ?? "") {
                    self.confirmPasswordHeaderTextFieldView.showErrorOnField(text: localized("password_not_match"))

                    self.canSavePassword = false

                    return false
                }

                self.newPasswordHeaderTextFieldView.hideTipAndError()
                self.confirmPasswordHeaderTextFieldView.hideTipAndError()

                self.canSavePassword = true

                return true
            }
            .assign(to: \.isEnabled, on: self.editButton)
            .store(in: &self.cancellables)

        Publishers.CombineLatest(self.securityQuestionHeaderTextFieldView.textPublisher, self.securityAnswerHeaderTextFieldView.textPublisher)
            .map { [weak self] securityQuestion, securityAnswer in
                if securityQuestion == "" || securityAnswer == "" {

                    self?.canSaveSecurityInfo = false

                    return false
                }
                if let userProfile = self?.viewModel.userProfilePublisher.value {
                    if securityQuestion == userProfile.securityQuestion && securityAnswer == userProfile.securityAnswer {

                        self?.canSaveSecurityInfo = false

                        return false
                    }
                }

                self?.canSaveSecurityInfo = true

                return true
            }
            .assign(to: \.isEnabled, on: self.editButton)
            .store(in: &self.cancellables)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        containerView.backgroundColor = UIColor.App.backgroundPrimary
        
        headerView.backgroundColor = UIColor.App.backgroundPrimary
        headerLabel.textColor = UIColor.App.textPrimary

        editButton.backgroundColor = .clear
        editButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        editButton.setTitleColor(UIColor.App.highlightPrimary, for: .highlighted)
        editButton.setTitleColor(UIColor.App.textDisablePrimary, for: .disabled)

        oldPasswordHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        oldPasswordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        oldPasswordHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        newPasswordHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        newPasswordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        newPasswordHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        confirmPasswordHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        confirmPasswordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        confirmPasswordHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

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

        self.passwordPolicyLabel.textColor = UIColor.App.inputTextTitle
    }

    private func bind(toViewModel viewModel: PasswordUpdateViewModel) {

        viewModel.policyPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] policy in
                if let policy = policy {

                    self?.passwordRegex = policy.regularExpression
                    self?.passwordRegexMessage = policy.message

                    self?.passwordPolicyLabel.text = self?.passwordRegexMessage ?? ""

                }
            })
            .store(in: &cancellables)

        viewModel.userProfilePublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] userProfile in

                if let userProfile = userProfile {
                    self?.setupProfileSecurity(profile: userProfile)
                }

            })
            .store(in: &cancellables)

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
    }

    private func setupProfileSecurity(profile: EveryMatrix.UserProfile) {

        self.securityQuestionHeaderTextFieldView.setText(profile.securityQuestion)

        self.securityAnswerHeaderTextFieldView.setText(profile.securityAnswer)

        self.isLoading = false
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

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.oldPasswordHeaderTextFieldView.resignFirstResponder()
        self.newPasswordHeaderTextFieldView.resignFirstResponder()
        self.confirmPasswordHeaderTextFieldView.resignFirstResponder()
        self.securityQuestionHeaderTextFieldView.resignFirstResponder()
        self.securityAnswerHeaderTextFieldView.resignFirstResponder()

    }

    @IBAction private func editAction() {

        if self.canSavePassword {
            self.savePassword()
        }

        if self.canSaveSecurityInfo {
            self.saveSecurityInfo()
        }

    }

    private func savePassword() {

        var validFields = true
        // Clean warnings
        newPasswordHeaderTextFieldView.hideTipAndError()
        confirmPasswordHeaderTextFieldView.hideTipAndError()

        if newPasswordHeaderTextFieldView.text.range(of: self.passwordRegex, options: .regularExpression) == nil {
            newPasswordHeaderTextFieldView.showErrorOnField(text: self.passwordRegexMessage)
            validFields = false
        }

        if confirmPasswordHeaderTextFieldView.text.range(of: self.passwordRegex, options: .regularExpression) == nil {
            confirmPasswordHeaderTextFieldView.showErrorOnField(text: self.passwordRegexMessage)
            validFields = false
        }

        if validFields {
            self.viewModel.savePassword(oldPassword: oldPasswordHeaderTextFieldView.text,
                                        newPassword: newPasswordHeaderTextFieldView.text)
        }

    }

    private func saveSecurityInfo() {

        self.viewModel.saveSecurityInfo(securityQuestion: self.securityQuestionHeaderTextFieldView.text,
                                        securityAnswer: self.securityAnswerHeaderTextFieldView.text)

    }

    @IBAction private func backAction() {
        self.navigationController?.popViewController(animated: true)
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
