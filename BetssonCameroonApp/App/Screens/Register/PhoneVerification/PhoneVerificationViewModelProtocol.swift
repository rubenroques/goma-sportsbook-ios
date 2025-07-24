//
//  PhoneVerificationViewModelProtocol.swift
//  Sportsbook
//
//  Created by André Lascas on 26/06/2025.
//

import Foundation
import GomaUI

protocol PhoneVerificationViewModelProtocol {
    var headerViewModel: PromotionalHeaderViewModelProtocol { get }
    var highlightedTextViewModel: HighlightedTextViewModelProtocol { get }
    var pinEntryViewModel: PinDigitEntryViewModelProtocol { get }
    var resendCodeCountdownViewModel: ResendCodeCountdownViewModelProtocol { get }
    var buttonViewModel: ButtonViewModelProtocol { get }
}
