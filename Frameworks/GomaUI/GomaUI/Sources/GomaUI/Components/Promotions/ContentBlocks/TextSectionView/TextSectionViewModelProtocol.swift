//
//  TextSectionViewModelProtocol.swift
//  GomaUI
//
//  Created by Claude on 06/11/2025.
//

import UIKit
import Combine

public struct TextSectionContent {
    public let title: String
    public let description: String
    public let titleTextColor: UIColor
    public let descriptionTextColor: UIColor
    public let titleFont: UIFont
    public let descriptionFont: UIFont
    public let spacing: CGFloat
    
    public init(
        title: String,
        description: String,
        titleTextColor: UIColor = StyleProvider.Color.textPrimary,
        descriptionTextColor: UIColor = StyleProvider.Color.textPrimary,
        titleFont: UIFont = StyleProvider.fontWith(type: .bold, size: 12),
        descriptionFont: UIFont = StyleProvider.fontWith(type: .regular, size: 12),
        spacing: CGFloat = 4
    ) {
        self.title = title
        self.description = description
        self.titleTextColor = titleTextColor
        self.descriptionTextColor = descriptionTextColor
        self.titleFont = titleFont
        self.descriptionFont = descriptionFont
        self.spacing = spacing
    }
}


public protocol TextSectionViewModelProtocol {
    var contentPublisher: AnyPublisher<TextSectionContent, Never> { get }
}
