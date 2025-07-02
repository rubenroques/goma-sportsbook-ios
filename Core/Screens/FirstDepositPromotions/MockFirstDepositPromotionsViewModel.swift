//
//  MockFirstDepositPromotionsViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 01/07/2025.
//

import Foundation
import GomaUI

class MockFirstDepositPromotionsViewModel: FirstDepositPromotionsViewModelProtocol {
    let headerViewModel: PromotionalHeaderViewModelProtocol
    let bonusCardsViewModel: PromotionalBonusCardsScrollViewModelProtocol

    init() {
        
        headerViewModel = MockPromotionalHeaderViewModel(headerData: PromotionalHeaderData(id: "header",
                                                                                           icon: "deposit_gift_icon",
                                                                                           title: "Claim a first deposit bonus!",
                                                                                           subtitle: "Select a first deposit bonus of your choosing..."))

        let cards: [PromotionalBonusCardData] = [
            PromotionalBonusCardData(
                id: "card1",
                headerText: "The Betsson Double",
                mainTitle: "Deposit XAF 1000 and play with XAF 2000",
                userAvatars: [],
                playersCount: "12.6k players chose this bonus",
                backgroundImageName: "promo_card_background",
                hasGradientView: false,
                claimButtonTitle: "Claim bonus",
                termsButtonTitle: "Terms and Conditions",
                bonusAmount: 1000
            ),
            PromotionalBonusCardData(
                id: "card2",
                headerText: "The Welcome Triple",
                mainTitle: "Deposit XAF 2000 and play with XAF 4000",
                userAvatars: [],
                playersCount: "8.2k players chose this bonus",
                backgroundImageName: "promo_card_background",
                hasGradientView: false,
                claimButtonTitle: "Claim bonus",
                termsButtonTitle: "Terms and Conditions",
                bonusAmount: 2000
            ),
            PromotionalBonusCardData(
                id: "card3",
                headerText: "The Starter Pack",
                mainTitle: "Deposit XAF 500 and play with XAF 1000",
                userAvatars: [],
                playersCount: "5.4k players chose this bonus",
                backgroundImageName: "promo_card_background",
                hasGradientView: false,
                claimButtonTitle: "Claim bonus",
                termsButtonTitle: "Terms and Conditions",
                bonusAmount: 500
            )
        ]

        let cardsData = PromotionalBonusCardsData(id: "first_deposit_bonuses", cards: cards)
        bonusCardsViewModel = MockPromotionalBonusCardsScrollViewModel(cardsData: cardsData)
    }
}
