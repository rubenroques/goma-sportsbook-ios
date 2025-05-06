//
//  SportRadarModelMapper+Wheel.swift
//  ServicesProvider
//
//  Created by André Lascas on 30/04/2025.
//

import Foundation

extension SportRadarModelMapper {
    
    static func wheelEligibility(fromInternalWheelEligibility wheelEligibility: SportRadarModels.WheelEligibility) -> WheelEligibility {
        
        let winBoosts = wheelEligibility.winBoosts.map( {
            return self.wheelStatus(fromInternalWheelStatus: $0)
        })
        
        return WheelEligibility(productCode: wheelEligibility.productCode, gameTransId: wheelEligibility.gameTransId, winBoosts: winBoosts)
    }
    
    static func wheelStatus(fromInternalWheelStatus wheelStatus: SportRadarModels.WheelStatus) -> WheelStatus {
        
        var mappedWheelConfiguration: WheelConfiguration?
        
        if let wheelConfiguration = wheelStatus.configuration {
            mappedWheelConfiguration = self.wheelConfiguration(fromInternalWheelConfiguration: wheelConfiguration)
        }
        
        return WheelStatus(gameTransId: wheelStatus.gameTransId, status: wheelStatus.status, message: wheelStatus.message, configuration: mappedWheelConfiguration)
    }
    
    static func wheelConfiguration(fromInternalWheelConfiguration wheelConfiguration: SportRadarModels.WheelConfiguration) -> WheelConfiguration {
        
        let wheelTiers = wheelConfiguration.tiers.map( {
            return self.wheelTier(fromInternalWhhelTier: $0)
        })
        
        return WheelConfiguration(id: wheelConfiguration.id, title: wheelConfiguration.title, tiers: wheelTiers)
    }
    
    static func wheelTier(fromInternalWhhelTier wheelTier: SportRadarModels.WheelTier) -> WheelTier {
        
        return WheelTier(name: wheelTier.name, chance: wheelTier.chance, boostMultiplier: wheelTier.boostMultiplier)
    }
    
    static func wheelOptInResponse(fromInternalWheelOptInResponse wheelOptInResponse: SportRadarModels.WheelOptInResponse) -> WheelOptInResponse {
        
        return WheelOptInResponse(status: wheelOptInResponse.status, message: wheelOptInResponse.message)
    }
}
