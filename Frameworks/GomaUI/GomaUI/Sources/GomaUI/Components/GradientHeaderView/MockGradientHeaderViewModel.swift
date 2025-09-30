//
//  MockGradientHeaderViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 12/03/2025.
//

import UIKit

public class MockGradientHeaderViewModel: GradientHeaderViewModelProtocol {
    
    public let title: String
    public let gradientColors: [(color: UIColor, location: NSNumber)]
    
    public init(title: String, gradientColors: [(color: UIColor, location: NSNumber)]) {
        self.title = title
        self.gradientColors = gradientColors
    }
}

// MARK: - Mock Presets
extension MockGradientHeaderViewModel {
    
    public static var defaultMock: MockGradientHeaderViewModel {
        return MockGradientHeaderViewModel(
            title: "Welcome Bonus",
            gradientColors: [
                (UIColor.systemOrange, 0.0),
                (UIColor.systemRed, 1.0)
            ]
        )
    }
    
    public static var blueGradientMock: MockGradientHeaderViewModel {
        return MockGradientHeaderViewModel(
            title: "Special Promotion",
            gradientColors: [
                (UIColor.systemBlue, 0.0),
                (UIColor.systemCyan, 1.0)
            ]
        )
    }
    
    public static var purpleGradientMock: MockGradientHeaderViewModel {
        return MockGradientHeaderViewModel(
            title: "Premium Offer",
            gradientColors: [
                (UIColor.systemPurple, 0.0),
                (UIColor.systemPink, 1.0)
            ]
        )
    }
    
    public static var longTitleMock: MockGradientHeaderViewModel {
        return MockGradientHeaderViewModel(
            title: "Amazing Welcome Bonus Promotion",
            gradientColors: [
                (UIColor.systemGreen, 0.0),
                (UIColor.systemYellow, 1.0)
            ]
        )
    }
}
