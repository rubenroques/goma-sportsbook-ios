//
//  PhoneLoginViewModelProtocol.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2025.
//

import Foundation
import GomaUI

protocol PhoneLoginViewModelProtocol {
    var headerViewModel: PromotionalHeaderViewModelProtocol { get }
    var highlightedTextViewModel: HighlightedTextViewModelProtocol { get }
    var phoneFieldViewModel: BorderedTextFieldViewModelProtocol { get }
    var passwordFieldViewModel: BorderedTextFieldViewModelProtocol { get }
    var buttonViewModel: ButtonViewModelProtocol { get }
}
