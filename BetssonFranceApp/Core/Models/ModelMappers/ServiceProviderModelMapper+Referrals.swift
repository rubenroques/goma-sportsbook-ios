//
//  ServiceProviderModelMapper+Referrals.swift
//  Sportsbook
//
//  Created by André Lascas on 11/03/2024.
//

import Foundation
import ServicesProvider

extension ServiceProviderModelMapper {
    
    static func referralLink(fromServiceProviderReferralLink referralLink: ServicesProvider.ReferralLink) -> ReferralLink {
        
        return ReferralLink(code: referralLink.code, link: referralLink.link)
    }
    
    static func referee(fromServiceProviderReferee referee: ServicesProvider.Referee) -> Referee {
        
        var kycStatus = KnowYourCustomerStatus.request
        
        if referee.kycStatus == "REQUESTED" {
            kycStatus = .request
        }
        else if referee.kycStatus == "PASS_COND" {
            kycStatus = .passConditional
        }
        else if referee.kycStatus == "PASS" {
            kycStatus = .pass
        }
        
        return Referee(id: referee.id, username: referee.username, registeredAt: referee.registeredAt, kycStatus: kycStatus, depositPassed: referee.depositPassed)
    }
}
