import Foundation
import UIKit
import Combine

public final class MockHighlightedTextViewModel: HighlightedTextViewModelProtocol {
    
    private let dataSubject: CurrentValueSubject<HighlightedTextData, Never>
    
    public var data: HighlightedTextData {
        dataSubject.value
    }
    
    public var dataPublisher: AnyPublisher<HighlightedTextData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public init(data: HighlightedTextData) {
        self.dataSubject = CurrentValueSubject(data)
    }
    
    public func configure(with data: HighlightedTextData) {
        dataSubject.send(data)
    }
}

// MARK: - Factory Methods
public extension MockHighlightedTextViewModel {
    static func defaultMock() -> MockHighlightedTextViewModel {
        let fullText = "We are sending a USSD Push interaction to +237 612345678"
        let phoneNumber = "+237 612345678"
        let phoneRanges = HighlightedTextView.findRanges(of: phoneNumber, in: fullText)
        
        let highlight = HighlightData(
            text: phoneNumber,
            color: StyleProvider.Color.highlightPrimary,
            ranges: phoneRanges
        )
        
        let data = HighlightedTextData(
            fullText: fullText,
            highlights: [highlight],
            textAlignment: .left
        )
        
        return MockHighlightedTextViewModel(data: data)
    }
    
    static func centeredMock() -> MockHighlightedTextViewModel {
        let fullText = "Your bonus expires in 24 hours"
        let highlight = HighlightData(
            text: "24 hours",
            color: StyleProvider.Color.highlightSecondary,
            ranges: HighlightedTextView.findRanges(of: "24 hours", in: fullText)
        )
        
        let data = HighlightedTextData(
            fullText: fullText,
            highlights: [highlight],
            textAlignment: .center
        )
        
        return MockHighlightedTextViewModel(data: data)
    }
    
    static func rightAlignedMock() -> MockHighlightedTextViewModel {
        let fullText = "Amount: $1,250.00"
        let highlight = HighlightData(
            text: "$1,250.00",
            color: StyleProvider.Color.highlightPrimary,
            ranges: HighlightedTextView.findRanges(of: "$1,250.00", in: fullText)
        )
        
        let data = HighlightedTextData(
            fullText: fullText,
            highlights: [highlight],
            textAlignment: .right
        )
        
        return MockHighlightedTextViewModel(data: data)
    }
    
    static func multipleHighlightsMock() -> MockHighlightedTextViewModel {
        let fullText = "Transfer $500.00 to John Smith at +237 612345678"
        
        let amountHighlight = HighlightData(
            text: "$500.00",
            color: StyleProvider.Color.highlightPrimary,
            ranges: HighlightedTextView.findRanges(of: "$500.00", in: fullText)
        )
        
        let nameHighlight = HighlightData(
            text: "John Smith",
            color: StyleProvider.Color.highlightSecondary,
            ranges: HighlightedTextView.findRanges(of: "John Smith", in: fullText)
        )
        
        let phoneHighlight = HighlightData(
            text: "+237 612345678",
            color: StyleProvider.Color.highlightPrimary,
            ranges: HighlightedTextView.findRanges(of: "+237 612345678", in: fullText)
        )
        
        let data = HighlightedTextData(
            fullText: fullText,
            highlights: [amountHighlight, nameHighlight, phoneHighlight],
            textAlignment: .left
        )
        
        return MockHighlightedTextViewModel(data: data)
    }
    
    static func linkMock() -> MockHighlightedTextViewModel {
            let fullText = "Please read our Terms and Conditions and Privacy Policy before continuing."
            
            let termsHighlight = HighlightData(
                text: "Terms and Conditions",
                color: StyleProvider.Color.highlightPrimary,
                ranges: HighlightedTextView.findRanges(of: "Terms and Conditions", in: fullText),
                type: .link
            )
            
            let privacyHighlight = HighlightData(
                text: "Privacy Policy",
                color: StyleProvider.Color.highlightPrimary,
                ranges: HighlightedTextView.findRanges(of: "Privacy Policy", in: fullText),
                type: .link
            )
            
            let data = HighlightedTextData(
                fullText: fullText,
                highlights: [termsHighlight, privacyHighlight],
                textAlignment: .left
            )
            
            return MockHighlightedTextViewModel(data: data)
        }
}
