import Foundation

struct CasinoSearchConfig: Decodable {
    struct RecommendedGames: Decodable { let enabled: Bool; let maxGames: Int?; let title: String? }
    struct SearchResults: Decodable { let enabled: Bool; let showResults: Bool; let showResultsCount: Bool; let resultsLabel: String? }
    struct NoResults: Decodable { let enabled: Bool; let message: String?; let showIcon: Bool }
    struct Sections: Decodable {
        struct SectionItem: Decodable { let enabled: Bool; let title: String?; let maxGames: Int? }
        let searchResults: SectionItem
        let mostPlayed: SectionItem
        let recentlyPlayed: SectionItem?
    }

    let recommendedGames: RecommendedGames
    let searchResults: SearchResults
    let noResults: NoResults
    let sections: Sections

    static var `default`: CasinoSearchConfig {
        return CasinoSearchConfig(
            recommendedGames: .init(enabled: true, maxGames: 10, title: "suggested_games"),
            searchResults: .init(enabled: true, showResults: true, showResultsCount: true, resultsLabel: "showing_results_for"),
            noResults: .init(enabled: true, message: "no_results_for", showIcon: true),
            sections: .init(
                searchResults: .init(enabled: true, title: "search_results", maxGames: 10),
                mostPlayed: .init(enabled: true, title: "most_played_games", maxGames: nil),
                recentlyPlayed: .init(enabled: false, title: "recently_played_games", maxGames: nil)
            )
        )
    }
}


