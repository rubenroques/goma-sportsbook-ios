//
//  MockPinDigitEntryViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 12/06/2025.
//

import Foundation
import UIKit
import Combine

public final class MockPinDigitEntryViewModel: PinDigitEntryViewModelProtocol {
    
    private let dataSubject: CurrentValueSubject<PinDigitEntryData, Never>
    public var isPinComplete: CurrentValueSubject<Bool, Never>

    public var data: PinDigitEntryData {
        dataSubject.value
    }
    
    public var dataPublisher: AnyPublisher<PinDigitEntryData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public init(data: PinDigitEntryData) {
        self.dataSubject = CurrentValueSubject(data)
        self.isPinComplete = .init(false)
    }
    
    public func configure(with data: PinDigitEntryData) {
        dataSubject.send(data)
    }
    
    public func addDigit(_ digit: String) {
        let currentData = dataSubject.value
        guard currentData.currentPin.count < currentData.digitCount else { return }
        
        let newPin = currentData.currentPin + digit
        let updatedData = PinDigitEntryData(
            id: currentData.id,
            digitCount: currentData.digitCount,
            currentPin: newPin
        )
        
        dataSubject.send(updatedData)
    }
    
    public func removeLastDigit() {
        let currentData = dataSubject.value
        guard !currentData.currentPin.isEmpty else { return }
        
        let newPin = String(currentData.currentPin.dropLast())
        let updatedData = PinDigitEntryData(
            id: currentData.id,
            digitCount: currentData.digitCount,
            currentPin: newPin
        )
        
        dataSubject.send(updatedData)
    }
    
    public func clearPin() {
        let currentData = dataSubject.value
        let updatedData = PinDigitEntryData(
            id: currentData.id,
            digitCount: currentData.digitCount,
            currentPin: ""
        )
        
        dataSubject.send(updatedData)
    }
}

// MARK: - Factory Methods
public extension MockPinDigitEntryViewModel {
    static func defaultMock() -> MockPinDigitEntryViewModel {
        let data = PinDigitEntryData(
            digitCount: 4,
            currentPin: ""
        )
        
        return MockPinDigitEntryViewModel(data: data)
    }
    
    static func partialPinMock() -> MockPinDigitEntryViewModel {
        let data = PinDigitEntryData(
            digitCount: 4,
            currentPin: "12"
        )
        
        return MockPinDigitEntryViewModel(data: data)
    }
    
    static func completePinMock() -> MockPinDigitEntryViewModel {
        let data = PinDigitEntryData(
            digitCount: 4,
            currentPin: "1234"
        )
        
        return MockPinDigitEntryViewModel(data: data)
    }
    
    static func sixDigitMock() -> MockPinDigitEntryViewModel {
        let data = PinDigitEntryData(
            digitCount: 6,
            currentPin: "123"
        )
        
        return MockPinDigitEntryViewModel(data: data)
    }
    
    static func eightDigitMock() -> MockPinDigitEntryViewModel {
        let data = PinDigitEntryData(
            digitCount: 8,
            currentPin: ""
        )
        
        return MockPinDigitEntryViewModel(data: data)
    }
}
