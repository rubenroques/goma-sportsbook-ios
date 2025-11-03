//
//  PhoneForgotPasswordSuccessViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 30/06/2025.
//

import Foundation
import GomaUI

class PhoneForgotPasswordSuccessViewModel: PhoneForgotPasswordSuccessViewModelProtocol {
    let statusInfoViewModel: StatusInfoViewModelProtocol
    let buttonViewModel: ButtonViewModelProtocol
    let resetPasswordType: ResetPasswordType

    init(resetPasswordType: ResetPasswordType) {
        self.resetPasswordType = resetPasswordType
        
        statusInfoViewModel = MockStatusInfoViewModel(
            statusInfo: StatusInfo(
                icon: "success_circle_icon",
                title: "Password Changed Successfully",
                message: "Your password has been updated. You can now log in with your new password."
            )
        )
        
        var buttonTitle = "Continue"
        
        switch resetPasswordType {
        case .forgot:
            buttonTitle = "Proceed to Log in"
        case .change:
            buttonTitle = "Continue"
        }
        
        buttonViewModel = MockButtonViewModel(buttonData: ButtonData(id: "continue",
                                                                     title: buttonTitle,
                                                                     style: .solidBackground,
                                                                     isEnabled: true))
    }
}
