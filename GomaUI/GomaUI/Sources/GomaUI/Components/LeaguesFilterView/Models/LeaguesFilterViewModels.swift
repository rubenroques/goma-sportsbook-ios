//
//  LeaguesFilterViewModels.swift
//  GomaUI
//
//  Created by André Lascas on 29/05/2025.
//

import Foundation

public struct LeagueOption: Equatable {
    public let id: Int
    public let icon: String?
    public let title: String
    public let count: Int
    
    public init(id: Int, icon: String?, title: String, count: Int) {
        self.id = id
        self.icon = icon
        self.title = title
        self.count = count
    }
}
