//
//  TSRouter.swift
//  Tipico
//
//  Created by Andrei Marinescu on 13/02/2020.
//  Copyright © 2020 Tipico. All rights reserved.
//

import Foundation
// swiftlint:disable type_body_length
enum TSRouter {

    case login(username: String, password: String)
    case getOperatorInfo
    case getSessionInfo
    case validateEmail(email: String)
    case validateUsername(username: String)
    case getCountries
    case simpleRegister(form: EveryMatrix.SimpleRegisterForm)
    case getMatchDetails(language: String, matchId: String)
    case getLocations(language: String, sortByPopularity: Bool = false)
    case getCustomTournaments(language: String, sportId: String)
    case getTournaments(language: String, sportId: String)
    case getPopularTournaments(language: String, sportId: String)
    case profileUpdate(form: EveryMatrix.ProfileForm)
    case oddsMatch(operatorId: String, language: String, matchId: String)
    case sportsStatus(operatorId: String, language: String, sportId: String)
    case getPolicy
    case changePassword(oldPassword: String, newPassword: String, captchaPublicKey: String?, captchaChallenge: String?, captchaResponse: String?)
    case getUserMetaData
    case postUserMetadata(favoriteEvents: [String])
    case getProfileStatus
    case getUserBalance
    case getBetslipSelectionInfo(language: String, stakeAmount: Double, betType: EveryMatrix.BetslipSubmitionType, tickets: [EveryMatrix.BetslipTicketSelection])
    case placeBet(language: String, amount: Double, betType: EveryMatrix.BetslipSubmitionType, tickets: [EveryMatrix.BetslipTicketSelection], oddsValidationType: String)
    case getOpenBets(language: String, records: Int, page: Int)
    case cashoutBet(language: String, betId: String)
    case getMatchOdds(language: String, matchId: String, bettingTypeId: String)
    case getDepositCashier(currency: String, amount: String, gamingAccountId: String)
    case getWithdrawCashier(currency: String, amount: String, gamingAccountId: String)

    case getMyTickets(language: String, ticketsType: EveryMatrix.MyTicketsType, records: Int, page: Int)

    case getSystemBetTypes(tickets: [EveryMatrix.BetslipTicketSelection])
    case getSystemBetSelectionInfo(language: String, stakeAmount: Double, systemBetType: SystemBetType, tickets: [EveryMatrix.BetslipTicketSelection])
    case placeSystemBet(language: String, amount: Double, systemBetType: SystemBetType, tickets: [EveryMatrix.BetslipTicketSelection], oddsValidationType: String)

    case matchDetailsPublisher(operatorId: String, language: String, matchId: String)
    case matchMarketGroupsPublisher(operatorId: String, language: String, matchId: String)
    case matchMarketGroupDetailsPublisher(operatorId: String, language: String, matchId: String, marketGroupName: String)

    case tournamentOddsPublisher(operatorId: String, language: String, eventId: String)

    case searchV2(language: String, limit: Int, query: String, eventStatuses: [Int], include: [String], bettingTypeIds: [String], sortBy: [String])

    case getSharedBetTokens(betId: String)
    case getSharedBetData(betToken: String)

    // EveryMatrix <-> GOMA  Subscriptions
    case sportsInitialDump(topic: String)
    case sportsPublisher(operatorId: String)
    case bettingOfferPublisher(operatorId: String, language: String, bettingOfferId: String)
    case liveMatchesPublisher(operatorId: String, language: String, sportId: String, matchesCount: Int)
    case popularMatchesPublisher(operatorId: String, language: String, sportId: String, matchesCount: Int)
    case popularTournamentsPublisher(operatorId: String, language: String, sportId: String, tournamentsCount: Int)
    case todayMatchesPublisher(operatorId: String, language: String, sportId: String, matchesCount: Int)

    case todayMatchesFilterPublisher(operatorId: String, language: String, sportId: String, matchesCount: Int, timeRange: String)
    case competitionsMatchesPublisher(operatorId: String, language: String, sportId: String, events: [String])
    case bannersInfoPublisher(operatorId: String, language: String)
    case locationsPublisher(operatorId: String, language: String, sportId: String)
    case tournamentsPublisher(operatorId: String, language: String, sportId: String)
    case favoriteMatchesPublisher(operatorId: String, language: String, userId: String)
    case cashoutPublisher(operatorId: String, language: String, betId: String)
    case matchDetailsAggregatorPublisher(operatorId: String, language: String, matchId: String)
    case matchMarketOdds(operatorId: String, language: String, matchId: String, bettingType: String, eventPartId: String)

    case eventPartScoresPublisher(operatorId: String, language: String, matchId: String)
    case sportsListPublisher(operatorId: String, language: String)
    case accountBalancePublisher
    case eventCategoryBySport(operatorId: String, language: String, sportId: String)

    // Others
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
    case disciplines(language: String)
    case locations(payload: [String: Any]?)
    case tournaments(payload: [String: Any]?)
    case popularTournaments(payload: [String: Any]?)
    case matches(payload: [String: Any]?)
    case popularMatches(payload: [String: Any]?)
    case todayMatches(payload: [String: Any]?)
    case nextMatches(payload: [String: Any]?)
    case events(payload: [String: Any]?)
    case odds(payload: [String: Any]?)

    var procedure: String {
        switch self {

        // RPCS
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
        case .getMatchDetails:
            return "/sports#matches"
        case .getPolicy:
            return "/user/pwd#getPolicy"
        case .changePassword( _, _, _, _, _):
            return "/user/pwd#change"
        case .getLocations:
            return "/sports#locations"
        case .getCustomTournaments:
            return "/sports#customEvents"
        case .getTournaments:
            return "/sports#tournaments"
        case .getPopularTournaments:
            return "/sports#popularTournaments"
        case .profileUpdate:
            return "/user/account#updateProfile"
        case .getUserMetaData:
            return "/sports#getUserMetadata"
        case .postUserMetadata:
            return "/sports#postUserMetadata"
        case .getProfileStatus:
            return "/user/account#getProfileStatus"
        case .getBetslipSelectionInfo:
            return "/sports#bettingOptionsV2"
        case .placeBet:
            return "/sports#placeBetV2"
        case .getUserBalance:
            return "/user/account#getGamingAccounts"
        case .getOpenBets:
            return "/sports#betHistoryV2"
        case .cashoutBet:
            return "/sports#cashOut"
        case .getMatchOdds:
            return "/sports#odds"
        case .getDepositCashier:
            return "/user/hostedcashier#deposit"
        case .getWithdrawCashier:
            return "/user/hostedcashier#withdraw"

        case .getSystemBetTypes:
            return "/sports#systemBetCalculationV2"
        case .getSystemBetSelectionInfo:
            return "/sports#bettingOptionsV2"
        case .placeSystemBet:
            return "/sports#placeBetV2"

        case .getMyTickets:
            return "/sports#betHistoryV2"


        case .matchDetailsPublisher(let operatorId, let language, let matchId):
            return "/sports/\(operatorId)/\(language)/match-aggregator-groups-overview/\(matchId)/1"
        case .matchMarketGroupsPublisher(let operatorId, let language, let matchId):
            return "/sports/\(operatorId)/\(language)/event/\(matchId)/market-groups"
        case .matchMarketGroupDetailsPublisher(let operatorId, let language, let matchId, let marketGroupName):
            return "/sports/\(operatorId)/\(language)/\(matchId)/match-odds/market-group/\(marketGroupName)"

        case .matchDetailsAggregatorPublisher(let operatorId, let language, let matchId):
            return "/sports/\(operatorId)/\(language)/match-aggregator-groups-overview/\(matchId)/1"

        case .tournamentOddsPublisher(let operatorId, let language, let eventId):
            return "/sports/\(operatorId)/\(language)/\(eventId)/tournament-odds"

        case .searchV2:
            return "/sports#searchV2"

        case .getSharedBetTokens:
            return "/sports#sharedBetTokens"

        case .getSharedBetData:
            return "/sports#sharedBetData"

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

        case .bettingOfferPublisher(let operatorId, let language, let bettingOfferId):
            return "/sports/\(operatorId)/\(language)/bettingOffers/\(bettingOfferId)"

        case .liveMatchesPublisher(let operatorId, let language, let sportId, let matchesCount):
            let marketsCount = 5
            return "/sports/\(operatorId)/\(language)/live-matches-aggregator-main/\(sportId)/all-locations/default-event-info/\(matchesCount)/\(marketsCount)"

        case .popularMatchesPublisher(let operatorId, let language, let sportId, let matchesCount):
            let marketsCount = 5
            return "/sports/\(operatorId)/\(language)/popular-matches-aggregator-main/\(sportId)/\(matchesCount)/\(marketsCount)"
        case .popularTournamentsPublisher(let operatorId, let language, let sportId, let tournamentsCount):
            return "/sports/\(operatorId)/\(language)/popular-tournaments/\(sportId)/\(tournamentsCount)"

        case .todayMatchesPublisher(let operatorId, let language, let sportId, let matchesCount):
            let marketsCount = 5
            return "/sports/\(operatorId)/\(language)/next-matches-aggregator-main/\(sportId)/\(matchesCount)/\(marketsCount)"
        case .todayMatchesFilterPublisher(let operatorId, let language, let sportId, let matchesCount, let timeRange):
            let marketsCount = 5
            return "/sports/\(operatorId)/\(language)/next-matches-aggregator-main/\(sportId)/\(timeRange)/\(matchesCount)/\(marketsCount)"
        case .competitionsMatchesPublisher(let operatorId, let language, _, let events):
            let marketsCount = 5
            let eventsIds = events.joined(separator: ",")
            return "/sports/\(operatorId)/\(language)/tournament-aggregator-main/\(eventsIds)/default-event-info/\(marketsCount)"
        
        case .bannersInfoPublisher(let operatorId, let language):
            return "/sports/\(operatorId)/\(language)/sportsBannerData"
        case .locationsPublisher(let operatorId, let language, let sportId):
            return "/sports/\(operatorId)/\(language)/locations/\(sportId)"
        case .tournamentsPublisher(let operatorId, let language, let sportId):
            return "/sports/\(operatorId)/\(language)/tournaments/\(sportId)"
        case .favoriteMatchesPublisher(let operatorId, let language, let userId):
            let marketsCount = 5
            return "/sports/\(operatorId)/\(language)/user-favorite-events-aggregator/\(userId)/\(marketsCount)"
        case .cashoutPublisher(let operatorId, let language, let betId):
            return "/sports/\(operatorId)/\(language)/cashout/\(betId)"
        case .matchMarketOdds(let operatorId, let language, let matchId, let bettingType, let eventPartId):
            return "/sports/\(operatorId)/\(language)/\(matchId)/match-odds/\(bettingType)/\(eventPartId)"

        case .eventPartScoresPublisher(let operatorId, let language, let matchId):
            return "/sports/\(operatorId)/\(language)/\(matchId)/eventPartScores/small"

        case .sportsListPublisher(let operatorId, let language):
            return "/sports/\(operatorId)/\(language)/disciplines/LIVE/BOTH"

        case .accountBalancePublisher:
            return "/account/balanceChanged"
        case .eventCategoryBySport(let operatorId, let language, let sportId):
            return "/sports/\(operatorId)/\(language)/event-category-by-sport/\(sportId)/BOTH"

        //
        //
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

        //
        //
        // RPC calls
        //
        case .login(let username, let password):
            return ["usernameOrEmail": username, "password": password]
        case .validateEmail(let email):
            return ["email": email]
        case let .validateUsername(username):
            return ["username": username]
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
        case .getMatchDetails(let language, let matchId):
            return ["lang": language,
                    "matchId": matchId]
        case .getPolicy:
            return [:]
        case .changePassword(let oldPassword, let newPassword, let captchaPublicKey, let captchaChallenge, let captchaResponse):
            return ["oldPassword": oldPassword,
                    "newPassword": newPassword,
                    "captchaPublicKey": captchaPublicKey ?? "",
                    "captchaChallenge": captchaChallenge ?? "",
                    "captchaResponse": captchaResponse ?? ""]
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
                    "securityQuestion": form.securityQuestion ?? "",
                    "securityAnswer": form.securityAnswer ?? "",
                    "userConsents": ["termsandconditions": true, "sms": false]]            
        case .getLocations(let language, let sortByPopularity):
            let sortByPopularityString = String(sortByPopularity)
            return ["lang": language,
                    "sortByPopularity": sortByPopularityString]

        case .getCustomTournaments(let language, _):
            return ["lang": language]
        case .getTournaments(let language, let sportId):
            return ["lang": language,
                    "sportId": sportId]
        case .getPopularTournaments(let language, let sportId):
            return ["lang": language,
                    "sportId": sportId]
        case .getUserMetaData:
            return ["keys": ["favoriteEvents"]]
        case .postUserMetadata(let favoriteEvents):
            return ["key": "favoriteEvents",
                    "value": favoriteEvents]
        case .getProfileStatus:
            return [:]
        case .getUserBalance:
            return ["expectBalance": true,
                    "expectBonus": true]
            
        case .getBetslipSelectionInfo(let language, let stakeAmount, let betType, let tickets):
            var selection: [Any] = []
            for ticket in tickets {
                selection.append([
                    "bettingOfferId": "\(ticket.id)",
                    "priceValue": ticket.currentOdd
                ])
            }
            let params: [String: Any] = ["lang": language,
                    "terminalType": "MOBILE",
                    "stakeAmount": stakeAmount,
                    "eachWay": false,
                    "type": betType.typeKeyword,
                          "selections": selection]
            return params

        case .placeBet(let language, let amount, let betType, let tickets, let oddsValidationType):
            var selection: [Any] = []
            for ticket in tickets {
                selection.append([
                    "bettingOfferId": "\(ticket.id)",
                    "priceValue": ticket.currentOdd
                ])
            }
            let params: [String: Any] = ["lang": language,
                    "terminalType": "MOBILE",
                    "amount": amount,
                    "eachWay": false,
                    "type": betType.typeKeyword,
                    "oddsValidationType": oddsValidationType,
                    "selections": selection]
            return params

        case .getOpenBets(let language, let records, let page):
            return ["lang": language,
                    "betStatuses": ["OPEN"],
                    "nrOfRecords": records,
                    "page": page
            ]
        case .cashoutBet(let language, let betId):
            return ["lang": language,
                    "betId": betId]

        case .getMatchOdds(let language, let matchId, let bettingTypeId):
            return ["lang": language,
                    "matchId": matchId,
                    "bettingTypeId": bettingTypeId]

        case .getDepositCashier(let currency, let amount, let gamingAccountId):
            let params: [String: Any] = ["fields": ["currency": currency,
                                                    "amount": amount,
                                                    "gamingAccountID": gamingAccountId,
                                                    "cashierMode": 0
                                                    ]
                                        ]
            return params
        case .getWithdrawCashier(let currency, let amount, let gamingAccountId):
            let params: [String: Any] = ["fields": ["currency": currency,
                                                    "amount": amount,
                                                    "gamingAccountID": gamingAccountId,
                                                    "cashierMode": 0
                                                    ]
                                        ]
            return params

        case .getSystemBetTypes(let tickets):
            var selection: [Any] = []
            for ticket in tickets {
                selection.append([
                    "bettingOfferId": "\(ticket.id)"
                ])
            }
            let params: [String: Any] = ["selections": selection]
            return params

        case .getSystemBetSelectionInfo(let language, let stakeAmount, let systemBetType, let tickets):
            var selection: [Any] = []
            for ticket in tickets {
                selection.append([
                    "bettingOfferId": "\(ticket.id)",
                    "priceValue": ticket.currentOdd
                ])
            }
            let params: [String: Any] = ["lang": language,
                    "terminalType": "MOBILE",
                    "stakeAmount": stakeAmount,
                    "eachWay": false,
                    "type": "SYSTEM",
                    "systemBetType": systemBetType.id,
                    "selections": selection]

            return params

        case .placeSystemBet(let language, let amount, let systemBetType, let tickets, let oddsValidationType):
            var selection: [Any] = []
            for ticket in tickets {
                selection.append([
                    "bettingOfferId": "\(ticket.id)",
                    "priceValue": ticket.currentOdd
                ])
            }
            let params: [String: Any] = ["lang": language,
                    "terminalType": "MOBILE",
                    "amount": amount,
                    "eachWay": false,
                    "type": "SYSTEM",
                    "systemBetType": systemBetType.id,
                    "oddsValidationType": oddsValidationType,
                    "selections": selection]
            return params

        case .getMyTickets(let language,let ticketsType, let records, let page):
            return ["lang": language,
                    "betStatuses": ticketsType.queryArray,
                    "nrOfRecords": records,
                    "page": page]

        case .searchV2(let language, let limit, let query, let eventStatuses, let include, let bettingTypeIds, let sortBy):
            return ["lang": language,
                    "limit": limit,
                    "query": query,
                    "eventStatuses": eventStatuses,
                    "include": include,
                    "bettingTypeIds": bettingTypeIds,
                    "sortBy": sortBy]

        case .getSharedBetTokens(let betId):
            return ["betId": betId]

        case .getSharedBetData(let betToken):
            return ["betToken": betToken]

        //
        //
        //
        // EM Subscription
        //
        case .sportsInitialDump(let topic):
            return ["topic": topic]

        //
        //
        //
        // Others
        //
        case .disciplines(let language):
            return ["lang": language]

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
        case .bettingOfferPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .liveMatchesPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .popularMatchesPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .popularTournamentsPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .todayMatchesPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .todayMatchesFilterPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .bannersInfoPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .competitionsMatchesPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .locationsPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .tournamentsPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .matchDetailsPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .matchMarketGroupsPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .matchMarketGroupDetailsPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .favoriteMatchesPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .cashoutPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .matchDetailsAggregatorPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .matchMarketOdds:
            return .sportsInitialDump(topic: self.procedure)
        case .tournamentOddsPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .eventPartScoresPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .sportsListPublisher:
            return .sportsInitialDump(topic: self.procedure)
        case .eventCategoryBySport:
            return .sportsInitialDump(topic: self.procedure)
        default:
            return nil
        }
    }

}

//      Cliente                                           EM Server
//         |                                                  |
//         |              -------------------->               |
//         |                                                  |
//         |                                                  |
//         |        RPC                         EM            |
//         |         |           ->             |             |
//         |         |                          |             |
//         |         |           <-             |             |
//         |         |                          |             |
//         |         |                          |             |
//         |                                                  |
//         |                                                  |
//         |                                                  |
//         |                                                  |
//         |    Subscribe                       EM            |
//         |         |           ->             |             |
//         |         |           <-             |             |
//         |         |           <-             |             |
//         |         |                          |             |
//         |         |           <-             |             |
//         |         |                          |             |
//         |         |           <-             |             |
//         |         |                          |             |
//         |         |           <-             |             |
//         |         |                          |             |
//         |         |                          |             |
//         |         |           ->             |             |
//         |                                                  |
//         |                                                  |
//         |                                                  |
//         |            <--------------------                 |
//         |                                                  |
//         |                                                  |

//
//
//         |             -------------------->                |
//         |             <--------------------                |
//
//
//         |             -------------------->                |
//         |             <--------------------                |
//
//
//

// SOCKET
//          Client                      Servidor
// RPC
//
//      nextMatches ---------------------------->
//
//      estrutura de dados  <--------------------
//
//
//
//
//
//
//

// SOCKET
//
// PUBLISHERS
//
//          Client                                     Servidor
//
//         wallet  ------------------------------------->
//
//     connect <------------------- (connect [id: 1234566] )
//
//     dados de update da wallet <------------------- (initial dump)
//
//     dados de update da wallet <------------------- (updates)
//
//     dados de update da wallet <------------------- (updates)
//
//
//     dados de update da wallet <------------------- (updates)
//
//
//     unregister [id: 1234566] ----------------------->
//
//
