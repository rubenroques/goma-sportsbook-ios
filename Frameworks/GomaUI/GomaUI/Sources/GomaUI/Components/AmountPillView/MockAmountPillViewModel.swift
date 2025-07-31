//
//  MockAmountPillViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 09/06/2025.
//

import Foundation
import Combine
import UIKit

/// Mock implementation of `AmountPillViewModelProtocol` for testing.
final public class MockAmountPillViewModel: AmountPillViewModelProtocol {
    
    // MARK: - Properties
    private let pillDataSubject: CurrentValueSubject<AmountPillData, Never>
    public var pillDataPublisher: AnyPublisher<AmountPillData, Never> {
        return pillDataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    public init(pillData: AmountPillData) {
        self.pillDataSubject = CurrentValueSubject(pillData)
    }
    
    // MARK: - AmountPillViewModelProtocol
    public func setSelected(_ isSelected: Bool) {
        let currentData = pillDataSubject.value
        let updatedData = AmountPillData(
            id: currentData.id,
            amount: currentData.amount,
            isSelected: isSelected
        )
        pillDataSubject.send(updatedData)
    }
}

// MARK: - Mock Factory
extension MockAmountPillViewModel {
    
    public static var defaultMock: MockAmountPillViewModel {
        let pillData = AmountPillData(
            id: "250",
            amount: "250",
            isSelected: false
        )
        return MockAmountPillViewModel(pillData: pillData)
    }
    
    public static var selectedMock: MockAmountPillViewModel {
        let pillData = AmountPillData(
            id: "250",
            amount: "250",
            isSelected: true
        )
        return MockAmountPillViewModel(pillData: pillData)
    }
}
