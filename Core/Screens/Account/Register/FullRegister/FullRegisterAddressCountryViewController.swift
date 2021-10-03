//
//  FullRegisterAddressCountryViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 24/09/2021.
//

import UIKit

class FullRegisterAddressCountryViewController: UIViewController {

    @IBOutlet private var topView: UIView!
    @IBOutlet private var navigationView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var containerView: UIView!

    @IBOutlet private var progressView: UIView!
    @IBOutlet private var progressLabel: UILabel!
    @IBOutlet private var progressImageView: UIImageView!

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var countrySelectTextFieldView: SelectTextFieldView!
    @IBOutlet private var address1HeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var address2HeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var cityHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var postalCodeHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var continueButton: RoundButton!

    init() {
        super.init(nibName: "FullRegisterAddressCountryViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commonInit()
        setupWithTheme()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func commonInit() {
        closeButton.setTitle(localized("string_close"), for: .normal)
        closeButton.titleLabel?.font = AppFont.with(type: .bold, size: 16)

        progressLabel.text = localized("string_complete_signup")
        progressLabel.font = AppFont.with(type: .bold, size: 24)

        titleLabel.text = localized("string_address_country")
        titleLabel.font = AppFont.with(type: .bold, size: 18)

        countrySelectTextFieldView.setPickerIcon(UIImage(named: "arrow_down")!)
        countrySelectTextFieldView.setLabelFont(font: .semibold, size: 16)
        countrySelectTextFieldView.setSelectionPicker(["Portugal", "Spain", "England"])

        address1HeaderTextFieldView.setPlaceholderText(localized("string_address_1"))

        address2HeaderTextFieldView.setPlaceholderText(localized("string_address_2"))
        cityHeaderTextFieldView.setPlaceholderText(localized("string_city"))
        postalCodeHeaderTextFieldView.setPlaceholderText(localized("string_postal_code"))

        continueButton.setTitle(localized("string_continue"), for: .normal)
        continueButton.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        continueButton.isEnabled = false

        checkUserInputs()

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

    }

    func setupWithTheme() {
        topView.backgroundColor = UIColor.App.mainBackground

        view.backgroundColor = UIColor.App.mainBackground

        containerView.backgroundColor = UIColor.App.mainBackground

        navigationView.backgroundColor = UIColor.App.mainBackground

        closeButton.setTitleColor(UIColor.App.headingMain, for: .normal)

        progressView.backgroundColor = UIColor.App.mainBackground

        progressLabel.textColor = UIColor.App.headingMain

        titleLabel.textColor = UIColor.App.headingMain

        address1HeaderTextFieldView.backgroundColor = UIColor.App.mainBackground
        address1HeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextField)
        address1HeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        address1HeaderTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        address1HeaderTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))

        address2HeaderTextFieldView.backgroundColor = UIColor.App.mainBackground
        address2HeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextField)
        address2HeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        address2HeaderTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        address2HeaderTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))

        cityHeaderTextFieldView.backgroundColor = UIColor.App.mainBackground
        cityHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextField)
        cityHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        cityHeaderTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        cityHeaderTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))

        postalCodeHeaderTextFieldView.backgroundColor = UIColor.App.mainBackground
        postalCodeHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextField)
        postalCodeHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        postalCodeHeaderTextFieldView.setHeaderLabelFont(AppFont.with(type: .semibold, size: 16))
        postalCodeHeaderTextFieldView.setTextFieldFont(AppFont.with(type: .semibold, size: 16))

        continueButton.backgroundColor = UIColor.App.mainBackground
        continueButton.setTitleColor(UIColor.App.headerTextField, for: .disabled)
        continueButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        continueButton.cornerRadius = CornerRadius.button
    }

    private func checkUserInputs() {
        // Check if both fields have data
        address1HeaderTextFieldView.hasText = { value in
            if value {
                if self.cityHeaderTextFieldView.text != "" && self.postalCodeHeaderTextFieldView.text != "" {
                    self.continueButton.enableButton()
                }
            }
            else {
                self.continueButton.disableButton()
            }
        }

        cityHeaderTextFieldView.hasText = { value in
            if value {
                if self.address1HeaderTextFieldView.text != "" && self.postalCodeHeaderTextFieldView.text != "" {
                    self.continueButton.enableButton()
                }
            }
            else {
                self.continueButton.disableButton()
            }
        }

        postalCodeHeaderTextFieldView.hasText = { value in
            if value {
                if self.cityHeaderTextFieldView.text != "" && self.address1HeaderTextFieldView.text != "" {
                    self.continueButton.enableButton()
                }
            }
            else {
                self.continueButton.disableButton()
            }
        }

        address1HeaderTextFieldView.didTapReturn = {
            self.view.endEditing(true)
        }

        address2HeaderTextFieldView.didTapReturn = {
            self.view.endEditing(true)
        }

        cityHeaderTextFieldView.didTapReturn = {
            self.view.endEditing(true)
        }

        postalCodeHeaderTextFieldView.didTapReturn = {
            self.view.endEditing(true)
        }
    }

    @IBAction private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func continueAction() {
        self.navigationController?.pushViewController(FullRegisterDocumentsViewController(), animated: true)
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        address1HeaderTextFieldView.resignFirstResponder()

        address2HeaderTextFieldView.resignFirstResponder()

        cityHeaderTextFieldView.resignFirstResponder()

        postalCodeHeaderTextFieldView.resignFirstResponder()
    }

    @objc func keyboardWillShow(notification: NSNotification) {

        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
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
