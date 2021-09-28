//
//  PersonalInfoViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 16/09/2021.
//

import UIKit
import Combine

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

    var cancellables = Set<AnyCancellable>()
    var userSession: UserSession?

    init(userSession: UserSession?) {
        self.userSession = userSession
        super.init(nibName: "PersonalInfoViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.commonInit()
        self.setupWithTheme()

        self.setupPublishers()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let user = self.userSession {
            birthDateHeaderTextFieldView.setTextFieldDefaultValue(user.birthDate)
            usernameHeaderTextFieldView.setTextFieldDefaultValue(user.username)
            emailHeaderTextFieldView.setTextFieldDefaultValue(user.email)
        }
    }


    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func commonInit() {

        headerLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 17)
        headerLabel.text = localized("string_personal_info")

        editButton.setTitle(localized("string_save"), for: .normal)
        editButton.titleLabel?.font = AppFont.with(type: .bold, size: 16)

        firstNameHeaderTextFieldView.setPlaceholderText(localized("string_first_name"))
        firstNameHeaderTextFieldView.showTipWithoutIcon(text: localized("string_names_match_id"),
                                                        color: UIColor.App.headerTextFieldGray)

        lastNameHeaderTextFieldView.setPlaceholderText(localized("string_last_name"))

        countryHeaderTextFieldView.setPlaceholderText(localized("string_nationality"))
        countryHeaderTextFieldView.setSelectionPicker(["-----"], headerVisible: true)
        countryHeaderTextFieldView.setImageTextField(UIImage(named: "arrow_dropdown_icon")!)
        countryHeaderTextFieldView.setTextFieldFont(AppFont.with(type: .regular, size: 16))
        countryHeaderTextFieldView.shouldBeginEditing = { return false }

        birthDateHeaderTextFieldView.setPlaceholderText(localized("string_birth_date"))
        birthDateHeaderTextFieldView.setImageTextField(UIImage(named: "calendar_regular_icon")!)
        birthDateHeaderTextFieldView.setDatePickerMode()
        //birthDateHeaderTextFieldView.shouldBeginEditing = { return false }

        adress1HeaderTextFieldView.setPlaceholderText(localized("string_address_1"))

        adress2HeaderTextFieldView.setPlaceholderText(localized("string_address_2"))

        cityHeaderTextFieldView.setPlaceholderText(localized("string_city"))

        postalCodeHeaderTextFieldView.setPlaceholderText(localized("string_postal_code"))

        usernameHeaderTextFieldView.setPlaceholderText(localized("string_username"))

        emailHeaderTextFieldView.setPlaceholderText(localized("string_email"))

        cardIdHeaderTextFieldView.setPlaceholderText(localized("string_id_number"))

        bankIdHeaderTextFieldView.setPlaceholderText(localized("string_bank_id"))

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        self.editButton.isEnabled = false
        self.countryHeaderTextFieldView.isUserInteractionEnabled = false

        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.calendar = calendar
        components.year = -18
        let maxDate = calendar.date(byAdding: components, to: Date())!
        birthDateHeaderTextFieldView.datePicker.maximumDate = maxDate

    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.mainBackgroundColor

        editButton.backgroundColor = .clear
        editButton.setTitleColor(UIColor.App.primaryButtonNormalColor, for: .normal)
        editButton.setTitleColor(UIColor.App.primaryButtonPressedColor, for: .highlighted)
        editButton.setTitleColor(UIColor.App.headerTextFieldGray, for: .disabled)

        containerView.backgroundColor = UIColor.App.mainBackgroundColor
        headerView.backgroundColor = UIColor.App.mainBackgroundColor
        headerLabel.textColor = UIColor.App.headingMain

        lineView.backgroundColor = UIColor.App.headerTextFieldGray.withAlphaComponent(0.2)

        firstNameHeaderTextFieldView.backgroundColor = UIColor.App.mainBackgroundColor
        firstNameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        firstNameHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        lastNameHeaderTextFieldView.backgroundColor = UIColor.App.mainBackgroundColor
        lastNameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        lastNameHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        countryHeaderTextFieldView.backgroundColor = UIColor.App.mainBackgroundColor
        countryHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        countryHeaderTextFieldView.setViewColor(UIColor.App.mainBackgroundColor)
        countryHeaderTextFieldView.setViewBorderColor(UIColor.App.headerTextFieldGray)

        birthDateHeaderTextFieldView.backgroundColor = UIColor.App.mainBackgroundColor
        birthDateHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        birthDateHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        adress1HeaderTextFieldView.backgroundColor = UIColor.App.mainBackgroundColor
        adress1HeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        adress1HeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        adress2HeaderTextFieldView.backgroundColor = UIColor.App.mainBackgroundColor
        adress2HeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        adress2HeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        cityHeaderTextFieldView.backgroundColor = UIColor.App.mainBackgroundColor
        cityHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        cityHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        postalCodeHeaderTextFieldView.backgroundColor = UIColor.App.mainBackgroundColor
        postalCodeHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        postalCodeHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        usernameHeaderTextFieldView.backgroundColor = UIColor.App.mainBackgroundColor
        usernameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        usernameHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        emailHeaderTextFieldView.backgroundColor = UIColor.App.mainBackgroundColor
        emailHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        emailHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        emailHeaderTextFieldView.isDisabled = true

        cardIdHeaderTextFieldView.backgroundColor = UIColor.App.mainBackgroundColor
        cardIdHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        cardIdHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        cardIdHeaderTextFieldView.isDisabled = true

        bankIdHeaderTextFieldView.backgroundColor = UIColor.App.mainBackgroundColor
        bankIdHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextFieldGray)
        bankIdHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        bankIdHeaderTextFieldView.isDisabled = true

    }


    private func setupPublishers() {

        Env.everyMatrixAPIClient.getCountries()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { _ in
                self.countryHeaderTextFieldView.isUserInteractionEnabled = true
            } receiveValue: { countries in
                self.setupWithCountryCodes(countries)
            }
        .store(in: &cancellables)

    }

    @IBAction private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func editAction() {
        self.didTapBackground()
        self.view.isUserInteractionEnabled = false

        executeDelayed(1.5) {
            self.backAction()
        }
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()
        self.firstNameHeaderTextFieldView.resignFirstResponder()
        self.lastNameHeaderTextFieldView.resignFirstResponder()
        self.countryHeaderTextFieldView.resignFirstResponder()
        self.adress1HeaderTextFieldView.resignFirstResponder()
        self.adress2HeaderTextFieldView.resignFirstResponder()
        self.cityHeaderTextFieldView.resignFirstResponder()
        self.postalCodeHeaderTextFieldView.resignFirstResponder()
        self.usernameHeaderTextFieldView.resignFirstResponder()
    }

}

// Flags business logic
extension PersonalInfoViewController {

    private func setupWithCountryCodes(_ listings: EveryMatrix.CountryListing) {

        for country in listings.countries where country.isoCode == listings.currentIpCountry {
            self.countryHeaderTextFieldView.setText( self.formatIndicativeCountry(country), slideUp: true)
        }

        self.countryHeaderTextFieldView.isUserInteractionEnabled = true
        self.countryHeaderTextFieldView.shouldBeginEditing = { [weak self] in
            self?.showCountrySelector(listing: listings)
            return false
        }
    }

    private func showCountrySelector(listing: EveryMatrix.CountryListing) {
        let phonePrefixSelectorViewController = PhonePrefixSelectorViewController(countriesArray: listing, showIndicatives: false)
        phonePrefixSelectorViewController.modalPresentationStyle = .overCurrentContext
        phonePrefixSelectorViewController.didSelectCountry = { [weak self] country in
            self?.setupWithSelectedCountry(country)
            phonePrefixSelectorViewController.animateDismissView()
        }
        self.present(phonePrefixSelectorViewController, animated: false, completion: nil)
    }

    private func setupWithSelectedCountry(_ country: EveryMatrix.Country) {
        self.countryHeaderTextFieldView.setText(formatIndicativeCountry(country), slideUp: true)
    }

    private func formatIndicativeCountry(_ country: EveryMatrix.Country) -> String {
        var stringCountry = "\(country.name)"
        if let isoCode = country.isoCode {
            stringCountry = "\(isoCode) - \(country.name)"
            if let flag = CountryFlagHelper.flag(forCode: isoCode) {
                stringCountry = "\(flag) \(country.name)"
            }
        }
        return stringCountry
    }

}

extension PersonalInfoViewController {

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height + 24
        scrollView.contentInset = contentInset
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset: UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }

}
