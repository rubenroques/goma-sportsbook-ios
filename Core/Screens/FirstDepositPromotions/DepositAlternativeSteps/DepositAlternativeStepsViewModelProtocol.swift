//
//  DepositAlternativeStepsViewModelProtocol.swift
//  Sportsbook
//
//  Created by André Lascas on 02/07/2025.
//

import Foundation
import GomaUI

protocol DepositAlternativeStepsViewModelProtocol {
    var navigationViewModel: CustomNavigationViewModelProtocol { get }
    var title: String { get }
    var stepViewModels: [StepInstructionViewModelProtocol] { get }
    var confirmButtonViewModel: ButtonViewModelProtocol { get }
    var resendButtonViewModel: ButtonViewModelProtocol { get }
    var cancelButtonViewModel: ButtonViewModelProtocol { get }

    var bonusDepositData: BonusDepositData { get }
    
    var shouldResendAction: (() -> Void)? { get set }

}
