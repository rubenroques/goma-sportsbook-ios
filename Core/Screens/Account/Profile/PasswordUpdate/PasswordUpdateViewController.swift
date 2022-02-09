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

    var cancellables = Set<AnyCancellable>()
    var passwordRegex: String = ""
    var passwordRegexMessage: String = ""

    init() {
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
    }

    

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupWithTheme()
    }

    func commonInit() {
        headerLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 17)
        headerLabel.text = localized("update_password")

        editButton.setTitle(localized("save"), for: .normal)
        editButton.titleLabel?.font = AppFont.with(type: .bold, size: 16)

        oldPasswordHeaderTextFieldView.setPlaceholderText(localized("old_password"))
        newPasswordHeaderTextFieldView.setPlaceholderText(localized("new_password"))
        confirmPasswordHeaderTextFieldView.setPlaceholderText(localized("confirm_password"))

        oldPasswordHeaderTextFieldView.setSecureField(true)
        oldPasswordHeaderTextFieldView.showPasswordLabelVisible(visible: false)
        oldPasswordHeaderTextFieldView.isTipPermanent = true
        
        newPasswordHeaderTextFieldView.setSecureField(true)
        confirmPasswordHeaderTextFieldView.setSecureField(true)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        editButton.isEnabled = false

        Env.everyMatrixClient.getPolicy()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { _ in
            } receiveValue: { [weak self] policy in
                self?.passwordRegex = policy.regularExpression
                self?.passwordRegexMessage = policy.message
                self?.oldPasswordHeaderTextFieldView.showTip(text: self?.passwordRegexMessage ?? "", color: UIColor.App.inputTextTitle)
            }
            .store(in: &cancellables)

        Publishers.CombineLatest3(self.oldPasswordHeaderTextFieldView.textPublisher,
                                  self.newPasswordHeaderTextFieldView.textPublisher,
                                  self.confirmPasswordHeaderTextFieldView.textPublisher)
            .map { oldPassword, new, confirm in
                if self.passwordRegex == "" {
                    return false
                }
                if oldPassword == "" ||
                    new?.range(of: self.passwordRegex, options: .regularExpression) == nil ||
                    confirm?.range(of: self.passwordRegex, options: .regularExpression) == nil {
                    return false
                }
                if (new ?? "") != (confirm ?? "") {
                    self.confirmPasswordHeaderTextFieldView.showErrorOnField(text: localized("password_not_match"))
                    return false
                }

                self.newPasswordHeaderTextFieldView.hideTipAndError()
                self.confirmPasswordHeaderTextFieldView.hideTipAndError()
                return true
            }
            .assign(to: \.isEnabled, on: self.editButton)
            .store(in: &self.cancellables)

    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundPrimary

        containerView.backgroundColor = UIColor.App.backgroundPrimary
        
        headerView.backgroundColor = UIColor.App.backgroundPrimary
        headerLabel.textColor = UIColor.App.textPrimary

        editButton.backgroundColor = .clear
        editButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        editButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .highlighted)
        editButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .disabled)

        oldPasswordHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        oldPasswordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        oldPasswordHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        newPasswordHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        newPasswordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        newPasswordHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        confirmPasswordHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        confirmPasswordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        confirmPasswordHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
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

    }

    @IBAction private func editAction() {

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
            Env.everyMatrixClient.changePassword(oldPassword: oldPasswordHeaderTextFieldView.text,
                                                 newPassword: newPasswordHeaderTextFieldView.text,
                                                 captchaPublicKey: "",
                                                 captchaChallenge: "",
                                                 captchaResponse: "")
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
                .sink( receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        var errorMessage = ""
                        switch error {
                        case .requestError(let value):
                            errorMessage = value
                        case .decodingError:
                            errorMessage = "\(error)"
                        case .httpError:
                            errorMessage = "\(error)"
                        case .unknown:
                            errorMessage = "\(error)"
                        case .missingTransportSessionID:
                            errorMessage = "\(error)"
                        case .notConnected:
                            errorMessage = "\(error)"
                        case .noResultsReceived:
                            errorMessage = "\(error)"
                        }
                        self.showAlert(type: .error, text: "\(errorMessage)")

                    }
                }, receiveValue: { _ in
                    self.showAlert(type: .success, text: localized("success_edit_password"))
                    UserDefaults.standard.userSession?.password = self.newPasswordHeaderTextFieldView.text
                }).store(in: &cancellables)

        }

    }

    @IBAction private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

}
