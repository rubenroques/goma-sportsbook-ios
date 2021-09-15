//
//  TSRouter.swift
//  Tipico
//
//  Created by Andrei Marinescu on 13/02/2020.
//  Copyright © 2020 Tipico. All rights reserved.
//

import Foundation

enum TSRouter {

    case login(username: String, password: String)

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
    // GOMA EveryMatrix
    case disciplines(payload: [String:Any]?)
    case locations(payload: [String:Any]?)
    case tournaments(payload: [String:Any]?)
    case popularTournaments(payload: [String:Any]?)
    case matches(payload: [String:Any]?)
    case popularMatches(payload: [String:Any]?)
    case todayMatches(payload: [String:Any]?)
    case nextMatches(payload: [String:Any]?)
    case events(payload: [String:Any]?)
    case odds(payload: [String:Any]?)
    // GOMA EveryMatrix Subscriptions
    case oddsMatch(language: String, matchId: String)

    var procedure: String {
        switch self {
        // EveryMatrix API
        case .login:
            return "/user#login"

        case .disciplines:
            return "/sports#disciplines"
        case .locations:
            return "/sports#locations"
        case .tournaments:
            return "/sports#tournaments"
        case .popularTournaments:
            return "/sports#popularTournaments"
        case .matches:
            return "/sports#matches"
        case .popularMatches:
            return "/sports#popularMatches"
        case .todayMatches:
            return "/sports#todayMatches"
        case .nextMatches:
            return "/sports#nextMatches"
        case .events:
            return "/sports#events"
        case .odds:
            return "/sports#odds"
        // EM Subscription
        case .oddsMatch(language: let language, matchId: let matchId):
            return "/sports/\(Env.operatorId)/\(language)/\(matchId)/match-odds"


        // Others
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
        case .removeLimit(let type):
            return "/user/limit#remove\(type)Limit"
        case .setLimit(let type, _, _, _):
            return "/user/limit#set\(type)Limit"
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
    
    var kwargs: [String: Any]? {
        switch self {
        case .login(let username, let password):
            return ["usernameOrEmail": username, "password": password]

        case .disciplines(payload: let payload):
            return payload
        case .locations(payload: let payload):
            return payload
        case .tournaments(payload: let payload):
            return payload
        case .popularTournaments(payload: let payload):
            return payload
        case .matches(payload: let payload):
            return payload
        case .popularMatches(payload: let payload):
            return payload
        case .todayMatches(payload: let payload):
            return payload
        case .nextMatches(payload: let payload):
            return payload
        case .events(payload: let payload):
            return payload
        case.odds(payload: let payload):
            return payload
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
