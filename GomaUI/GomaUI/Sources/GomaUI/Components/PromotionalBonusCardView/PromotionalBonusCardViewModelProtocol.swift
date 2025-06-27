//
//  PromotionalBonusCardViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 09/06/2025.
//

import Foundation
import Combine
import UIKit

// MARK: - Data Models
public struct UserAvatar: Equatable, Hashable {
    public let id: String
    public let imageUrl: String?
    public let imageName: String?
    
    public init(id: String, imageUrl: String? = nil, imageName: String? = nil) {
        self.id = id
        self.imageUrl = imageUrl
        self.imageName = imageName
    }
}

public struct PromotionalBonusCardData: Equatable, Hashable {
    public let id: String
    public let headerText: String
    public let mainTitle: String
    public let userAvatars: [UserAvatar]
    public let playersCount: String
    public let backgroundImageName: String?
    public let hasGradientView: Bool
    public let claimButtonTitle: String
    public let termsButtonTitle: String
    
    public init(
        id: String,
        headerText: String,
        mainTitle: String,
        userAvatars: [UserAvatar],
        playersCount: String,
        backgroundImageName: String? = nil,
        hasGradientView: Bool = true,
        claimButtonTitle: String = "Claim bonus",
        termsButtonTitle: String = "Terms and Conditions"
    ) {
        self.id = id
        self.headerText = headerText
        self.mainTitle = mainTitle
        self.userAvatars = userAvatars
        self.playersCount = playersCount
        self.backgroundImageName = backgroundImageName
        self.hasGradientView = hasGradientView
        self.claimButtonTitle = claimButtonTitle
        self.termsButtonTitle = termsButtonTitle
    }
}

// MARK: - View Model Protocol
public protocol PromotionalBonusCardViewModelProtocol {
    /// Publisher for reactive updates
    var cardDataPublisher: AnyPublisher<PromotionalBonusCardData, Never> { get }
    
    /// Actions
    func claimBonusTapped()
    func termsTapped()
}
