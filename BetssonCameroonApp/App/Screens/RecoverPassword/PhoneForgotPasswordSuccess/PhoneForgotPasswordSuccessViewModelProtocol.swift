//
//  PhoneForgotPasswordSuccessViewModelProtocol.swift
//  Sportsbook
//
//  Created by André Lascas on 30/06/2025.
//

import Foundation
import GomaUI

protocol PhoneForgotPasswordSuccessViewModelProtocol {
    var resetPasswordType: ResetPasswordType { get }
    var statusInfoViewModel: StatusInfoViewModelProtocol { get }
    var buttonViewModel: ButtonViewModelProtocol { get }
}
