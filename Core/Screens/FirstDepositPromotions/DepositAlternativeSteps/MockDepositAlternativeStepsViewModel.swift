//
//  MockDepositAlternativeStepsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 02/07/2025.
//

import Foundation
import GomaUI

class MockDepositAlternativeStepsViewModel: DepositAlternativeStepsViewModelProtocol {
    let navigationViewModel: CustomNavigationViewModelProtocol
    let title: String
    let stepViewModels: [StepInstructionViewModelProtocol]
    let confirmButtonViewModel: ButtonViewModelProtocol
    let resendButtonViewModel: ButtonViewModelProtocol
    let cancelButtonViewModel: ButtonViewModelProtocol

    var bonusDepositData: BonusDepositData
    
    init(bonusDepositData: BonusDepositData) {
        
        self.bonusDepositData = bonusDepositData
        
        navigationViewModel = MockCustomNavigationViewModel(data: CustomNavigationData(id: "deposit_alternative_steps",
                                                                                       logoImage: "betsson_logo",
                                                                                       closeIcon: "close_circle_icon",
                                                                                       backgroundColor: StyleProvider.Color.highlightPrimary, closeIconTintColor: StyleProvider.Color.allWhite))
        
        title = "Alternative Deposit Instruction"
        
        stepViewModels = [
            MockStepInstructionViewModel(data: StepInstructionData(stepNumber: 1,
                                                                   instructionText: "On the mobile money menu, select x, then select the x option.",
                                                                   highlightedWords: ["x"])),
            MockStepInstructionViewModel(data: StepInstructionData(stepNumber: 2,
                                                                   instructionText: "Enter 889104 as the business number.",
                                                                   highlightedWords: ["889104"])),
            MockStepInstructionViewModel(data: StepInstructionData(stepNumber: 3,
                                                                   instructionText: "Enter betsson as the account number.",
                                                                   highlightedWords: ["betsson"])),
            MockStepInstructionViewModel(data: StepInstructionData(stepNumber: 4,
                                                                   instructionText: "Enter the exact amount you wish to deposit. eg. XAF 1,000",
                                                                   highlightedWords: ["XAF 1,000"])),
            MockStepInstructionViewModel(data: StepInstructionData(stepNumber: 5,
                                                                   instructionText: "Enter the your PIN and press okay to send.")),
            MockStepInstructionViewModel(data: StepInstructionData(stepNumber: 6,
                                                                   instructionText: "After you receive a transaction confirmation SMS from your provider, click on the Confirm Payment button below.",
                                                                   highlightedWords: ["Confirm Payment"]))
        ]
        
        confirmButtonViewModel = MockButtonViewModel(buttonData: ButtonData(id: "confirm_payment",
                                                                     title: "Confirm Payment",
                                                                     style: .solidBackground,
                                                                     isEnabled: true))
        
        resendButtonViewModel = MockButtonViewModel(buttonData: ButtonData(id: "resend_ussd",
                                                                     title: "Resend USSD Push",
                                                                           style: .bordered,
                                                                     isEnabled: true))
        
        cancelButtonViewModel = MockButtonViewModel(buttonData: ButtonData(id: "cancel",
                                                                     title: "Cancel Transaction",
                                                                           style: .bordered,
                                                                     isEnabled: true))
    }
}
