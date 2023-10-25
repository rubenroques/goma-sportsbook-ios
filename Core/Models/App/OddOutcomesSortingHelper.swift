//
//  OddOutcomesSortingHelper.swift
//  Sportsbook
//
//  Created by Ruben Roques on 27/03/2023.
//

import Foundation

struct OddOutcomesSortingHelper {

    static func sortValueForOutcome(_ key: String) -> Int {
        switch key.lowercased() {
        case "yes": return 10
        case "no": return 20

        case "oui": return 10
        case "non": return 20
            
        case "home": return 10
        case "draw": return 20
        case "none": return 21
        case "": return 22
        case "away": return 30
            
        case "domicile": return 10
        case "nul": return 20
        case "aucun": return 21
        case "extérieur": return 30

        case "home_draw": return 10
        case "home_away": return 20
        case "away_draw": return 30

        case "over": return 10
        case "under": return 20

        case "plus": return 10
        case "moins": return 20

        case "odd": return 10
        case "even": return 20

        case "impair": return 10
        case "pair": return 20
            
        case "exact": return 10
        case "range": return 20
        case "more_than": return 30

        case "in_90_minutes": return 10
        case "in_extra_time": return 20
        case "on_penalties": return 30

        case "home-true": return 10
        case "home-false": return 15
        case "-true": return 20
        case "-false": return 25
        case "away-true": return 30
        case "away-false": return 35

        case "home_draw-true": return 10
        case "home_draw-false": return 15
        case "home_away-true": return 20
        case "home_away-false": return 25
        case "away_draw-true": return 30
        case "away_draw-false": return 35

        case "over-true": return 10
        case "over-false": return 15
        case "under-true": return 20
        case "under-false": return 25

        case "odd-true": return 10
        case "odd-false": return 15
        case "even-true": return 20
        case "even-false": return 25

        case "yes-true": return 10
        case "yes-false": return 15
        case "no-true": return 20
        case "no-false": return 25

        case "true": return 10
        case "false": return 20

        case "h": return 10
        case "d": return 20
        case "a": return 30

        default:
            return 1000
        }
    }

}
