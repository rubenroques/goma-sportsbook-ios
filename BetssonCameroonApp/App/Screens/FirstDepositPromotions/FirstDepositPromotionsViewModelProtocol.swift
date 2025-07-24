//
//  FirstDepositPromotionsViewModelProtocol.swift
//  Sportsbook
//
//  Created by André Lascas on 01/07/2025.
//

import Foundation
import GomaUI

protocol FirstDepositPromotionsViewModelProtocol {
    var headerViewModel: PromotionalHeaderViewModelProtocol { get }
    var bonusCardsViewModel: PromotionalBonusCardsScrollViewModelProtocol { get }
}
