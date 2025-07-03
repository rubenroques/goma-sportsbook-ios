//
//  MockDepositVerificationViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 01/07/2025.
//

import Foundation
import GomaUI
import Combine

class MockDepositVerificationViewModel: DepositVerificationViewModelProtocol {
    var transactionVerificationViewModel: TransactionVerificationViewModelProtocol
    let cancelButtonViewModel: ButtonViewModelProtocol
    let alternativeStepsButtonViewModel: ButtonViewModelProtocol
    var isShowingAlternativeSteps: Bool = false

    let shouldUpdateTransactionState = PassthroughSubject<Void, Never>()

    var bonusDepositData: BonusDepositData

    init(bonusDepositData: BonusDepositData) {
        
        self.bonusDepositData = bonusDepositData
        
        transactionVerificationViewModel = MockTransactionVerificationViewModel.incompletePinMock
        
        cancelButtonViewModel = MockButtonViewModel(buttonData: ButtonData(id: "cancel",
                                                                     title: "Cancel Transaction",
                                                                     style: .solidBackground,
                                                                     isEnabled: true))
        
        alternativeStepsButtonViewModel = MockButtonViewModel(buttonData: ButtonData(id: "alternative_steps",
                                                                     title: "Alternative Steps",
                                                                     style: .solidBackground,
                                                                     isEnabled: true))
        
        // TESTING
        updateVerifyTransaction()
    }
    
    func updateVerifyTransaction() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
            
            let updatedTransactionVerificationViewModel = MockTransactionVerificationViewModel.completePinMock
            
            self?.transactionVerificationViewModel.configure(with: updatedTransactionVerificationViewModel.data)
            
            self?.isShowingAlternativeSteps = true
            
            self?.shouldUpdateTransactionState.send()
        }
    }
    
    func resendTransaction() {
        
        let updatedTransactionVerificationViewModel = MockTransactionVerificationViewModel.incompletePinMock
        
        self.transactionVerificationViewModel.configure(with: updatedTransactionVerificationViewModel.data)
        
        self.isShowingAlternativeSteps = false
        
        self.shouldUpdateTransactionState.send()
        
        updateVerifyTransaction()
    }
}
