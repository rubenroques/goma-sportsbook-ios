//
//  FootballCards.swift
//  ServicesProvider
//
//  Created by Claude Code on 16/11/2025.
//

import Foundation

/// Represents card counts for a football/futsal/handball match
///
/// Used by EventLiveData to track yellow cards, yellow-red cards, and red cards
/// for both home and away teams.
///
/// This is a ServicesProvider public model (provider-agnostic domain model) that can be
/// used by all providers: EveryMatrix, Goma, SportRadar.
///
/// Supported sports:
/// - Football (sportId: 1)
/// - Futsal (sportId: 49)
/// - Handball (sportId: 7)
///
/// Card types tracked:
/// - Yellow cards (typeId "2")
/// - Yellow-red cards (typeId "3") - Second yellow = red
/// - Red cards (typeId "4") - Direct red cards
public struct FootballCards: Equatable, Codable {

    /// Home team card count
    public var home: Int?

    /// Away team card count
    public var away: Int?

    public init(home: Int?, away: Int?) {
        self.home = home
        self.away = away
    }

    /// Check if there are any cards (at least one team has cards)
    public var hasCards: Bool {
        return (home ?? 0) > 0 || (away ?? 0) > 0
    }
}
