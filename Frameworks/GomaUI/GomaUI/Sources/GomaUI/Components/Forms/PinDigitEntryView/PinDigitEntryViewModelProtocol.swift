import Foundation
import UIKit
import Combine

// MARK: - Data Models
public struct PinDigitEntryData {
    public let id: String
    public let digitCount: Int
    public let currentPin: String
    
    public init(
        id: String = UUID().uuidString,
        digitCount: Int = 4,
        currentPin: String = ""
    ) {
        self.id = id
        self.digitCount = digitCount
        self.currentPin = currentPin
    }
}

// MARK: - View Model Protocol
public protocol PinDigitEntryViewModelProtocol {
    var data: PinDigitEntryData { get }
    var dataPublisher: AnyPublisher<PinDigitEntryData, Never> { get }
    var isPinComplete: CurrentValueSubject<Bool, Never> { get set }

    func configure(with data: PinDigitEntryData)
    func addDigit(_ digit: String)
    func removeLastDigit()
    func clearPin()
}
