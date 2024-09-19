//
//  StyleHelpers.swift
//  Sportsbook
//
//  Created by Ruben Roques on 04/11/2021.
//

import UIKit
import Combine

class StyleHelper {

    // Singleton instance
    static let shared = StyleHelper()

    // Published property to react to changes in cardsStyle
    @Published private(set) var cardsStyleActive: CardsStyle

    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Set initial value when the singleton is created
        self.cardsStyleActive = UserDefaults.standard.cardsStyle
        
        // Subscribe to changes in UserDefaults
        NotificationCenter.default.publisher(for: .cardsStyleChanged)
            .sink { [weak self] _ in
                self?.cardsStyleActive = UserDefaults.standard.cardsStyle
            }
            .store(in: &cancellables)
    }
    
    static func styleButton(button: UIButton) {
        button.setTitleColor(UIColor.App.buttonTextPrimary, for: .normal)
        button.setTitleColor(UIColor.App.buttonTextPrimary.withAlphaComponent(0.7), for: .highlighted)
        button.setTitleColor(UIColor.App.buttonTextDisablePrimary, for: .disabled)

        button.setBackgroundColor(UIColor.App.buttonBackgroundPrimary, for: .normal)
        button.setBackgroundColor(UIColor.App.buttonBackgroundSecondary, for: .highlighted)

        button.layer.cornerRadius = CornerRadius.button
        button.layer.masksToBounds = true
        button.backgroundColor = .clear
    }

    static func cardsStyleActive() -> CardsStyle {
        return UserDefaults.standard.cardsStyle
    }

    static func cardsStyleHeight() -> CGFloat {
        switch Self.cardsStyleActive() {
        case .small:
            return MatchWidgetCollectionViewCell.smallCellHeight
        case .normal:
            return MatchWidgetCollectionViewCell.normalCellHeight
        }
    }

    static func competitionCardsStyleHeight() -> CGFloat {
        switch Self.cardsStyleActive() {
        case .small:
            return 90
        case .normal:
            return 125
        }
    }

    static func cardsStyleMargin() -> CGFloat {
        switch Self.cardsStyleActive() {
        case .small:
            return 1
        case .normal:
            return 8
        }
    }

}

extension Notification.Name {
    static let cardsStyleChanged = Notification.Name("CardsStyleChanged")
}
