//
//  PromotionCardViewModelProtocol.swift
//  GomaUI
//
//  Created on 29/08/2025.
//

import Foundation
import Combine
import UIKit

// MARK: - Data Models
public struct PromotionCardData: Equatable, Hashable {
    public let id: String
    public let title: String
    public let description: String
    public let imageURL: String
    public let tag: String?
    public let ctaText: String?
    public let ctaURL: String?
    public let showReadMoreButton: Bool
    
    public init(
        id: String,
        title: String,
        description: String,
        imageURL: String,
        tag: String? = nil,
        ctaText: String? = nil,
        ctaURL: String? = nil,
        showReadMoreButton: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.imageURL = imageURL
        self.tag = tag
        self.ctaText = ctaText
        self.ctaURL = ctaURL
        self.showReadMoreButton = showReadMoreButton
    }
}

// MARK: - Display State
public struct PromotionCardDisplayState: Equatable {
    public let cardData: PromotionCardData
    public let isVisible: Bool
    
    public init(cardData: PromotionCardData, isVisible: Bool = true) {
        self.cardData = cardData
        self.isVisible = isVisible
    }
    
    // Convenience properties for easier access
    public var id: String { cardData.id }
    public var title: String { cardData.title }
    public var description: String { cardData.description }
    public var imageURL: String { cardData.imageURL }
    public var tag: String? { cardData.tag }
    public var ctaText: String? { cardData.ctaText }
    public var ctaURL: String? { cardData.ctaURL }
    public var showReadMoreButton: Bool { cardData.showReadMoreButton }
}

// MARK: - View Model Protocol
public protocol PromotionCardViewModelProtocol {
    /// Publisher for reactive updates
    var displayStatePublisher: AnyPublisher<PromotionCardDisplayState, Never> { get }
    
    /// Button ViewModels
    var ctaButtonViewModel: ButtonViewModelProtocol { get }
    var readMoreButtonViewModel: ButtonViewModelProtocol { get }
    
    /// Actions
    func didTapCTAButton()
    func didTapReadMoreButton()
    func didTapCard()
    
    /// Configuration
    func configure(with cardData: PromotionCardData)
}
