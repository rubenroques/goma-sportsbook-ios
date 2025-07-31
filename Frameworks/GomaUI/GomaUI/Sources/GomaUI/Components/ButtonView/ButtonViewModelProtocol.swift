//
//  ButtonViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 09/06/2025.
//

import Foundation
import Combine
import UIKit

// MARK: - Button Style Enum
public enum ButtonStyle {
    case solidBackground
    case bordered
    case transparent
}

// MARK: - Data Models
public struct ButtonData: Equatable, Hashable {
    public let id: String
    public let title: String
    public let style: ButtonStyle
    public let isEnabled: Bool
    
    public init(id: String, title: String, style: ButtonStyle, isEnabled: Bool = true) {
        self.id = id
        self.title = title
        self.style = style
        self.isEnabled = isEnabled
    }
}

// MARK: - View Model Protocol
public protocol ButtonViewModelProtocol {
    /// Publisher for reactive updates
    var buttonDataPublisher: AnyPublisher<ButtonData, Never> { get }
    
    /// Button action
    func buttonTapped()
    
    /// Update button state
    func setEnabled(_ isEnabled: Bool)
}
