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
    @IBOutlet private var titleHeaderTextFieldView: DropDownSelectionView!
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

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func commonInit() {

        closeButton.setTitle(localized("close"), for: .normal)
        closeButton.titleLabel?.font = AppFont.with(type: .bold, size: 16)

        progressLabel.text = localized("complete_signup")
        progressLabel.font = AppFont.with(type: .bold, size: 24)

        titleLabel.text = localized("personal_information")
        titleLabel.font = AppFont.with(type: .bold, size: 18)

        
       // titleHeaderTextFieldView.setSelectionPicker(UserTitles.titles, headerVisible: true)
        titleHeaderTextFieldView.setPlaceholderText(localized("title"))
    

        titleHeaderTextFieldView.setTextFieldFont(AppFont.with(type: .regular, size: 16))

        firstNameHeaderTextFieldView.setPlaceholderText(localized("first_name"))
        firstNameHeaderTextFieldView.showTipWithoutIcon(text: localized("names_match_id"), color: UIColor.App.inputTextTitle)

        lastNameHeaderTextFieldView.setPlaceholderText(localized("last_name"))
        lastNameHeaderTextFieldView.showTipWithoutIcon(text: localized("names_match_id"), color: UIColor.App.inputTextTitle)

        countryHeaderTextFieldView.setPlaceholderText(localized("country"))
        countryHeaderTextFieldView.setSelectionPicker(["-----"], headerVisible: true)
        countryHeaderTextFieldView.setImageTextField(UIImage(named: "arrow_dropdown_icon")!)
        countryHeaderTextFieldView.setTextFieldFont(AppFont.with(type: .regular, size: 16))
        countryHeaderTextFieldView.isUserInteractionEnabled = false

        address1HeaderTextFieldView.setPlaceholderText(localized("address_1"))

        address2HeaderTextFieldView.setPlaceholderText(localized("address_2"))

        cityHeaderTextFieldView.setPlaceholderText(localized("city"))

        postalCodeHeaderTextFieldView.setPlaceholderText(localized("postal_code"))

        continueButton.setTitle(localized("continue_"), for: .normal)
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

        topView.backgroundColor = UIColor.App.backgroundPrimary

        view.backgroundColor = UIColor.App.backgroundPrimary

        containerView.backgroundColor = UIColor.App.backgroundPrimary

        navigationView.backgroundColor = UIColor.App.backgroundPrimary

        closeButton.setTitleColor(UIColor.App.inputText, for: .normal)

        progressView.backgroundColor = UIColor.App.backgroundPrimary

        progressLabel.textColor = UIColor.App.inputText

        titleLabel.textColor = UIColor.App.inputText

        titleHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        titleHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
        titleHeaderTextFieldView.setViewColor(UIColor.App.backgroundPrimary)
        titleHeaderTextFieldView.setViewBorderColor(UIColor.App.inputTextTitle)

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

        address1HeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        address1HeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        address1HeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        address2HeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        address2HeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        address2HeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        cityStackView.backgroundColor = UIColor.App.backgroundPrimary

        cityHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        cityHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        cityHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        postalCodeHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        postalCodeHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        postalCodeHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        continueButton.backgroundColor = UIColor.App.backgroundPrimary
        continueButton.setTitleColor(UIColor.App.inputTextTitle, for: .disabled)
        continueButton.setTitleColor(UIColor.App.inputText, for: .normal)
        continueButton.cornerRadius = CornerRadius.button

    }

    private func checkUserInputs() {

        let titleText = titleHeaderTextFieldView.textField.text == "" ? false : true
        let firstNameText = firstNameHeaderTextFieldView.text == "" ? false : true
        let lastNameText = lastNameHeaderTextFieldView.text == "" ? false : true
        let address1Text = address1HeaderTextFieldView.text == "" ? false : true
        let cityText = cityHeaderTextFieldView.text == "" ? false : true
        let postalCodeText = postalCodeHeaderTextFieldView.text == "" ? false : true

        if  titleText && firstNameText && lastNameText && address1Text && cityText && postalCodeText {
            self.continueButton.isEnabled = true
            continueButton.backgroundColor = UIColor.App.buttonBackgroundPrimary
            self.setupFullRegisterUserInfoForm()
        }
        else {
            self.continueButton.isEnabled = false
            continueButton.backgroundColor = UIColor.App.backgroundPrimary
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
        let titleText = titleHeaderTextFieldView.textField.text
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
        fullRegisterUserInfo = FullRegisterUserInfo(title: "titleText",
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
        
        //self.navigationController?.present(FullRegisterAddressCountryViewController(registerForm: self.fullRegisterUserInfo!), animated: true)
        
        self.navigationController?.pushViewController(FullRegisterAddressCountryViewController(registerForm: self.fullRegisterUserInfo!), animated: true)
    }

    @IBAction private func closeAction() {
          // foi presented porque tem um presentingViewController
       // self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
    
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
