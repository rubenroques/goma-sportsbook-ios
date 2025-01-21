//
//  EventLiveDataExtended.swift
//
//
//  Created by Ruben Roques on 03/04/2024.
//

import Foundation

extension SportRadarModels {
    
    struct EventLiveDataExtended: Codable {
        var id: String
        
        var homeScore: Int?
        var awayScore: Int?
        
        var matchTime: String?
        var status: EventStatus?
        
        var scores: [String: Score]
        
        var activePlayerServing: ActivePlayerServe?
        
        enum CodingKeys: String, CodingKey {
            case targetEventId = "targetEventId"
            case attributedContainer = "attributes"
            case completeContainer = "COMPLETE"
            case currentScoreContainer = "CURRENT_SCORE"
            case competitorContainer = "COMPETITOR"
            case servingContainer = "SERVE"
            case statusContainer = "STATUS"
            case eventContainer = "EVENT"
            case emptyContainer = ""
            case matchScoreContainer = "MATCH_SCORE"
            case homeScore = "home"
            case awayScore = "away"
            case eventStatus = "status"
            case matchTime = "matchTime"
        }
        
        init(id: String,
             homeScore: Int?,
             awayScore: Int?,
             matchTime: String?,
             status: EventStatus?,
             scores: [String: Score],
             activePlayerServing: ActivePlayerServe?
        ) {
            self.id = id
            self.homeScore = homeScore
            self.awayScore = awayScore
            self.matchTime = matchTime
            self.status = status
            self.scores = scores
            self.activePlayerServing = activePlayerServing
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = (try? container.decode(String.self, forKey: .targetEventId)) ?? "000"
            
            self.matchTime = nil
            if let fullMatchTime = try container.decodeIfPresent(String.self, forKey: .matchTime),
               let minutesPart = SocketMessageParseHelper.extractMatchMinutes(from: fullMatchTime) {
                self.matchTime = minutesPart
            }
            
            //
            // Status
            self.status = nil
            if let attributesContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributedContainer),
               let completeContainer = try? attributesContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .completeContainer),
               let statusContainer = try? completeContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .statusContainer),
               let eventContainer = try? statusContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .eventContainer) {
                let statusValue =  try eventContainer.decode(String.self, forKey: .emptyContainer)
                self.status = EventStatus.init(value: statusValue)
            }
            
            //
            // Scores
            self.homeScore = nil
            self.awayScore = nil
            
            self.scores = [:]
            
            //
            // Serving Player
            self.activePlayerServing = nil
            if let attributesContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributedContainer),
               let completeContainer = try? attributesContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .completeContainer),
               let servingContainer = try? completeContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .servingContainer),
               let eventContainer = try? servingContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .eventContainer)
            {
                if let activePlayerServingInt =  try? eventContainer.decode(Int.self, forKey: .emptyContainer) {
                    if activePlayerServingInt == 1 {
                        self.activePlayerServing = .home
                    }
                    else if activePlayerServingInt == 2 {
                        self.activePlayerServing = .away
                    }
                }
                else if let activePlayerServingString =  try? eventContainer.decode(String.self, forKey: .emptyContainer) {
                    if activePlayerServingString == "1" {
                        self.activePlayerServing = .home
                    }
                    else if activePlayerServingString == "2" {
                        self.activePlayerServing = .away
                    }
                }
                else {
                    self.activePlayerServing = nil
                }
            }
            
            
            // ----------------------------------------------------------------------------------------------------------------
            // Legacy scores
            if let attributesContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributedContainer),
               let completeContainer = try? attributesContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .completeContainer),
               let currentScoreContainer = try? completeContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .currentScoreContainer),
               let competitorContainer = try? currentScoreContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .competitorContainer) {
                
                if let homeScore = try? competitorContainer.decode(Int.self, forKey: .homeScore) {
                    self.homeScore = homeScore
                }
                if let awayScore = try? competitorContainer.decode(Int.self, forKey: .awayScore) {
                    self.awayScore = awayScore
                }
            }
            else if let attributesContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributedContainer),
                    let completeContainer = try? attributesContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .completeContainer),
                    let matchScoreContainer = try? completeContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .matchScoreContainer),
                    let competitorContainer = try? matchScoreContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .competitorContainer) {
                
                if let homeScore = try? competitorContainer.decode(Int.self, forKey: .homeScore) {
                    self.homeScore = homeScore
                }
                if let awayScore = try? competitorContainer.decode(Int.self, forKey: .awayScore) {
                    self.awayScore = awayScore
                }
            }
            // ----------------------------------------------------------------------------------------------------------------
            
            //
            // New scores logic
            let attributesContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributedContainer)
            let completeContainer = try attributesContainer.nestedContainer(keyedBy: ScoreCodingKeys.self, forKey: .completeContainer)
            
            let scoresArray = try completeContainer.allKeys.compactMap { key -> Score? in
                let container = try completeContainer.nestedContainer(keyedBy: Score.CompetitorCodingKeys.self, forKey: key)
                return try Score(from: container, key: key)
            }
            
            self.scores = Dictionary(uniqueKeysWithValues: scoresArray.map { ($0.key, $0) })
            
            //
            if self.matchTime == nil, self.status == nil, self.homeScore == nil,
               self.awayScore == nil, self.scores.isEmpty, self.activePlayerServing == nil
            {
                let context = DecodingError.Context(codingPath: [CodingKeys.attributedContainer], debugDescription: "No parsed content found on EventLiveDataExtended")
                throw DecodingError.valueNotFound(ContentRoute.self, context)
            }
            
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(id, forKey: .targetEventId)
            
            var attributesContainer = container.nestedContainer(keyedBy: CodingKeys.self, forKey: .attributedContainer)
            var completeContainer = attributesContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .completeContainer)
            var statusContainer = completeContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .statusContainer)
            // var eventContainer = statusContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .eventContainer)
            
            var currentScoreContainer = completeContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .currentScoreContainer)
            var competitorContainer = currentScoreContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .competitorContainer)
            
            try competitorContainer.encode(homeScore, forKey: .homeScore)
            try competitorContainer.encode(awayScore, forKey: .awayScore)
            
            try container.encode(matchTime, forKey: .matchTime)
        }
        
    }
    
}
