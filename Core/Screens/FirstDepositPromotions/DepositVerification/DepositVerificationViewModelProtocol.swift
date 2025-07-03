//
//  DepositVerificationViewModelProtocol.swift
//  Sportsbook
//
//  Created by André Lascas on 01/07/2025.
//

import Foundation
import GomaUI
import Combine

protocol DepositVerificationViewModelProtocol {
    var transactionVerificationViewModel: TransactionVerificationViewModelProtocol { get set }
    var cancelButtonViewModel: ButtonViewModelProtocol { get }
    var alternativeStepsButtonViewModel: ButtonViewModelProtocol { get }
    var isShowingAlternativeSteps: Bool { get set }
    
    var shouldUpdateTransactionState: PassthroughSubject<Void, Never> { get }

    var bonusDepositData: BonusDepositData { get }
    
    func resendTransaction()
}
