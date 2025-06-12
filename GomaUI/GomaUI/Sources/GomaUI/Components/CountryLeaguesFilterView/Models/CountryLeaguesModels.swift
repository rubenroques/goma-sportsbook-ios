//
//  CountryLeaguesModels.swift
//  GomaUI
//
//  Created by André Lascas on 28/05/2025.
//

import UIKit

public struct CountryLeagueOptions: Equatable {
    public let id: Int
    public let icon: String?
    public let title: String
    public var leagues: [LeagueOption]
    public var isExpanded: Bool
    
    public init(id: Int, icon: String?, title: String, leagues: [LeagueOption], isExpanded: Bool = false) {
        self.id = id
        self.icon = icon
        self.title = title
        self.leagues = leagues
        self.isExpanded = isExpanded
    }
}
