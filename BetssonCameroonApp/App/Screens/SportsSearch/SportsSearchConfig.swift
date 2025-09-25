import Foundation

struct SportsSearchConfig: Decodable {
    struct SuggestedEvents: Decodable { let enabled: Bool; let maxEvents: Int?; let title: String? }
    struct SearchResults: Decodable { let enabled: Bool; let showResults: Bool; let showResultsCount: Bool; let resultsLabel: String? }
    struct NoResults: Decodable { let enabled: Bool; let message: String?; let showIcon: Bool }

    let suggestedEvents: SuggestedEvents
    let searchResults: SearchResults
    let noResults: NoResults

    static var `default`: SportsSearchConfig {
        SportsSearchConfig(
            suggestedEvents: .init(enabled: true, maxEvents: 5, title: "suggested_events"),
            searchResults: .init(enabled: true, showResults: true, showResultsCount: true, resultsLabel: "showing_results_for"),
            noResults: .init(enabled: true, message: "no_results_for", showIcon: true)
        )
    }
}


