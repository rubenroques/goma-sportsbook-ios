//
//  File.swift
//
//
//  Created by Ruben Roques on 19/01/2024.
//

import Foundation

extension GomaModelMapper {
    
    static func betTypes(fromGomaBetTypes betTypes: [GomaModels.BetType]) -> [BetType] {
        return betTypes.map(Self.betType(fromGomaBetType:))
    }
    
    static func betType(fromGomaBetType betType: GomaModels.BetType) -> BetType {
        
        var numberOfBets: Int = 0
        var betGroupingType: BetGroupingType = .single(identifier: betType.identifier)
        
        switch betType {
        case .single:
            numberOfBets = 1
            betGroupingType = .single(identifier: betType.identifier)
        case .multiple:
            numberOfBets = .max
            betGroupingType = .multiple(identifier: betType.identifier)
        case .system:
            betGroupingType = .system(identifier: betType.identifier, name: betType.name, numberOfBets: 1)
        }
        
        return BetType(name: betType.name,
                       grouping: betGroupingType,
                       code: betType.identifier,
                       numberOfBets: numberOfBets,
                       potencialReturn: 0.0,
                       totalStake: nil)
    }
    
    static func gomaBetType(fromBetGroupingType betGroupingType: BetGroupingType) -> GomaModels.BetType {
        
        switch betGroupingType {
        case .single:
            return .single
        case .multiple:
            return .multiple
        case .system(let identifier, let name, _):
            return .system(type: GomaModels.SystemBetType(type: identifier, label: name))
        }
        
    }
    
    static func placedBetsResponse(fromPlaceBetTicketsResponses placeBetTicketsResponses: [GomaModels.PlaceBetTicketResponse] ) -> PlacedBetsResponse {
        let bets = placeBetTicketsResponses.map(Self.bet(fromPlaceBetTicketResponse:))
        let totalStake = placeBetTicketsResponses.map(\.stake).reduce(1, *)
        return PlacedBetsResponse(identifier: "", bets: [], detailedBets: bets, requiredConfirmation: false, totalStake: totalStake)
    }
    
//
//    static func placedBetsResponse(fromPlaceBetTicketResponse placedBet :GomaModels.PlaceBetTicketResponse) -> PlacedBetsResponse {
//        
//        
//        let selections = placedBet.selections.map({
//            Self.betSelection(fromMyTicketSelection: $0)
//        })
//        
//        let bet = Self.bet(fromMyTicket: myTicket)
//        return PlacedBetsResponse(identifier: "\(myTicket.id)", bets: [], detailedBets: [bet])
//    }
//    
    static func placedBetsResponse(fromMyTicket myTicket :GomaModels.MyTicket) -> PlacedBetsResponse {
        let bet = Self.bet(fromMyTicket: myTicket)
        return PlacedBetsResponse(identifier: "\(myTicket.id)", bets: [], detailedBets: [bet], requiredConfirmation: false, totalStake: bet.stake)
    }
        
    static func bet(fromPlaceBetTicketResponse placeBetTicketResponse: GomaModels.PlaceBetTicketResponse) -> Bet {
        
        let betState = BetState(rawValue: placeBetTicketResponse.status) ?? .undefined

        
        let selections = placeBetTicketResponse.selections.map({
            Self.betSelection(fromMyTicketSelection: $0)
        })
        
        var betDate = Date()
        let dateString = placeBetTicketResponse.createdAt ?? ""

        // Attempt to parse the string into a Date object
        if let date = Self.parseDateString(dateString: dateString) {
            betDate = date
        }
                
        return Bet(identifier: "\(placeBetTicketResponse.id)",
                   type: placeBetTicketResponse.type,
                   state: betState,
                   result: .notSpecified,
                   globalState: betState,
                   stake: placeBetTicketResponse.stake,
                   totalOdd: placeBetTicketResponse.odds,
                   currency: "EUR",
                   selections: selections,
                   potentialReturn: placeBetTicketResponse.possibleWinnings,
                   date: betDate,
                   freebet: false,
                   shareId: placeBetTicketResponse.shareId)
        
    }
    
}
