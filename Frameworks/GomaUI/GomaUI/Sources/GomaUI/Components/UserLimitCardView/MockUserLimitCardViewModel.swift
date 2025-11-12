//
//  MockUserLimitCardViewModel.swift
//  GomaUI
//
//  Created by Claude on 11/11/2025.
//

import Foundation

public final class MockUserLimitCardViewModel: UserLimitCardViewModelProtocol {
    public let limitId: String
    public var typeText: String
    public var valueText: String
    public let actionButtonViewModel: ButtonViewModelProtocol
    
    public init(
        limitId: String = UUID().uuidString,
        typeText: String = "Daily",
        valueText: String = "5.0 XAF",
        actionButtonTitle: String = "Remove",
        buttonStyle: ButtonStyle = .solidBackground
    ) {
        self.limitId = limitId
        self.typeText = typeText
        self.valueText = valueText
        
        let buttonData = ButtonData(
            id: limitId,
            title: actionButtonTitle,
            style: buttonStyle,
            backgroundColor: StyleProvider.Color.alertError
        )
        self.actionButtonViewModel = MockButtonViewModel(buttonData: buttonData)
    }
}

// MARK: - Factory Helpers
public extension MockUserLimitCardViewModel {
    static func removalMock() -> MockUserLimitCardViewModel {
        MockUserLimitCardViewModel(
            limitId: "limit_daily",
            typeText: "Daily",
            valueText: "5 XAF",
            actionButtonTitle: "Remove",
            buttonStyle: .solidBackground
        )
    }
    
    static func disabledMock() -> MockUserLimitCardViewModel {
        let viewModel = MockUserLimitCardViewModel(
            limitId: "limit_weekly",
            typeText: "Weekly",
            valueText: "10 XAF",
            actionButtonTitle: "Remove",
            buttonStyle: .solidBackground
        )
        viewModel.actionButtonViewModel.setEnabled(false)
        return viewModel
    }
}

