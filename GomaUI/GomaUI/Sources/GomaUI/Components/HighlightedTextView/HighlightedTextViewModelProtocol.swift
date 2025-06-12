//
//  HighlightedTextViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 11/06/2025.
//

import Foundation
import UIKit
import Combine

// MARK: - Highlight Types
public enum HighlightType {
    case highlight
    case link
    
    var fontType: StyleProvider.FontType {
        switch self {
        case .highlight:
            return .bold
        case .link:
            return .regular
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .highlight:
            return 14
        case .link:
            return 12
        }
    }
    
    var isUnderlined: Bool {
        switch self {
        case .highlight:
            return false
        case .link:
            return true
        }
    }
}

// MARK: - Data Models
public struct HighlightData {
    public let text: String
    public let color: UIColor
    public let ranges: [NSRange]
    public let type: HighlightType

    public init(text: String, color: UIColor, ranges: [NSRange], type: HighlightType = .highlight) {
        self.text = text
        self.color = color
        self.ranges = ranges
        self.type = type
    }
}

public struct HighlightedTextData {
    public let id: String
    public let fullText: String
    public let highlights: [HighlightData]
    public let textAlignment: NSTextAlignment
    public let baseFontType: StyleProvider.FontType
    public let baseFontSize: CGFloat
    
    public init(
        id: String = UUID().uuidString,
        fullText: String,
        highlights: [HighlightData],
        textAlignment: NSTextAlignment = .left,
        baseFontType: StyleProvider.FontType = .regular,
        baseFontSize: CGFloat = 14
    ) {
        self.id = id
        self.fullText = fullText
        self.highlights = highlights
        self.textAlignment = textAlignment
        self.baseFontType = baseFontType
        self.baseFontSize = baseFontSize
    }
}

// MARK: - View Model Protocol
public protocol HighlightedTextViewModelProtocol {
    var data: HighlightedTextData { get }
    var dataPublisher: AnyPublisher<HighlightedTextData, Never> { get }
    
    func configure(with data: HighlightedTextData)
}
