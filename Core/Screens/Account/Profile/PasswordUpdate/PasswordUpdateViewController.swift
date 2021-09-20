//
//  PasswordUpdateViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 20/09/2021.
//

import UIKit

class PasswordUpdateViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private var editButton: UIButton!
    @IBOutlet private var oldPasswordHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var newPasswordHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var confirmPasswordHeaderTextFieldView: HeaderTextFieldView!

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

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.App.backgroundDarkProfile

        containerView.backgroundColor = UIColor.App.backgroundDarkProfile

        headerView.backgroundColor = UIColor.App.backgroundDarkProfile

        backButton.backgroundColor = UIColor.App.backgroundDarkProfile
        backButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.tintColor = UIColor.App.headingMain

        headerLabel.textColor = UIColor.App.headingMain

        editButton.backgroundColor = UIColor.App.backgroundDarkProfile

        oldPasswordHeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        oldPasswordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        oldPasswordHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        oldPasswordHeaderTextFieldView.setSecureField(true)

        newPasswordHeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        newPasswordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        newPasswordHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        newPasswordHeaderTextFieldView.setSecureField(true)

        confirmPasswordHeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        confirmPasswordHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        confirmPasswordHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        confirmPasswordHeaderTextFieldView.setSecureField(true)
    }

    func commonInit() {
        backButton.setImage(UIImage(named: "caret-left"), for: .normal)

        headerLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 17)
        headerLabel.text = localized("string_update_password")

        underlineButtonTitleLabel(button: editButton)

        oldPasswordHeaderTextFieldView.setPlaceholderText(localized("string_old_password"))

        newPasswordHeaderTextFieldView.setPlaceholderText(localized("string_new_password"))

        confirmPasswordHeaderTextFieldView.setPlaceholderText(localized("string_confirm_password"))

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    func underlineButtonTitleLabel(button: UIButton) {
        let text = localized("string_edit")

        let underlineAttriString = NSMutableAttributedString(string: text)

        let range1 = (text as NSString).range(of: localized("string_edit"))

        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: AppFont.with(type: .regular, size: 16), range: range1)

        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.App.buttonMain, range: range1)

        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)

        button.setAttributedTitle(underlineAttriString, for: .normal)
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

        _ = self.oldPasswordHeaderTextFieldView.resignFirstResponder()

        _ = self.newPasswordHeaderTextFieldView.resignFirstResponder()

        _ = self.confirmPasswordHeaderTextFieldView.resignFirstResponder()

    }

    @IBAction private func editAction() {
        // Clean warnings
        oldPasswordHeaderTextFieldView.hideTipAndError()
        newPasswordHeaderTextFieldView.hideTipAndError()
        confirmPasswordHeaderTextFieldView.hideTipAndError()

        // TEST field verification
        let oldPassword = "goma123"
        if oldPasswordHeaderTextFieldView.text != oldPassword {
            oldPasswordHeaderTextFieldView.showErrorOnField(text: localized("string_old_password_error"))
        }
        else if newPasswordHeaderTextFieldView.text != confirmPasswordHeaderTextFieldView.text {
            confirmPasswordHeaderTextFieldView.showErrorOnField(text: localized("string_password_not_match"))
        }
        else {
            // TEST Alert
            if oldPasswordHeaderTextFieldView.text != "" && newPasswordHeaderTextFieldView.text != "" && confirmPasswordHeaderTextFieldView.text != "" {
                showAlert(type: .success, text: localized("string_success_edit_password"))
            }
            else {
                showAlert(type: .error, text: localized("string_error_edit_password"))
            }
        }

    }

    @IBAction private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

}
