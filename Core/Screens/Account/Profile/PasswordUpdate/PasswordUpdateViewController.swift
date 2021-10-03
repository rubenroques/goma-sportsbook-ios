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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupWithTheme()
    }

    func commonInit() {
        headerLabel.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 17)
        headerLabel.text = localized("string_update_password")

        editButton.setTitle(localized("string_save"), for: .normal)
        editButton.titleLabel?.font = AppFont.with(type: .bold, size: 16)

        oldPasswordHeaderTextFieldView.setPlaceholderText(localized("string_old_password"))
        newPasswordHeaderTextFieldView.setPlaceholderText(localized("string_new_password"))
        confirmPasswordHeaderTextFieldView.setPlaceholderText(localized("string_confirm_password"))

        oldPasswordHeaderTextFieldView.setSecureField(true)
        oldPasswordHeaderTextFieldView.showPasswordLabelVisible(visible: false)
        
        newPasswordHeaderTextFieldView.setSecureField(true)
        confirmPasswordHeaderTextFieldView.setSecureField(true)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        editButton.isEnabled = false

        Publishers.CombineLatest3(oldPasswordHeaderTextFieldView.textPublisher,
                                  newPasswordHeaderTextFieldView.textPublisher,
                                  confirmPasswordHeaderTextFieldView.textPublisher)
            .map { oldPassword, new, confirm in

                if (oldPassword ?? "").count < 8 || (new ?? "").count < 8 || (confirm ?? "").count < 8 {
                    return false
                }
                if (new ?? "") != (confirm ?? "") {
                    return false
                }
                return true
            }
            .assign(to: \.isEnabled, on: editButton)
            .store(in: &cancellables)
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.mainBackground

        containerView.backgroundColor = UIColor.App.mainBackground
        
        headerView.backgroundColor = UIColor.App.mainBackground
        headerLabel.textColor = UIColor.App.headingMain

        editButton.backgroundColor = .clear
        editButton.setTitleColor(UIColor.App.primaryButtonNormal, for: .normal)
        editButton.setTitleColor(UIColor.App.primaryButtonPressed, for: .highlighted)
        editButton.setTitleColor(UIColor.App.headerTextField, for: .disabled)

        oldPasswordHeaderTextFieldView.backgroundColor = UIColor.App.mainBackground
        oldPasswordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextField)
        oldPasswordHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        newPasswordHeaderTextFieldView.backgroundColor = UIColor.App.mainBackground
        newPasswordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextField)
        newPasswordHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        confirmPasswordHeaderTextFieldView.backgroundColor = UIColor.App.mainBackground
        confirmPasswordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextField)
        confirmPasswordHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
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
        self.view.bringSubviewToFront(popup)
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.oldPasswordHeaderTextFieldView.resignFirstResponder()
        self.newPasswordHeaderTextFieldView.resignFirstResponder()
        self.confirmPasswordHeaderTextFieldView.resignFirstResponder()

    }

    @IBAction private func editAction() {

        self.didTapBackground()
        self.view.isUserInteractionEnabled = false

        executeDelayed(1.5) {
            self.backAction()
        }

        
//        // Clean warnings
//        oldPasswordHeaderTextFieldView.hideTipAndError()
//        newPasswordHeaderTextFieldView.hideTipAndError()
//        confirmPasswordHeaderTextFieldView.hideTipAndError()
//
//        // TEST field verification
//        let oldPassword = "goma123"
//        if oldPasswordHeaderTextFieldView.text != oldPassword {
//            oldPasswordHeaderTextFieldView.showErrorOnField(text: localized("string_old_password_error"))
//        }
//        else if newPasswordHeaderTextFieldView.text != confirmPasswordHeaderTextFieldView.text {
//            confirmPasswordHeaderTextFieldView.showErrorOnField(text: localized("string_password_not_match"))
//        }
//        else {
//            // TEST Alert
//            if oldPasswordHeaderTextFieldView.text != "" && newPasswordHeaderTextFieldView.text != "" && confirmPasswordHeaderTextFieldView.text != "" {
//                showAlert(type: .success, text: localized("string_success_edit_password"))
//            }
//            else {
//                showAlert(type: .error, text: localized("string_error_edit_password"))
//            }
//        }

    }

    @IBAction private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

}
