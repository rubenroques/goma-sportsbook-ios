//
//  FilterOptionModels.swift
//  GomaUI
//
//  Created by André Lascas on 03/06/2025.
//

import Foundation

public struct FilterOptionItem {
    public let type: FilterOptionType
    public let title: String
    public let icon: String
    
    public init(type: FilterOptionType, title: String, icon: String) {
        self.type = type
        self.title = title
        self.icon = icon
    }
}

public enum FilterOptionType {
    case sport
    case sortBy
    case league
}
