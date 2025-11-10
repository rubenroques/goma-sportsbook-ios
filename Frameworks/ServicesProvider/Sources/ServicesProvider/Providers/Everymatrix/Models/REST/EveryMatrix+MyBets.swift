//
//  EveryMatrix+MyBets.swift
//  ServicesProvider
//
//  Created on 28/08/2025.
//

import Foundation

extension EveryMatrix {

    // MARK: - MyBets Request Models

    struct EarlySettlementOption: Codable {
        let scoreDifference: Double?
    }
    
    // MARK: - MyBets Response Models
    
    struct Bet: Codable {
        let id: String?
        let selections: [BetSelection]?
        let type: String?
        let systemBetType: String?
        let amount: Double?
        let totalBetAmount: Double?
        let freeBetAmount: Double?
        let currency: String
        let maxWinning: Double?
        let possibleProfit: Double?
        let stakeBackOptions: String?
        let betStakeBack: String?
        let totalPriceValue: Double?
        let numberOfSelections: Int?
        let status: String?
        let statusLabel: String?
        let placedDate: String?
        let settledDate: String?
        let placementStatusConfirmedDate: String?
        let freeBet: Bool?
        let oddsBoost: Bool?
        let betBuilder: Bool?
        let mbaBet: Bool?
        let eachWay: Bool?
        let currentPossibleWinning: Double?
        let totalBalanceImpact: Double?
        let terminalType: String?
        let totalBetAmountTax: Double?
        let totalBetAmountEurTax: Double?
        let totalBetAmountNetto: Double?
        let maxWinningTax: Double?
        let maxWinningNetto: Double?
        let betPayoutTax: Double?
        let totalPayoutTax: Double?
        let betStakeNet: Double?
        let betStakeNetEur: Double?
        let partialCashOuts: [String]? // Array type may need adjustment based on actual structure
        let betRemainingStake: Double?
        let overallBetReturns: Double?
        let overallCashoutAmount: Double?
        let cashOutDate: String?
        let totalPriceValueByBetStatus: Double?
        let betNetReturns: Double?
        let potentialNetReturns: Double?
        let potentialWinTax: Double?
        let taxEnabled: Bool?
        let pendingCashOutStatus: String?
        let betPlacementStatus: String?
        let betSettlementStatus: String?
        let paymentTime: String?
        let ticketCode: String?
        let paymentStatus: String?
        let bonusWalletId: String?
        let hasBonusMoney: Bool?
        let realStake: Double?
        let bonusStake: Double?


        enum CodingKeys: String, CodingKey {
            case id
            case selections
            case type
            case systemBetType
            case amount
            case totalBetAmount
            case freeBetAmount
            case currency
            case maxWinning
            case possibleProfit
            case stakeBackOptions
            case betStakeBack
            case totalPriceValue
            case numberOfSelections
            case status
            case statusLabel
            case placedDate
            case settledDate
            case placementStatusConfirmedDate
            case freeBet
            case oddsBoost
            case betBuilder
            case mbaBet
            case eachWay
            case currentPossibleWinning
            case totalBalanceImpact
            case terminalType
            case totalBetAmountTax
            case totalBetAmountEurTax
            case totalBetAmountNetto
            case maxWinningTax
            case maxWinningNetto
            case betPayoutTax
            case totalPayoutTax
            case betStakeNet
            case betStakeNetEur
            case partialCashOuts
            case betRemainingStake
            case overallBetReturns
            case overallCashoutAmount
            case cashOutDate
            case totalPriceValueByBetStatus
            case betNetReturns
            case potentialNetReturns
            case potentialWinTax
            case taxEnabled
            case pendingCashOutStatus
            case betPlacementStatus
            case betSettlementStatus
            case paymentTime
            case ticketCode
            case paymentStatus
            case bonusWalletId
            case hasBonusMoney
            case realStake
            case bonusStake
        }
    }

    struct BetSelection: Codable {
        let id: String?
        let outcomeId: String?
        let status: String?
        let initialPriceValue: Double?
        let priceValue: Double?
        let betBuilderOdds: Double?
        let initialBetBuilderOdds: Double?
        let sportId: String?
        let sportName: String?
        let sportParentId: String?
        let sportParentName: String?
        let tournamentId: String?
        let tournamentName: String?
        let eventId: String?
        let eventTypeId: String?
        let eventName: String?
        let eventIsLiveTournament: Bool?
        let eventScoreAtPlaceBet: String?
        let homeParticipantId: String?
        let awayParticipantId: String?
        let homeParticipantName: String?
        let awayParticipantName: String?
        let homeParticipantLogoUrl: String?
        let awayParticipantLogoUrl: String?
        let eventDate: String?
        let bettingTypeId: String?
        let bettingTypeName: String?
        let marketName: String?
        let isLive: Bool?
        let eventStatusId: String?
        let actualBetBuilderGroupSettlementStatus: String?
        let exchangeRateTimestamp: String?
        let banker: Bool?
        let cashOutDate: String?
        let cashOutOdds: Double?
        let cashOutBetBuilderOdds: Double?
        let priceValueByStatus: Double?
        let eachWay: String?
        let earlySettlement: String?
        let earlySettlementDate: String?
        let earlySettlementOption: EarlySettlementOption?
        let eventTemplateName: String?
        let boreDrawOption: String?
        let venueId: String?
        let venueName: String?
        let bettingTypeEventPartId: String?
        let bettingTypeEventPartName: String?
        let betName: String?
        let shortBetName: String?
        
        
        enum CodingKeys: String, CodingKey {
            case id
            case outcomeId
            case status
            case initialPriceValue
            case priceValue
            case betBuilderOdds
            case initialBetBuilderOdds
            case sportId
            case sportName
            case sportParentId
            case sportParentName
            case tournamentId
            case tournamentName
            case eventId
            case eventTypeId
            case eventName
            case eventIsLiveTournament
            case eventScoreAtPlaceBet
            case homeParticipantId
            case awayParticipantId
            case homeParticipantName
            case awayParticipantName
            case homeParticipantLogoUrl
            case awayParticipantLogoUrl
            case eventDate
            case bettingTypeId
            case bettingTypeName
            case marketName
            case isLive
            case eventStatusId
            case actualBetBuilderGroupSettlementStatus
            case exchangeRateTimestamp
            case banker
            case cashOutDate
            case cashOutOdds
            case cashOutBetBuilderOdds
            case priceValueByStatus
            case eachWay
            case earlySettlement
            case earlySettlementDate
            case earlySettlementOption
            case eventTemplateName
            case boreDrawOption
            case venueId
            case venueName
            case bettingTypeEventPartId
            case bettingTypeEventPartName
            case betName
            case shortBetName
        }
    }

}
