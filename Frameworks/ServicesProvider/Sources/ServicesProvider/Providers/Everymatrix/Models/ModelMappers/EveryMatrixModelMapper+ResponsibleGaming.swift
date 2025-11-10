//
//  EveryMatrixModelMapper+ResponsibleGaming.swift
//  ServicesProvider
//
//  Created by Claude on 07/11/2025.
//

import Foundation

extension EveryMatrixModelMapper {
    
    static func userLimitsResponse(from response: EveryMatrix.ResponsibleGamingLimitsResponse) -> UserLimitsResponse {
        let limits = response.limits.compactMap { userLimit(from: $0) }
        return UserLimitsResponse(limits: limits)
    }

    static func userLimit(from limit: EveryMatrix.ResponsibleGamingLimit) -> UserLimit? {
        guard let id = limit.id,
              let playerId = limit.playerId,
              let domainId = limit.domainId,
              let amount = limit.amount,
              let currency = limit.currency,
              let period = limit.period,
              let type = limit.type
        else {
            return nil
        }
        return UserLimit(
            id: id,
            playerId: playerId,
            domainId: domainId,
            amount: amount,
            currency: currency,
            period: period,
            type: type,
            products: limit.products ?? [],
            walletTypes: limit.walletTypes ?? []
        )
    }
}
