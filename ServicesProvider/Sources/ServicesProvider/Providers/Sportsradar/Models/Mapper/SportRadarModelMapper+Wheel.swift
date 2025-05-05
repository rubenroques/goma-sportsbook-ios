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
        
        return WheelConfiguration(id: wheelConfiguration.id)
    }
    
    static func wheelOptInResponse(fromInternalWheelOptInResponse wheelOptInResponse: SportRadarModels.WheelOptInResponse) -> WheelOptInResponse {
        
        return WheelOptInResponse(status: wheelOptInResponse.status, message: wheelOptInResponse.message)
    }
}
