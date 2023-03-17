//
//  ServicesProviderModelMapper+Bonus.swift
//  Sportsbook
//
//  Created by André Lascas on 16/03/2023.
//

import Foundation
import ServicesProvider

extension ServiceProviderModelMapper {
    static func grantedBonus(fromServiceProviderGrantedBonus grantedBonus: ServicesProvider.GrantedBonus) -> GrantedBonus {

        if let initialWager = grantedBonus.wagerRequirement,
           let remainingWager = grantedBonus.amountWagered,
           let initialWagerAmount = Double(initialWager),
           let remainingWagerAmount = Double(remainingWager) {

            return GrantedBonus(id: "\(grantedBonus.id)",
                                name: grantedBonus.name,
                                status: grantedBonus.status,
                                amount: Double(grantedBonus.amount),
                                remainingAmount: Double(grantedBonus.amount),
                                expiryDate: grantedBonus.expiryDate ,
                                grantedDate: grantedBonus.triggerDate,
                                initialWagerRequirementAmount: initialWagerAmount,
                                remainingWagerRequirementAmount: remainingWagerAmount)
        }

        return GrantedBonus(id: "\(grantedBonus.id)",
                            name: grantedBonus.name,
                            status: grantedBonus.status,
                            amount: Double(grantedBonus.amount),
                            remainingAmount: Double(grantedBonus.amount),
                            expiryDate: grantedBonus.expiryDate ,
                            grantedDate: grantedBonus.triggerDate)
    }
}
