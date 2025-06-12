//
//  MockStepInstructionViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 11/06/2025.
//

import Foundation
import UIKit
import Combine

public final class MockStepInstructionViewModel: StepInstructionViewModelProtocol {
    
    private let dataSubject: CurrentValueSubject<StepInstructionData, Never>
    private let highlightedTextViewModelInstance: HighlightedTextViewModelProtocol
    
    public var data: StepInstructionData {
        dataSubject.value
    }
    
    public var dataPublisher: AnyPublisher<StepInstructionData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public var highlightedTextViewModel: HighlightedTextViewModelProtocol {
        highlightedTextViewModelInstance
    }
    
    public init(data: StepInstructionData, highlightedTextViewModel: HighlightedTextViewModelProtocol? = nil) {
        self.dataSubject = CurrentValueSubject(data)
        
        // Create highlighted text view model
        if let providedViewModel = highlightedTextViewModel {
            self.highlightedTextViewModelInstance = providedViewModel
        } else {
            self.highlightedTextViewModelInstance = Self.createHighlightedTextViewModel(for: data)
        }
    }
    
    public func configure(with data: StepInstructionData) {
        dataSubject.send(data)
    }
    
    // MARK: - Private Methods
    private static func createHighlightedTextViewModel(for data: StepInstructionData) -> HighlightedTextViewModelProtocol {
        var highlights: [HighlightData] = []
        
        // Create highlights for each highlighted word
        for word in data.highlightedWords {
            let ranges = HighlightedTextView.findRanges(of: word, in: data.instructionText)
            
            let highlight = HighlightData(
                text: word,
                color: StyleProvider.Color.highlightPrimary,
                ranges: ranges
            )
            
            highlights.append(highlight)
        }
        
        let highlightedTextData = HighlightedTextData(
            fullText: data.instructionText,
            highlights: highlights,
            textAlignment: .left
        )
        
        return MockHighlightedTextViewModel(data: highlightedTextData)
    }
}

// MARK: - Factory Methods
public extension MockStepInstructionViewModel {
    static func defaultMock() -> MockStepInstructionViewModel {
        let data = StepInstructionData(
            stepNumber: 1,
            instructionText: "On the mobile money menu, select x, then select the x option.",
            highlightedWords: ["x"]
        )
        
        return MockStepInstructionViewModel(data: data)
    }
    
    static func customColorMock() -> MockStepInstructionViewModel {
        let data = StepInstructionData(
            stepNumber: 2,
            instructionText: "After you receive a transaction confirmation SMS from your provider, click on the Confirm Payment button below.",
            highlightedWords: ["Confirm Payment"],
            indicatorColor: StyleProvider.Color.highlightSecondary,
            numberTextColor: StyleProvider.Color.textPrimary
        )
        
        return MockStepInstructionViewModel(data: data)
    }
    
    static func multipleHighlightsMock() -> MockStepInstructionViewModel {
        let data = StepInstructionData(
            stepNumber: 3,
            instructionText: "You will receive a confirmation SMS on your registered number.",
            highlightedWords: ["confirmation SMS", "registered number"]
        )
        
        return MockStepInstructionViewModel(data: data)
    }
    
}
