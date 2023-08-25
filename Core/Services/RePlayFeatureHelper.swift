//
//  RePlayFeatureHelper.swift
//  Sportsbook
//
//  Created by Ruben Roques on 24/08/2023.
//

import Foundation

struct RePlayFeatureHelper {

    static func shouldShowRePlay(forMatch match: Match) -> Bool {
            let matchSport = match.sport.alphaId ?? ""
            return TargetVariables.hasFeatureEnabled(feature: .cashback) &&
            match.status == .notStarted &&
            Env.businessSettingsSocket.clientSettings.replaySportsCodes.contains(matchSport)
    }

    static func shouldShowRePlay(forSport sport: Sport) -> Bool {
            let matchSport = sport.alphaId ?? ""
            return TargetVariables.hasFeatureEnabled(feature: .cashback) &&
            Env.businessSettingsSocket.clientSettings.replaySportsCodes.contains(matchSport)
    }

}
