import Foundation
import UIKit
import Combine

// MARK: - Data Models
public struct StepInstructionData {
    public let id: String
    public let stepNumber: Int
    public let instructionText: String
    public let highlightedWords: [String]
    public let indicatorColor: UIColor?
    public let numberTextColor: UIColor?
    
    public init(
        id: String = UUID().uuidString,
        stepNumber: Int,
        instructionText: String,
        highlightedWords: [String] = [],
        indicatorColor: UIColor? = nil,
        numberTextColor: UIColor? = nil
    ) {
        self.id = id
        self.stepNumber = stepNumber
        self.instructionText = instructionText
        self.highlightedWords = highlightedWords
        self.indicatorColor = indicatorColor
        self.numberTextColor = numberTextColor
    }
}

// MARK: - View Model Protocol
public protocol StepInstructionViewModelProtocol {
    var data: StepInstructionData { get }
    var dataPublisher: AnyPublisher<StepInstructionData, Never> { get }
    var highlightedTextViewModel: HighlightedTextViewModelProtocol { get }
    
    func configure(with data: StepInstructionData)
}
