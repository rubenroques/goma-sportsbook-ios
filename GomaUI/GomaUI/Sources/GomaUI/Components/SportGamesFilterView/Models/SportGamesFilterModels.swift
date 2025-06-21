//
//  SportGamesFilterModels.swift
//  GomaUI
//
//  Created by André Lascas on 29/05/2025.
//

import Foundation
import UIKit

public struct SportFilter {
    public let id: String
    public let title: String
    public let icon: String?
    
    public init(id: String, title: String, icon: String?) {
        self.id = id
        self.title = title
        self.icon = icon
    }
}

public struct GameItem: Equatable, Hashable {
    public let title: String
    public let icon: String?
    
    public init(title: String, icon: String?) {
        self.title = title
        self.icon = icon
    }
}

public enum SportGamesFilterStateType {
    case expanded
    case collapsed
}
