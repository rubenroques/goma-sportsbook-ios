//
//  FullRegisterPersonalInfoViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 24/09/2021.
//

import UIKit
import Combine
import ServiceProvider

class FullRegisterPersonalInfoViewController: UIViewController {

    @IBOutlet private var topView: UIView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var titleHeaderTextFieldView: HeaderDropDownSelectionView!
    @IBOutlet private var firstNameHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var lastNameHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var countryHeaderTextFieldView: HeaderDropDownSelectionView!
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
    var countries: [Country] = []
    var isBackButtonDisabled: Bool
    
    private var profile: UserProfile?
    private var currentCountry: Country?
    private var selectedCountry: Country?

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

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        setupWithTheme()
    }

    func commonInit() {

        closeButton.titleLabel?.font = AppFont.with(type: AppFont.AppFontType.semibold, size: 17)
        closeButton.setTitle(localized("close"), for: .normal)

        progressLabel.text = localized("complete_signup")
        progressLabel.font = AppFont.with(type: .bold, size: 24)

        titleLabel.text = localized("personal_information")
        titleLabel.font = AppFont.with(type: .bold, size: 18)

        titleHeaderTextFieldView.setSelectionPicker([""], headerVisible: true)
        titleHeaderTextFieldView.setPlaceholderText(localized("title"))
        titleHeaderTextFieldView.setTextFieldFont(AppFont.with(type: .regular, size: 16))
        titleHeaderTextFieldView.setImageTextField(UIImage(named: "arrow_dropdown_icon")!)
        titleHeaderTextFieldView.setTextFieldFont(AppFont.with(type: .regular, size: 16))
        titleHeaderTextFieldView.setHeaderLabelFont(AppFont.with(type: .regular, size: 15))
        titleHeaderTextFieldView.setPlaceholderTextColor(UIColor.App.inputTextTitle)

        firstNameHeaderTextFieldView.setPlaceholderText(localized("first_name"))
        firstNameHeaderTextFieldView.showTipWithoutIcon(text: localized("names_match_id"), color: UIColor.App.inputTextTitle)

        lastNameHeaderTextFieldView.setPlaceholderText(localized("last_name"))
        lastNameHeaderTextFieldView.showTipWithoutIcon(text: localized("names_match_id"), color: UIColor.App.inputTextTitle)

        countryHeaderTextFieldView.setPlaceholderText(localized("nationality"))
        countryHeaderTextFieldView.setSelectionPicker([""], headerVisible: true)
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

        self.checkUserInputs()

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

        closeButton.setTitleColor( UIColor.App.highlightPrimary, for: .normal)
        closeButton.setTitleColor( UIColor.App.highlightPrimary.withAlphaComponent(0.7), for: .highlighted)
        closeButton.setTitleColor( UIColor.App.highlightPrimary.withAlphaComponent(0.4), for: .disabled)

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

        continueButton.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        continueButton.setBackgroundColor(UIColor.App.buttonDisablePrimary, for: .disabled)
        continueButton.setTitleColor(UIColor.App.buttonTextDisablePrimary, for: .disabled)
        continueButton.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        continueButton.cornerRadius = CornerRadius.button

    }

    private func checkUserInputs() {

        let titleText = titleHeaderTextFieldView.text == "" ? false : true
        let firstNameText = firstNameHeaderTextFieldView.text == "" ? false : true
        let lastNameText = lastNameHeaderTextFieldView.text == "" ? false : true
        let address1Text = address1HeaderTextFieldView.text == "" ? false : true
        let cityText = cityHeaderTextFieldView.text == "" ? false : true
        let postalCodeText = postalCodeHeaderTextFieldView.text == "" ? false : true
        
        
        if titleText && firstNameText && lastNameText && address1Text
            && cityText && postalCodeText && self.selectedCountry != nil {
            
            self.continueButton.isEnabled = true
            continueButton.backgroundColor = UIColor.App.buttonBackgroundPrimary
        }
        else {
            self.continueButton.isEnabled = false
            continueButton.backgroundColor = UIColor.App.backgroundPrimary
        }
    }

    private func setupPublishers() {

//        Env.everyMatrixClient.getCountries()
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//            .sink { _ in
//                self.countryHeaderTextFieldView.isUserInteractionEnabled = true
//            } receiveValue: { countries in
//                self.countries = countries
//                self.setupWithCountryCodes(countries)
//            }
//        .store(in: &cancellables)

        Env.serviceProvider.getProfile()
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.showLoadingView()
                self?.view.isUserInteractionEnabled = false
            },
            receiveCompletion: { [weak self] _ in
                self?.hideLoadingView()
                self?.view.isUserInteractionEnabled = true
            })
            .map(ServiceProviderModelMapper.userProfile(_:))
            .sink { _ in
                
            } receiveValue: { profile in
                self.setupProfile(profile: profile)
            }
            .store(in: &cancellables)
        
        Env.serviceProvider.getCurrentCountry()
            .compactMap({ $0 })
            .map({ (serviceProviderCountry: ServiceProvider.Country) -> Country in
                return Country(name: serviceProviderCountry.name,
                               capital: serviceProviderCountry.capital,
                               region: serviceProviderCountry.region,
                               iso2Code: serviceProviderCountry.iso2Code,
                               iso3Code: serviceProviderCountry.iso3Code,
                               numericCode: serviceProviderCountry.numericCode,
                               phonePrefix: serviceProviderCountry.phonePrefix)
            })
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.countryHeaderTextFieldView.isUserInteractionEnabled = true
            } receiveValue: { [weak self] currentCountry in
                self?.currentCountry = currentCountry
                self?.selectedCountry = currentCountry
            }
            .store(in: &cancellables)
        
        Env.serviceProvider.getCountries()
            .map { (serviceProviderCountries: [ServiceProvider.Country]) -> [Country] in
                serviceProviderCountries.map({ (serviceProviderCountry: ServiceProvider.Country) -> Country in
                    return Country(name: serviceProviderCountry.name,
                                   capital: serviceProviderCountry.capital,
                                   region: serviceProviderCountry.region,
                                   iso2Code: serviceProviderCountry.iso2Code,
                                   iso3Code: serviceProviderCountry.iso3Code,
                                   numericCode: serviceProviderCountry.numericCode,
                                   phonePrefix: serviceProviderCountry.phonePrefix)
                    
                })
            }
            .receive(on: DispatchQueue.main)
            .sink { _ in
                self.countryHeaderTextFieldView.isUserInteractionEnabled = true
            } receiveValue: {  [weak self] countriesArray in
                self?.countries = countriesArray
                
                self?.setupWithCountryCodes(countriesArray)
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

    func createFullRegisterUserForm() -> FullRegisterUserForm {
        
        let gender = titleHeaderTextFieldView.text == UserTitle.mister.rawValue ? "M" : "F"

        let firstName = self.firstNameHeaderTextFieldView.text
        let lastName = self.lastNameHeaderTextFieldView.text
        let address1 = self.address1HeaderTextFieldView.text
        let address2 = self.address2HeaderTextFieldView.text
        let city = self.cityHeaderTextFieldView.text
        let postalCode = self.postalCodeHeaderTextFieldView.text
        let birthDate = self.profile?.birthDate
        
        return FullRegisterUserForm(username: nil,
                                    email: nil,
                                    firstName: firstName,
                                    lastName: lastName,
                                    birthDate: birthDate,
                                    gender: gender,
                                    mobilePrefix: nil,
                                    mobileNumber: nil,
                                    address: address1,
                                    province: address2,
                                    city: city,
                                    postalCode: postalCode,
                                    country: self.selectedCountry,
                                    cardId: nil)

    }

    private func setupProfile(profile: UserProfile) {
                
        self.profile = profile
        
        if let optionIndex = UserTitle.titles.firstIndex(of: profile.title?.rawValue ?? "") {
            self.titleHeaderTextFieldView.setSelectionPicker(UserTitle.titles, headerVisible: true)
            self.titleHeaderTextFieldView.setSelectedPickerOption(option: optionIndex)
        }
        else {
            self.titleHeaderTextFieldView.setSelectionPicker(UserTitle.titles, headerVisible: true)
            self.titleHeaderTextFieldView.setSelectedPickerOption(option: UserTitle.titles.startIndex)
        }
        
        self.firstNameHeaderTextFieldView.setText(profile.firstName ?? "")
        self.lastNameHeaderTextFieldView.setText(profile.lastName ?? "")
        
        if let country = profile.nationality {
            self.selectedCountry = country
            self.countryHeaderTextFieldView.setText( self.formatIndicativeCountry(country), slideUp: true)
        }
    }
    
    @IBAction private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func continueAction() {
        let fullRegisterUserForm = self.createFullRegisterUserForm()
        let fullRegisterAddressCountryViewController = FullRegisterAddressCountryViewController(registerForm: fullRegisterUserForm)
        self.navigationController?.pushViewController(fullRegisterAddressCountryViewController, animated: true)
    }

    @IBAction private func closeAction() {
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
    private func setupWithCountryCodes(_ countries: [Country]) {
        self.countryHeaderTextFieldView.isUserInteractionEnabled = true
        self.countryHeaderTextFieldView.shouldBeginEditing = { [weak self] in
            self?.showCountrySelector(countries)
            return false
        }
    }

    private func showCountrySelector(_ countries: [Country]) {
        let phonePrefixSelectorViewController = PhonePrefixSelectorViewController(countries: countries,
                                                                                  originCountry: nil,
                                                                                  showIndicatives: false)
        phonePrefixSelectorViewController.modalPresentationStyle = .overCurrentContext
        phonePrefixSelectorViewController.didSelectCountry = { [weak self] country in
            self?.setupWithSelectedCountry(country)
            phonePrefixSelectorViewController.animateDismissView()
        }
        self.present(phonePrefixSelectorViewController, animated: false, completion: nil)
    }

    private func setupWithSelectedCountry(_ country: Country) {
        self.selectedCountry = country
        self.countryHeaderTextFieldView.setText(self.formatIndicativeCountry(country), slideUp: true)
    }

    private func formatIndicativeCountry(_ country: Country) -> String {
        var stringCountry = "\(country.name)"
        let isoCode = country.iso2Code
        
        stringCountry = "\(isoCode) - \(country.name)"
        if let flag = CountryFlagHelper.flag(forCode: isoCode) {
            stringCountry = "\(flag) \(country.name)"
        }
        
        return stringCountry
    }
}
