import Foundation
import UIKit
import Combine


public final class MockTermsAcceptanceViewModel: TermsAcceptanceViewModelProtocol {
    
    private let dataSubject: CurrentValueSubject<TermsAcceptanceData, Never>
    private let highlightedTextViewModelInstance: HighlightedTextViewModelProtocol
    
    public var data: TermsAcceptanceData {
        dataSubject.value
    }
    
    public var dataPublisher: AnyPublisher<TermsAcceptanceData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public var highlightedTextViewModel: HighlightedTextViewModelProtocol {
        highlightedTextViewModelInstance
    }
    
    public init(data: TermsAcceptanceData, highlightedTextViewModel: HighlightedTextViewModelProtocol? = nil) {
        self.dataSubject = CurrentValueSubject(data)
        
        // Create highlighted text view model
        if let providedViewModel = highlightedTextViewModel {
            self.highlightedTextViewModelInstance = providedViewModel
        } else {
            self.highlightedTextViewModelInstance = Self.createHighlightedTextViewModel(for: data)
        }
    }
    
    public func configure(with data: TermsAcceptanceData) {
        dataSubject.send(data)
    }
    
    public func toggleAcceptance() {
        let currentData = dataSubject.value
        let updatedData = TermsAcceptanceData(
            id: currentData.id,
            fullText: currentData.fullText,
            termsText: currentData.termsText,
            privacyText: currentData.privacyText,
            isAccepted: !currentData.isAccepted
        )
        dataSubject.send(updatedData)
    }
    
    // MARK: - Private Methods
    private static func createHighlightedTextViewModel(for data: TermsAcceptanceData) -> HighlightedTextViewModelProtocol {
        var highlights: [HighlightData] = []
        
        // Highlight Terms and Conditions
        let termsRanges = HighlightedTextView.findRanges(of: data.termsText, in: data.fullText)
        if !termsRanges.isEmpty {
            let termsHighlight = HighlightData(
                text: data.termsText,
                color: StyleProvider.Color.highlightPrimary,
                ranges: termsRanges,
                type: .link
            )
            highlights.append(termsHighlight)
        }
        
        // Highlight Privacy Policy
        let privacyRanges = HighlightedTextView.findRanges(of: data.privacyText, in: data.fullText)
        if !privacyRanges.isEmpty {
            let privacyHighlight = HighlightData(
                text: data.privacyText,
                color: StyleProvider.Color.highlightPrimary,
                ranges: privacyRanges,
                type: .link
            )
            highlights.append(privacyHighlight)
        }
        
        // Cookies Policy
        if let cookiesText = data.cookiesText {
            let cookiesRanges = HighlightedTextView.findRanges(of: cookiesText, in: data.fullText)
            if !cookiesRanges.isEmpty {
                let cookiesHighlight = HighlightData(
                    text: cookiesText,
                    color: StyleProvider.Color.highlightPrimary,
                    ranges: cookiesRanges,
                    type: .link
                )
                highlights.append(cookiesHighlight)
            }
        }
        
        let highlightedTextData = HighlightedTextData(
            fullText: data.fullText,
            highlights: highlights,
            textAlignment: .left,
            baseFontType: .regular,
            baseFontSize: 12
        )
        
        return MockHighlightedTextViewModel(data: highlightedTextData)
    }
}

// MARK: - Factory Methods
public extension MockTermsAcceptanceViewModel {
    static var defaultMock: MockTermsAcceptanceViewModel {
        let data = TermsAcceptanceData(
            fullText: "By creating an account I agree that I am 21 years of age or older and have read and accepted our general Terms and Conditions and Privacy Policy",
            termsText: LocalizationProvider.string("terms_consent_popup_title"),
            privacyText: LocalizationProvider.string("privacy_policy_footer_link"),
            isAccepted: false
        )
        
        return MockTermsAcceptanceViewModel(data: data)
    }
    
    static var acceptedMock: MockTermsAcceptanceViewModel {
        let data = TermsAcceptanceData(
            fullText: "By creating an account I agree that I am 21 years of age or older and have read and accepted our general Terms and Conditions and Privacy Policy",
            termsText: LocalizationProvider.string("terms_consent_popup_title"),
            privacyText: LocalizationProvider.string("privacy_policy_footer_link"),
            isAccepted: true
        )
        
        return MockTermsAcceptanceViewModel(data: data)
    }
    
    static var shortTextMock: MockTermsAcceptanceViewModel {
        let data = TermsAcceptanceData(
            fullText: "I accept the Terms and Privacy Policy",
            termsText: "Terms",
            privacyText: LocalizationProvider.string("privacy_policy_footer_link"),
            isAccepted: false
        )
        
        return MockTermsAcceptanceViewModel(data: data)
    }
    
}
