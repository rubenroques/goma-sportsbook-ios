//
//  DepositBonusSuccessViewModelProtocol.swift
//  Sportsbook
//
//  Created by André Lascas on 02/07/2025.
//

import Foundation
import GomaUI

protocol DepositBonusSuccessViewModelProtocol {
    var statusNotificationViewModel: StatusNotificationViewModelProtocol { get }
    var infoRowViewModels: [InfoRowViewModelProtocol] { get }
    
    var bonusDepositData: BonusDepositData { get }

}
