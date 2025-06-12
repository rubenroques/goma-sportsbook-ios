//
//  MockTransactionVerificationViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 11/06/2025.
//

import Foundation
import UIKit
import Combine

public final class MockTransactionVerificationViewModel: TransactionVerificationViewModelProtocol {
    
    private let dataSubject: CurrentValueSubject<TransactionVerificationData, Never>
    private let highlightedTextViewModelInstance: HighlightedTextViewModelProtocol
    
    public var data: TransactionVerificationData {
        dataSubject.value
    }
    
    public var dataPublisher: AnyPublisher<TransactionVerificationData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public var highlightedTextViewModel: HighlightedTextViewModelProtocol {
        highlightedTextViewModelInstance
    }
    
    public init(data: TransactionVerificationData) {
        self.dataSubject = CurrentValueSubject(data)
        
        let fullText = data.subtitle

        if let highlightText = data.highlightText {
            let phoneRanges = HighlightedTextView.findRanges(of: highlightText, in: fullText)
            
            let highlight = HighlightData(
                text: highlightText,
                color: StyleProvider.Color.highlightPrimary,
                ranges: phoneRanges
            )
            
            let highlightedTextData = HighlightedTextData(
                fullText: fullText,
                highlights: [highlight],
                textAlignment: .center
            )
            
            self.highlightedTextViewModelInstance = MockHighlightedTextViewModel(data: highlightedTextData)
        }
        else {
            let highlightedTextData = HighlightedTextData(
                fullText: fullText,
                highlights: [],
                textAlignment: .center
            )
            
            self.highlightedTextViewModelInstance = MockHighlightedTextViewModel(data: highlightedTextData)
        }
        
    }
    
    public func configure(with data: TransactionVerificationData) {
        dataSubject.send(data)
    }
}

// MARK: - Factory Methods
public extension MockTransactionVerificationViewModel {
    static func defaultMock() -> MockTransactionVerificationViewModel {
        let data = TransactionVerificationData(
            title: "USSD Push coming through...",
            subtitle: "We are sending a USSD Push interaction to +237 612345678",
            highlightText: "+237 612345678",
            topImage: UIImage(systemName: "arrow.2.circlepath")?.withTintColor(StyleProvider.Color.highlightPrimary, renderingMode: .alwaysOriginal),
            bottomImage: UIImage(systemName: "iphone")?.withTintColor(StyleProvider.Color.textSecondary, renderingMode: .alwaysOriginal)
        )
        
        return MockTransactionVerificationViewModel(data: data)
    }
    
    static func simpleMock() -> MockTransactionVerificationViewModel {
        let data = TransactionVerificationData(
            title: "Received it yet?",
            subtitle: "Follow the prompt to proceed",
            topImage: UIImage(systemName: "arrow.2.circlepath")?.withTintColor(StyleProvider.Color.highlightPrimary, renderingMode: .alwaysOriginal),
            bottomImage: UIImage(systemName: "phone.badge.checkmark")?.withTintColor(StyleProvider.Color.highlightPrimary, renderingMode: .alwaysOriginal)
        )
        
        return MockTransactionVerificationViewModel(data: data)
    }
    
}
