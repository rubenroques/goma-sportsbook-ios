//
//  MockTextSectionViewModel.swift
//  GomaUI
//
//  Created by Claude on 06/11/2025.
//

import UIKit
import Combine

public final class MockTextSectionViewModel: TextSectionViewModelProtocol {
    private let contentSubject: CurrentValueSubject<TextSectionContent, Never>
    public var contentPublisher: AnyPublisher<TextSectionContent, Never> {
        contentSubject.eraseToAnyPublisher()
    }
    
    public init(content: TextSectionContent) {
        self.contentSubject = CurrentValueSubject(content)
    }
    
    public func update(content: TextSectionContent) {
        contentSubject.send(content)
    }
    
    public static var `default`: MockTextSectionViewModel {
        let content = TextSectionContent(
            title: "One bet too many?",
            description: "We want our players to have fun while gaming at Betsson, so we encourage you to gamble responsibly at all times. Gambling should be fun. Borrowing money to play, spending more than you can afford or using money set aside for other purposes is unwise and can lead to significant problems for yourself and others around you. The Betsson team wants players to be safe with their gaming and wise with the way they play.",
            titleTextColor: StyleProvider.Color.textPrimary,
            descriptionTextColor: StyleProvider.Color.textPrimary,
            titleFont: StyleProvider.fontWith(type: .bold, size: 12),
            descriptionFont: StyleProvider.fontWith(type: .regular, size: 12),
            spacing: 4
        )
        return MockTextSectionViewModel(content: content)
    }
    
    public static func custom(
        title: String,
        description: String,
        titleColor: UIColor = StyleProvider.Color.textPrimary,
        descriptionColor: UIColor = StyleProvider.Color.textSecondary,
        titleFont: UIFont = StyleProvider.fontWith(type: .semibold, size: 16),
        descriptionFont: UIFont = StyleProvider.fontWith(type: .regular, size: 14),
        spacing: CGFloat = 8
    ) -> MockTextSectionViewModel {
        let content = TextSectionContent(
            title: title,
            description: description,
            titleTextColor: titleColor,
            descriptionTextColor: descriptionColor,
            titleFont: titleFont,
            descriptionFont: descriptionFont,
            spacing: spacing
        )
        return MockTextSectionViewModel(content: content)
    }
}

