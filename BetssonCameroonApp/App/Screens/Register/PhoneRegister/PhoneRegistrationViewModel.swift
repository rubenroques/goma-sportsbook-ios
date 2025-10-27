//
//  MockPhoneRegistrationViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 25/06/2025.
//

import Foundation
import GomaUI
import Combine
import ServicesProvider

class PhoneRegistrationViewModel: PhoneRegistrationViewModelProtocol {
    let headerViewModel: PromotionalHeaderViewModelProtocol
    let highlightedTextViewModel: HighlightedTextViewModelProtocol
    
    var phoneFieldViewModel: BorderedTextFieldViewModelProtocol?
    var passwordFieldViewModel: BorderedTextFieldViewModelProtocol?
    var firstNameFieldViewModel: BorderedTextFieldViewModelProtocol?
    var lastNameFieldViewModel: BorderedTextFieldViewModelProtocol?
    var birthDateFieldViewModel: BorderedTextFieldViewModelProtocol?
    var termsViewModel: TermsAcceptanceViewModelProtocol?
    
    let buttonViewModel: ButtonViewModelProtocol
    
    private var cancellables = Set<AnyCancellable>()
    
    private let isLoadingConfigSubject = CurrentValueSubject<Bool, Never>(true)
    var isLoadingConfigPublisher: AnyPublisher<Bool, Never> { isLoadingConfigSubject.eraseToAnyPublisher() }
    
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    var isLoadingPublisher: AnyPublisher<Bool, Never> { isLoadingSubject.eraseToAnyPublisher() }
    
    var isRegisterDataComplete: CurrentValueSubject<Bool, Never> = .init(false)
    var registerComplete: (() -> Void)?
    var registerError: ((String) -> Void)?
    var showBonusOnRegister: (() -> Void)?
    
    var registrationConfig: RegistrationConfigContent?
    var extractedTermsHTMLData: RegisterConfigHelper.ExtractedHTMLData?
    var birthDateMinMax: (min: String, max: String)?


    var phonePrefixText: String = ""
    var phoneText: String = ""
    var password: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var birthDate: String = ""
    
    init() {
        
        headerViewModel = MockPromotionalHeaderViewModel(headerData: PromotionalHeaderData(id: "registerHeader",
                                                                                           icon: "key_icon",
                                                                                           title: "Get in on the action!",
                                                                                           subtitle: nil))
        
        highlightedTextViewModel = MockHighlightedTextViewModel(data: HighlightedTextData(fullText: "Sign up securely in just 2 minutes", highlights: []))
        
        buttonViewModel = MockButtonViewModel(buttonData: ButtonData(id: "register",
                                                                     title: "Create Account",
                                                                     style: .solidBackground,
                                                                     isEnabled: true))
        
        getRegistrationConfig()
        
    }
    
    func getRegistrationConfig() {
        
        self.isLoadingSubject.send(true)
        
        Env.servicesProvider.getRegistrationConfig()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    print("FINISHED GET REGISTRATION CONFIG")
                case .failure(let error):
                    print("ERROR GET REGISTRATION CONFIG: \(error)")
                    self?.isLoadingSubject.send(false)
                    self?.isLoadingConfigSubject.send(false)
                }
            }, receiveValue: { [weak self] registrationConfigResponse in
                
                let mappedRegistrationConfig = ServiceProviderModelMapper.registrationConfigResponse(fromInternalResponse: registrationConfigResponse)
                
                if let termsConfig = mappedRegistrationConfig.content.fields.first(where: {
                    $0.name == "TermsAndConditions"
                }) {
                    
                    self?.extractedTermsHTMLData = RegisterConfigHelper.extractLinksAndCleanText(from: termsConfig.displayName)
                }
                
                self?.handleRegistrationConfig(mappedRegistrationConfig.content)
                
            })
            .store(in: &cancellables)
    }
    
    func handleRegistrationConfig(_ config: RegistrationConfigContent) {
        self.registrationConfig = config
        
        for field in config.fields {
            
            switch field.name {
            case "Mobile":
                let phoneConfig = config.fields.first(where: {
                    $0.name == "Mobile"
                })
                
                phonePrefixText = phoneConfig?.defaultValue ?? "+237"
                phoneFieldViewModel = MockBorderedTextFieldViewModel(
                    textFieldData: BorderedTextFieldData(id: "phone",
                                                         placeholder: field.placeholder ?? "Mobile Phone Number",
                                                         prefix: phoneConfig?.defaultValue ?? "+237",
                                                         isSecure: false,
                                                         isRequired: true,
                                                         visualState: .idle,
                                                         keyboardType: .phonePad,
                                                         textContentType: .telephoneNumber))
            case "Password":
                let passwordConfig = config.fields.first(where: {
                    $0.name == "Password"
                })
                
                passwordFieldViewModel = MockBorderedTextFieldViewModel(
                    textFieldData: BorderedTextFieldData(id: "password",
                                                         placeholder: field.placeholder ?? "Password (4 characters)",
                                                         isSecure: true,
                                                         isRequired: true,
                                                         visualState: .idle,
                                                         keyboardType: .default,
                                                         textContentType: .password))
            case "FirstnameOnDocument":
                firstNameFieldViewModel = MockBorderedTextFieldViewModel(
                    textFieldData: BorderedTextFieldData(
                        id: "firstName",
                        placeholder: field.placeholder ?? "Enter your first name",
                        isSecure: false,
                        isRequired: true,
                        visualState: .idle,
                        keyboardType: .default,
                        textContentType: .givenName
                    )
                )
            case "LastNameOnDocument":
                lastNameFieldViewModel = MockBorderedTextFieldViewModel(
                    textFieldData: BorderedTextFieldData(
                        id: "lastName",
                        placeholder: field.placeholder ?? "Enter your last name",
                        isSecure: false,
                        isRequired: true,
                        visualState: .idle,
                        keyboardType: .default,
                        textContentType: .familyName
                    )
                )
            case "BirthDate":
                // Store min/max dates for date picker configuration
                if let minDateString = field.validate.min,
                   let maxDateString = field.validate.max {
                    self.birthDateMinMax = (min: minDateString, max: maxDateString)
                }

                birthDateFieldViewModel = MockBorderedTextFieldViewModel(
                    textFieldData: BorderedTextFieldData(
                        id: "birthDate",
                        placeholder: field.placeholder ?? "yyyy-mm-dd",
                        isSecure: false,
                        isRequired: true,
                        usesCustomInput: true,  // Use date picker instead of keyboard
                        visualState: .idle,
                        keyboardType: .numbersAndPunctuation,
                        textContentType: .none
                    )
                )
            case "TermsAndConditions":
                let extractedTermsHTMLData = self.extractedTermsHTMLData
                
                // swiftlint:disable line_length
                let fullText = extractedTermsHTMLData?.fullText ?? "By creating an account I agree that I am 21 years of age or older and have read and accepted our general Terms and Conditions and Privacy Policy"
                
                let termsData = extractedTermsHTMLData?.extractedLinks.first(where: {
                    $0.type == .terms
                })
                
                let privacyData = extractedTermsHTMLData?.extractedLinks.first(where: {
                    $0.type == .privacyPolicy
                })
                
                let cookiesData = extractedTermsHTMLData?.extractedLinks.first(where: {
                    $0.type == .cookies
                })
                
                termsViewModel = MockTermsAcceptanceViewModel(data: TermsAcceptanceData(fullText: fullText,
                                                                              termsText: termsData?.text ?? "Terms and Conditions",
                                                                              privacyText: privacyData?.text ?? "Privacy Policy",
                                                                              cookiesText: cookiesData?.text,
                                                                                        isAccepted: true))
            default:
                ()
            }
        }
        
        setupPublishers()
        
        isLoadingSubject.send(false)
        isLoadingConfigSubject.send(false)
    }
    
    private func setupPublishers() {
        
        guard let registrationConfig = registrationConfig,
              let phoneFieldViewModel = phoneFieldViewModel,
              let passwordFieldViewModel = passwordFieldViewModel,
              let termsViewModel = termsViewModel else {
            return
        }
        
        // Create validity publishers for all fields
        let phoneNumberValidityPublisher = phoneFieldViewModel.textPublisher
            .map({ phoneNumber in
                RegisterConfigHelper.isValidPhoneNumber(phoneText: phoneNumber, registrationConfig: registrationConfig).0
            })
        
        let passwordValidityPublisher = passwordFieldViewModel.textPublisher
            .map({ password in
                RegisterConfigHelper.isValidPassword(passwordText: password, registrationConfig: registrationConfig).0
            })
        
        // Optional field validity publishers - default to true if field doesn't exist
        let firstNameValidityPublisher: AnyPublisher<Bool, Never> = firstNameFieldViewModel?.textPublisher
            .map({ firstName in
                RegisterConfigHelper.isValidFirstName(text: firstName, registrationConfig: registrationConfig).0
            })
            .eraseToAnyPublisher() ?? Just(true).eraseToAnyPublisher()
        
        let lastNameValidityPublisher: AnyPublisher<Bool, Never> = lastNameFieldViewModel?.textPublisher
            .map({ lastName in
                RegisterConfigHelper.isValidLastName(text: lastName, registrationConfig: registrationConfig).0
            })
            .eraseToAnyPublisher() ?? Just(true).eraseToAnyPublisher()
        
        let birthDateValidityPublisher: AnyPublisher<Bool, Never> = birthDateFieldViewModel?.textPublisher
            .map({ birthDate in
                RegisterConfigHelper.isValidBirthDate(dateText: birthDate, registrationConfig: registrationConfig).0
            })
            .eraseToAnyPublisher() ?? Just(true).eraseToAnyPublisher()
        
        // Combine all validity publishers
        Publishers.CombineLatest(
            Publishers.CombineLatest4(
                phoneNumberValidityPublisher,
                passwordValidityPublisher,
                firstNameValidityPublisher,
                lastNameValidityPublisher
            ),
            Publishers.CombineLatest(
                birthDateValidityPublisher,
                termsViewModel.dataPublisher
            )
        )
        .map { firstGroup, secondGroup in
            let (phoneValid, passValid, firstNameValid, lastNameValid) = firstGroup
            let (birthDateValid, termsData) = secondGroup
            return phoneValid && passValid && firstNameValid && lastNameValid && birthDateValid && termsData.isAccepted
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] isEnabled in
            self?.buttonViewModel.setEnabled(isEnabled)
            self?.isRegisterDataComplete.send(isEnabled)
        }
        .store(in: &cancellables)
        
        // Phone field text subscription
        phoneFieldViewModel.textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] phoneText in
                guard let self = self else { return }
                
                let isValidPhoneNumberData = RegisterConfigHelper.isValidPhoneNumber(phoneText: phoneText, registrationConfig: registrationConfig)
                
                if phoneText.isEmpty {
                    phoneFieldViewModel.clearError()
                } else if !isValidPhoneNumberData.0 {
                    phoneFieldViewModel.setError("\(isValidPhoneNumberData.1)")
                } else {
                    phoneFieldViewModel.clearError()
                }
                
                self.phoneText = phoneText
            }
            .store(in: &cancellables)
        
        // Password field text subscription
        passwordFieldViewModel.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] passwordText in
                
                let isValidPasswordData = RegisterConfigHelper.isValidPassword(passwordText: passwordText, registrationConfig: registrationConfig)
                
                if !isValidPasswordData.0 && !passwordText.isEmpty {
                    passwordFieldViewModel.setError("\(isValidPasswordData.1)")
                }
                else {
                    passwordFieldViewModel.clearError()
                }
                
                self?.password = passwordText
            })
            .store(in: &cancellables)
        
        // First name field text subscription (if exists)
        if let firstNameFieldViewModel = firstNameFieldViewModel {
            firstNameFieldViewModel.textPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] firstNameText in
                    guard let self = self else { return }
                    
                    let isValidFirstNameData = RegisterConfigHelper.isValidFirstName(text: firstNameText, registrationConfig: registrationConfig)
                    
                    if firstNameText.isEmpty {
                        firstNameFieldViewModel.clearError()
                    } else if !isValidFirstNameData.0 {
                        firstNameFieldViewModel.setError("\(isValidFirstNameData.1)")
                    } else {
                        firstNameFieldViewModel.clearError()
                    }
                    
                    self.firstName = firstNameText
                }
                .store(in: &cancellables)
        }
        
        // Last name field text subscription (if exists)
        if let lastNameFieldViewModel = lastNameFieldViewModel {
            lastNameFieldViewModel.textPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] lastNameText in
                    guard let self = self else { return }
                    
                    let isValidLastNameData = RegisterConfigHelper.isValidLastName(text: lastNameText, registrationConfig: registrationConfig)
                    
                    if lastNameText.isEmpty {
                        lastNameFieldViewModel.clearError()
                    } else if !isValidLastNameData.0 {
                        lastNameFieldViewModel.setError("\(isValidLastNameData.1)")
                    } else {
                        lastNameFieldViewModel.clearError()
                    }
                    
                    self.lastName = lastNameText
                }
                .store(in: &cancellables)
        }
        
        // Birth date field text subscription (if exists)
        if let birthDateFieldViewModel = birthDateFieldViewModel {
            birthDateFieldViewModel.textPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] birthDateText in
                    guard let self = self else { return }
                    
                    let isValidBirthDateData = RegisterConfigHelper.isValidBirthDate(dateText: birthDateText, registrationConfig: registrationConfig)
                    
                    if birthDateText.isEmpty {
                        birthDateFieldViewModel.clearError()
                    } else if !isValidBirthDateData.0 {
                        birthDateFieldViewModel.setError("\(isValidBirthDateData.1)")
                    } else {
                        birthDateFieldViewModel.clearError()
                    }
                    
                    self.birthDate = birthDateText
                }
                .store(in: &cancellables)
        }
        
    }
    
    func registerUser() {
        
        isLoadingSubject.send(true)
        
        let registrationId = registrationConfig?.registrationID ?? ""
        
        // Pass all fields to the sign-up form
        let signUpFormType = SignUpFormType.phone(PhoneSignUpForm(
            phone: self.phoneText,
            phonePrefix: self.phonePrefixText,
            password: self.password,
            registrationId: registrationId,
            firstName: self.firstName.isEmpty ? nil : self.firstName,
            lastName: self.lastName.isEmpty ? nil : self.lastName,
            birthDate: self.birthDate.isEmpty ? nil : self.birthDate
        ))
        
        Env.servicesProvider.signUp(with: signUpFormType)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    print("PHONE REGISTER FINISHED")
                case .failure(let error):
                    print("PHONE REGISTER ERROR: \(error)")
                    switch error {
                    case .errorMessage(let message):
                        self?.registerError?(message)
                    default:
                        self?.registerError?(error.localizedDescription)
                    }
                    
                    self?.isLoadingSubject.send(false)
                    
                }
                
            }, receiveValue: { [weak self] signUpResponse in
                
                self?.loginUserAfterRegister()
            })
            .store(in: &cancellables)
    }
    
    func loginUserAfterRegister() {
        
        Env.userSessionStore.login(withUsername: "\(phonePrefixText)\(phoneText)", password: self.password)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    switch error {
                    case .errorMessage(let errorMessage):
                        self?.registerError?(errorMessage)
                    default:
                        self?.registerError?("Login after register error")
                    }
                case .finished:
                    ()
                }
                
                self?.isLoadingSubject.send(false)
                
            }, receiveValue: { [weak self] _ in
                self?.registerComplete?()
                
            })
            .store(in: &cancellables)
    }
    
}

class RegisterConfigHelper {
    
    static func extractLinksAndCleanText(from htmlString: String) -> ExtractedHTMLData {
        var cleanText = htmlString
        var links: [ExtractedLink] = []
        
        // Regular expression to match <a href="..." target="_blank">...</a> tags
        let linkPattern = #"<a href="([^"]+)" target="_blank">([^<]+)</a>"#
        
        do {
            let regex = try NSRegularExpression(pattern: linkPattern, options: [])
            let range = NSRange(location: 0, length: htmlString.utf16.count)
            
            // Find all matches
            let matches = regex.matches(in: htmlString, options: [], range: range)
            
            // Process matches in reverse order to avoid index shifting
            for match in matches.reversed() {
                if match.numberOfRanges == 3 {
                    let urlRange = match.range(at: 1)
                    let textRange = match.range(at: 2)
                    
                    if let url = Range(urlRange, in: htmlString),
                       let text = Range(textRange, in: htmlString) {
                        let linkUrl = String(htmlString[url])
                        let linkText = String(htmlString[text])
                        let linkType = ExtractedLinkType(from: linkUrl)
                        
                        // Add to links array
                        links.append(ExtractedLink(text: linkText, url: linkUrl, type: linkType))
                        
                        // Replace the entire <a> tag with just the text
                        let fullMatchRange = match.range(at: 0)
                        if let fullRange = Range(fullMatchRange, in: htmlString) {
                            cleanText = cleanText.replacingCharacters(in: fullRange, with: linkText)
                        }
                    }
                }
            }
        } catch {
            print("Regex error: \(error)")
        }
        
        return ExtractedHTMLData(fullText: cleanText, extractedLinks: links)
    }
    
    static func isValidPhoneNumber(phoneText: String, registrationConfig: RegistrationConfigContent) -> (Bool, String) {
        
        if let phoneRules = registrationConfig.fields.first(where: {
            $0.name == "Mobile"
        }) {
            
            // Check regex rule from registration config
            if let regexRule = phoneRules.validate.custom.first(where: {
                $0.rule == "regex"
            }) {
                if let regex = try? NSRegularExpression(pattern: regexRule.pattern ?? "") {
                    let range = NSRange(location: 0, length: phoneText.utf16.count)
                    let isValid = regex.firstMatch(in: phoneText, options: [], range: range) != nil
                    
                    if !isValid {
                        return (false, regexRule.errorMessage)
                    }
                }
            }
            
            if let phoneMinLengthRule = phoneRules.validate.minLength,
               let phoneMaxLengthRule = phoneRules.validate.maxLength {
                
                let isValid = (phoneText.count >= phoneMinLengthRule) && (phoneText.count <= phoneMaxLengthRule)
                
                if !isValid {
                    return (false, "Phone number must be between \(phoneMinLengthRule) and \(phoneMaxLengthRule) digits")
                }
            }
            
        }
        
        return (true, "")
    }
    
    static func isValidPassword(passwordText: String, registrationConfig: RegistrationConfigContent) -> (Bool, String) {
        if let passwordRules = registrationConfig.fields.first(where: {
            $0.name == "Password"
        }) {
            
            if let passwordMinLengthRule = passwordRules.validate.minLength {
                
                let isValid = passwordText.count >= passwordMinLengthRule
                
                if !isValid {
                    return (false, "Password too small")
                }
            }
            
            if let passwordMaxLengthRule = passwordRules.validate.maxLength {
                
                let isValid = passwordText.count <= passwordMaxLengthRule
                
                if !isValid {
                    return (false, "Password greater than \(passwordMaxLengthRule) characters")
                }
            }
            
            let passwordCustomRules = passwordRules.validate.custom
            
            // Check regex rules from registration config
            if let regexRule = passwordCustomRules.first(where: {
                let displayName = $0.displayName ?? ""
                return $0.rule == "regex" && displayName.contains("numerical")
            }) {
                if let regex = try? NSRegularExpression(pattern: regexRule.pattern ?? "") {
                    let range = NSRange(location: 0, length: passwordText.utf16.count)
                    let isValid = regex.firstMatch(in: passwordText, options: [], range: range) != nil
                    
                    if !isValid {
                        return (false, regexRule.errorMessage)
                    }
                }
                
            }
            
            if let regexRule = passwordCustomRules.first(where: {
                let displayName = $0.displayName ?? ""
                return $0.rule == "regex" && displayName.contains("include")
            }) {
                if let regex = try? NSRegularExpression(pattern: regexRule.pattern ?? "") {
                    let range = NSRange(location: 0, length: passwordText.utf16.count)
                    let isValid = regex.firstMatch(in: passwordText, options: [], range: range) != nil
                    
                    if !isValid {
                        return (false, regexRule.errorMessage)
                    }
                }
                
            }
            
        }
        
        return (true, "")
    }
    
    static func isValidFirstName(text: String, registrationConfig: RegistrationConfigContent) -> (Bool, String) {
        if let firstNameRules = registrationConfig.fields.first(where: {
            $0.name == "FirstnameOnDocument"
        }) {
            
            // Check regex rule from registration config
            if let regexRule = firstNameRules.validate.custom.first(where: {
                $0.rule == "regex"
            }) {
                if let regex = try? NSRegularExpression(pattern: regexRule.pattern ?? "") {
                    let range = NSRange(location: 0, length: text.utf16.count)
                    let isValid = regex.firstMatch(in: text, options: [], range: range) != nil
                    
                    if !isValid {
                        return (false, regexRule.errorMessage)
                    }
                }
            }
            
            if let minLength = firstNameRules.validate.minLength,
               let maxLength = firstNameRules.validate.maxLength {
                
                let isValid = (text.count >= minLength) && (text.count <= maxLength)
                
                if !isValid {
                    return (false, "First name must be between \(minLength) and \(maxLength) characters")
                }
            }
        }
        
        return (true, "")
    }
    
    static func isValidLastName(text: String, registrationConfig: RegistrationConfigContent) -> (Bool, String) {
        if let lastNameRules = registrationConfig.fields.first(where: {
            $0.name == "LastNameOnDocument"
        }) {
            
            // Check regex rule from registration config
            if let regexRule = lastNameRules.validate.custom.first(where: {
                $0.rule == "regex"
            }) {
                if let regex = try? NSRegularExpression(pattern: regexRule.pattern ?? "") {
                    let range = NSRange(location: 0, length: text.utf16.count)
                    let isValid = regex.firstMatch(in: text, options: [], range: range) != nil
                    
                    if !isValid {
                        return (false, regexRule.errorMessage)
                    }
                }
            }
            
            if let minLength = lastNameRules.validate.minLength,
               let maxLength = lastNameRules.validate.maxLength {
                
                let isValid = (text.count >= minLength) && (text.count <= maxLength)
                
                if !isValid {
                    return (false, "Last name must be between \(minLength) and \(maxLength) characters")
                }
            }
        }
        
        return (true, "")
    }
    
    static func isValidBirthDate(dateText: String, registrationConfig: RegistrationConfigContent) -> (Bool, String) {
        if let birthDateRules = registrationConfig.fields.first(where: {
            $0.name == "BirthDate"
        }) {
            
            // Date format validation (yyyy-MM-dd)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            
            guard let parsedDate = dateFormatter.date(from: dateText) else {
                return (false, "Invalid date format. Use yyyy-mm-dd")
            }
            
            // Check min/max dates from config
            if let minDateString = birthDateRules.validate.min,
               let maxDateString = birthDateRules.validate.max {
                
                let minDate = dateFormatter.date(from: minDateString)
                let maxDate = dateFormatter.date(from: maxDateString)
                
                if let minDate = minDate, parsedDate < minDate {
                    return (false, "Date must be after \(minDateString)")
                }
                
                if let maxDate = maxDate, parsedDate > maxDate {
                    return (false, "You must be at least 21 years old")
                }
            }
            
            // Check min-age custom validation rule
            if let minAgeRule = birthDateRules.validate.custom.first(where: {
                $0.rule == "min-age"
            }) {
                // The age validation is handled by the max date, but we can add additional check
                let calendar = Calendar.current
                let now = Date()
                let ageComponents = calendar.dateComponents([.year], from: parsedDate, to: now)
                
                if let age = ageComponents.year, age < 21 {
                    return (false, minAgeRule.errorMessage)
                }
            }
        }
        
        return (true, "")
    }
    
    struct ExtractedHTMLData {
        let fullText: String
        let extractedLinks: [ExtractedLink]
    }
    
    struct ExtractedLink {
        let text: String
        let url: String
        let type: ExtractedLinkType
    }
    
    enum ExtractedLinkType {
        case terms
        case privacyPolicy
        case cookies
        case none
        
        init(from text: String) {
            let lowercasedText = text.lowercased()
            
            if lowercasedText.contains("terms") && lowercasedText.contains("conditions") {
                self = .terms
            } else if lowercasedText.contains("privacy") {
                self = .privacyPolicy
            } else if lowercasedText.contains("cookie") {
                self = .cookies
            } else {
                // Default fallback
                self = .none
            }
        }
    }
    
}
