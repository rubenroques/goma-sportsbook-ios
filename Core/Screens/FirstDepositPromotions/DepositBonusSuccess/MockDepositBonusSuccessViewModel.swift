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
        
        statusNotificationViewModel = MockStatusNotificationViewModel(data: StatusNotificationData(type: .success, message: "Deposit Successful", icon: "success_circle_icon"))
        
        infoRowViewModels = [
            MockInfoRowViewModel(data: InfoRowData(leftText: "Your Deposit", rightText: "XAF \(bonusDepositData.selectedAmount)")),
            MockInfoRowViewModel(data: InfoRowData(leftText: "First Deposit Bonus", rightText: "XAF \(bonusDepositData.bonusAmount)")),
            MockInfoRowViewModel(data: InfoRowData(leftText: "Total Amount", rightText: "XAF \(bonusDepositData.selectedAmount + bonusDepositData.bonusAmount)"))
        ]
    }
}
