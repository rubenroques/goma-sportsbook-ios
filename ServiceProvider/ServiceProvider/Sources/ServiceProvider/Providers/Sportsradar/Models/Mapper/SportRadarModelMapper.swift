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
    // Sports
    //
    static func sportTypeDetails(fromInternalSportTypeDetails internalSportTypeDetails: SportRadarModels.SportTypeDetails)
    -> SportTypeDetails? {
        guard
            let sportType = Self.sportType(fromInternalSportType: internalSportTypeDetails.sportType)
        else {
            return nil
        }
        return SportTypeDetails(sportType: sportType, eventsCount: internalSportTypeDetails.eventsCount)
    }
    
    static func internalSportTypeDetails(fromSportTypeDetails sportTypeDetails: SportTypeDetails)
    -> SportRadarModels.SportTypeDetails? {
        guard
            let sportType = Self.internalSportType(fromSportType: sportTypeDetails.sportType)
        else {
            return nil
        }
        return SportRadarModels.SportTypeDetails(sportType: sportType, eventsCount: sportTypeDetails.eventsCount)
    }
    
    //
    static func sportType(fromInternalSportType internalSportType: SportRadarModels.SportType) -> SportType? {
        switch internalSportType {
        case .football: return .football
        case .golf: return .golf
        case .tennis: return .tennis
        case .americanFootball: return .americanFootball
        case .iceHockey: return .iceHockey
        case .handball: return .handball
        case .basketball: return .basketball
        case .baseball: return .baseball
        case .fieldHockey: return .fieldHockey
        case .softball: return .softball
        case .weightlifting: return .weightlifting
        case .athletics: return .athletics
        case .badminton: return .badminton
        case .aussieRules: return .afl
        case .bandy: return .bandy
        case .bowls: return .bowls
        case .beachFootball: return .beachFootball
        case .cricket: return .cricket
        case .curling: return .curling
        case .cycling: return .cycling
        case .darts: return .darts
        case .floorball: return .floorball
        case .futsal: return .futsal
        case .motorsport: return .motorRacing
        case .pesapallo: return .pesapallo
        case .rugbyLeague: return .rugbyLeague
        case .rugbyUnion: return .rugbyUnion
        case .snooker: return .snooker
        case .squash: return .squash
        case .tableTennis: return .tableTennis
        case .volleyball: return .volleyball
        case .alpineSkiing: return .alpineSkiing
        case .biathlon: return .biathlon
        case .bobsleigh: return .bobsleigh
        case .luge: return .luge
        case .nordicCombined: return .nordicCombined
        case .skiJumping: return .skiJumping
        case .snowboard: return .snowboard
        case .speedSkating: return .speedSkating
        case .archery: return .archery
        case .diving: return .diving
        case .smite: return .smite
        case .fencing: return .fencing
        case .judo: return .judo
        case .lacrosse: return .lacrosse
        case .modernPentathlon: return .modernPentathlon
        case .pool: return .pool
        case .rowing: return .rowing
        case .sailing: return .sailing
        case .shooting: return .shooting
        case .shortTrackSpeedSkating: return .shortTrackSpeedSkating
        case .skeleton: return .skeleton
        case .specials: return .specials
        case .swimming: return .swimming
        case .figureSkating: return .figureSkating
        case .sportClimbing: return .sportClimbing
        case .triathlon: return .triathlon
        case .skateboarding: return .skateboarding
        case .surfing: return .surfing
        case .gaelicFootball: return .gaelicFootball
        case .greyhoundRacing: return .greyhounds
        case .horseRacing: return .horseRacing
        case .canoe: return .canoeing
        case .counterStrike: return .csGo
        case .dota2: return .dota2
        case .leagueOfLegends: return .leagueOfLegends
        case .starCraft: return .starcraft2
        case .callOfDuty: return .callOfDuty
        case .heroesOfTheStorm: return .heroesOfTheStorm
        case .overwatch: return .overwatch
        case .worldOfWarcraft: return .warcraft3
        case .playerUnknownsBattlegrounds: return .pubg
        case .heartstone: return .hearthstone
        case .virtualHorseRacing: return .virtualHorseRacing
        case .virtualFootball: return .virtualFootball
        case .virtualBasketball: return .virtualBasketball
        case .virtualTennis: return .virtualTennis
        case .streetFighter: return .virtualStreetFighter
        case .virtualGreyhoundRacing: return .virtualGreyhounds
        case .electronicIceHockey: return .eIceHockey
        case .eSportNba2K: return .virtualNba2K
        case .waterpolo: return .waterPolo
        case .beachVolley: return .beachVolleyball
        case .gymnastic: return .gymnastics
        case .freestyle: return .freestyleSkiing
        case .crossCountry: return .crossCountrySkiing
        case .equestrian: return .equestrianSports
        case .winterSports: return .wintersports
            
        case .gaelicHurling: return .gaelicHurling
        case .gaelicSports: return .gaelicSports
        case .rinkHockey: return .rinkHockey
        case .dogRacing: return .dogRacing
        case .basketball3X3: return .basketball3X3
        case .worldOfTanks: return .worldOfTanks
        case .olympics: return .olympics
        case .synchronizedSwimming: return .synchronizedSwimming
        case .trotting: return .trotting
            
        case .canoeSlalom: return .canoeSlalom
        case .cyclingBmxFreestyle: return .cyclingBmxFreestyle
        case .cyclingBmxRacing: return .cyclingBmxRacing
        case .mountainBike: return .mountainBike
        case .trackCycling: return .trackCycling
        case .trampolineGymnastics: return .trampolineGymnastics
        case .rhythmicGymnastics: return .rhythmicGymnastics
        case .marathonSwimming: return .marathonSwimming
            
        case .boxing: return .boxing
        case .taekwondo: return .taekwondo
        case .karate: return .karate
        case .wrestling: return .wrestling
        case .mma: return .mma
            
        case .stockCarRacing: return .stockCarRacing
        case .touringCarRacing: return .touringCarRacing
        case .rally: return .rally
        case .speedway: return .speedway
        case .formulaE: return .formulaE
        case .indyRacing: return .indyRacing
        case .motorcycleRacing: return .motorcycleRacing
        case .formula1: return .formula1
            
        case .numbers: return .numbers
        case .emptyBets: return .emptyBets
        case .lotteries: return .lotteries
            
        default: return nil
        }
    }
    
    static func internalSportType(fromSportType sportType: SportType) -> SportRadarModels.SportType? {
        switch sportType {
        case .football: return .football
        case .golf: return .golf
        case .tennis: return .tennis
        case .americanFootball: return .americanFootball
        case .iceHockey: return .iceHockey
        case .handball: return .handball
        case .basketball: return .basketball
        case .baseball: return .baseball
        case .fieldHockey: return .fieldHockey
        case .softball: return .softball
        case .weightlifting: return .weightlifting
        case .athletics: return .athletics
        case .badminton: return .badminton
        case .afl: return .aussieRules
        case .bandy: return .bandy
        case .bowls: return .bowls
        case .beachFootball: return .beachFootball
        case .cricket: return .cricket
        case .curling: return .curling
        case .cycling: return .cycling
        case .darts: return .darts
        case .floorball: return .floorball
        case .futsal: return .futsal
        case .motorRacing: return .motorsport
        case .pesapallo: return .pesapallo
        case .rugbyLeague: return .rugbyLeague
        case .rugbyUnion: return .rugbyUnion
        case .snooker: return .snooker
        case .squash: return .squash
        case .tableTennis: return .tableTennis
        case .volleyball: return .volleyball
        case .alpineSkiing: return .alpineSkiing
        case .biathlon: return .biathlon
        case .bobsleigh: return .bobsleigh
        case .luge: return .luge
        case .nordicCombined: return .nordicCombined
        case .skiJumping: return .skiJumping
        case .snowboard: return .snowboard
        case .speedSkating: return .speedSkating
        case .archery: return .archery
        case .diving: return .diving
        case .smite: return .smite
        case .fencing: return .fencing
        case .judo: return .judo
        case .lacrosse: return .lacrosse
        case .modernPentathlon: return .modernPentathlon
        case .pool: return .pool
        case .rowing: return .rowing
        case .sailing: return .sailing
        case .shooting: return .shooting
        case .shortTrackSpeedSkating: return .shortTrackSpeedSkating
        case .skeleton: return .skeleton
        case .specials: return .specials
        case .swimming: return .swimming
        case .figureSkating: return .figureSkating
        case .sportClimbing: return .sportClimbing
        case .triathlon: return .triathlon
        case .skateboarding: return .skateboarding
        case .surfing: return .surfing
        case .gaelicFootball: return .gaelicFootball
        case .greyhounds: return .greyhoundRacing
        case .horseRacing: return .horseRacing
        case .canoeing: return .canoe
        case .csGo: return .counterStrike
        case .dota2: return .dota2
        case .leagueOfLegends: return .leagueOfLegends
        case .starcraft2: return .starCraft
        case .callOfDuty: return .callOfDuty
        case .heroesOfTheStorm: return .heroesOfTheStorm
        case .overwatch: return .overwatch
        case .warcraft3: return .worldOfWarcraft
        case .pubg: return .playerUnknownsBattlegrounds
        case .hearthstone: return .heartstone
        case .virtualHorseRacing: return .virtualHorseRacing
        case .virtualFootball: return .virtualFootball
        case .virtualBasketball: return .virtualBasketball
        case .virtualTennis: return .virtualTennis
        case .virtualStreetFighter: return .streetFighter
        case .virtualGreyhounds: return .virtualGreyhoundRacing
            
        case .eIceHockey: return .electronicIceHockey
        case .virtualNba2K: return .eSportNba2K
            
        case .waterPolo: return .waterpolo
        case .beachVolleyball: return .beachVolley
        case .gymnastics: return .gymnastic
        case .freestyleSkiing: return .freestyle
        case .crossCountrySkiing: return .crossCountry
        case .equestrianSports: return .equestrian
        case .wintersports: return .winterSports
            
        case .gaelicHurling: return .gaelicHurling
        case .gaelicSports: return .gaelicSports
        case .rinkHockey: return .rinkHockey
        case .dogRacing: return .dogRacing
        case .basketball3X3: return .basketball3X3
        case .worldOfTanks: return .worldOfTanks
        case .olympics: return .olympics
        case .synchronizedSwimming: return .synchronizedSwimming
        case .trotting: return .trotting
            
        case .canoeSlalom: return .canoeSlalom
        case .cyclingBmxFreestyle: return .cyclingBmxFreestyle
        case .cyclingBmxRacing: return .cyclingBmxRacing
        case .mountainBike: return .mountainBike
        case .trackCycling: return .trackCycling
        case .trampolineGymnastics: return .trampolineGymnastics
        case .rhythmicGymnastics: return .rhythmicGymnastics
        case .marathonSwimming: return .marathonSwimming
            
        case .boxing: return .boxing
        case .taekwondo: return .taekwondo
        case .karate: return .karate
        case .wrestling: return .wrestling
        case .mma: return .mma
            
        case .stockCarRacing: return .stockCarRacing
        case .touringCarRacing: return .touringCarRacing
        case .rally: return .rally
        case .speedway: return .speedway
        case .formulaE: return .formulaE
        case .indyRacing: return .indyRacing
        case .motorcycleRacing: return .motorcycleRacing
        case .formula1: return .formula1
            
        case .numbers: return .numbers
        case .emptyBets: return .emptyBets
        case .lotteries: return .lotteries
            
        default: return nil
        }
    }

    static func sportUnique(fromSportNode sportNode: SportNode) -> SportUnique? {

        let sportUnique = SportUnique(name: sportNode.name, numericId: sportNode.id, alphaId: nil, iconId: nil, numberEvents: sportNode.numberEvents, numberOutrightEvents: sportNode.numberOutrightEvents, numberOutrightMarkets: sportNode.numberOutrightMarkets)

        return sportUnique
    }

    static func sportUnique(fromScheduledSport scheduledSport: ScheduledSport) -> SportUnique? {

        let sportUnique = SportUnique(name: scheduledSport.name, numericId: nil, alphaId: scheduledSport.id, iconId: nil, numberEvents: nil, numberOutrightEvents: nil, numberOutrightMarkets: nil)
        return sportUnique

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
