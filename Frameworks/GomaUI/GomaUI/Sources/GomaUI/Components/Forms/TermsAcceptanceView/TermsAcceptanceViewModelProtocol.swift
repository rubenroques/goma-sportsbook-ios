import Foundation
import UIKit
import Combine

// MARK: - Data Models
public struct TermsAcceptanceData {
    public let id: String
    public let fullText: String
    public let termsText: String
    public let privacyText: String
    public let cookiesText: String?
    public let isAccepted: Bool
    
    public init(
        id: String = UUID().uuidString,
        fullText: String,
        termsText: String,
        privacyText: String,
        cookiesText: String? = nil,
        isAccepted: Bool = false
    ) {
        self.id = id
        self.fullText = fullText
        self.termsText = termsText
        self.privacyText = privacyText
        self.cookiesText = cookiesText
        self.isAccepted = isAccepted
    }
}

// MARK: - View Model Protocol
public protocol TermsAcceptanceViewModelProtocol {
    var data: TermsAcceptanceData { get }
    var dataPublisher: AnyPublisher<TermsAcceptanceData, Never> { get }
    var highlightedTextViewModel: HighlightedTextViewModelProtocol { get }
    
    func configure(with data: TermsAcceptanceData)
    func toggleAcceptance()
}
