//
//  SportRadarModelMapper.swift
//  
//
//  Created by Ruben Roques on 11/10/2022.
//

import Foundation

struct SportRadarModelMapper {
    
    // ============================================================
    // User
    //
    static func userProfile(fromPlayerInfoResponse playerInfoResponse: SportRadarModels.PlayerInfoResponse) -> UserProfile? {
        
        var userRegistrationStatus = UserRegistrationStatus.quickOpen
        switch playerInfoResponse.registrationStatus ?? "" {
        case "QUICK_OPEN": userRegistrationStatus = .quickOpen
        case "QUICK_REG": userRegistrationStatus = .quickRegister
        case "PLAYER": userRegistrationStatus = .completed
        default: userRegistrationStatus = .quickOpen
        }

        return UserProfile(userIdentifier: playerInfoResponse.partyId,
                           username: playerInfoResponse.userId,
                           email: playerInfoResponse.email,
                           firstName: playerInfoResponse.firstName,
                           lastName: playerInfoResponse.lastName,
                           birthDate: playerInfoResponse.birthDateFormatted,
                           gender: playerInfoResponse.gender,
                           nationalityCode: playerInfoResponse.nationality,
                           countryCode: playerInfoResponse.country,
                           personalIdNumber: playerInfoResponse.idCardNumber,
                           address: playerInfoResponse.address,
                           province: playerInfoResponse.province,
                           city: playerInfoResponse.city,
                           postalCode: playerInfoResponse.postalCode,
                           emailVerificationStatus: EmailVerificationStatus(fromStringKey:  playerInfoResponse.emailVerificationStatus),
                           userRegistrationStatus: userRegistrationStatus)
        
    }
    
    static func userOverview(fromInternalLoginResponse loginResponse: SportRadarModels.LoginResponse) -> UserOverview? {
        guard
            let sessionKey = loginResponse.sessionKey,
            let username = loginResponse.username,
            let email = loginResponse.email
        else {
            return nil
        }
        return UserOverview(sessionKey: sessionKey,
                            username: username,
                            email: email,
                            partyID: loginResponse.partyId,
                            language: loginResponse.language,
                            currency: loginResponse.currency,
                            parentID: loginResponse.parentId,
                            level: loginResponse.level,
                            userType: loginResponse.userType,
                            isFirstLogin: loginResponse.isFirstLogin,
                            registrationStatus: loginResponse.registrationStatus,
                            country: loginResponse.country,
                            kycStatus: loginResponse.kycStatus,
                            lockStatus: loginResponse.lockStatus)
    }
    
    static func userWallet(fromBalanceResponse playerInfoResponse: SportRadarModels.BalanceResponse) -> UserWallet {
        return UserWallet(vipStatus: playerInfoResponse.vipStatus,
                           currency: playerInfoResponse.currency,
                           loyaltyPoint: playerInfoResponse.loyaltyPoint,
                           totalString: playerInfoResponse.totalBalance,
                           total: playerInfoResponse.totalBalanceNumber,
                           withdrawableString: playerInfoResponse.withdrawableBalance,
                           withdrawable: playerInfoResponse.withdrawableBalanceNumber,
                           bonusString: playerInfoResponse.bonusBalance,
                           bonus: playerInfoResponse.bonusBalanceNumber,
                           pendingBonusString: playerInfoResponse.pendingBonusBalance,
                           pendingBonus: playerInfoResponse.pendingBonusBalanceNumber,
                           casinoPlayableBonusString: playerInfoResponse.casinoPlayableBonusBalance,
                           casinoPlayableBonus: playerInfoResponse.casinoPlayableBonusBalanceNumber,
                           sportsbookPlayableBonusString: playerInfoResponse.sportsbookPlayableBonusBalance,
                           sportsbookPlayableBonus: playerInfoResponse.sportsbookPlayableBonusBalanceNumber,
                           withdrawableEscrowString: playerInfoResponse.withdrawableEscrowBalance,
                           withdrawableEscrow: playerInfoResponse.withdrawableEscrowBalanceNumber,
                           totalWithdrawableString: playerInfoResponse.totalWithdrawableBalance,
                           totalWithdrawable: playerInfoResponse.totalWithdrawableBalanceNumber,
                           withdrawRestrictionAmountString: playerInfoResponse.withdrawRestrictionAmount,
                           withdrawRestrictionAmount: playerInfoResponse.withdrawRestrictionAmountNumber,
                           totalEscrowString: playerInfoResponse.totalEscrowBalance,
                           totalEscrow: playerInfoResponse.totalEscrowBalanceNumber)
    }
    
    // ============================================================
    // Events
    //
    static func eventsGroup(fromInternalEvents internalEvents: [SportRadarModels.Event]) -> EventsGroup {
        let events = internalEvents.map({ event -> Event in
            if let eventMarkets = event.markets {
                let markets = eventMarkets.map(Self.market(fromInternalMarket:))
                return Event(id: event.id,
                             homeTeamName: event.homeName ?? "",
                             awayTeamName: event.awayName ?? "",
                             sportTypeName: event.sportTypeName ?? "",
                             competitionId: event.competitionId ?? "",
                             competitionName: event.competitionName ?? "",
                             startDate: event.startDate ?? Date(),
                             markets: markets)
            }
            return Event(id: event.id,
                         homeTeamName: event.homeName ?? "",
                         awayTeamName: event.awayName ?? "",
                         sportTypeName: event.sportTypeName ?? "",
                         competitionId: event.competitionId ?? "",
                         competitionName: event.competitionName ?? "",
                         startDate: event.startDate ?? Date(),
                         markets: [])
        })
        
        let filterEvents = events.filter({
            !$0.markets.isEmpty
        })
        
        return EventsGroup(events: filterEvents)
    }
    
    static func market(fromInternalMarket internalMarket: SportRadarModels.Market) -> Market {
        let outcomes = internalMarket.outcomes.map(Self.outcome(fromInternalOutcome:))
        return Market(id: internalMarket.id, name: internalMarket.name, outcomes: outcomes, marketTypeId: internalMarket.marketTypeId, eventMarketTypeId: internalMarket.eventMarketTypeId, eventName: internalMarket.eventName)
    }
    
    static func outcome(fromInternalOutcome internalOutcome: SportRadarModels.Outcome) -> Outcome {
        return Outcome(id: internalOutcome.id, name: internalOutcome.name, odd: internalOutcome.odd, marketId: internalOutcome.marketId, orderValue: internalOutcome.orderValue, externalReference: internalOutcome.externalReference)
    }
    
    // ============================================================
    // Betting
    //
    
    static func bettingHistory(fromInternalBettingHistory internalBettingHistory: SportRadarModels.BettingHistory) -> BettingHistory {
        let betGroups = Dictionary.init(grouping: internalBettingHistory.bets, by: \.identifier)
        let bets = betGroups.map { identifier, internalBets in
            let betSelections = internalBets.map(Self.betSelection(fromInternalBet:))
            let potentialReturn: Double = internalBets.first?.potentialReturn ?? 0.0
            return Bet(identifier: identifier, selections: betSelections, potentialReturn: potentialReturn)
        }
        return BettingHistory(bets: bets)
    }

    static func betSelection(fromInternalBet internalBet: SportRadarModels.Bet) -> BetSelection {

        let state: BetState
        switch internalBet.state {
        case .opened: state = .opened
        case .closed: state = .closed
        case .settled: state = .settled
        case .cancelled: state = .cancelled
        case .undefined: state = .undefined
        case .attempted: state = .attempted
        case .allStates: state = .undefined
        }

        let result: BetResult
        switch internalBet.result {
        case .open: result = .open
        case .won: result = .won
        case .lost: result = .lost
        case .drawn: result = .drawn
        case .notSpecified: result = .notSpecified
        case .void: result = .void
        }

        return BetSelection(identifier: internalBet.identifier,
                            state: state,
                            result: result,
                            eventName: internalBet.eventName,
                            homeTeamName: internalBet.homeTeamName,
                            awayTeamName: internalBet.awayTeamName,
                            marketName: internalBet.marketName,
                            outcomeName: internalBet.outcomeName)
    }
    
    //  SportRadar ---> ServiceProvider
    static func betSlip(fromInternalBetslip betslip: SportRadarModels.BetSlip) -> BetSlip {
        return BetSlip(tickets: betslip.tickets.map(Self.betTicket(fromInternalBetTicket:)))
    }
    
    static func betTicket(fromInternalBetTicket betTicket: SportRadarModels.BetTicket) -> BetTicket {
        return BetTicket(selection: betTicket.selections.map(Self.betTicketSelection(fromInternalBetTicketSelection:)),
                         betType: "")
    }
    
    static func betTicketSelection(fromInternalBetTicketSelection betTicketSelection: SportRadarModels.BetTicketSelection) -> BetTicketSelection {
        return BetTicketSelection(identifier: betTicketSelection.identifier,
                                  eventName: "",
                                  homeTeamName: "",
                                  awayTeamName: "",
                                  marketName: "",
                                  outcomeName: "",
                                  odd: .fraction(numerator: Int(betTicketSelection.priceUp) ?? 0,
                                                 denominator: Int(betTicketSelection.priceDown) ?? 1))
    }

    //
    // PlacedBetResponse
    //
    static func placedBetResponse(fromInternalPlacedBetResponse placedBetResponse: SportRadarModels.PlacedBetResponse) -> PlacedBetResponse {
        let bets = placedBetResponse.bets.map(Self.placedBetEntry(fromInternalPlacedBetEntry:))
        return PlacedBetResponse(identifier: placedBetResponse.identifier,
                          bets: bets)
    }

    static func placedBetEntry(fromInternalPlacedBetEntry placedBetEntry: SportRadarModels.PlacedBetEntry) -> PlacedBetEntry {
        let betLegs = placedBetEntry.betLegs.map(Self.placedBetLeg(fromInternalPlacedBetLeg:))
        return PlacedBetEntry(identifier: placedBetEntry.identifier,
                              potentialReturn: placedBetEntry.potentialReturn,
                              placeStake: placedBetEntry.placeStake,
                              betLegs: betLegs)
    }

    static func placedBetLeg(fromInternalPlacedBetLeg placedBetLeg: SportRadarModels.PlacedBetLeg) -> PlacedBetLeg {
        return PlacedBetLeg(identifier: placedBetLeg.identifier,
                            priceType: placedBetLeg.priceType,
                            priceNumerator: placedBetLeg.priceNumerator,
                            priceDenominator: placedBetLeg.priceDenominator)
    }


    //
    //  ServiceProvider ---> SportRadar
    static func internalBetSlip(fromBetslip betslip: BetSlip) -> SportRadarModels.BetSlip {
        return SportRadarModels.BetSlip(tickets: betslip.tickets.map(Self.internalBetTicket(fromBetTicket:)))
    }
    
    static func internalBetTicket(fromBetTicket betTicket: BetTicket) -> SportRadarModels.BetTicket {
        return SportRadarModels.BetTicket(selections: betTicket.selection.map(Self.internalBetTicketSelection(fromBetTicketSelection:)),
                                          betTypeCode: betTicket.betType,
                                          placeStake: "",
                                          winStake: "",
                                          pool: false)
    }
    
    static func internalBetTicketSelection(fromBetTicketSelection betTicketSelection: BetTicketSelection) -> SportRadarModels.BetTicketSelection {
        return SportRadarModels.BetTicketSelection(identifier: betTicketSelection.identifier,
                                                   eachWayReduction: "",
                                                   eachWayPlaceTerms: "",
                                                   idFOPriceType: "",
                                                   isTrap: "",
                                                   priceUp: "",
                                                   priceDown: "")
    }

    // ============================================================
    // Sports
    //
    static func sportType(fromSportRadarSportType sportRadarSportType: SportRadarModels.SportType) -> SportType {
        // Try get the internal sport id name
        let cleanedSportRadarSportTypeName = Self.simplify(string: sportRadarSportType.name)
        let sportTypeInfoId = SportTypeInfo.allCases.first { sportTypeInfo in
            let cleanedName = Self.simplify(string: sportTypeInfo.name)
            return cleanedName == cleanedSportRadarSportTypeName
        }?.id

        let sportType = SportType(name: sportRadarSportType.name,
                                  numericId: sportRadarSportType.numericId,
                                  alphaId: sportRadarSportType.alphaId,
                                  iconId: sportTypeInfoId,
                                  showEventCategory: false,
                                  numberEvents: sportRadarSportType.numberEvents,
                                  numberOutrightEvents: sportRadarSportType.numberOutrightEvents,
                                  numberOutrightMarkets: sportRadarSportType.numberOutrightMarkets)

        return sportType
    }

    static func sportType(fromSportNode sportNode: SportRadarModels.SportNode) -> SportRadarModels.SportType {
        let sportUnique = SportRadarModels.SportType(name: sportNode.name,
                                    numericId: sportNode.id,
                                    alphaId: nil,
                                    numberEvents: sportNode.numberEvents,
                                    numberOutrightEvents: sportNode.numberOutrightEvents,
                                    numberOutrightMarkets: sportNode.numberOutrightMarkets)
        return sportUnique
    }

    static func sportType(fromScheduledSport scheduledSport: SportRadarModels.ScheduledSport) -> SportRadarModels.SportType {
        let sportUnique = SportRadarModels.SportType(name: scheduledSport.name,
                                                     numericId: nil,
                                                     alphaId: scheduledSport.id,
                                                     numberEvents: 0,
                                                     numberOutrightEvents: 0,
                                                     numberOutrightMarkets: 0)
        return sportUnique
        
    }

    private static func simplify(string: String) -> String {
        let validChars = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return string.filter { validChars.contains($0) }.lowercased()
    }
    // ==========================================

}

extension EmailVerificationStatus {
    init(fromStringKey key: String) {
        switch key {
        case "VERIFIED":
            self = .verified
        default:
            self = .unverified
        }
    }
}
