//
//  SortFilterModels.swift
//  GomaUI
//
//  Created by André Lascas on 29/05/2025.
//

import Foundation

public struct SortOption: Equatable {
    public var id: Int
    public var icon: String?
    public var title: String
    public var count: Int
    public var iconTintChange: Bool
    
    public init(id: Int, icon: String?, title: String, count: Int, iconTintChange: Bool = true) {
        self.id = id
        self.icon = icon
        self.title = title
        self.count = count
        self.iconTintChange = iconTintChange
    }
}
