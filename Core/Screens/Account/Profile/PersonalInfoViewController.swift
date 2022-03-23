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

    @IBOutlet private var titleHeaderTextFieldView: HeaderTextFieldView!
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
    var countries: EveryMatrix.CountryListing?
    var profile: EveryMatrix.UserProfile?

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

    }

    

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.setupWithTheme()
    }

    func commonInit() {

        headerLabel.font = AppFont.with(type: AppFont.AppFontType.medium, size: 17)
        headerLabel.text = localized("personal_info")

        editButton.setTitle(localized("save"), for: .normal)
        editButton.titleLabel?.font = AppFont.with(type: .bold, size: 16)

        titleHeaderTextFieldView.setPlaceholderText(localized("title"))
        titleHeaderTextFieldView.setSelectionPicker(UserTitles.titles, headerVisible: true)
        titleHeaderTextFieldView.setImageTextField(UIImage(named: "arrow_dropdown_icon")!)
        titleHeaderTextFieldView.setTextFieldFont(AppFont.with(type: .regular, size: 16))

        firstNameHeaderTextFieldView.setPlaceholderText(localized("first_name"))
        firstNameHeaderTextFieldView.showTipWithoutIcon(text: localized("names_match_id"),
                                                        color: UIColor.App.inputTextTitle)

        lastNameHeaderTextFieldView.setPlaceholderText(localized("last_name"))

        countryHeaderTextFieldView.setPlaceholderText(localized("nationality"))
        countryHeaderTextFieldView.setSelectionPicker(["-----"], headerVisible: true)
        countryHeaderTextFieldView.setImageTextField(UIImage(named: "arrow_dropdown_icon")!)
        countryHeaderTextFieldView.setTextFieldFont(AppFont.with(type: .regular, size: 16))
        countryHeaderTextFieldView.shouldBeginEditing = { return false }

        birthDateHeaderTextFieldView.setPlaceholderText(localized("birth_date"))
        birthDateHeaderTextFieldView.setImageTextField(UIImage(named: "calendar_regular_icon")!)
        birthDateHeaderTextFieldView.setDatePickerMode()

        adress1HeaderTextFieldView.setPlaceholderText(localized("address_1"))

        adress2HeaderTextFieldView.setPlaceholderText(localized("address_2"))

        cityHeaderTextFieldView.setPlaceholderText(localized("city"))

        postalCodeHeaderTextFieldView.setPlaceholderText(localized("postal_code"))

        usernameHeaderTextFieldView.setPlaceholderText(localized("username"))

        emailHeaderTextFieldView.setPlaceholderText(localized("email"))

        cardIdHeaderTextFieldView.setPlaceholderText(localized("id_number"))

        bankIdHeaderTextFieldView.setPlaceholderText(localized("bank_id"))

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

        self.view.backgroundColor = UIColor.App.backgroundPrimary

        editButton.backgroundColor = .clear
        editButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        editButton.setTitleColor(UIColor.App.highlightPrimary, for: .highlighted)
        editButton.setTitleColor(UIColor.App.highlightPrimary, for: .disabled)

        containerView.backgroundColor = UIColor.App.backgroundPrimary
        headerView.backgroundColor = UIColor.App.backgroundPrimary
        headerLabel.textColor = UIColor.App.textPrimary

        lineView.backgroundColor = UIColor.App.inputTextTitle.withAlphaComponent(0.2)

        titleHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        titleHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
        titleHeaderTextFieldView.setViewColor(UIColor.App.backgroundPrimary)
        titleHeaderTextFieldView.setViewBorderColor(UIColor.App.inputTextTitle)

        print(titleHeaderTextFieldView.text)
        firstNameHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        firstNameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        firstNameHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        lastNameHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        lastNameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        lastNameHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        countryHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        countryHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
        countryHeaderTextFieldView.setViewColor(UIColor.App.backgroundPrimary)
        countryHeaderTextFieldView.setViewBorderColor(UIColor.App.inputTextTitle)

        birthDateHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        birthDateHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        birthDateHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        adress1HeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        adress1HeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        adress1HeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        adress2HeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        adress2HeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        adress2HeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        cityHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        cityHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        cityHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        postalCodeHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        postalCodeHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        postalCodeHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        usernameHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        usernameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        usernameHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
        usernameHeaderTextFieldView.isDisabled = true

        emailHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        emailHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        emailHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
        emailHeaderTextFieldView.isDisabled = true

        cardIdHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        cardIdHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        cardIdHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        bankIdHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        bankIdHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        bankIdHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
        bankIdHeaderTextFieldView.isDisabled = true

        
    }

    private func setupPublishers() {

        Env.everyMatrixClient.getCountries()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { _ in
                self.countryHeaderTextFieldView.isUserInteractionEnabled = true
            } receiveValue: { countries in
                self.countries = countries
                self.setupWithCountryCodes(countries)
            }
        .store(in: &cancellables)

        Env.everyMatrixClient.getProfile()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            .sink { _ in

            } receiveValue: { profile in
                self.setupProfile(profile: profile)
            }
        .store(in: &cancellables)

    }

    func checkProfileInfoChanged() {
        // Updatable fields
        let emailChanged = emailHeaderTextFieldView.text == profile?.email ? false : true
        let titleChanged = titleHeaderTextFieldView.text == profile?.title ? false : true
        let firstNameChanged = firstNameHeaderTextFieldView.text == profile?.firstname ? false : true
        let lastNameChanged = lastNameHeaderTextFieldView.text == profile?.surname ? false : true
        let address1Changed = adress1HeaderTextFieldView.text == profile?.address1 ? false : true
        let address2Changed = adress2HeaderTextFieldView.text == profile?.address2 ? false : true
        let cityChanged = cityHeaderTextFieldView.text == profile?.city ? false : true
        let postalCodeChanged = postalCodeHeaderTextFieldView.text == profile?.postalCode ? false : true
        let personalIdChanged = cardIdHeaderTextFieldView.text == profile?.personalID ? false : true

        if emailChanged || titleChanged || firstNameChanged || lastNameChanged || address1Changed || address2Changed || cityChanged || postalCodeChanged || personalIdChanged {
            self.editButton.isEnabled = true
        }
        else {
            self.editButton.isEnabled = false
        }
    }

    @IBAction private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func editAction() {

        var validFields = true

        let email = emailHeaderTextFieldView.text
        let title = titleHeaderTextFieldView.text
        let gender = titleHeaderTextFieldView.text == "Mr." ? "M" : "F"
        let firstName = firstNameHeaderTextFieldView.text
        let lastName = lastNameHeaderTextFieldView.text
        let birthDate = birthDateHeaderTextFieldView.text
        let mobilePrefix = profile?.mobilePrefix ?? ""
        let mobile = profile?.mobile ?? ""
        let phonePrefix = profile?.phonePrefix ?? ""
        let phone = profile?.phone ?? ""
        let country = profile?.country ?? ""
        let address1 = adress1HeaderTextFieldView.text
        let address2 = adress2HeaderTextFieldView.text
        let city = cityHeaderTextFieldView.text
        let postalCode = postalCodeHeaderTextFieldView.text
        let personalId = cardIdHeaderTextFieldView.text
        let securityQuestion = profile?.securityQuestion ?? ""
        let securityAnswer = profile?.securityAnswer ?? ""

        // Verify required fields
        if firstName == "" {
            firstNameHeaderTextFieldView.showErrorOnField(text: localized("required_field"))
            validFields = false
        }
        else if lastName == "" {
            lastNameHeaderTextFieldView.showErrorOnField(text: localized("required_field"))
            validFields = false
        }
        else if address1 == "" {
            adress1HeaderTextFieldView.showErrorOnField(text: localized("required_field"))
            validFields = false
        }
        else if city == "" {
            cityHeaderTextFieldView.showErrorOnField(text: localized("required_field"))
            validFields = false
        }
        else if postalCode == "" {
            postalCodeHeaderTextFieldView.showErrorOnField(text: localized("required_field"))
            validFields = false
        }

        if validFields {
            let form = EveryMatrix.ProfileForm(email: email,
                                               title: title,
                                               gender: gender,
                                               firstname: firstName,
                                               surname: lastName,
                                               birthDate: birthDate,
                                               country: country,
                                               address1: address1,
                                               address2: address2,
                                               city: city,
                                               postalCode: postalCode,
                                               mobile: mobile,
                                               mobilePrefix: mobilePrefix,
                                               phone: phone,
                                               phonePrefix: phonePrefix, personalID: personalId,
                                               securityQuestion: securityQuestion,
                                               securityAnswer: securityAnswer)

            self.updateProfile(form: form)
        }
    }

    func showAlert(type: EditAlertView.AlertState, text: String = "") {

        let popup = EditAlertView()
        popup.alertState = type
        if text != "" {
            popup.setAlertText(text)
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
            popup.alpha = 1
        }, completion: { _ in
        })
        popup.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(popup)
        NSLayoutConstraint.activate([
            popup.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            popup.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            popup.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
        popup.onClose = {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                popup.alpha = 0
            }, completion: { _ in
                popup.removeFromSuperview()
            })
        }
        self.view.bringSubviewToFront(popup)
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
        self.cardIdHeaderTextFieldView.resignFirstResponder()
    }

    private func updateProfile(form: EveryMatrix.ProfileForm) {
        Env.everyMatrixClient.updateProfile(form: form)
            .breakpointOnError()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case let .requestError(message):
                        self.showAlert(type: .error, text: message)
                    default:
                        self.showAlert(type: .error, text: "\(error)")
                    }
                case .finished:
                    ()
                }
            } receiveValue: { _ in
                self.showAlert(type: .success, text: localized("profile_updated_success"))
            }
            .store(in: &cancellables)
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

    private func setupProfile(profile: EveryMatrix.UserProfileField) {
        self.profile = profile.fields

        if let optionIndex = UserTitles.titles.firstIndex(of: profile.fields.title) {
            self.titleHeaderTextFieldView.setSelectedPickerOption(option: optionIndex)
        }
        self.titleHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkProfileInfoChanged()
            })
            .store(in: &cancellables)

        if !profile.isFirstnameUpdatable {
            self.firstNameHeaderTextFieldView.isDisabled = true
        }
        self.firstNameHeaderTextFieldView.setText(profile.fields.firstname)
        self.firstNameHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkProfileInfoChanged()
            })
            .store(in: &cancellables)

        if !profile.isSurnameUpdatable {
            self.lastNameHeaderTextFieldView.isDisabled = true
        }
        self.lastNameHeaderTextFieldView.setText(profile.fields.surname)
        self.lastNameHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkProfileInfoChanged()
            })
            .store(in: &cancellables)

        if !profile.isCountryUpdatable {
            self.countryHeaderTextFieldView.isDisabled = true
        }
        for country in countries!.countries where country.isoCode == profile.fields.country {
            self.countryHeaderTextFieldView.setText( self.formatIndicativeCountry(country), slideUp: true)
        }

        if !profile.isBirthDateUpdatable {
            self.birthDateHeaderTextFieldView.isDisabled = true
        }
        self.birthDateHeaderTextFieldView.setText(profile.fields.birthDate)

        self.adress1HeaderTextFieldView.setText(profile.fields.address1)
        self.adress1HeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkProfileInfoChanged()
            })
            .store(in: &cancellables)

        self.adress2HeaderTextFieldView.setText(profile.fields.address2)
        self.adress2HeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkProfileInfoChanged()
            })
            .store(in: &cancellables)

        self.cityHeaderTextFieldView.setText(profile.fields.city)
        self.cityHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkProfileInfoChanged()
            })
            .store(in: &cancellables)

        self.postalCodeHeaderTextFieldView.setText(profile.fields.postalCode)
        self.postalCodeHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkProfileInfoChanged()
            })
            .store(in: &cancellables)

        self.usernameHeaderTextFieldView.setText(profile.fields.username)

        if !profile.isEmailUpdatable {
            self.emailHeaderTextFieldView.isDisabled = true
        }
        self.emailHeaderTextFieldView.setText(profile.fields.email)

        self.cardIdHeaderTextFieldView.setText(profile.fields.personalID)
        self.cardIdHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkProfileInfoChanged()
            })
            .store(in: &cancellables)
    }

}

extension PersonalInfoViewController {

    @objc func keyboardWillShow(notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            var keyboardFrame: CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        else {
            return
        }

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
