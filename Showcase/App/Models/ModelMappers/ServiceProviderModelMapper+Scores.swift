//
//  ServiceProviderModelMapper+Scores.swift
//  Sportsbook
//
//  Created by Ruben Roques on 03/04/2024.
//

import Foundation
import ServicesProvider

extension ServiceProviderModelMapper {
    static func scoresDictionary(fromInternalScoresDictionary internalScores: [String: ServicesProvider.Score]) -> [String: Score] {
        return internalScores.mapValues(Self.score(fromInternalScore:))
    }
    
    static func scores(fromInternalScores internalScores: [ServicesProvider.Score]) -> [Score] {
        return internalScores.map(Self.score(fromInternalScore:))
    }
    
    static func score(fromInternalScore internalScore: ServicesProvider.Score) -> Score {
        switch internalScore {

        case .set(index: let index, home: let home, away: let away):
            return Score.set(index: index, home: home, away: away)
        case .gamePart(index: let index, home: let home, away: let away):
            return Score.gamePart(index: index, home: home, away: away)
        case .matchFull(home: let home, away: let away):
            return Score.matchFull(home: home, away: away)
        }

    }
}
