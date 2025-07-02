//
//  AmountPillsViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 09/06/2025.
//

import Foundation
import Combine
import UIKit

// MARK: - Data Models
public struct AmountPillsData: Equatable {
    public let id: String
    public let pills: [AmountPillData]
    public let selectedPillId: String?
    
    public init(id: String, pills: [AmountPillData], selectedPillId: String? = nil) {
        self.id = id
        self.pills = pills
        self.selectedPillId = selectedPillId
    }
}

// MARK: - View Model Protocol
public protocol AmountPillsViewModelProtocol {
    /// Publisher for reactive updates
    var pillsDataPublisher: AnyPublisher<AmountPillsData, Never> { get }
    var pillsDataSubject: CurrentValueSubject<AmountPillsData, Never> { get }

    /// Select a specific pill
    func selectPill(withId id: String)
    
    /// Clear selection
    func clearSelection()
}
