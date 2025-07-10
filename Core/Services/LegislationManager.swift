//
//  LegislationManager.swift
//  Sportsbook
//
//  Created by André Lascas on 10/07/2025.
//

import Foundation
import Combine
import ServicesProvider

public class LegislationManager {
    
    var registrationConfig: RegistrationConfigContent?
    var extractedTermsHTMLData: ExtractedHTMLData?
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    public init() {
        
    }
    
    func getRegistrationConfig() {
        
        Env.servicesProvider.getRegistrationConfig()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    print("FINISHED GET REGISTRATION CONFIG")
                case .failure(let error):
                    print("ERROR GET REGISTRATION CONFIG: \(error)")
                }
            }, receiveValue: { [weak self] registrationConfigResponse in
                
                let mappedRegistrationConfig = ServiceProviderModelMapper.registrationConfigResponse(fromInternalResponse: registrationConfigResponse)
                
                self?.registrationConfig = mappedRegistrationConfig.content
                
                if let termsConfig = mappedRegistrationConfig.content.fields.first(where: {
                    $0.name == "TermsAndConditions"
                }) {
                    
                    self?.extractedTermsHTMLData = self?.extractLinksAndCleanText(from: termsConfig.displayName)
                }
                
            })
            .store(in: &cancellables)
    }
    
    func extractLinksAndCleanText(from htmlString: String) -> ExtractedHTMLData {
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
    
    func isValidPhoneNumber(phoneText: String) -> (Bool, String) {
        if let phoneRules = self.registrationConfig?.fields.first(where: {
            $0.name == "Mobile"
        })?.validate.custom {
            
            // Check regex rule from registration config
            if let regexRule = phoneRules.first(where: {
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
            
        }
        
        // Additional validation with the specific regex pattern
        let specificRegex = try? NSRegularExpression(pattern: "^0?\\d{9}$")
        let range = NSRange(location: 0, length: phoneText.utf16.count)
        let isValidWithSpecificRegex = specificRegex?.firstMatch(in: phoneText, options: [], range: range) != nil
        
        if !isValidWithSpecificRegex {
            return (false, "Phone number must be 9 digits (with optional leading 0)")
        }
        
        return (true, "")
    }
    
    func isValidPassword(passwordText: String) -> (Bool, String) {
        if let passwordRules = self.registrationConfig?.fields.first(where: {
            $0.name == "Password"
        }) {
            
            if let passwordMinLengthRule = passwordRules.validate.minLength {
                
                let isValid = passwordText.count >= passwordMinLengthRule
                
                if !isValid {
                    return (false, "Password too small")
                }
            }
            
            let passwordCustomRules = passwordRules.validate.custom
            // Check regex rule from registration config
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
