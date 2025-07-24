//
//  Match.swift
//  BetssonCameroonApp
//
//  Created by Ruben Roques on 21/07/2025.
//

import Foundation

struct Match: Hashable {
    
    var id: String
    var competitionId: String
    var competitionName: String
    var homeParticipant: Participant
    var awayParticipant: Participant
    var date: Date?
    
    var sport: Sport
    var sportIdCode: String?
    
    var venue: Location?
    var numberTotalOfMarkets: Int
    var markets: [Market]
    var rootPartId: String
    var sportName: String?
    
    var status: Status
    
    var homeParticipantScore: Int?
    var awayParticipantScore: Int?
    
    var matchTime: String?
    
    var promoImageURL: String?
    var oldMainMarketId: String?
    
    var trackableReference: String?
    
    var competitionOutright: Competition?
    
    var detailedScores: [String: Score]?
    
    var activePlayerServe: ActivePlayerServe?
    
    var detailedStatus: String {
        switch self.status {
        case .unknown:
            return ""
        case .notStarted:
            let translatedStatus = localized("live_status_starting_soon")
            return translatedStatus
            
        case .inProgress(let details):
            let translatedStatus = "live_status_" + details
            return localized(translatedStatus)
        case .ended:
            let translatedStatus = localized("live_status_ended")
            return translatedStatus
        }
        
    }
    
    enum Status: Hashable {
        case unknown
        case notStarted
        case inProgress(String)
        case ended
    }
    
    enum ActivePlayerServe: String, Codable, Hashable {
        case home
        case away
    }
    
    init(id: String,
         competitionId: String,
         competitionName: String,
         homeParticipant: Participant,
         awayParticipant: Participant,
         homeParticipantScore: Int? = nil,
         awayParticipantScore: Int? = nil,
         date: Date? = nil,
         sport: Sport,
         sportIdCode: String?,
         venue: Location? = nil,
         numberTotalOfMarkets: Int,
         markets: [Market],
         rootPartId: String,
         status: Status,
         trackableReference: String? = nil,
         matchTime: String? = nil,
         promoImageURL: String? = nil,
         oldMainMarketId: String? = nil,
         competitionOutright: Competition? = nil,
         activePlayerServe: ActivePlayerServe? = nil,
         detailedScores: [String: Score]? = nil) {
        
        self.id = id
        self.competitionId = competitionId
        self.competitionName = competitionName
        self.homeParticipant = homeParticipant
        self.awayParticipant = awayParticipant
        self.homeParticipantScore = homeParticipantScore
        self.awayParticipantScore = awayParticipantScore
        self.date = date
        
        self.sport = sport
        self.sportIdCode = sportIdCode
        
        self.trackableReference = trackableReference
        
        self.venue = venue
        self.numberTotalOfMarkets = numberTotalOfMarkets
        self.markets = markets
        self.rootPartId = rootPartId
        self.status = status
        self.matchTime = matchTime
        
        self.promoImageURL = promoImageURL
        self.oldMainMarketId = oldMainMarketId
        
        self.competitionOutright = competitionOutright
        self.detailedScores = detailedScores
    }
    
}

extension Match.Status {
    
    var isPreLive: Bool {
        switch self {
        case .unknown:
            return false
        case .notStarted:
            return true
        case .inProgress:
            return false
        case .ended:
            return false
        }
    }
    
    var isLive: Bool {
        switch self {
        case .unknown:
            return false
        case .notStarted:
            return false
        case .inProgress:
            return true
        case .ended:
            return false
        }
    }
    
    var isPostLive: Bool {
        switch self {
            
        case .unknown:
            return false
        case .notStarted:
            return false
        case .inProgress:
            return false
        case .ended:
            return true
        }
    }
}
