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

    static func applicableBonus(fromServiceProviderAvailableBonus availableBonus: ServicesProvider.AvailableBonus) -> ApplicableBonus {

        return ApplicableBonus(code: availableBonus.id, name: availableBonus.name, description: availableBonus.description ?? "", url: nil, html: nil, assets: availableBonus.imageUrl)

    }

    static func documentTypeGroup(fromServiceProviderDocumentTypeGroup documentTypeGroup: ServicesProvider.DocumentTypeGroup) -> DocumentTypeGroup {

        switch documentTypeGroup {
        case .identityCard: return .identityCard
        case .passport: return .passport
        case .drivingLicense: return .drivingLicense
        case .residenceId: return .residenceId
        case .proofOfAddress: return .proofAddress
        case .rib: return .rib
        case .others: return .others
        }
    }
}
