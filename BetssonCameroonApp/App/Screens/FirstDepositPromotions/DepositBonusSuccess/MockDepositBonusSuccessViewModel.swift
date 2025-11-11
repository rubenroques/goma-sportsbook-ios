//
//  MockDepositBonusSuccessViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 02/07/2025.
//

import Foundation
import GomaUI

class MockDepositBonusSuccessViewModel: DepositBonusSuccessViewModelProtocol {
    let statusNotificationViewModel: StatusNotificationViewModelProtocol
    let infoRowViewModels: [InfoRowViewModelProtocol]

    var bonusDepositData: BonusDepositData

    init(bonusDepositData: BonusDepositData) {
        
        self.bonusDepositData = bonusDepositData
        
        statusNotificationViewModel = MockStatusNotificationViewModel(data: StatusNotificationData(type: .success, message: "Deposit Successful 🤑", icon: "success_circle_icon"))
        
        infoRowViewModels = [
            MockInfoRowViewModel(data: InfoRowData(leftText: "Your Deposit", rightText: CurrencyHelper.formatAmountWithCurrency(bonusDepositData.selectedAmount, currency: "XAF"))),
            MockInfoRowViewModel(data: InfoRowData(leftText: "First Deposit Bonus", rightText: CurrencyHelper.formatAmountWithCurrency(bonusDepositData.bonusAmount, currency: "XAF"))),
            MockInfoRowViewModel(data: InfoRowData(leftText: "Total Amount", rightText: CurrencyHelper.formatAmountWithCurrency(bonusDepositData.selectedAmount + bonusDepositData.bonusAmount, currency: "XAF")))
        ]
    }
}
