//
//  PersonalInfoViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 16/09/2021.
//

import UIKit

class PersonalInfoViewController: UIViewController {


    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private var editButton: UIButton!
    @IBOutlet private var firstNameHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var lastNameHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var countryHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var birthDateHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var adress1HeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var adress2HeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var cityHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var postalCodeHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var lineView: UIView!
    @IBOutlet private var usernameHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var emailHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var cardIdHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var bankIdHeaderTextFieldView: HeaderTextFieldView!
    // Variables
    var birthDate: String = "2017-01-01"
    var username: String = "GOMA"
    var email: String = "goma@gomadevelopment.pt"
    var cardId: String = "123453 0 Z12"
    var bankId: String = "PT0990122382"
    init() {
        super.init(nibName: "PersonalInfoViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commonInit()
        setupWithTheme()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func setupWithTheme() {
        self.view.backgroundColor = UIColor.Core.backgroundDarkProfile

        containerView.backgroundColor = UIColor.Core.backgroundDarkProfile

        headerView.backgroundColor = UIColor.Core.backgroundDarkProfile

        backButton.backgroundColor = UIColor.Core.backgroundDarkProfile
        backButton.setTitleColor(UIColor.Core.headingMain, for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.tintColor = UIColor.Core.headingMain

        headerLabel.textColor = UIColor.Core.headingMain

        editButton.backgroundColor = UIColor.Core.backgroundDarkProfile

        firstNameHeaderTextFieldView.backgroundColor = UIColor.Core.backgroundDarkProfile
        firstNameHeaderTextFieldView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        firstNameHeaderTextFieldView.setTextFieldColor(UIColor.Core.headingMain)
        firstNameHeaderTextFieldView.setSecureField(false)

        lastNameHeaderTextFieldView.backgroundColor = UIColor.Core.backgroundDarkProfile
        lastNameHeaderTextFieldView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        lastNameHeaderTextFieldView.setTextFieldColor(UIColor.Core.headingMain)
        lastNameHeaderTextFieldView.setSecureField(false)

        countryHeaderTextFieldView.backgroundColor = UIColor.Core.backgroundDarkProfile
        countryHeaderTextFieldView.setTextFieldColor(UIColor.Core.headingMain)
        countryHeaderTextFieldView.setViewColor(UIColor.Core.backgroundDarkProfile)
        countryHeaderTextFieldView.setViewBorderColor(UIColor.Core.headerTextFieldGray)
        countryHeaderTextFieldView.setSecureField(false)

        birthDateHeaderTextFieldView.backgroundColor = UIColor.Core.backgroundDarkProfile
        birthDateHeaderTextFieldView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        birthDateHeaderTextFieldView.setTextFieldColor(UIColor.Core.headingMain)
        birthDateHeaderTextFieldView.setSecureField(false)
        birthDateHeaderTextFieldView.isDisabled = true

        adress1HeaderTextFieldView.backgroundColor = UIColor.Core.backgroundDarkProfile
        adress1HeaderTextFieldView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        adress1HeaderTextFieldView.setTextFieldColor(UIColor.Core.headingMain)
        adress1HeaderTextFieldView.setSecureField(false)

        adress2HeaderTextFieldView.backgroundColor = UIColor.Core.backgroundDarkProfile
        adress2HeaderTextFieldView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        adress2HeaderTextFieldView.setTextFieldColor(UIColor.Core.headingMain)
        adress2HeaderTextFieldView.setSecureField(false)

        cityHeaderTextFieldView.backgroundColor = UIColor.Core.backgroundDarkProfile
        cityHeaderTextFieldView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        cityHeaderTextFieldView.setTextFieldColor(UIColor.Core.headingMain)
        cityHeaderTextFieldView.setSecureField(false)

        postalCodeHeaderTextFieldView.backgroundColor = UIColor.Core.backgroundDarkProfile
        postalCodeHeaderTextFieldView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        postalCodeHeaderTextFieldView.setTextFieldColor(UIColor.Core.headingMain)
        postalCodeHeaderTextFieldView.setSecureField(false)

        lineView.backgroundColor = UIColor.Core.headerTextFieldGray.withAlphaComponent(0.2)

        usernameHeaderTextFieldView.backgroundColor = UIColor.Core.backgroundDarkProfile
        usernameHeaderTextFieldView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        usernameHeaderTextFieldView.setTextFieldColor(UIColor.Core.headingMain)
        usernameHeaderTextFieldView.setSecureField(false)

        emailHeaderTextFieldView.backgroundColor = UIColor.Core.backgroundDarkProfile
        emailHeaderTextFieldView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        emailHeaderTextFieldView.setTextFieldColor(UIColor.Core.headingMain)
        emailHeaderTextFieldView.setSecureField(false)
        emailHeaderTextFieldView.isDisabled = true

        cardIdHeaderTextFieldView.backgroundColor = UIColor.Core.backgroundDarkProfile
        cardIdHeaderTextFieldView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        cardIdHeaderTextFieldView.setTextFieldColor(UIColor.Core.headingMain)
        cardIdHeaderTextFieldView.setSecureField(false)
        cardIdHeaderTextFieldView.isDisabled = true

        bankIdHeaderTextFieldView.backgroundColor = UIColor.Core.backgroundDarkProfile
        bankIdHeaderTextFieldView.setHeaderLabelColor(UIColor.Core.headerTextFieldGray)
        bankIdHeaderTextFieldView.setTextFieldColor(UIColor.Core.headingMain)
        bankIdHeaderTextFieldView.setSecureField(false)
        bankIdHeaderTextFieldView.isDisabled = true

    }

    func commonInit() {

        backButton.setImage(UIImage(named: "caret-left"), for: .normal)

        headerLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 17)
        headerLabel.text = localized("string_personal_info")

        underlineButtonTitleLabel(button: editButton)

        firstNameHeaderTextFieldView.setPlaceholderText(localized("string_first_name"))
        firstNameHeaderTextFieldView.showTipWithoutIcon(text: localized("string_names_match_id"), color: UIColor.Core.headerTextFieldGray)

        lastNameHeaderTextFieldView.setPlaceholderText(localized("string_last_name"))

        countryHeaderTextFieldView.setPlaceholderText(localized("string_nationality"))
        countryHeaderTextFieldView.setSelectionPicker(["Portugal", "Spain", "England"], headerVisible: true)
        countryHeaderTextFieldView.setImageTextField(UIImage(named: "Arrow_Down")!)
        countryHeaderTextFieldView.setTextFieldFont(AppFont.with(type: .regular, size: 16))
        countryHeaderTextFieldView.isSelect = true

        birthDateHeaderTextFieldView.setPlaceholderText(localized("string_birth_date"))
        birthDateHeaderTextFieldView.setTextFieldDefaultValue(birthDate)

        adress1HeaderTextFieldView.setPlaceholderText(localized("string_address_1"))

        adress2HeaderTextFieldView.setPlaceholderText(localized("string_address_2"))

        cityHeaderTextFieldView.setPlaceholderText(localized("string_city"))

        postalCodeHeaderTextFieldView.setPlaceholderText(localized("string_postal_code"))

        usernameHeaderTextFieldView.setPlaceholderText(localized("string_username"))
        usernameHeaderTextFieldView.setTextFieldDefaultValue(username)

        emailHeaderTextFieldView.setPlaceholderText(localized("string_email"))
        emailHeaderTextFieldView.setTextFieldDefaultValue(email)

        cardIdHeaderTextFieldView.setPlaceholderText(localized("string_id_number"))
        cardIdHeaderTextFieldView.setTextFieldDefaultValue(cardId)

        bankIdHeaderTextFieldView.setPlaceholderText(localized("string_bank_id"))
        bankIdHeaderTextFieldView.setTextFieldDefaultValue(bankId)

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }

    func underlineButtonTitleLabel(button: UIButton) {
        let text = localized("string_edit")

        let underlineAttriString = NSMutableAttributedString(string: text)

        let range1 = (text as NSString).range(of: localized("string_edit"))

        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: AppFont.with(type: .regular, size: 16), range: range1)

        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.Core.buttonMain, range: range1)

        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)

        button.setAttributedTitle(underlineAttriString, for: .normal)
    }

    func showAlert(type: EditAlertView.AlertState) {

        let popup = EditAlertView()
        popup.alertState = type
        popup.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(popup)
        NSLayoutConstraint.activate([

            popup.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            popup.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            popup.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        self.view.bringSubviewToFront(popup)
      }

    @IBAction private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func editAction() {
        // TEST
        if firstNameHeaderTextFieldView.text != "" {
            showAlert(type: .success)
        } else {
            showAlert(type: .error)
        }
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        _ = self.firstNameHeaderTextFieldView.resignFirstResponder()

        _ = self.lastNameHeaderTextFieldView.resignFirstResponder()

        _ = self.countryHeaderTextFieldView.resignFirstResponder()

        _ = self.adress1HeaderTextFieldView.resignFirstResponder()

        _ = self.adress2HeaderTextFieldView.resignFirstResponder()

        _ = self.cityHeaderTextFieldView.resignFirstResponder()

        _ = self.postalCodeHeaderTextFieldView.resignFirstResponder()

        _ = self.usernameHeaderTextFieldView.resignFirstResponder()
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
