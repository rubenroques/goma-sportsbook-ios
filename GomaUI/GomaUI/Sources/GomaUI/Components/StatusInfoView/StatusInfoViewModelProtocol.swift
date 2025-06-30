//
//  StatusInfoViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 30/06/2025.
//

import Foundation

public struct StatusInfo {
    public let id: String
    public let icon: String
    public let title: String
    public let message: String
    
    public init(
        id: String = UUID().uuidString,
        icon: String,
        title: String,
        message: String
    ) {
        self.id = id
        self.icon = icon
        self.title = title
        self.message = message
    }
}

public protocol StatusInfoViewModelProtocol {
    var statusInfo: StatusInfo { get }
}
