//
//  EveryMatrixSportPatterns.swift
//  ServicesProvider
//
//  Created by Claude Code on 16/11/2025.
//

import Foundation

/// Pattern matching utilities for EveryMatrix EVENT_INFO processing
/// Ported from Betsson Cameroon web app logic (constants.js)
///
/// This struct provides:
/// - Sport template mappings for 48 sports
/// - Regex pattern matching for score part identification
/// - Ordinal number extraction from event part names
struct EveryMatrixSportPatterns {

    // MARK: - Score Templates

    enum ScoreTemplate {
        /// BASIC: Only whole match score (9 sports)
        /// Used by: Football, Rugby, MMA, Boxing, etc.
        case basic

        /// SIMPLE: Whole match + all active periods/quarters/innings/sets (18 sports)
        /// Used by: Basketball, Ice Hockey, Baseball, Volleyball, etc.
        case simple

        /// DETAILED: Tennis-specific with sets + current game points
        /// Used by: Tennis only
        case detailed

        /// DEFAULT: Fallback for unknown sports - just whole match score
        case `default`
    }

    // MARK: - Sport IDs (48 Sports)

    // BASIC template sports
    static let FOOTBALL = "1"
    static let GOLF = "2"
    static let RUGBY_LEAGUE = "28"
    static let AFL = "38"
    static let RUGBY_UNION = "39"
    static let GAELIC_FOOTBALL = "47"
    static let FUTSAL = "49"
    static let VIRTUAL_FOOTBALL = "86"
    static let BOXING = "176"
    static let MMA = "177"

    // SIMPLE template sports
    static let TENNIS = "3"
    static let AMERICAN_FOOTBALL = "5"
    static let ICE_HOCKEY = "6"
    static let HANDBALL = "7"
    static let BASKETBALL = "8"
    static let BASEBALL = "9"
    static let BADMINTON = "14"
    static let VOLLEYBALL = "20"
    static let WATER_POLO = "22"
    static let CRICKET = "26"
    static let SNOOKER = "36"
    static let BANDY = "40"
    static let FLOORBALL = "41"
    static let DARTS = "45"
    static let TABLE_TENNIS = "63"
    static let BEACH_VOLLEYBALL = "64"
    static let SQUASH = "76"
    static let VIRTUAL_BASKETBALL = "157"
    static let VIRTUAL_ICE_HOCKEY = "158"

    // MARK: - Sport → Template Mapping

    /// Maps sportId to appropriate score template
    /// Covers 48 sports from EveryMatrix API
    static let sportTemplateMap: [String: ScoreTemplate] = [
        // BASIC (9 sports) - Only whole match score
        "1": .basic,    // Football
        "49": .basic,   // Futsal
        "39": .basic,   // Rugby Union
        "28": .basic,   // Rugby League
        "38": .basic,   // AFL
        "47": .basic,   // Gaelic Football
        "177": .basic,  // MMA
        "176": .basic,  // Boxing
        "86": .basic,   // Virtual Football

        // SIMPLE (18 sports) - Whole match + all active periods
        "8": .simple,   // Basketball (quarters)
        "6": .simple,   // Ice Hockey (periods)
        "7": .simple,   // Handball (halves)
        "5": .simple,   // American Football (quarters)
        "22": .simple,  // Water Polo (quarters)
        "41": .simple,  // Floorball (periods)
        "40": .simple,  // Bandy (halves)
        "9": .simple,   // Baseball (innings)
        "26": .simple,  // Cricket (innings)
        "20": .simple,  // Volleyball (sets)
        "64": .simple,  // Beach Volleyball (sets)
        "63": .simple,  // Table Tennis (sets)
        "14": .simple,  // Badminton (sets)
        "76": .simple,  // Squash (sets)
        "45": .simple,  // Darts (legs/sets)
        "36": .simple,  // Snooker (frames)
        "157": .simple, // Virtual Basketball
        "158": .simple, // Virtual Ice Hockey

        // DETAILED (1 sport) - Tennis special handling
        "3": .detailed  // Tennis (sets + current game points + serve)
    ]

    // MARK: - Regex Pattern Matching

    /// Check if eventPartName matches "Whole Match" pattern
    /// Examples: "Whole Match", "whole match"
    static func isWholeMatch(_ text: String) -> Bool {
        text.range(of: #"whole\s+match"#, options: [.regularExpression, .caseInsensitive]) != nil
    }

    /// Check if eventPartName matches set pattern (tennis, volleyball, etc.)
    /// Examples: "1st Set", "2nd Set", "3rd Set"
    ///
    /// IMPORTANT: Excludes game entries like "4th Game (2nd Set)" which contain "set" in the name
    /// but are actually game scores, not set scores. These should be filtered by statusId in game processing.
    static func isSet(_ text: String) -> Bool {
        let matchesPattern = text.range(of: #"\d+(st|nd|rd|th)\s+set"#, options: [.regularExpression, .caseInsensitive]) != nil
        let isGameEntry = text.lowercased().contains("game")
        return matchesPattern && !isGameEntry
    }

    /// Check if eventPartName matches quarter pattern (basketball, american football)
    /// Examples: "1st Quarter", "2nd Quarter", "3rd Quarter", "4th Quarter"
    static func isQuarter(_ text: String) -> Bool {
        text.range(of: #"\d+(st|nd|rd|th)\s+quarter"#, options: [.regularExpression, .caseInsensitive]) != nil
    }

    /// Check if eventPartName matches period pattern (ice hockey, floorball)
    /// Examples: "1st Period", "2nd Period", "3rd Period"
    static func isPeriod(_ text: String) -> Bool {
        text.range(of: #"\d+(st|nd|rd|th)\s+period"#, options: [.regularExpression, .caseInsensitive]) != nil
    }

    /// Check if eventPartName matches inning pattern (baseball, cricket)
    /// Examples: "1st Inning", "2nd Inning", "9th Inning"
    static func isInning(_ text: String) -> Bool {
        text.range(of: #"\d+(st|nd|rd|th)\s+inning"#, options: [.regularExpression, .caseInsensitive]) != nil
    }

    /// Check if eventPartName matches game pattern (tennis current game)
    /// Examples: "1st Game", "2nd Game"
    static func isGame(_ text: String) -> Bool {
        text.range(of: #"\d+(st|nd|rd|th)\s+game"#, options: [.regularExpression, .caseInsensitive]) != nil
    }

    /// Check if eventPartName matches tie-break pattern
    /// Examples: "Tie-Break", "tie break", "Tie Break"
    static func isTieBreak(_ text: String) -> Bool {
        text.range(of: #"tie[-\s]?break"#, options: [.regularExpression, .caseInsensitive]) != nil
    }

    // MARK: - Ordinal Number Extraction

    /// Extract ordinal number from text
    /// - Parameter text: Event part name with ordinal number
    /// - Returns: Extracted number, defaults to 1 if extraction fails
    ///
    /// Examples:
    /// - "2nd Quarter" → 2
    /// - "3rd Set" → 3
    /// - "1st Inning" → 1
    static func extractOrdinalNumber(from text: String) -> Int {
        let pattern = #"\d+"#
        guard let range = text.range(of: pattern, options: .regularExpression),
              let number = Int(text[range]) else {
            return 1  // Default to 1 if extraction fails
        }
        return number
    }
}
