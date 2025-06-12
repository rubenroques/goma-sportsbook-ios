//
//  MockAmountPillsViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 09/06/2025.
//

import Foundation
import Combine
import UIKit

/// Mock implementation of `AmountPillsViewModelProtocol` for testing.
final public class MockAmountPillsViewModel: AmountPillsViewModelProtocol {
    
    // MARK: - Properties
    private let pillsDataSubject: CurrentValueSubject<AmountPillsData, Never>
    public var pillsDataPublisher: AnyPublisher<AmountPillsData, Never> {
        return pillsDataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init(pillsData: AmountPillsData) {
        self.pillsDataSubject = CurrentValueSubject(pillsData)
    }
    
    // MARK: - AmountPillsViewModelProtocol
    public func selectPill(withId id: String) {
        let currentData = pillsDataSubject.value
        let updatedData = AmountPillsData(
            id: currentData.id,
            pills: currentData.pills,
            selectedPillId: id
        )
        pillsDataSubject.send(updatedData)
    }
    
    public func clearSelection() {
        let currentData = pillsDataSubject.value
        let updatedData = AmountPillsData(
            id: currentData.id,
            pills: currentData.pills,
            selectedPillId: nil
        )
        pillsDataSubject.send(updatedData)
    }
}

// MARK: - Mock Factory
extension MockAmountPillsViewModel {
    
    /// Default mock matching the image
    public static var defaultMock: MockAmountPillsViewModel {
        let pills = [
            AmountPillData(id: "250", amount: "250", isSelected: false),
            AmountPillData(id: "500", amount: "500", isSelected: false),
            AmountPillData(id: "1000", amount: "1000", isSelected: false),
            AmountPillData(id: "2000", amount: "2000", isSelected: false),
            AmountPillData(id: "3000", amount: "3000", isSelected: false),
            AmountPillData(id: "5000", amount: "5000", isSelected: false),
            AmountPillData(id: "10000", amount: "10000", isSelected: false),
            AmountPillData(id: "20000", amount: "20000", isSelected: false)
        ]
        
        let pillsData = AmountPillsData(
            id: "amount_selection",
            pills: pills,
            selectedPillId: nil
        )
        
        return MockAmountPillsViewModel(pillsData: pillsData)
    }
    
    /// Mock with selection
    public static var selectedMock: MockAmountPillsViewModel {
        let pills = [
            AmountPillData(id: "250", amount: "250", isSelected: false),
            AmountPillData(id: "500", amount: "500", isSelected: true),
            AmountPillData(id: "1000", amount: "1000", isSelected: false),
            AmountPillData(id: "2000", amount: "2000", isSelected: false)
        ]
        
        let pillsData = AmountPillsData(
            id: "amount_selection",
            pills: pills,
            selectedPillId: "500"
        )
        
        return MockAmountPillsViewModel(pillsData: pillsData)
    }
}
