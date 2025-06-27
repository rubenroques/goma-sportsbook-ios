//
//  TransactionVerificationViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 11/06/2025.
//

import Foundation
import UIKit
import Combine

// MARK: - Data Models
public struct TransactionVerificationData {
    public let id: String
    public let title: String
    public let subtitle: String
    public let highlightText: String?
    public let topImage: String?
    public let bottomImage: String?
    
    public init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String,
        highlightText: String? = nil,
        topImage: String? = nil,
        bottomImage: String? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.highlightText = highlightText
        self.topImage = topImage
        self.bottomImage = bottomImage
    }
}

// MARK: - View Model Protocol
public protocol TransactionVerificationViewModelProtocol {
    var data: TransactionVerificationData { get }
    var dataPublisher: AnyPublisher<TransactionVerificationData, Never> { get }
    var highlightedTextViewModel: HighlightedTextViewModelProtocol { get }
    
    func configure(with data: TransactionVerificationData)
}
