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
        
        return WheelStatus(winBoostId: wheelStatus.winBoostId, gameTransId: wheelStatus.gameTransId, status: wheelStatus.status, message: wheelStatus.message, configuration: mappedWheelConfiguration)
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
    
    static func wheelOptInData(fromInternalWheelOptInData wheelOptInData: SportRadarModels.WheelOptInData) -> WheelOptInData {
        
        var awardedTier: WheelAwardedTier?
        
        if let wheelAwardedTier = wheelOptInData.awardedTier {
            awardedTier = self.wheelAwardedTier(fromInternalWheelAwardedTier: wheelAwardedTier)
        }
        
        return WheelOptInData(status: wheelOptInData.status, winBoostId: wheelOptInData.winBoostId, gameTranId: wheelOptInData.gameTranId, awardedTier: awardedTier)
    }
    
    static func wheelAwardedTier(fromInternalWheelAwardedTier wheelAwardedTier: SportRadarModels.WheelAwardedTier) -> WheelAwardedTier {
        
        return WheelAwardedTier(configurationId: wheelAwardedTier.configurationId, name: wheelAwardedTier.name, boostMultiplier: wheelAwardedTier.boostMultiplier)
    }
    
    static func grantedWinBoosts(fromInternalGrantedWinBoosts grantedWinBoosts: SportRadarModels.GrantedWinBoosts) -> GrantedWinBoosts {
        
        let winBoosts = grantedWinBoosts.winBoosts.map({
            return self.grantedWinBoostInfo(fromInternalGrantedWinBoostInfo: $0)
        })
        
        return GrantedWinBoosts(gameTranId: grantedWinBoosts.gameTranId, winBoosts: winBoosts)
    }
    
    static func grantedWinBoostInfo(fromInternalGrantedWinBoostInfo grantedWinBoostInfo: SportRadarModels.GrantedWinBoostInfo) -> GrantedWinBoostInfo {
        
        var mappedWheelAwardedTier: WheelAwardedTier?
        
        if let awardedTier = grantedWinBoostInfo.awardedTier {
            mappedWheelAwardedTier = self.wheelAwardedTier(fromInternalWheelAwardedTier: awardedTier)
        }
        
        
        return GrantedWinBoostInfo(winBoostId: grantedWinBoostInfo.winBoostId, gameTranId: grantedWinBoostInfo.gameTranId, status: grantedWinBoostInfo.status, awardedTier: mappedWheelAwardedTier, boostAmount: grantedWinBoostInfo.boostAmount)
    }
}
