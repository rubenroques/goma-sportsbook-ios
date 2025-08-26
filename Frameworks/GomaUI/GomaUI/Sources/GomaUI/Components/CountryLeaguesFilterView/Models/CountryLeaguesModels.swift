import UIKit

public struct CountryLeagueOptions: Equatable {
    public let id: String
    public let icon: String?
    public let title: String
    public var leagues: [LeagueOption]
    public var isExpanded: Bool
    
    public init(id: String, icon: String?, title: String, leagues: [LeagueOption], isExpanded: Bool = false) {
        self.id = id
        self.icon = icon
        self.title = title
        self.leagues = leagues
        self.isExpanded = isExpanded
    }
}
