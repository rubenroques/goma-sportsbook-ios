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

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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

        topFieldsSetup()

        lineView.backgroundColor = UIColor.App.headerTextFieldGray.withAlphaComponent(0.2)

        bottomFieldsSetup()

    }

    func commonInit() {

        backButton.setImage(UIImage(named: "caret-left"), for: .normal)

        headerLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 17)
        headerLabel.text = localized("string_personal_info")

        underlineButtonTitleLabel(button: editButton)

        firstNameHeaderTextFieldView.setPlaceholderText(localized("string_first_name"))
        firstNameHeaderTextFieldView.showTipWithoutIcon(text: localized("string_names_match_id"), color: UIColor.App.headerTextFieldGray)

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

    func topFieldsSetup() {
        firstNameHeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        firstNameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        firstNameHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        firstNameHeaderTextFieldView.setSecureField(false)

        lastNameHeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        lastNameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        lastNameHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        lastNameHeaderTextFieldView.setSecureField(false)

        countryHeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        countryHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        countryHeaderTextFieldView.setViewColor(UIColor.App.backgroundDarkProfile)
        countryHeaderTextFieldView.setViewBorderColor(UIColor.App.headerTextFieldGray)
        countryHeaderTextFieldView.setSecureField(false)

        birthDateHeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        birthDateHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        birthDateHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        birthDateHeaderTextFieldView.setSecureField(false)
        birthDateHeaderTextFieldView.isDisabled = true

        adress1HeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        adress1HeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        adress1HeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        adress1HeaderTextFieldView.setSecureField(false)

        adress2HeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        adress2HeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        adress2HeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        adress2HeaderTextFieldView.setSecureField(false)

        cityHeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        cityHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        cityHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        cityHeaderTextFieldView.setSecureField(false)

        postalCodeHeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        postalCodeHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        postalCodeHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        postalCodeHeaderTextFieldView.setSecureField(false)
    }

    func bottomFieldsSetup() {
        usernameHeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        usernameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        usernameHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        usernameHeaderTextFieldView.setSecureField(false)

        emailHeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        emailHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        emailHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        emailHeaderTextFieldView.setSecureField(false)
        emailHeaderTextFieldView.isDisabled = true

        cardIdHeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        cardIdHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        cardIdHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        cardIdHeaderTextFieldView.setSecureField(false)
        cardIdHeaderTextFieldView.isDisabled = true

        bankIdHeaderTextFieldView.backgroundColor = UIColor.App.backgroundDarkProfile
        bankIdHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        bankIdHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        bankIdHeaderTextFieldView.setSecureField(false)
        bankIdHeaderTextFieldView.isDisabled = true
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
        }
        else {
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
