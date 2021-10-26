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
    case getOperatorInfo
    case getSessionInfo
    case validateEmail(email: String)
    case validateUsername(username: String)
    case getCountries
    case simpleRegister(form: EveryMatrix.SimpleRegisterForm)
    case matchDetails(language: String, matchId: String)
    case profileUpdate(form: EveryMatrix.ProfileForm)
    case registrationDismissed
    case getTransportSessionID
    case getClientIdentity
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
    case disciplines(payload: [String: Any]?)
    case locations(payload: [String: Any]?)
    case tournaments(payload: [String: Any]?)
    case popularTournaments(payload: [String: Any]?)
    case matches(payload: [String: Any]?)
    case popularMatches(payload: [String: Any]?)
    case todayMatches(payload: [String: Any]?)
    case nextMatches(payload: [String: Any]?)
    case events(payload: [String: Any]?)
    case odds(payload: [String: Any]?)

    // GOMA EveryMatrix Subscriptions tests
    case oddsMatch(operatorId: String, language: String, matchId: String)
    case sportsStatus(operatorId: String, language: String, sportId: String)

    case sportsInitialDump(topic: String)

    // EveryMatrix <-> GOMA  Subscriptions
    case sportsPublisher(operatorId: String)
    case popularMatchesPublisher(operatorId: String, language: String, sportId: String)
    case todayMatchesPublisher(operatorId: String, language: String, sportId: String)
    case competitionsMatchesPublisher(operatorId: String, language: String, sportId: String, events: [String])
    case bannersInfoPublisher(operatorId: String, language: String)

    var procedure: String {
        switch self {
            // EveryMatrix API
        case .login:
            return "/user#login"
        case .getOperatorInfo:
            return "/sports#operatorInfo"
        case .getSessionInfo:
            return "/user#getSessionInfo"

        case .validateEmail:
            return "/user/account#validateEmail"

        case .validateUsername:
            return "/user/account#validateUsername"
        case .getCountries:
            return "/user/account#getCountries"
        case .simpleRegister:
            return "/user/account#register"
        case .matchDetails:
            return "/sports#matches"
        case .profileUpdate:
            return "/user/account#updateProfile"
        //
        //
        // EM Subscription
        // Sports
        case .sportsInitialDump:
            return "/sports#initialDump"
        case .oddsMatch(let operatorId, let language, let matchId):
            return "/sports/\(operatorId)/\(language)/\(matchId)/match-odds"
        case .sportsStatus(let operatorId, let language, let sportId):
            return "/sports/\(operatorId)/\(language)/sport/\(sportId)"
        case .sportsPublisher(let operatorId):
            return "/sports/\(operatorId)/en/disciplines/BOTH/BOTH"

        case .popularMatchesPublisher(let operatorId, let language, let sportId):
            let marketsCount = 5
            let eventsCount = 10
            return "/sports/\(operatorId)/\(language)/popular-matches-aggregator-main/\(sportId)/\(eventsCount)/\(marketsCount)"

        case .todayMatchesPublisher(let operatorId, let language, let sportId):
            let marketsCount = 5
            let eventsCount = 10
            return "/sports/\(operatorId)/\(language)/next-matches-aggregator-main/\(sportId)/\(eventsCount)/\(marketsCount)"

        case .competitionsMatchesPublisher(let operatorId, let language, _, let events):
            let marketsCount = 5
            let eventsIds = events.joined(separator: ",")
            return "/sports/\(operatorId)/\(language)/tournament-aggregator-main/\(eventsIds)/default-event-info/\(marketsCount)"
        
        case .bannersInfoPublisher(let operatorId, let language):
            return "/sports/\(operatorId)/\(language)/sportsBannerData"
        //
        //
        //
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

            // Others
        case .registrationDismissed:
            return "/registrationDismissed"
        case .getTransportSessionID:
            return "/user#getTransportSessionID"
        case .getClientIdentity:
            return "/connection#getClientIdentity"

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
        case .validateEmail(let email):
            return ["email": email]
        case let .validateUsername(username):
            return ["username": username]
        case .getCountries:
            return [:]
        case let .simpleRegister(form):
            return ["email": form.email,
                    "username": form.username,
                    "password": form.password,
                    "birthDate": form.birthDate,
                    "mobilePrefix": form.mobilePrefix,
                    "mobile": form.mobileNumber,
                    "country": "PT",
                    "currency": "EUR",
                    "emailVerificationURL": form.emailVerificationURL,
                    "userConsents": ["termsandconditions": true, "sms": false]]
        case let .profileUpdate(form):
            return ["email": form.email,
                    "title": form.title,
                    "gender": form.gender,
                    "firstName": form.firstname,
                    "surname": form.surname,
                    "birthDate": form.birthDate,
                    "mobilePrefix": form.mobilePrefix,
                    "mobile": form.mobile,
                    "phonePrefix": form.phonePrefix,
                    "phone": form.phone,
                    "country": form.country,
                    "address1": form.address1,
                    "address2": form.address2,
                    "city": form.city,
                    "postalCode": form.postalCode,
                    "personalID": form.personalID,
                    "userConsents": ["termsandconditions": true, "sms": false]]
        case .matchDetails(let language, let matchId):
            return ["lang": language,
                    "matchId": matchId]
            
            //
            //
        case .sportsInitialDump(let topic):
            return ["topic": topic]
        case .sportsPublisher:
            return [:]

            //
            //
            //
            //
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
            return [:]

        case .getGamingAccounts:
            return ["expectBalance": true,
                    "expectBonus": true]

        case .addToFavorites(id: let gameID), .removeFromFavorites(id: let gameID):
            return ["anonymousUserIdentity": false,
                    "type": "game",
                    "id": gameID]

        case .getFavorites:
            return ["anonymousUserIdentity": false,
                    "expectedGameFields": 1,
                    "expectedTableFields": 67108864,
                    "filterByPlatform": ["imobile"],
                    "specificExportFields": ["gameID"]
            ]

        case .getApplicableBonuses(gamingAccountID: let gamingAcctID):
            return ["type": "transfer",
                    "gamingAccountID": gamingAcctID]

        case .getGrantedBonuses, .getClaimableBonuses:
            return [:]

        case .applyBonusCode(bonusCode: let bCode):
            return ["bonusCode": bCode]

        case .forfeitBonus(bonusID: let bID):
            return ["bonusID": bID]

            // swiftlint:disable identifier_name
        case .setLimit(type: _, period: let p, amount: let a, currency: let c):
            return ["period": p,
                    "amount": a,
                    "currency": c]

        case .realityCheckSet(value: let val):
            return ["value": val]

        case .getTransactionHistory(type: let tp, startTime: let st, endTime: let et, pageIndex: let pi, pageSize: let ps):
            return ["type": tp, "startTime": st, "endTime": et, "pageIndex": pi, "pageSize": ps]

        case .getLaunchURL(slug: let sl, tableId: let tID, realMoney: let rm, culture: let cult, pid: let posid):
            if sl != nil {
                if posid != nil {
                    return ["slug": sl!, "realMoney": rm, "culture": cult, "pid": posid!]
                }
                else {
                    return ["slug": sl!, "realMoney": rm, "culture": cult]
                }
            }
            else {
                if posid != nil {
                    return ["tableId": tID!, "realMoney": rm, "culture": cult, "pid": posid!]
                }
                else {
                    return ["tableId": tID!, "realMoney": rm, "culture": cult]
                }
            }
        case .acceptTC:
            return ["acceptedTermsType": ""]
        case .coolOff24h:
            return ["reason": "24hourPanic", "unsatisfiedReason": "", "period": "CoolOffFor24Hours"]
        default:
            return nil
        }
    }

    var intiailDumpRequest: TSRouter? {
        switch self {
        case .popularMatchesPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .todayMatchesPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .bannersInfoPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .competitionsMatchesPublisher:
            return .sportsInitialDump(topic: self.procedure)
        default:
            return nil
        }
    }

}
