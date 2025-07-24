//
//  BonusProgressViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 05/04/2022.
//

import Foundation
import Combine

class BonusProgressViewModel: NSObject {
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var bonus: GrantedBonus
    var progressType: ProgressType

    var title: String = ""
    var amountCurrency: String = CurrencySymbol.eur.identifier
    var remainingAmount: Double = 0.0
    var totalAmount: Double = 0.0
    var progressBarAmount: Float = 0.0
    var progressAmountString: String = "-.-"

    // MARK: Lifetime and Cycle
    init(bonus: GrantedBonus, progressType: ProgressType) {

        self.bonus = bonus
        self.progressType = progressType
        
        super.init()

        self.setupProgressInfo()
    }

    func setupProgressInfo() {

        var remainingAmount = 0.0
        var totalAmount = 0.0

        switch progressType {
        case .bonus:
            title = localized("bonus_amount")

            if let bonusAmount = bonus.amount, let bonusRemainingAmount = bonus.remainingAmount {
                remainingAmount = bonusRemainingAmount
                totalAmount = bonusAmount
            }

            if let bonusCurrency = bonus.currency {

                if let currencySymbolEnumCase = CurrencySymbol(rawValue: bonusCurrency) {
                    amountCurrency = currencySymbolEnumCase.identifier
                }
            }

        case .wager:
            title = localized("wager_amount")

            if let wagerAmount = bonus.initialWagerRequirementAmount, let wagerRemainingAmount = bonus.remainingWagerRequirementAmount {
                remainingAmount = wagerRemainingAmount
                totalAmount = wagerAmount
            }
        }

        progressBarAmount = Float(remainingAmount/totalAmount)

        // self.progressBarView.progress = progressBarAmount

        progressAmountString = "\(remainingAmount) / \(totalAmount) \(amountCurrency)"
        // self.setupColoredLabel(label: self.progressAmountLabel, text: progressAmountString, color: bonusColor)

    }
}
