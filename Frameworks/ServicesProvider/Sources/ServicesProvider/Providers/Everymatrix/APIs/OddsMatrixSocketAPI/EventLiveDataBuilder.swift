//
//  EventLiveDataBuilder.swift
//  ServicesProvider
//
//  Created by Claude Code on 16/11/2025.
//

import Foundation

/// Stateless utility for building EventLiveData from EveryMatrix EventInfo DTOs
///
/// This builder is shared across all subscription managers that need to transform
/// EventInfo entities into EventLiveData:
/// - LiveMatchesPaginator
/// - MatchDetailsManager
/// - Any other future subscription managers
///
/// Ported from Betsson Cameroon web app EVENT_INFO processing logic.
///
/// Supports:
/// - 48 sports via template system (BASIC, SIMPLE, DETAILED, DEFAULT)
/// - 7 EVENT_INFO types: SCORE (1), YELLOW_CARDS (2), YELLOW_RED_CARDS (3),
///   RED_CARDS (4), SERVE (37), EVENT_STATUS (92), MATCH_TIME (95)
/// - Pattern-based score part matching (quarters, periods, innings, sets, games)
/// - Participant ID mapping for correct home/away assignment
/// - Active period filtering (only show live periods, hide completed ones)
struct EventLiveDataBuilder {

    // MARK: - Public API

    /// Build EventLiveData from EventInfo DTOs and optional MatchDTO
    ///
    /// - Parameters:
    ///   - eventId: Match event ID
    ///   - eventInfos: Array of EVENT_INFO entities from WebSocket (typeId determines type)
    ///   - matchData: Optional MatchDTO for participant mapping and sportId determination
    /// - Returns: Complete EventLiveData with scores, cards, time, status, serve
    ///
    /// Example usage:
    /// ```swift
    /// let eventInfos = eventInfoStore.observeEventInfosForEvent(eventId: "123")
    /// let matchData = eventInfoStore.get(EveryMatrix.MatchDTO.self, id: "123")
    /// let liveData = EventLiveDataBuilder.buildEventLiveData(
    ///     eventId: "123",
    ///     from: eventInfos,
    ///     matchData: matchData
    /// )
    /// ```
    static func buildEventLiveData(
        eventId: String,
        from eventInfos: [EveryMatrix.EventInfoDTO],
        matchData: EveryMatrix.MatchDTO?
    ) -> EventLiveData {

        print("[LIVE_SCORE] 🏗️ Building EventLiveData for event: \(eventId)")
        print("[LIVE_SCORE]    Match: \(matchData?.homeParticipantName ?? "?") vs \(matchData?.awayParticipantName ?? "?")")
        print("[LIVE_SCORE]    EventInfos count: \(eventInfos.count)")

        // Step 1: Determine sport template (default to .default for unknown sports)
        let sportId = matchData?.sportId ?? ""
        let template = EveryMatrixSportPatterns.sportTemplateMap[sportId] ?? .default
        print("[LIVE_SCORE]    Sport ID: \(sportId), Template: \(template)")

        // Step 2: Initialize data containers
        var homeScore: Int?
        var awayScore: Int?
        var matchTimeMinutes: Int?
        var status: EventStatus?
        var detailedScores: [String: Score] = [:]
        var activePlayerServing: ActivePlayerServe?

        var yellowCards: FootballCards?
        var yellowRedCards: FootballCards?
        var redCards: FootballCards?

        // Step 3: Process each EVENT_INFO by typeId
        for info in eventInfos {
            switch info.typeId {
            case "1":  // SCORE
                processScore(info, matchData, template, &detailedScores, &homeScore, &awayScore)

            case "2":  // YELLOW_CARDS
                yellowCards = extractCards(info, matchData)
                if let cards = yellowCards {
                    print("[LIVE_SCORE] ⚡ YELLOW_CARDS extracted: home=\(cards.home?.description ?? "nil"), away=\(cards.away?.description ?? "nil")")
                }

            case "3":  // YELLOW_RED_CARDS
                yellowRedCards = extractCards(info, matchData)
                if let cards = yellowRedCards {
                    print("[LIVE_SCORE] ⚡ YELLOW_RED_CARDS extracted: home=\(cards.home?.description ?? "nil"), away=\(cards.away?.description ?? "nil")")
                }

            case "4":  // RED_CARDS
                redCards = extractCards(info, matchData)
                if let cards = redCards {
                    print("[LIVE_SCORE] ⚡ RED_CARDS extracted: home=\(cards.home?.description ?? "nil"), away=\(cards.away?.description ?? "nil")")
                }

            case "37": // SERVE (tennis, table tennis, badminton, volleyball)
                activePlayerServing = extractServe(info, matchData)

            case "92": // EVENT_STATUS
                status = extractEventStatus(info)

            case "95": // MATCH_TIME (minutes elapsed)
                matchTimeMinutes = extractMatchTime(info)

            default:
                break
            }
        }

        // Step 4: Format match time
        let formattedMatchTime: String?
        if let minutes = matchTimeMinutes {
            formattedMatchTime = "\(minutes)'"
        } else {
            formattedMatchTime = nil
        }

        // Step 5: Log final result
        print("[LIVE_SCORE] ✅ EventLiveData built:")
        print("[LIVE_SCORE]    Score: \(homeScore?.description ?? "nil") - \(awayScore?.description ?? "nil")")
        print("[LIVE_SCORE]    DetailedScores count: \(detailedScores.count)")
        print("[LIVE_SCORE]    Yellow: \(yellowCards?.home?.description ?? "nil")-\(yellowCards?.away?.description ?? "nil")")
        print("[LIVE_SCORE]    YellowRed: \(yellowRedCards?.home?.description ?? "nil")-\(yellowRedCards?.away?.description ?? "nil")")
        print("[LIVE_SCORE]    Red: \(redCards?.home?.description ?? "nil")-\(redCards?.away?.description ?? "nil")")
        if let total = EventLiveData(
            id: eventId,
            homeScore: homeScore,
            awayScore: awayScore,
            matchTime: formattedMatchTime,
            status: status,
            detailedScores: detailedScores.isEmpty ? nil : detailedScores,
            activePlayerServing: activePlayerServing,
            yellowCards: yellowCards,
            yellowRedCards: yellowRedCards,
            redCards: redCards
        ).totalCards {
            print("[LIVE_SCORE]    Total cards: home=\(total.home), away=\(total.away)")
        }

        // Step 6: Return EventLiveData
        return EventLiveData(
            id: eventId,
            homeScore: homeScore,
            awayScore: awayScore,
            matchTime: formattedMatchTime,
            status: status,
            detailedScores: detailedScores.isEmpty ? nil : detailedScores,
            activePlayerServing: activePlayerServing,
            yellowCards: yellowCards,
            yellowRedCards: yellowRedCards,
            redCards: redCards
        )
    }

    // MARK: - Score Processing (Template Dispatcher)

    /// Main score processing dispatcher - routes to template-specific logic
    private static func processScore(
        _ info: EveryMatrix.EventInfoDTO,
        _ matchData: EveryMatrix.MatchDTO?,
        _ template: EveryMatrixSportPatterns.ScoreTemplate,
        _ detailedScores: inout [String: Score],
        _ homeScore: inout Int?,
        _ awayScore: inout Int?
    ) {
        switch template {
        case .basic:
            processBasicScore(info, matchData, &detailedScores, &homeScore, &awayScore)
        case .simple:
            processSimpleScore(info, matchData, &detailedScores, &homeScore, &awayScore)
        case .detailed:
            processDetailedScore(info, matchData, &detailedScores, &homeScore, &awayScore)
        case .default:
            processDefaultScore(info, matchData, &detailedScores, &homeScore, &awayScore)
        }
    }

    // MARK: - Template Implementations

    /// BASIC Template: Only whole match score
    ///
    /// Used by 9 sports: Football, Futsal, Rugby Union, Rugby League, AFL,
    /// Gaelic Football, MMA, Boxing, Virtual Football
    ///
    /// Business Logic: Viewers only care about total goals/points, not period breakdown
    ///
    /// Output example:
    /// ```
    /// detailedScores = ["Whole Match": .matchFull(home: 2, away: 1)]
    /// ```
    private static func processBasicScore(
        _ info: EveryMatrix.EventInfoDTO,
        _ matchData: EveryMatrix.MatchDTO?,
        _ detailedScores: inout [String: Score],
        _ homeScore: inout Int?,
        _ awayScore: inout Int?
    ) {
        guard let eventPartName = info.eventPartName else { return }

        // Only store "Whole Match" score
        if EveryMatrixSportPatterns.isWholeMatch(eventPartName) {
            let (home, away) = mapScoreToTeams(info, matchData)
            detailedScores[eventPartName] = .matchFull(home: home, away: away)
            homeScore = home
            awayScore = away
        }
        // All other periods (1st Half, 2nd Half, etc.) are ignored
    }

    /// SIMPLE Template: Whole match + ALL periods/quarters/innings/sets
    ///
    /// Used by 18 sports: Basketball, Ice Hockey, Baseball, Volleyball, Handball,
    /// American Football, Water Polo, Floorball, Bandy, Cricket, Beach Volleyball,
    /// Table Tennis, Badminton, Squash, Darts, Snooker, Virtual Basketball, Virtual Ice Hockey
    ///
    /// Business Logic: Each period is significant for betting. Show ALL periods/quarters/innings
    /// (both active and completed) to provide full score breakdown.
    ///
    /// Output example (Basketball):
    /// ```
    /// detailedScores = [
    ///   "Whole Match": .matchFull(home: 93, away: 74),
    ///   "Q1": .gamePart(home: 35, away: 18),  // Completed quarter
    ///   "Q2": .gamePart(home: 26, away: 32),  // Completed quarter
    ///   "Q3": .gamePart(home: 26, away: 21),  // Completed quarter
    ///   "Q4": .gamePart(home: 6, away: 3)     // Active quarter
    /// ]
    /// ```
    private static func processSimpleScore(
        _ info: EveryMatrix.EventInfoDTO,
        _ matchData: EveryMatrix.MatchDTO?,
        _ detailedScores: inout [String: Score],
        _ homeScore: inout Int?,
        _ awayScore: inout Int?
    ) {
        guard let eventPartName = info.eventPartName else { return }
        let (home, away) = mapScoreToTeams(info, matchData)

        // 1. Whole match total (always show)
        if EveryMatrixSportPatterns.isWholeMatch(eventPartName) {
            detailedScores[eventPartName] = .matchFull(home: home, away: away)
            homeScore = home
            awayScore = away
            return
        }

        // 2. Quarters (Basketball, American Football)
        if EveryMatrixSportPatterns.isQuarter(eventPartName) {
            let index = EveryMatrixSportPatterns.extractOrdinalNumber(from: eventPartName)
            detailedScores["Q\(index)"] = .gamePart(index: index, home: home, away: away)
            return
        }

        // 3. Periods (Ice Hockey, Floorball)
        if EveryMatrixSportPatterns.isPeriod(eventPartName) {
            let index = EveryMatrixSportPatterns.extractOrdinalNumber(from: eventPartName)
            detailedScores["P\(index)"] = .gamePart(index: index, home: home, away: away)
            return
        }

        // 4. Innings (Baseball, Cricket) - keep full name like "1st Inning"
        if EveryMatrixSportPatterns.isInning(eventPartName) {
            let index = EveryMatrixSportPatterns.extractOrdinalNumber(from: eventPartName)
            detailedScores[eventPartName] = .gamePart(index: index, home: home, away: away)
            return
        }

        // 5. Sets (Volleyball, Table Tennis, Badminton, Squash)
        // Note: Uses .set enum case (not .gamePart) to preserve set index
        if EveryMatrixSportPatterns.isSet(eventPartName) {
            let index = EveryMatrixSportPatterns.extractOrdinalNumber(from: eventPartName)
            detailedScores[eventPartName] = .set(index: index, home: home, away: away)
            return
        }
    }

    /// DETAILED Template: Whole match + completed sets + current game points
    ///
    /// Used by: Tennis only
    ///
    /// Business Logic:
    /// - Tennis has unique game→set→match hierarchy
    /// - Current game points (0, 15, 30, 40, 50=Advantage) are most important for live viewing
    /// - Show ALL sets (completed and active), but only the ACTIVE game
    /// - Filter out completed games (statusId "4") to avoid UI clutter
    /// - Tie-breaks not yet supported (excluded)
    ///
    /// Output example:
    /// ```
    /// detailedScores = [
    ///   "Whole Match": .matchFull(home: 2, away: 1),  // Sets won
    ///   "Game": .gamePart(home: 30, away: 15),        // Current game points
    ///   "1st Set": .set(index: 1, home: 6, away: 4),  // Completed set
    ///   "2nd Set": .set(index: 2, home: 3, away: 6),  // Completed set
    ///   "3rd Set": .set(index: 3, home: 2, away: 1)   // Active set
    /// ]
    /// activePlayerServing = .home
    /// ```
    private static func processDetailedScore(
        _ info: EveryMatrix.EventInfoDTO,
        _ matchData: EveryMatrix.MatchDTO?,
        _ detailedScores: inout [String: Score],
        _ homeScore: inout Int?,
        _ awayScore: inout Int?
    ) {
        guard let eventPartName = info.eventPartName else { return }
        let (home, away) = mapScoreToTeams(info, matchData)

        // 1. Whole match total (sets won)
        if EveryMatrixSportPatterns.isWholeMatch(eventPartName) {
            detailedScores[eventPartName] = .matchFull(home: home, away: away)
            homeScore = home
            awayScore = away
            return
        }

        // 2. Sets (1st Set, 2nd Set, 3rd Set)
        // Store ALL sets (active and completed) - tennis viewers want to see set history
        // Note: isSet() properly excludes game entries like "4th Game (2nd Set)"
        if EveryMatrixSportPatterns.isSet(eventPartName) {
            let index = EveryMatrixSportPatterns.extractOrdinalNumber(from: eventPartName)
            detailedScores[eventPartName] = .set(index: index, home: home, away: away)
            return
        }

        // 3. Current Game - ONLY if active (statusId "1") and NOT a tie-break
        // Filter completed games (statusId "4") - viewers don't need historical game scores
        if EveryMatrixSportPatterns.isGame(eventPartName) &&
           info.statusId == "1" &&
           !EveryMatrixSportPatterns.isTieBreak(eventPartName) {
            // Store current game points (0, 15, 30, 40, 50=Advantage)
            // Use key "Game" instead of "1st Game", "2nd Game" for simplicity
            detailedScores["Game"] = .gamePart(index: nil, home: home, away: away)
            return
        }

        // Ignore:
        // - Completed games (statusId "4")
        // - Tie-breaks (not yet supported)
    }

    /// DEFAULT Template: Fallback for sports not explicitly implemented
    ///
    /// This ensures unknown sports still get basic score display.
    /// Only shows whole match score, ignores all periods.
    ///
    /// Used by: Any sport not in sportTemplateMap (e.g., Golf, Motor Racing, etc.)
    ///
    /// Output example:
    /// ```
    /// detailedScores = ["Whole Match": .matchFull(home: nil, away: nil)]
    /// ```
    private static func processDefaultScore(
        _ info: EveryMatrix.EventInfoDTO,
        _ matchData: EveryMatrix.MatchDTO?,
        _ detailedScores: inout [String: Score],
        _ homeScore: inout Int?,
        _ awayScore: inout Int?
    ) {
        guard let eventPartName = info.eventPartName else { return }

        // Only store "Whole Match" score
        if EveryMatrixSportPatterns.isWholeMatch(eventPartName) {
            let (home, away) = mapScoreToTeams(info, matchData)
            detailedScores[eventPartName] = .matchFull(home: home, away: away)
            homeScore = home
            awayScore = away
        }
        // All other periods are ignored
    }

    // MARK: - Participant Mapping (CRITICAL)

    /// Map scores to correct teams using participant IDs
    ///
    /// **CRITICAL**: Never assume paramFloat1 is home score!
    /// EveryMatrix API does NOT guarantee home team first in parameters.
    ///
    /// The correct approach:
    /// 1. Check paramParticipantId1 against homeParticipantId/awayParticipantId
    /// 2. Assign paramFloat1 to the correct team based on ID match
    /// 3. Do the same for paramParticipantId2/paramFloat2
    ///
    /// Example from real API:
    /// ```
    /// MatchDTO:
    ///   homeParticipantId: "12345"
    ///   awayParticipantId: "67890"
    ///
    /// EventInfoDTO (Score):
    ///   paramParticipantId1: "67890"  // AWAY team first!
    ///   paramFloat1: 2.0
    ///   paramParticipantId2: "12345"  // HOME team second!
    ///   paramFloat2: 1.0
    ///
    /// Result: home=1, away=2 (correctly mapped)
    /// ```
    ///
    /// - Parameters:
    ///   - info: EventInfoDTO with score values and participant IDs
    ///   - matchData: MatchDTO with participant ID references
    /// - Returns: Tuple of (home: Int?, away: Int?) with correctly mapped scores
    private static func mapScoreToTeams(
        _ info: EveryMatrix.EventInfoDTO,
        _ matchData: EveryMatrix.MatchDTO?
    ) -> (home: Int?, away: Int?) {
        var homeValue: Int?
        var awayValue: Int?

        guard let match = matchData else {
            // Fallback if no match data available (shouldn't happen in practice)
            return (Int(info.paramFloat1 ?? 0), Int(info.paramFloat2 ?? 0))
        }

        // Map using participant IDs - NEVER assume order!
        if let pid1 = info.paramParticipantId1, let score1 = info.paramFloat1 {
            if pid1 == match.homeParticipantId {
                homeValue = Int(score1)
            } else if pid1 == match.awayParticipantId {
                awayValue = Int(score1)
            }
        }

        if let pid2 = info.paramParticipantId2, let score2 = info.paramFloat2 {
            if pid2 == match.homeParticipantId {
                homeValue = Int(score2)
            } else if pid2 == match.awayParticipantId {
                awayValue = Int(score2)
            }
        }

        return (homeValue, awayValue)
    }

    // MARK: - Card Extraction (typeId 2, 3, 4)

    /// Extract card counts from EVENT_INFO and map to correct teams
    ///
    /// Used for three card types:
    /// - typeId "2": YELLOW_CARDS
    /// - typeId "3": YELLOW_RED_CARDS (second yellow = red)
    /// - typeId "4": RED_CARDS (direct red, not from second yellow)
    ///
    /// Sports supported: Football, Futsal, Handball
    ///
    /// Uses same participant ID mapping as scores to ensure correct team assignment.
    ///
    /// - Parameters:
    ///   - info: EventInfoDTO with card counts in paramFloat1/paramFloat2
    ///   - matchData: MatchDTO with participant ID references
    /// - Returns: Optional FootballCards with home/away counts, or nil if no card data
    private static func extractCards(
        _ info: EveryMatrix.EventInfoDTO,
        _ matchData: EveryMatrix.MatchDTO?
    ) -> FootballCards? {
        print("[LIVE_SCORE] 🔍 Extracting cards (typeId \(info.typeId)):")
        print("[LIVE_SCORE]    paramFloat1: \(info.paramFloat1?.description ?? "nil"), paramParticipantId1: \(info.paramParticipantId1 ?? "nil")")
        print("[LIVE_SCORE]    paramFloat2: \(info.paramFloat2?.description ?? "nil"), paramParticipantId2: \(info.paramParticipantId2 ?? "nil")")

        guard let match = matchData else {
            print("[LIVE_SCORE]    ❌ No match data - cannot map cards")
            return nil
        }

        print("[LIVE_SCORE]    Match homeParticipantId: \(match.homeParticipantId)")
        print("[LIVE_SCORE]    Match awayParticipantId: \(match.awayParticipantId)")

        var homeCards: Int?
        var awayCards: Int?

        // Map cards to correct teams using participant IDs
        if let pid1 = info.paramParticipantId1, let count1 = info.paramFloat1 {
            if pid1 == match.homeParticipantId {
                homeCards = Int(count1)
                print("[LIVE_SCORE]    ✓ Mapped paramFloat1 (\(count1)) → HOME (participant \(pid1))")
            } else if pid1 == match.awayParticipantId {
                awayCards = Int(count1)
                print("[LIVE_SCORE]    ✓ Mapped paramFloat1 (\(count1)) → AWAY (participant \(pid1))")
            } else {
                print("[LIVE_SCORE]    ⚠️ paramParticipantId1 (\(pid1)) doesn't match home or away")
            }
        }

        if let pid2 = info.paramParticipantId2, let count2 = info.paramFloat2 {
            if pid2 == match.homeParticipantId {
                homeCards = Int(count2)
                print("[LIVE_SCORE]    ✓ Mapped paramFloat2 (\(count2)) → HOME (participant \(pid2))")
            } else if pid2 == match.awayParticipantId {
                awayCards = Int(count2)
                print("[LIVE_SCORE]    ✓ Mapped paramFloat2 (\(count2)) → AWAY (participant \(pid2))")
            } else {
                print("[LIVE_SCORE]    ⚠️ paramParticipantId2 (\(pid2)) doesn't match home or away")
            }
        }

        let cards = FootballCards(home: homeCards, away: awayCards)
        print("[LIVE_SCORE]    Result: home=\(homeCards?.description ?? "nil"), away=\(awayCards?.description ?? "nil")")

        // Return nil if no cards, otherwise return the FootballCards struct
        return cards.hasCards ? cards : nil
    }

    // MARK: - Other EVENT_INFO Extractors

    /// Extract serve information (typeId "37")
    ///
    /// Used for racquet sports: Tennis, Table Tennis, Badminton, Volleyball
    ///
    /// Determines which participant is currently serving based on paramParticipantId1.
    ///
    /// - Parameters:
    ///   - info: EventInfoDTO with serving participant ID
    ///   - matchData: MatchDTO with participant ID references
    /// - Returns: ActivePlayerServe (.home or .away) or nil if no serve data
    private static func extractServe(
        _ info: EveryMatrix.EventInfoDTO,
        _ matchData: EveryMatrix.MatchDTO?
    ) -> ActivePlayerServe? {
        guard let participantId = info.paramParticipantId1,
              let match = matchData else { return nil }

        if participantId == match.homeParticipantId {
            return .home
        } else if participantId == match.awayParticipantId {
            return .away
        }
        return nil
    }

    /// Extract event status (typeId "92")
    ///
    /// Maps EveryMatrix status strings to EventStatus enum.
    ///
    /// Status mapping:
    /// - "pending", "not started", "not_started" → .notStarted
    /// - "ended", "interrupted", "canceled", "cancelled", "walkover", "abandoned", "retired" → .ended
    /// - All others → .inProgress(currentPartName)
    ///
    /// - Parameter info: EventInfoDTO with status in paramEventStatusName1
    /// - Returns: EventStatus or nil if no status data
    private static func extractEventStatus(_ info: EveryMatrix.EventInfoDTO) -> EventStatus? {
        guard let statusName = info.paramEventStatusName1?.lowercased() else { return nil }

        switch statusName {
        case "pending", "not started", "not_started":
            return .notStarted
        case "ended", "interrupted", "canceled", "cancelled", "walkover", "abandoned", "retired":
            return .ended(info.paramEventPartName1 ?? statusName)
        default:
            // In progress - include current part name (e.g., "2nd Half", "3rd Quarter")
            return .inProgress(info.paramEventPartName1 ?? statusName)
        }
    }

    /// Extract match time in minutes (typeId "95")
    ///
    /// Used for time-based sports: Football, Rugby, Handball, etc.
    ///
    /// Provides elapsed match time in minutes. Extra/stoppage time is available
    /// in paramFloat2 but currently not used.
    ///
    /// - Parameter info: EventInfoDTO with time in paramFloat1 (minutes)
    /// - Returns: Integer minutes elapsed or nil if no time data
    private static func extractMatchTime(_ info: EveryMatrix.EventInfoDTO) -> Int? {
        return info.paramFloat1.map { Int($0) }
    }
}
