//
//  StatusNotificationViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 11/06/2025.
//

import Foundation
import UIKit
import Combine

// MARK: - Data Models
public struct StatusNotificationData {
    public let id: String
    public let type: StatusNotificationType
    public let message: String
    public let icon: String?
    
    public init(
        id: String = UUID().uuidString,
        type: StatusNotificationType,
        message: String,
        icon: String? = nil
    ) {
        self.id = id
        self.type = type
        self.message = message
        self.icon = icon
    }
}

// MARK: - View Model Protocol
public protocol StatusNotificationViewModelProtocol {
    var data: StatusNotificationData { get }
    var dataPublisher: AnyPublisher<StatusNotificationData, Never> { get }
    
    func configure(with data: StatusNotificationData)
}
