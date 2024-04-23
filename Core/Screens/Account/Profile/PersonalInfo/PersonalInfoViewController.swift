//
//  PersonalInfoViewController.swift
//  Sportsbook
//
//  Created by André Lascas on 16/09/2021.
//

import UIKit
import Combine
import ServicesProvider
import SharedModels

class PersonalInfoViewController: UIViewController {

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var headerView: UIView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var headerLabel: UILabel!
    @IBOutlet private var editButton: UIButton!

    @IBOutlet private var titleHeaderTextFieldView: HeaderDropDownSelectionView!
    @IBOutlet private var firstNameHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var lastNameHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var countryHeaderTextFieldView: HeaderDropDownSelectionView!
    @IBOutlet private var birthDateHeaderTextFieldView: HeaderDropDownSelectionView!
    @IBOutlet private var adress1HeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var adress2HeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var cityHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var postalCodeHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var lineView: UIView!
    @IBOutlet private var usernameHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var emailHeaderTextFieldView: HeaderTextFieldView!
    
    @IBOutlet private weak var phoneNumberHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var cardIdHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var bankIdHeaderTextFieldView: HeaderTextFieldView!

    @IBOutlet private var placeOfBirthHeaderTextFieldView: HeaderTextFieldView!
    @IBOutlet private var departmentOfBirthHeaderTextFieldView: HeaderTextFieldView!

    @IBOutlet private var infoView: UIView!
    @IBOutlet private var infoLabel: UILabel!
    // Variables

    private var cancellables = Set<AnyCancellable>()
    private var countries: [Country] = []
    private var profile: UserProfile?
    
    private var originalFormHash: String?

    init() {
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
        editButton.isHidden = true

//        titleHeaderTextFieldView.setPlaceholderText(localized("title"))
        titleHeaderTextFieldView.setPlaceholderText(localized("gender"))
        titleHeaderTextFieldView.setSelectionPicker(["---"], headerVisible: true)
        titleHeaderTextFieldView.setImageTextField(UIImage(named: "arrow_dropdown_icon")!)
        titleHeaderTextFieldView.setTextFieldFont(AppFont.with(type: .regular, size: 16))
        titleHeaderTextFieldView.setHeaderLabelFont(AppFont.with(type: .regular, size: 15))
        titleHeaderTextFieldView.setPlaceholderTextColor(UIColor.App.inputTextTitle)
        titleHeaderTextFieldView.isDisabled = true

        firstNameHeaderTextFieldView.setPlaceholderText(localized("first_name"))
        firstNameHeaderTextFieldView.showTipWithoutIcon(text: localized("names_match_id"),
                                                        color: UIColor.App.inputTextTitle)
        firstNameHeaderTextFieldView.isDisabled = true

        lastNameHeaderTextFieldView.setPlaceholderText(localized("last_name"))
        lastNameHeaderTextFieldView.isDisabled = true

        countryHeaderTextFieldView.setPlaceholderText(localized("country_of_birth"))
        countryHeaderTextFieldView.setSelectionPicker(["---"], headerVisible: true)
        countryHeaderTextFieldView.setImageTextField(UIImage(named: "arrow_dropdown_icon")!)
        countryHeaderTextFieldView.setTextFieldFont(AppFont.with(type: .regular, size: 16))
        countryHeaderTextFieldView.setHeaderLabelFont(AppFont.with(type: .regular, size: 15))
        countryHeaderTextFieldView.setPlaceholderTextColor(UIColor.App.inputTextTitle)
        countryHeaderTextFieldView.shouldBeginEditing = { return false }

        birthDateHeaderTextFieldView.setPlaceholderText(localized("birth_date"))
        birthDateHeaderTextFieldView.setImageTextField(UIImage(named: "calendar_regular_icon")!)
        birthDateHeaderTextFieldView.setTextFieldFont(AppFont.with(type: .regular, size: 16))
        birthDateHeaderTextFieldView.setHeaderLabelFont(AppFont.with(type: .regular, size: 15))
        birthDateHeaderTextFieldView.setPlaceholderTextColor(UIColor.App.inputTextTitle)
        birthDateHeaderTextFieldView.shouldBeginEditing = { return false }

        adress1HeaderTextFieldView.setPlaceholderText(localized("address"))
        adress1HeaderTextFieldView.isDisabled = true

        adress2HeaderTextFieldView.setPlaceholderText(localized("street_number"))
        adress2HeaderTextFieldView.isDisabled = true

        cityHeaderTextFieldView.setPlaceholderText(localized("city"))
        cityHeaderTextFieldView.isDisabled = true

        postalCodeHeaderTextFieldView.setPlaceholderText(localized("postal_code"))
        postalCodeHeaderTextFieldView.isDisabled = true

        usernameHeaderTextFieldView.setPlaceholderText(localized("username"))
        usernameHeaderTextFieldView.isDisabled = true

        emailHeaderTextFieldView.setPlaceholderText(localized("email"))
        emailHeaderTextFieldView.isDisabled = true
        
        phoneNumberHeaderTextFieldView.setPlaceholderText(localized("phone_number"))
        phoneNumberHeaderTextFieldView.isDisabled = true

        cardIdHeaderTextFieldView.setPlaceholderText(localized("id_number"))

        bankIdHeaderTextFieldView.setPlaceholderText(localized("bank_id"))

        placeOfBirthHeaderTextFieldView.setPlaceholderText(localized("place_of_birth"))
        placeOfBirthHeaderTextFieldView.isDisabled = true

        departmentOfBirthHeaderTextFieldView.setPlaceholderText(localized("department_of_birth"))
        departmentOfBirthHeaderTextFieldView.isDisabled = true

        let tapGestureRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(didTapBackgroundView))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        self.editButton.isEnabled = false
        self.countryHeaderTextFieldView.isUserInteractionEnabled = false

        let calendar = Calendar(identifier: .gregorian)
        var components = DateComponents()
        components.calendar = calendar
        components.year = -18
        let maxDate = calendar.date(byAdding: components, to: Date())!
        birthDateHeaderTextFieldView.datePicker.maximumDate = maxDate

        self.cardIdHeaderTextFieldView.isHidden = true
        self.bankIdHeaderTextFieldView.isHidden = true

        self.infoView.layer.cornerRadius = CornerRadius.view
        self.infoView.layer.masksToBounds = true

        self.infoLabel.text = localized("contact_support")
        self.infoLabel.numberOfLines = 0
        self.infoLabel.font = AppFont.with(type: .semibold, size: 16)
        self.infoLabel.textAlignment = .center

        let infoViewTap = UITapGestureRecognizer(target: self, action: #selector(self.tapInfoView))
        self.infoView.addGestureRecognizer(infoViewTap)

    }

    func setupWithTheme() {

        self.view.backgroundColor = UIColor.App.backgroundPrimary

        editButton.backgroundColor = .clear
        editButton.setTitleColor(UIColor.App.highlightPrimary, for: .normal)
        editButton.setTitleColor(UIColor.App.highlightPrimary, for: .highlighted)
        editButton.setTitleColor(UIColor.App.highlightPrimary.withAlphaComponent(0.4), for: .disabled)

        containerView.backgroundColor = UIColor.App.backgroundPrimary
        headerView.backgroundColor = UIColor.App.backgroundPrimary
        headerLabel.textColor = UIColor.App.textPrimary

        lineView.backgroundColor = UIColor.App.inputTextTitle.withAlphaComponent(0.2)

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
        countryHeaderTextFieldView.isDisabled = true

        birthDateHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        birthDateHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
        birthDateHeaderTextFieldView.setViewColor(UIColor.App.backgroundPrimary)
        birthDateHeaderTextFieldView.setViewBorderColor(UIColor.App.inputTextTitle)
//        birthDateHeaderTextFieldView.isDisabled = true
        birthDateHeaderTextFieldView.setDatePickerMode()
        
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
        
        phoneNumberHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        phoneNumberHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        phoneNumberHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
        phoneNumberHeaderTextFieldView.isDisabled = true

        cardIdHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        cardIdHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        cardIdHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        bankIdHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        bankIdHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        bankIdHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
        bankIdHeaderTextFieldView.isDisabled = true

        placeOfBirthHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        placeOfBirthHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        placeOfBirthHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)
//        placeOfBirthHeaderTextFieldView.isDisabled = true

        departmentOfBirthHeaderTextFieldView.backgroundColor = UIColor.App.backgroundPrimary
        departmentOfBirthHeaderTextFieldView.setHeaderLabelColor(UIColor.App.inputTextTitle)
        departmentOfBirthHeaderTextFieldView.setTextFieldColor(UIColor.App.inputText)

        self.infoView.backgroundColor = UIColor.App.highlightPrimary

        self.infoLabel.textColor = UIColor.App.buttonTextPrimary
    }

    private func setupPublishers() {

        Publishers.MergeMany(self.titleHeaderTextFieldView.textPublisher.eraseToAnyPublisher(),
                             self.firstNameHeaderTextFieldView.textPublisher.eraseToAnyPublisher(),
                             self.lastNameHeaderTextFieldView.textPublisher.eraseToAnyPublisher(),
                             self.countryHeaderTextFieldView.textPublisher.eraseToAnyPublisher(),
                             self.birthDateHeaderTextFieldView.textPublisher.eraseToAnyPublisher(),
                             self.adress1HeaderTextFieldView.textPublisher.eraseToAnyPublisher(),
                             self.adress2HeaderTextFieldView.textPublisher.eraseToAnyPublisher(),
                             self.cityHeaderTextFieldView.textPublisher.eraseToAnyPublisher(),
                             self.postalCodeHeaderTextFieldView.textPublisher.eraseToAnyPublisher(),
                             self.usernameHeaderTextFieldView.textPublisher.eraseToAnyPublisher(),
                             self.emailHeaderTextFieldView.textPublisher.eraseToAnyPublisher(),
                             self.phoneNumberHeaderTextFieldView.textPublisher.eraseToAnyPublisher(),
                             self.cardIdHeaderTextFieldView.textPublisher.eraseToAnyPublisher(),
                             self.bankIdHeaderTextFieldView.textPublisher.eraseToAnyPublisher(),
                             self.placeOfBirthHeaderTextFieldView.textPublisher.eraseToAnyPublisher(),
                             self.departmentOfBirthHeaderTextFieldView.textPublisher.eraseToAnyPublisher())
        .flatMap({ [weak self] _ -> AnyPublisher<Bool, Never> in
            let newHash = self?.generateFormHash()
            if let originalHash = self?.originalFormHash {
                return Just(newHash != originalHash).eraseToAnyPublisher()
            }
            else {
                return Just(false).eraseToAnyPublisher()
            }
        })
        .sink(receiveValue: { (isEnabled: Bool) -> Void in
            self.editButton.isEnabled = isEnabled
        })
        .store(in: &cancellables)

        Env.servicesProvider.getProfile()
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

    }

    func generateFormHash() -> String {
        return [self.titleHeaderTextFieldView.text,
                self.firstNameHeaderTextFieldView.text,
                self.lastNameHeaderTextFieldView.text,
                self.countryHeaderTextFieldView.text,
                self.birthDateHeaderTextFieldView.text,
                self.adress1HeaderTextFieldView.text,
                self.adress2HeaderTextFieldView.text,
                self.cityHeaderTextFieldView.text,
                self.postalCodeHeaderTextFieldView.text,
                self.usernameHeaderTextFieldView.text,
                self.emailHeaderTextFieldView.text,
                self.phoneNumberHeaderTextFieldView.text,
                self.cardIdHeaderTextFieldView.text,
                self.bankIdHeaderTextFieldView.text,
                self.placeOfBirthHeaderTextFieldView.text,
                self.departmentOfBirthHeaderTextFieldView.text].joined().MD5
    }

    @objc private func tapInfoView() {

//        let supportViewModel = SupportPageViewModel()
//
//        let supportViewController = SupportPageViewController(viewModel: supportViewModel)
//
//        self.navigationController?.pushViewController(supportViewController, animated: true)
        
        if let url = URL(string: "https://support.betsson.fr/hc/fr") {
            UIApplication.shared.open(url)
        }
    }

    @IBAction private func didTapBackButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func didTapSaveButton() {

        var validFields = true

        // let username = usernameHeaderTextFieldView.text
        // let email = emailHeaderTextFieldView.text
        //let gender = titleHeaderTextFieldView.text == UserTitle.mister.rawValue ? "M" : "F"
        let gender = titleHeaderTextFieldView.text == UserGender.male.rawValue ? "M" : "F"

        let firstName = firstNameHeaderTextFieldView.text
        let lastName = lastNameHeaderTextFieldView.text
        let birthDateString = birthDateHeaderTextFieldView.text
//        let mobilePrefix = profile?.mobilePrefix ?? ""
//        let mobile = profile?.mobile ?? ""
//        let phonePrefix = profile?.phonePrefix ?? ""
//        let phone = profile?.phone ?? ""
//        let country = profile?.country ?? ""
        let address1 = adress1HeaderTextFieldView.text
        let address2 = adress2HeaderTextFieldView.text
        
        let postalCode = postalCodeHeaderTextFieldView.text
        let personalId = cardIdHeaderTextFieldView.text

//        let city = self.profile?.city
        let city = cityHeaderTextFieldView.text

        let placeOfBirth = placeOfBirthHeaderTextFieldView.text

        let departmentOfBirth = departmentOfBirthHeaderTextFieldView.text
        
        var serviceProviderCountry: SharedModels.Country?
        if let countryValue = self.profile?.country {
            serviceProviderCountry = ServiceProviderModelMapper.country(fromCountry: countryValue)
        }
        
        let date = DateFormatter(format: "yyyy-MM-dd").date(from: birthDateString)
//        let securityQuestion = profile?.securityQuestion ?? ""
//        let securityAnswer = profile?.securityAnswer ?? ""

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

        if !validFields {
            return
        }

        let form = ServicesProvider.UpdateUserProfileForm.init(username: nil,
                                                              email: nil,
                                                              firstName: firstName,
                                                              lastName: lastName,
                                                              birthDate: date,
                                                              gender: gender,
                                                              address: address1,
                                                              province: address2,
                                                              city: city,
                                                              postalCode: postalCode,
                                                              country: serviceProviderCountry,
                                                              cardId: personalId)
        self.showLoadingView()
        
        Env.servicesProvider.updateUserProfile(form: form)
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.showLoadingView()
                self?.view.isUserInteractionEnabled = false
            },
            receiveCompletion: { [weak self] _ in
                self?.hideLoadingView()
                self?.view.isUserInteractionEnabled = true
            })
            .sink { completion in
                if case .failure = completion {
                    self.showAlert(type: .error, text: "")
                }
                self.hideLoadingView()
            } receiveValue: { _ in
                // self.showAlert(type: .success, text: localized("profile_updated_success"))
            }
            .store(in: &cancellables)

        if address2 != "" || placeOfBirth != "" {
            Env.servicesProvider.updateExtraInfo(placeOfBirth: placeOfBirth, address2: address2)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        ()
                    case .failure(let error):
                        print("EXTRA INFO ERROR: \(error)")
                    }

                }, receiveValue: { [weak self] limitsResponse in
                    
                    print("EXTRA INFO RESPONSE: \(limitsResponse)")
                    
                })
                .store(in: &cancellables)
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

    @objc func didTapBackgroundView() {
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

    private func setupProfile(profile: UserProfile) {
        self.profile = profile

        if let optionIndex = UserGender.titles.firstIndex(of: profile.title?.genderAbbreviation ?? "") {
            self.titleHeaderTextFieldView.setSelectionPicker(UserGender.titles, headerVisible: true)
            self.titleHeaderTextFieldView.setSelectedPickerOption(option: optionIndex)
        }
        else {
            self.titleHeaderTextFieldView.setText("")

            self.titleHeaderTextFieldView.setSelectionPicker(UserGender.titles, headerVisible: true)
            self.titleHeaderTextFieldView.setSelectedPickerOption(option: UserGender.titles.startIndex)
        }
        
        self.usernameHeaderTextFieldView.setText(profile.username)
        self.emailHeaderTextFieldView.setText(profile.email)
        
        let fullMobilePhone = "\(profile.mobilePhone ?? "-")"
        
        self.phoneNumberHeaderTextFieldView.setText(fullMobilePhone)
        
        self.firstNameHeaderTextFieldView.setText(profile.firstName ?? "-")
        self.lastNameHeaderTextFieldView.setText(profile.lastName ?? "-")
        
        if let country = profile.nationality {
            self.countryHeaderTextFieldView.setText( self.formatIndicativeCountry(country, showName: true), slideUp: true)
        }
        
        self.birthDateHeaderTextFieldView.setText(profile.birthDate.toString(formatString: "dd-MM-yyyy"))
        self.adress1HeaderTextFieldView.setText(profile.address ?? "-")
        self.adress2HeaderTextFieldView.setText(profile.streetNumber ?? "-")
        self.cityHeaderTextFieldView.setText(profile.city ?? "-")
        self.postalCodeHeaderTextFieldView.setText(profile.postalCode ?? "-")
        
        self.cardIdHeaderTextFieldView.setText(profile.personalIdNumber ?? "-")

        self.placeOfBirthHeaderTextFieldView.setText(profile.placeOfBirth ?? "-")

        self.departmentOfBirthHeaderTextFieldView.setText(profile.birthDepartment ?? "-")
        
        self.originalFormHash = self.generateFormHash()

    }

}

// Flags business logic
extension PersonalInfoViewController {

    private func formatIndicativeCountry(_ country: Country, showName: Bool? = false) -> String {
        var stringCountry = "\(country.phonePrefix)"
        let isoCode = country.iso2Code

        if let showName, !showName {
            stringCountry = "\(isoCode) - \(country.phonePrefix)"
            if let flag = CountryFlagHelper.flag(forCode: isoCode) {
                stringCountry = "\(flag) \(country.phonePrefix)"
            }
        }
        else {
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

