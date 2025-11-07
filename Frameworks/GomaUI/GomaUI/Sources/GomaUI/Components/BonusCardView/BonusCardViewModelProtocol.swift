//
//  BonusCardViewModelProtocol.swift
//  GomaUI
//
//  Created by Claude on 23/10/2025.
//

import Foundation
import Combine

// MARK: - Data Models
public struct BonusCardData: Equatable, Hashable {
    public let id: String
    public let title: String
    public let description: String
    public let imageURL: String
    public let tag: String?
    public let ctaText: String
    public let ctaURL: String?
    public let termsText: String
    public let termsURL: String?
    
    public init(
        id: String,
        title: String,
        description: String,
        imageURL: String,
        tag: String? = nil,
        ctaText: String,
        ctaURL: String? = nil,
        termsText: String,
        termsURL: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.tag = tag
        self.ctaText = ctaText
        self.ctaURL = ctaURL
        self.termsText = termsText
        self.termsURL = termsURL
    }
}

// MARK: - Display State
public struct BonusCardDisplayState: Equatable {
    public let cardData: BonusCardData
    public let isVisible: Bool
    
    public init(cardData: BonusCardData, isVisible: Bool = true) {
        self.cardData = cardData
        self.isVisible = isVisible
    }
    
    // Convenience properties for easier access
    public var id: String { cardData.id }
    public var title: String { cardData.title }
    public var description: String { cardData.description }
    public var imageURL: String { cardData.imageURL }
    public var tag: String? { cardData.tag }
    public var ctaText: String { cardData.ctaText }
    public var ctaURL: String? { cardData.ctaURL }
    public var termsText: String { cardData.termsText }
    public var termsURL: String? { cardData.termsURL }
    public var hasTermsURL: Bool { cardData.termsURL != nil }
}

// MARK: - View Model Protocol
public protocol BonusCardViewModelProtocol {
    /// Publisher for reactive updates
    var displayStatePublisher: AnyPublisher<BonusCardDisplayState, Never> { get }
    
    /// Button ViewModels
    var ctaButtonViewModel: ButtonViewModelProtocol { get }
    var termsButtonViewModel: ButtonViewModelProtocol { get }
    
    /// Actions
    func didTapCTAButton()
    func didTapTerms()
    func didTapCard()
    
    /// Configuration
    func configure(with cardData: BonusCardData)
}

