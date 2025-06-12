//
//  TermsAcceptanceViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 12/06/2025.
//

import Foundation
import UIKit
import Combine

// MARK: - Data Models
public struct TermsAcceptanceData {
    public let id: String
    public let fullText: String
    public let termsText: String
    public let privacyText: String
    public let isAccepted: Bool
    
    public init(
        id: String = UUID().uuidString,
        fullText: String,
        termsText: String,
        privacyText: String,
        isAccepted: Bool = false
    ) {
        self.id = id
        self.fullText = fullText
        self.termsText = termsText
        self.privacyText = privacyText
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
