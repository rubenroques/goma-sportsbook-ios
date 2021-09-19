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
    @IBOutlet private var backImageView: UIImageView!
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

        self.view.backgroundColor = UIColor.App.mainBackgroundColor

        containerView.backgroundColor = UIColor.App.mainBackgroundColor

        backView.backgroundColor = UIColor.App.mainBackgroundColor

        titleLabel.textColor = UIColor.App.headingMain

        textLabel.textColor = UIColor.App.headingMain

        codeHeaderTextFieldView.backgroundColor = UIColor.App.mainBackgroundColor
        codeHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        codeHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        codeHeaderTextFieldView.setSecureField(false)

        doneButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        doneButton.backgroundColor = UIColor.App.primaryButtonNormalColor
        doneButton.cornerRadius = BorderRadius.button

        pasteClipboardButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        pasteClipboardButton.backgroundColor = UIColor.App.mainBackgroundColor
    }

    func commonInit() {
        backImageView.image = UIImage(named: "caret-left")
        backImageView.sizeToFit()

        titleLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 26)
        titleLabel.text = localized("string_enter_code")

        textLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 15)
        textLabel.text = localized("string_enter_code_text")

        codeHeaderTextFieldView.setPlaceholderText(localized("string_code"))

        doneButton.setTitle(localized("string_done"), for: .normal)
        doneButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 18)

        pasteClipboardButton.setTitle(localized("string_paste_clipboard"), for: .normal)
        pasteClipboardButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.medium, size: 18)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        let tapBackImageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapBackImageGestureRecognizer:)))
            backImageView.isUserInteractionEnabled = true
        backImageView.addGestureRecognizer(tapBackImageGestureRecognizer)
    }

    @objc func imageTapped(tapBackImageGestureRecognizer: UITapGestureRecognizer)
    {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func doneAction() {
        // Finish
    }


    @IBAction func pasteClipboardAction() {
        let pb = UIPasteboard.general;
        codeHeaderTextFieldView.setTextFieldDefaultValue(pb.string ?? "")
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        _ = self.codeHeaderTextFieldView.resignFirstResponder()

    }

}
