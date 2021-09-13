//
//  TSRouter.swift
//  Tipico
//
//  Created by Andrei Marinescu on 13/02/2020.
//  Copyright © 2020 Tipico. All rights reserved.
//

import Foundation

enum TSRouter {
    case registrationDismissed
    case getTransportSessionID
    case getClientIdentity
    case getSessionInfo
    case getCmsSessionID
    case sessionStateChange
    case getProfile
    case getGamingAccounts
    case getGrantedBonuses
    case getClaimableBonuses
    case getFavorites
    case addToFavorites(id: String)
    case removeFromFavorites(id: String)
    case watchBalance
    case balanceChanged
    case getApplicableBonuses(gamingAccountID: Int)
    case applyBonusCode(bonusCode: String)
    case forfeitBonus(bonusID: String)
    case getLimits
    case removeLimit(type: String)
    case setLimit(type: String, period: String, amount: String, currency: String)
    case realityCheckGetCfg
    case realityCheckGet
    case realityCheckSet(value: String)
    case getTransactionHistory(type: String, startTime: String, endTime: String, pageIndex: Int, pageSize: Int)
    case getLaunchURL(slug: String?, tableId: String?, realMoney: Bool, culture: String, pid: String?)
    case logout
    case acceptTC
    case coolOff24h
    
    
    var procedure: String {
        switch self {
            case .registrationDismissed:
                return "/registrationDismissed"
            case .getTransportSessionID:
                return "/user#getTransportSessionID"
            case .getClientIdentity:
                return "/connection#getClientIdentity"
            case .getSessionInfo:
                return "/user#getSessionInfo"
            case .getCmsSessionID:
                return "/user#getCmsSessionID"
            case .sessionStateChange:
                return "/sessionStateChange"
            case .getProfile:
                return "/user/account#getProfile"
            case .getGamingAccounts:
                return "/user/account#getGamingAccounts"
            case .getGrantedBonuses:
                return "/user/bonus#getGrantedBonuses"
            case .getClaimableBonuses:
                return "/user/bonus#getClaimableBonuses"
                
            case .addToFavorites:
                return "/casino#addToFavorites"
            case .removeFromFavorites:
                return "/casino#removeFromFavorites"
            case .getFavorites:
                return "/casino#getFavorites"
            case .watchBalance:
                return "/user/account#watchBalance"
            case .balanceChanged:
                return "/account/balanceChanged"
            case .getApplicableBonuses:
                return "/user#getApplicableBonuses"
            case .applyBonusCode:
                return "/user/bonus#apply"
            case .forfeitBonus:
                return "/user/bonus#forfeit"
            case .getLimits:
                return "/user/limit#getLimits"
            case .removeLimit(type: let tp):
                return "/user/limit#remove\(tp)Limit"
            case .setLimit(type: let tp, period: _, amount: _, currency: _):
                return "/user/limit#set\(tp)Limit"
            case .realityCheckGetCfg:
                return "/user/realityCheck#getCfg"
            case .realityCheckGet:
                return "/user/realityCheck#get"
            case .realityCheckSet:
                return "/user/realityCheck#set"
            case .getTransactionHistory:
                return "/user#getTransactionHistory"
            case .getLaunchURL:
                return "/casino#getLaunchUrl"
            case .logout:
                return "/user#logout"
            case .acceptTC:
                return "/user#acceptTCv2"
            case .coolOff24h:
                return "/user/coolOff#enable"
        }
    }
    
    var args: [Any]? {
        return nil
    }
    
    var kwargs: [String : Any]? {
        switch self {
            case .getSessionInfo:
                return ["culture": "de", "externalParty": "tipico", "fields": ["domainHost": "games.tipico.de"], "includeTermsConditionsFlags": true]
            case .getGamingAccounts:
                return ["expectBalance": true, "expectBonus": true]
                
            case .addToFavorites(id: let gameID), .removeFromFavorites(id: let gameID):
                return ["anonymousUserIdentity": false, "type": "game", "id": gameID]
                
            case .getFavorites:
                return ["anonymousUserIdentity": false, "expectedGameFields": 1, "expectedTableFields": 67108864, "filterByPlatform": ["iPhone"], "specificExportFields": ["gameID"]]
                
            case .getApplicableBonuses(gamingAccountID: let gamingAcctID):
                return ["type": "transfer", "gamingAccountID": gamingAcctID]
                
            case .getGrantedBonuses, .getClaimableBonuses:
                return [:]
                
            case .applyBonusCode(bonusCode: let bCode):
                return ["bonusCode": bCode]
                
            case .forfeitBonus(bonusID: let bID):
                return ["bonusID": bID]
            // swiftlint:disable identifier_name
            case .setLimit(type: _, period: let p, amount: let a, currency: let c):
                return ["period" : p, "amount" : a, "currency" : c]
                
            case .realityCheckSet(value: let val):
                return ["value" : val]
                
            case .getTransactionHistory(type: let tp, startTime: let st, endTime: let et, pageIndex: let pi, pageSize: let ps):
                return ["type": tp, "startTime": st, "endTime": et, "pageIndex": pi, "pageSize": ps]
                
            case .getLaunchURL(slug: let sl, tableId: let tID, realMoney: let rm, culture: let cult, pid: let posid):
                if sl != nil {
                    if posid != nil {
                        return ["slug": sl!, "realMoney": rm, "culture": cult, "pid": posid!]
                    } else {
                        return ["slug": sl!, "realMoney": rm, "culture": cult]
                    }
                } else {
                    if posid != nil {
                        return ["tableId": tID!, "realMoney": rm, "culture": cult, "pid": posid!]
                    } else {
                        return ["tableId": tID!, "realMoney": rm, "culture": cult]
                    }
                }
            case .acceptTC:
                return ["acceptedTermsType" : ""]
            case .coolOff24h:
                return ["reason": "24hourPanic", "unsatisfiedReason" : "", "period" : "CoolOffFor24Hours"]
            default:
                return nil
        }
    }
}
