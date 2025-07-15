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

class MockPhoneRegistrationViewModel: PhoneRegistrationViewModelProtocol {
    let headerViewModel: PromotionalHeaderViewModelProtocol
    let highlightedTextViewModel: HighlightedTextViewModelProtocol
    var phoneFieldViewModel: BorderedTextFieldViewModelProtocol?
    var passwordFieldViewModel: BorderedTextFieldViewModelProtocol?
    let referralFieldViewModel: BorderedTextFieldViewModelProtocol?
    var termsViewModel: TermsAcceptanceViewModelProtocol?
    let buttonViewModel: ButtonViewModelProtocol

    private var cancellables = Set<AnyCancellable>()
    
    private let isLoadingConfigSubject = CurrentValueSubject<Bool, Never>(true)
    var isLoadingConfigPublisher: AnyPublisher<Bool, Never> { isLoadingConfigSubject.eraseToAnyPublisher() }
    
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    var isLoadingPublisher: AnyPublisher<Bool, Never> { isLoadingSubject.eraseToAnyPublisher() }
    
    var isRegisterDataComplete: CurrentValueSubject<Bool, Never> = .init(false)
    let registerComplete = PassthroughSubject<Void, Never>()
    let registerError = PassthroughSubject<String, Never>()
    
    var registrationConfig: RegistrationConfigContent?
    var extractedTermsHTMLData: RegisterConfigHelper.ExtractedHTMLData?
    var phoneText: String = ""
    var password: String = ""
    
    init() {
                
        headerViewModel = MockPromotionalHeaderViewModel(headerData: PromotionalHeaderData(id: "registerHeader",
                                                                                           icon: "key_icon",
                                                                                           title: "Get in on the action!",
                                                                                           subtitle: nil))
        
        highlightedTextViewModel = MockHighlightedTextViewModel(data: HighlightedTextData(fullText: "Sign up securely in just 2 minutes", highlights: []))
        
        referralFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: BorderedTextFieldData(id: "referral",
                                                                                                     placeholder: "Referral Code",
                                                                                                     isSecure: false,
                                                                                                     visualState: .idle,
                                                                                                     keyboardType: .default,
                                                                                                     textContentType: .oneTimeCode))
        
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
                
                phoneFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: BorderedTextFieldData(id: "phone",
                                                                                           placeholder: "New number *",
                                                                                           prefix: phoneConfig?.defaultValue ?? "",
                                                                                           isSecure: false,
                                                                                           visualState: .idle,
                                                                                           keyboardType: .phonePad,
                                                                                           textContentType: .telephoneNumber))
            case "Password":
                let passwordConfig = config.fields.first(where: {
                    $0.name == "Password"
                })
                
                passwordFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: BorderedTextFieldData(id: "password",
                                                                                           placeholder: "Password (4 characters minimum) *",
                                                                                           isSecure: true,
                                                                                           visualState: .idle,
                                                                                           keyboardType: .default,
                                                                                           textContentType: .password))
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
                                                                              cookiesText: cookiesData?.text))
            default:
                ()
            }
        }
        
        setupPublishers()
        isLoadingSubject.send(false)
        isLoadingConfigSubject.send(false)
    }
    
    private func setupPublishers() {
        
        if let registrationConfig = registrationConfig,
           let phoneFieldViewModel = phoneFieldViewModel,
           let passwordFieldViewModel = passwordFieldViewModel,
           let termsViewModel = termsViewModel {
            
            Publishers.CombineLatest4(phoneFieldViewModel.textPublisher, passwordFieldViewModel.textPublisher, termsViewModel.dataPublisher, passwordFieldViewModel.visualStatePublisher)
                .map { phone, password, termsAccepted, passwordVisualState in
                    let isPasswordValid: Bool
                    
                    if case .error = passwordVisualState {
                        isPasswordValid = false
                    }
                    else {
                        if password.isEmpty {
                            isPasswordValid = false
                        }
                        else {
                            isPasswordValid = true
                        }
                    }
                    
                    return !phone.isEmpty && isPasswordValid && termsAccepted.isAccepted
                }
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isEnabled in
                    self?.buttonViewModel.setEnabled(isEnabled)
                    self?.isRegisterDataComplete.send(isEnabled)
                }
                .store(in: &cancellables)
            
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
            
            passwordFieldViewModel.textPublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] passwordText in
                    
                    let isValidPasswordData = RegisterConfigHelper.isValidPassword(passwordText: passwordText, registrationConfig: registrationConfig)
                    
                    if !isValidPasswordData.0 && passwordText.isNotEmpty {
                        passwordFieldViewModel.setError("\(isValidPasswordData.1)")
                    }
                    else {
                        passwordFieldViewModel.clearError()
                    }
                    
                    self?.password = passwordText
                })
                .store(in: &cancellables)
            
        }
        
    }
    
    func registerUser() {
        
        isLoadingSubject.send(true)

        let registrationId = registrationConfig?.registrationID ?? ""
        
        let signUpFormType = SignUpFormType.phone(PhoneSignUpForm(phone: phoneText, password: password, registrationId: registrationId))
        
        Env.servicesProvider.signUp(with: signUpFormType)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    print("PHONE REGISTER FINISHED")
                case .failure(let error):
                    print("PHONE REGISTER ERROR: \(error)")
                    self?.registerError.send(error.localizedDescription)
                }
                
                self?.isLoadingSubject.send(false)

            }, receiveValue: { [weak self] signUpResponse in
                
                print("PHONE REGISTER RESPONSE: \(signUpResponse)")
                
                self?.registerComplete.send()
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
