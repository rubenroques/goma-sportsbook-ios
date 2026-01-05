//
//  FloatingOverlayViewModelProtocol.swift
//  GomaUI
//
//  Created on 06/04/2025.
//

import Combine
import UIKit

// MARK: - Mode
public enum FloatingOverlayMode: Equatable {
    case sportsbook
    case casino
    case custom(icon: UIImage, message: String)
    
    var icon: UIImage {
        switch self {
        case .sportsbook:
            return UIImage(systemName: "soccerball") ?? UIImage()
        case .casino:
            return UIImage(systemName: "dice") ?? UIImage()
        case .custom(let icon, _):
            return icon
        }
    }
    
    var message: String {
        switch self {
        case .sportsbook:
            return "You're in Sportsbook 🔥"
        case .casino:
            return "You're in Casino 🎲"
        case .custom(_, let message):
            return message
        }
    }
}

// MARK: - Display State
public struct FloatingOverlayDisplayState: Equatable {
    public let mode: FloatingOverlayMode
    public let duration: TimeInterval?
    public let isVisible: Bool
    
    public init(mode: FloatingOverlayMode, duration: TimeInterval? = nil, isVisible: Bool = false) {
        self.mode = mode
        self.duration = duration
        self.isVisible = isVisible
    }
}

// MARK: - View Model Protocol
public protocol FloatingOverlayViewModelProtocol {
    var displayStatePublisher: AnyPublisher<FloatingOverlayDisplayState, Never> { get }
    
    func show(mode: FloatingOverlayMode, duration: TimeInterval?)
    func hide()
}