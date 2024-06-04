//
//  Score.swift
//
//
//  Created by Ruben Roques on 03/04/2024.
//

import Foundation

extension SportRadarModels {
    
    enum Score: Codable, Hashable {
        case set(index: Int, home: Int?, away: Int?)
        case gamePart(home: Int?, away: Int?)
        case matchFull(home: Int?, away: Int?)
        
        enum CompetitorCodingKeys: String, CodingKey {
            case competitor = "COMPETITOR"
            case home
            case away
        }
        
        init?(stringValue: String, homeScore: Int?, awayScore: Int?) {
            guard
                let scoreCodingKeys = ScoreCodingKeys(stringValue: stringValue)
            else {
                return nil
            }
            
            switch scoreCodingKeys {
            case .gameScore:
                self = .gamePart(home: homeScore, away: awayScore)
            case .currentScore:
                self = .matchFull(home: homeScore, away: awayScore)
            case .matchScore:
                self = .matchFull(home: homeScore, away: awayScore)
            case .periodScore(let index):
                self = .set(index: index, home: homeScore, away: awayScore)
            case .setScore(let index):
                self = .set(index: index, home: homeScore, away: awayScore)
            }
        }
        
        init(from container: KeyedDecodingContainer<CompetitorCodingKeys>, key: ScoreCodingKeys) throws {
            let homeScoreValue: Int
            let awayScoreValue: Int
            
            if let competitorContainer = try? container.nestedContainer(keyedBy: CompetitorCodingKeys.self, forKey: .competitor) {
                homeScoreValue = try competitorContainer.decode(Int.self, forKey: .home)
                awayScoreValue = try competitorContainer.decode(Int.self, forKey: .away)
            }
            else {
                homeScoreValue = try container.decode(Int.self, forKey: .home)
                awayScoreValue = try container.decode(Int.self, forKey: .away)
            }
            
            switch key {
            case .matchScore, .currentScore:
                self = .matchFull(home: homeScoreValue, away: awayScoreValue)
            case .gameScore:
                self = .gamePart(home: homeScoreValue, away: awayScoreValue)
            case .periodScore(let index), .setScore(let index):
                self = .set(index: index, home: homeScoreValue, away: awayScoreValue)
            }
        }
        
        var sortValue: Int {
            switch self {
            case .set(let index, _, _):
                return index
            case .gamePart:
                return 100
            case .matchFull:
                return 200
            }
        }
        
        var key: String {
            switch self {
            case .set(let index, _, _):
                return "set\(index)"
            case .gamePart:
                return "gamePart"
            case .matchFull:
                return "matchFull"
            }
        }
        
    }
    
    
    enum ScoreCodingKeys: CodingKey {
        case gameScore
        case currentScore
        case matchScore
        case periodScore(Int)
        case setScore(Int)
        
        init?(stringValue: String) {
            switch stringValue {
            case "GAME_SCORE":
                self = .gameScore
            case "CURRENT_SCORE":
                self = .currentScore
            case "MATCH_SCORE":
                self = .matchScore
            default:
                if let number = Self.extractNumber(from: stringValue, pattern: "PERIOD(\\d+)_SCORE") {
                    self = .periodScore(number)
                } else if let number = Self.extractNumber(from: stringValue, pattern: "SET(\\d+)_SCORE") {
                    self = .setScore(number)
                } else {
                    return nil
                }
            }
        }
        
        init?(intValue: Int) {
            return nil
        }
        
        var stringValue: String {
            switch self {
            case .gameScore:
                return "GAME_SCORE"
            case .currentScore:
                return "CURRENT_SCORE"
            case .matchScore:
                return "MATCH_SCORE"
            case .periodScore(let number):
                return "PERIOD\(number)_SCORE"
            case .setScore(let number):
                return "SET\(number)_SCORE"
            }
        }
        
        var intValue: Int? {
            switch self {
            case .periodScore(let number), .setScore(let number):
                return number
            default:
                return nil
            }
        }
        
        private static func extractNumber(from string: String, pattern: String) -> Int? {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
                return nil
            }
            let matches = regex.matches(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
            guard let match = matches.first else {
                return nil
            }
            let range = match.range(at: 1)
            guard let swiftRange = Range(range, in: string) else {
                return nil
            }
            return Int(string[swiftRange])
        }
    }
}


extension SportRadarModels {
    enum ActivePlayerServe: String, Codable {
        case home
        case away
    }
}
