//
//  SimpleRegisterSendEmailCodeViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 16/09/2021.
//

import UIKit

class SimpleRegisterSendEmailCodeViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var backView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var codeHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var doneButton: RoundButton!
    @IBOutlet private var pasteClipboardButton: UIButton!

    init() {
        super.init(nibName: "SimpleRegisterSendEmailCodeViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupWithTheme()
        commonInit()
    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.mainBackground

        containerView.backgroundColor = UIColor.App.mainBackground

        backView.backgroundColor = UIColor.App.mainBackground

        titleLabel.textColor = UIColor.App.headingMain

        textLabel.textColor = UIColor.App.headingMain

        codeHeaderTextFieldView.backgroundColor = UIColor.App.mainBackground
        codeHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextField)
        codeHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        codeHeaderTextFieldView.setSecureField(false)

        doneButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        doneButton.backgroundColor = UIColor.App.primaryButtonNormal
        doneButton.cornerRadius = CornerRadius.button

        pasteClipboardButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        pasteClipboardButton.backgroundColor = UIColor.App.mainBackground
    }

    func commonInit() {

        titleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 26)
        titleLabel.text = localized("enter_code")

        textLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 15)
        textLabel.text = localized("enter_code_text")

        codeHeaderTextFieldView.setPlaceholderText(localized("code"))

        doneButton.setTitle(localized("done"), for: .normal)
        doneButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 18)

        pasteClipboardButton.setTitle(localized("paste_clipboard"), for: .normal)
        pasteClipboardButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 18)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

    }

    @IBAction private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func doneAction() {
        // Finish
    }

    @IBAction private func pasteClipboardAction() {
        let pb = UIPasteboard.general
        codeHeaderTextFieldView.setTextFieldDefaultValue(pb.string ?? "")
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        _ = self.codeHeaderTextFieldView.resignFirstResponder()

    }

}
