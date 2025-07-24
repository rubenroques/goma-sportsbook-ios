//
//  DepositBonusViewModelProtocol.swift
//  Sportsbook
//
//  Created by André Lascas on 01/07/2025.
//

import Foundation
import GomaUI
import Combine

protocol DepositBonusViewModelProtocol {
    var headerViewModel: PromotionalHeaderViewModelProtocol { get }
    var highlightedTextViewModel: HighlightedTextViewModelProtocol { get }
    var amountFieldViewModel: BorderedTextFieldViewModelProtocol { get }
    var amountPillsViewModel: AmountPillsViewModelProtocol { get }
    var bonusInfoViewModel: DepositBonusBalanceViewModelProtocol { get }
    var buttonViewModel: ButtonViewModelProtocol { get }
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var shouldVerifyTransaction: PassthroughSubject<Void, Never> { get }
    
    func requestVerifyTransaction()
    
    var promotionalBonusCardData: PromotionalBonusCardData { get }
    var bonusDepositData: BonusDepositData { get }

}
