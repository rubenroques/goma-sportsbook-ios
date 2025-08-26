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
            
            self.highlightedTextViewModelInstance.configure(with: highlightedTextData)
        }
        else {
            let highlightedTextData = HighlightedTextData(
                fullText: fullText,
                highlights: [],
                textAlignment: .center
            )
            
            self.highlightedTextViewModelInstance.configure(with: highlightedTextData)
        }
        
        dataSubject.send(data)
    }
}

// MARK: - Factory Methods
public extension MockTransactionVerificationViewModel {
    static var defaultMock: MockTransactionVerificationViewModel {
        let data = TransactionVerificationData(
            id: "ussd_push",
            title: "USSD Push coming through...",
            subtitle: "We are sending a USSD Push interaction to +237 612345678",
            highlightText: "+237 612345678",
            topImage: "arrow.2.circlepath",
            bottomImage: "iphone"
        )
        
        return MockTransactionVerificationViewModel(data: data)
    }
    
    static var simpleMock: MockTransactionVerificationViewModel {
        let data = TransactionVerificationData(
            id: "ussd_received",
            title: "Received it yet?",
            subtitle: "Follow the prompt to proceed",
            topImage: "arrow.2.circlepath",
            bottomImage: "phone.badge.checkmark"
        )
        
        return MockTransactionVerificationViewModel(data: data)
    }
    
    static var incompletePinMock: MockTransactionVerificationViewModel {
        let data = TransactionVerificationData(
            id: "ussd_push",
            title: "USSD Push coming through...",
            subtitle: "We are sending a USSD Push interaction to +237 612345678",
            highlightText: "+237 612345678",
            topImage: "loader_icon",
            bottomImage: "incomplete_pin_image"
        )
        
        return MockTransactionVerificationViewModel(data: data)
    }
    
    static var completePinMock: MockTransactionVerificationViewModel {
        let data = TransactionVerificationData(
            id: "ussd_received",
            title: "Received it yet?",
            subtitle: "Follow the prompt to proceed",
            topImage: "check_icon",
            bottomImage: "complete_pin_image"
        )
        
        return MockTransactionVerificationViewModel(data: data)
    }
    
}
