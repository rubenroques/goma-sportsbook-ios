//
//  SmallRegisterStep4ViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 16/09/2021.
//

import UIKit

class SmallRegisterStep4ViewController: UIViewController {

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var backView: UIView!
    @IBOutlet private var backImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var codeHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var doneButton: RoundButton!
    @IBOutlet private var pasteClipboardButton: UIButton!
    // Variables
    var imageGradient: UIImage = UIImage()

    init() {
        super.init(nibName: "SmallRegisterStep4ViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        imageGradient = UIImage.init().getGradientColorImage(red: 37, green: 40, blue: 50, alpha: 1.0, bounds: self.view.bounds)

        setupWithTheme()
        commonInit()
    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor(patternImage: imageGradient)

        containerView.backgroundColor = UIColor(patternImage: imageGradient)

        backView.backgroundColor = UIColor(patternImage: imageGradient)

        titleLabel.textColor = .white

        textLabel.textColor = .white

        codeHeaderTextFieldView.backgroundColor = UIColor(patternImage: imageGradient)
        codeHeaderTextFieldView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        codeHeaderTextFieldView.setTextFieldColor(.white)
        codeHeaderTextFieldView.setSecureField(false)

        doneButton.setTitleColor(.white, for: .normal)
        doneButton.backgroundColor = UIColor.Core.buttonMain
        doneButton.cornerRadius = BorderRadius.button

        pasteClipboardButton.setTitleColor(.white, for: .normal)
        pasteClipboardButton.backgroundColor = UIColor(patternImage: imageGradient)
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
