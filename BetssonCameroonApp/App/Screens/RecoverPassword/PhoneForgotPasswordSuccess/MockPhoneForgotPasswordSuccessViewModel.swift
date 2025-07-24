//
//  MockPhoneForgotPasswordSuccessViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 30/06/2025.
//

import Foundation
import GomaUI

class MockPasswordChangeSuccessScreenViewModel: PhoneForgotPasswordSuccessViewModelProtocol {
    let statusInfoViewModel: StatusInfoViewModelProtocol
    let buttonViewModel: ButtonViewModelProtocol

    init() {
        statusInfoViewModel = MockStatusInfoViewModel(
            statusInfo: StatusInfo(
                icon: "success_circle_icon",
                title: "Password Changed Successfully",
                message: "Your password has been updated. You can now log in with your new password."
            )
        )
        
        buttonViewModel = MockButtonViewModel(buttonData: ButtonData(id: "continue",
                                                                     title: "Proceed to Log in",
                                                                     style: .solidBackground,
                                                                     isEnabled: true))
    }
}
