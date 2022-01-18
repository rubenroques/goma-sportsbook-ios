//
//  FullRegisterPersonalInfoViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 24/09/2021.
//

import UIKit
import Combine

class FullRegisterPersonalInfoViewController: UIViewController {

    @IBOutlet private var topView: UIView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var titleHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var firstNameHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var lastNameHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var countryHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var address1HeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var address2HeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var cityStackView: UIStackView!
    @IBOutlet private var cityHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var postalCodeHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var continueButton: RoundButton!
    @IBOutlet private var navigationView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var closeButton: UIButton!
    @IBOutlet private var progressView: UIView!
    @IBOutlet private var progressLabel: UILabel!
    @IBOutlet private var progressImageView: UIImageView!

    // Variables
    var buttonEnabled: Bool = false
    var cancellables = Set<AnyCancellable>()
    var countries: EveryMatrix.CountryListing?
    var fullRegisterUserInfo: FullRegisterUserInfo?
    var isBackButtonDisabled: Bool

    init(isBackButtonDisabled: Bool = false) {
        self.isBackButtonDisabled = isBackButtonDisabled
        super.init(nibName: "FullRegisterPersonalInfoViewController", bundle: nil)
    }

    @available(iOS, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        commonInit()
        setupWithTheme()

        self.setupPublishers()

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

        titleLabel.text = localized("string_personal_information")
        titleLabel.font = AppFont.with(type: .bold, size: 18)

        titleHeaderTextFieldView.setPlaceholderText(localized("string_title"))
        titleHeaderTextFieldView.setSelectionPicker(UserTitles.titles, headerVisible: true)
        titleHeaderTextFieldView.setImageTextField(UIImage(named: "arrow_dropdown_icon")!)
        titleHeaderTextFieldView.setTextFieldFont(AppFont.with(type: .regular, size: 16))

        firstNameHeaderTextFieldView.setPlaceholderText(localized("string_first_name"))
        firstNameHeaderTextFieldView.showTipWithoutIcon(text: localized("string_names_match_id"), color: UIColor.App.headerTextField)

        lastNameHeaderTextFieldView.setPlaceholderText(localized("string_last_name"))
        lastNameHeaderTextFieldView.showTipWithoutIcon(text: localized("string_names_match_id"), color: UIColor.App.headerTextField)

        countryHeaderTextFieldView.setPlaceholderText(localized("string_country"))
        countryHeaderTextFieldView.setSelectionPicker(["-----"], headerVisible: true)
        countryHeaderTextFieldView.setImageTextField(UIImage(named: "arrow_dropdown_icon")!)
        countryHeaderTextFieldView.setTextFieldFont(AppFont.with(type: .regular, size: 16))
        countryHeaderTextFieldView.isUserInteractionEnabled = false

        address1HeaderTextFieldView.setPlaceholderText(localized("string_address_1"))

        address2HeaderTextFieldView.setPlaceholderText(localized("string_address_2"))

        cityHeaderTextFieldView.setPlaceholderText(localized("string_city"))

        postalCodeHeaderTextFieldView.setPlaceholderText(localized("string_postal_code"))

        continueButton.setTitle(localized("string_continue_"), for: .normal)
        continueButton.titleLabel?.font = AppFont.with(type: .bold, size: 17)
        continueButton.isEnabled = false

        checkUserInputs()

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackground))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        if isBackButtonDisabled {
            self.backButton.isHidden = true
        }
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

        titleHeaderTextFieldView.backgroundColor = UIColor.App.mainBackground
        titleHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        titleHeaderTextFieldView.setViewColor(UIColor.App.mainBackground)
        titleHeaderTextFieldView.setViewBorderColor(UIColor.App.headerTextField)

        firstNameHeaderTextFieldView.backgroundColor = UIColor.App.mainBackground
        firstNameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextField)
        firstNameHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        lastNameHeaderTextFieldView.backgroundColor = UIColor.App.mainBackground
        lastNameHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextField)
        lastNameHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        countryHeaderTextFieldView.backgroundColor = UIColor.App.mainBackground
        countryHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)
        countryHeaderTextFieldView.setViewColor(UIColor.App.mainBackground)
        countryHeaderTextFieldView.setViewBorderColor(UIColor.App.headerTextField)

        address1HeaderTextFieldView.backgroundColor = UIColor.App.mainBackground
        address1HeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextField)
        address1HeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        address2HeaderTextFieldView.backgroundColor = UIColor.App.mainBackground
        address2HeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextField)
        address2HeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        cityStackView.backgroundColor = UIColor.App.mainBackground

        cityHeaderTextFieldView.backgroundColor = UIColor.App.mainBackground
        cityHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextField)
        cityHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        postalCodeHeaderTextFieldView.backgroundColor = UIColor.App.mainBackground
        postalCodeHeaderTextFieldView.setHeaderLabelColor(UIColor.App.headerTextField)
        postalCodeHeaderTextFieldView.setTextFieldColor(UIColor.App.headingMain)

        continueButton.backgroundColor = UIColor.App.mainBackground
        continueButton.setTitleColor(UIColor.App.headerTextField, for: .disabled)
        continueButton.setTitleColor(UIColor.App.headingMain, for: .normal)
        continueButton.cornerRadius = CornerRadius.button

    }

    private func checkUserInputs() {

        let titleText = titleHeaderTextFieldView.text == "" ? false : true
        let firstNameText = firstNameHeaderTextFieldView.text == "" ? false : true
        let lastNameText = lastNameHeaderTextFieldView.text == "" ? false : true
        let address1Text = address1HeaderTextFieldView.text == "" ? false : true
        let cityText = cityHeaderTextFieldView.text == "" ? false : true
        let postalCodeText = postalCodeHeaderTextFieldView.text == "" ? false : true

        if  titleText && firstNameText && lastNameText && address1Text && cityText && postalCodeText {
            self.continueButton.isEnabled = true
            continueButton.backgroundColor = UIColor.App.mainTint
            self.setupFullRegisterUserInfoForm()
        }
        else {
            self.continueButton.isEnabled = false
            continueButton.backgroundColor = UIColor.App.mainBackground
        }
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

        self.titleHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkUserInputs()
            })
            .store(in: &cancellables)

        self.firstNameHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkUserInputs()
            })
            .store(in: &cancellables)

        self.lastNameHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkUserInputs()
            })
            .store(in: &cancellables)

        self.countryHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkUserInputs()
            })
            .store(in: &cancellables)

        self.address1HeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkUserInputs()
            })
            .store(in: &cancellables)

        self.address2HeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkUserInputs()
            })
            .store(in: &cancellables)

        self.cityHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkUserInputs()
            })
            .store(in: &cancellables)

        self.postalCodeHeaderTextFieldView.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.checkUserInputs()
            })
            .store(in: &cancellables)
    }

    func setupFullRegisterUserInfoForm() {
        let titleText = titleHeaderTextFieldView.text
        let firstNameText = firstNameHeaderTextFieldView.text
        let lastNameText = lastNameHeaderTextFieldView.text
        var countryText = ""
        let countryNameEmojiless = countryHeaderTextFieldView.text.unicodeScalars
            .filter { !$0.properties.isEmojiPresentation}
            .reduce("") { $0 + String($1) }
        let countryName = countryNameEmojiless.replacingOccurrences(of: " ", with: "")
        for country in self.countries!.countries where country.name == countryName {
            countryText = country.isoCode ?? ""
        }
        let address1Text = address1HeaderTextFieldView.text
        let address2Text = address2HeaderTextFieldView.text
        let cityText = cityHeaderTextFieldView.text
        let postalCodeText = postalCodeHeaderTextFieldView.text
        fullRegisterUserInfo = FullRegisterUserInfo(title: titleText,
            firstName: firstNameText,
            lastName: lastNameText,
            country: countryText,
            address1: address1Text,
            address2: address2Text,
            city: cityText,
            postalCode: postalCodeText,
            securityQuestion: "",
            securityAnswer: "",
            personalID: "")
    }

    @IBAction private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func continueAction() {
        self.navigationController?.pushViewController(FullRegisterAddressCountryViewController(registerForm: self.fullRegisterUserInfo!), animated: true)
        // self.present(FullRegisterAddressCountryViewController(registerForm: self.fullRegisterUserInfo!), animated: true, completion: nil)
    }

    @IBAction private func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc func didTapBackground() {
        self.resignFirstResponder()

        self.firstNameHeaderTextFieldView.resignFirstResponder()

        self.lastNameHeaderTextFieldView.resignFirstResponder()

        self.address1HeaderTextFieldView.resignFirstResponder()

        self.address2HeaderTextFieldView.resignFirstResponder()

        self.cityHeaderTextFieldView.resignFirstResponder()

        self.postalCodeHeaderTextFieldView.resignFirstResponder()
    }

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

extension FullRegisterPersonalInfoViewController {
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
