import Foundation
import UIKit
import Combine


public final class MockCapsuleViewModel: CapsuleViewModelProtocol {
    
    private let dataSubject: CurrentValueSubject<CapsuleData, Never>
    
    public var data: CapsuleData {
        dataSubject.value
    }
    
    public var dataPublisher: AnyPublisher<CapsuleData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public init(data: CapsuleData) {
        self.dataSubject = CurrentValueSubject(data)
    }
    
    public func configure(with data: CapsuleData) {
        dataSubject.send(data)
    }
}

// MARK: - Factory Methods
extension MockCapsuleViewModel {
    
    public static var liveBadge: MockCapsuleViewModel {
        let data = CapsuleData(
            text: "LIVE",
            backgroundColor: StyleProvider.Color.highlightSecondary,
            textColor: StyleProvider.Color.buttonTextPrimary,
            font: StyleProvider.fontWith(type: .bold, size: 10),
            horizontalPadding: 12.0,
            verticalPadding: 4.0
        )
        return MockCapsuleViewModel(data: data)
    }
    
    public static var countBadge: MockCapsuleViewModel {
        let data = CapsuleData(
            text: "16",
            backgroundColor: StyleProvider.Color.highlightPrimary,
            textColor: StyleProvider.Color.buttonTextPrimary,
            font: StyleProvider.fontWith(type: .bold, size: 10),
            horizontalPadding: 8.0,
            verticalPadding: 2.0,
            minimumHeight: 16.0
        )
        return MockCapsuleViewModel(data: data)
    }
    
    public static var tagStyle: MockCapsuleViewModel {
        let data = CapsuleData(
            text: "Football",
            backgroundColor: StyleProvider.Color.backgroundPrimary,
            textColor: StyleProvider.Color.textPrimary,
            font: StyleProvider.fontWith(type: .medium, size: 12),
            horizontalPadding: 16.0,
            verticalPadding: 8.0
        )
        return MockCapsuleViewModel(data: data)
    }
    
    public static var statusPending: MockCapsuleViewModel {
        let data = CapsuleData(
            text: LocalizationProvider.string("pending"),
            backgroundColor: UIColor.systemOrange,
            textColor: StyleProvider.Color.buttonTextPrimary,
            font: StyleProvider.fontWith(type: .medium, size: 11),
            horizontalPadding: 10.0,
            verticalPadding: 6.0
        )
        return MockCapsuleViewModel(data: data)
    }
    
    public static var statusSuccess: MockCapsuleViewModel {
        let data = CapsuleData(
            text: "Completed",
            backgroundColor: UIColor.systemGreen,
            textColor: StyleProvider.Color.buttonTextPrimary,
            font: StyleProvider.fontWith(type: .medium, size: 11),
            horizontalPadding: 10.0,
            verticalPadding: 6.0
        )
        return MockCapsuleViewModel(data: data)
    }
    
    public static var statusError: MockCapsuleViewModel {
        let data = CapsuleData(
            text: LocalizationProvider.string("failed"),
            backgroundColor: UIColor.systemRed,
            textColor: StyleProvider.Color.buttonTextPrimary,
            font: StyleProvider.fontWith(type: .medium, size: 11),
            horizontalPadding: 10.0,
            verticalPadding: 6.0
        )
        return MockCapsuleViewModel(data: data)
    }
    
    public static var promotionalNew: MockCapsuleViewModel {
        let data = CapsuleData(
            text: "NEW",
            backgroundColor: UIColor.systemPurple,
            textColor: StyleProvider.Color.buttonTextPrimary,
            font: StyleProvider.fontWith(type: .bold, size: 9),
            horizontalPadding: 6.0,
            verticalPadding: 2.0
        )
        return MockCapsuleViewModel(data: data)
    }
    
    public static var promotionalHot: MockCapsuleViewModel {
        let data = CapsuleData(
            text: "🔥 HOT",
            backgroundColor: UIColor.systemRed,
            textColor: StyleProvider.Color.buttonTextPrimary,
            font: StyleProvider.fontWith(type: .bold, size: 9),
            horizontalPadding: 8.0,
            verticalPadding: 3.0
        )
        return MockCapsuleViewModel(data: data)
    }
    
    // For sports betting specific use cases
    public static var matchStatusLive: MockCapsuleViewModel {
        let data = CapsuleData(
            text: "1st Half, 41mins",
            backgroundColor: StyleProvider.Color.highlightSecondary,
            textColor: StyleProvider.Color.buttonTextPrimary,
            font: StyleProvider.fontWith(type: .bold, size: 10),
            horizontalPadding: 12.0,
            verticalPadding: 4.0
        )
        return MockCapsuleViewModel(data: data)
    }
    
    public static var matchStatusHalfTime: MockCapsuleViewModel {
        let data = CapsuleData(
            text: "Half Time",
            backgroundColor: StyleProvider.Color.highlightSecondary,
            textColor: StyleProvider.Color.buttonTextPrimary,
            font: StyleProvider.fontWith(type: .bold, size: 10),
            horizontalPadding: 12.0,
            verticalPadding: 4.0
        )
        return MockCapsuleViewModel(data: data)
    }
    
    public static var marketCount: MockCapsuleViewModel {
        let data = CapsuleData(
            text: "127",
            backgroundColor: StyleProvider.Color.highlightPrimary,
            textColor: StyleProvider.Color.buttonTextPrimary,
            font: StyleProvider.fontWith(type: .bold, size: 10),
            horizontalPadding: 8.0,
            verticalPadding: 4.0,
            minimumHeight: 20.0
        )
        return MockCapsuleViewModel(data: data)
    }
    
    // Customizable factory method
    public static func custom(
        text: String,
        backgroundColor: UIColor = UIColor.systemBlue,
        textColor: UIColor = UIColor.white,
        fontSize: CGFloat = 10,
        fontWeight: StyleProvider.FontType = .medium,
        horizontalPadding: CGFloat = 12.0,
        verticalPadding: CGFloat = 4.0
    ) -> MockCapsuleViewModel {
        let data = CapsuleData(
            text: text,
            backgroundColor: backgroundColor,
            textColor: textColor,
            font: StyleProvider.fontWith(type: fontWeight, size: fontSize),
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding
        )
        return MockCapsuleViewModel(data: data)
    }
}
