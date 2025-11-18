//
//  ResponsibleGamingUserLimitCardViewModel.swift
//  BetssonCameroonApp
//
//  Created by Claude on 11/11/2025.
//

import Foundation
import UIKit
import GomaUI

final class ResponsibleGamingUserLimitCardViewModel: UserLimitCardViewModelProtocol {
    let limitId: String
    let typeText: String
    let valueText: String
    let actionButtonViewModel: ButtonViewModelProtocol
    
    init(
        limitId: String,
        typeText: String,
        valueText: String,
        actionTitle: String
    ) {
        self.limitId = limitId
        self.typeText = typeText
        self.valueText = valueText
        
        let buttonData = ButtonData(
            id: limitId,
            title: actionTitle,
            style: .solidBackground,
            backgroundColor: StyleProvider.Color.alertError,
            disabledBackgroundColor: StyleProvider.Color.buttonDisablePrimary,
            textColor: StyleProvider.Color.buttonTextPrimary,
            fontSize: 12,
            fontType: .bold
        )
        self.actionButtonViewModel = ButtonViewModel(buttonData: buttonData)
    }
}



