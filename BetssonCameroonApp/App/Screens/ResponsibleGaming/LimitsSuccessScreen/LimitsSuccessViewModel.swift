//
//  LimitsSuccessViewModel.swift
//  BetssonCameroonApp
//
//  Created by GPT-5 Codex on 11/11/2025.
//

import Foundation
import GomaUI

final class LimitsSuccessViewModel: LimitsSuccessViewModelProtocol {
    
    // MARK: - Properties
    let successActionItem: ActionRowItem
    let infoRowViewModels: [InfoRowViewModelProtocol]
    
    // MARK: - Initialization
    init(
        successMessage: String,
        periodTitle: String,
        periodValue: String,
        amountTitle: String? = nil,
        amountValue: String? = nil,
        statusTitle: String,
        statusValue: String,
        highlightStatus: Bool = true
    ) {
        self.successActionItem = ActionRowItem(
            icon: "checkmark.circle.fill",
            title: successMessage,
            type: .action,
            action: .custom,
            isTappable: false
        )
        
        let periodData = InfoRowData(
            leftText: periodTitle,
            rightText: periodValue
        )
        
        let statusData = InfoRowData(
            leftText: statusTitle,
            rightText: statusValue,
            rightTextColor: highlightStatus ? StyleProvider.Color.highlightPrimary : nil
        )
        
        var rows: [InfoRowData] = [periodData]
        
        if let amountTitle, let amountValue {
            rows.append(
                InfoRowData(
                    leftText: amountTitle,
                    rightText: amountValue
                )
            )
        }
        
        rows.append(statusData)
        
        self.infoRowViewModels = rows.map { MockInfoRowViewModel(data: $0) }
    }
}


