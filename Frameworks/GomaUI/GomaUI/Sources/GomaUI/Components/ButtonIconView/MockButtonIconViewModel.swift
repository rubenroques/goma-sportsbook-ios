import Foundation
import Combine
import UIKit


/// Mock implementation of ButtonIconViewModelProtocol for testing and previews
public final class MockButtonIconViewModel: ButtonIconViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<ButtonIconData, Never>
    
    public var dataPublisher: AnyPublisher<ButtonIconData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: ButtonIconData {
        dataSubject.value
    }
    
    // MARK: - Initialization
    public init(title: String = "Button", icon: String? = nil, layoutType: ButtonIconLayoutType = .iconLeft, isEnabled: Bool = true, backgroundColor: UIColor? = nil, cornerRadius: CGFloat? = nil, iconColor: UIColor? = nil) {
        let initialData = ButtonIconData(title: title, icon: icon, layoutType: layoutType, isEnabled: isEnabled, backgroundColor: backgroundColor, cornerRadius: cornerRadius, iconColor: iconColor)
        self.dataSubject = CurrentValueSubject(initialData)
    }
    
    // MARK: - Protocol Methods
    public func updateTitle(_ title: String) {
        let newData = ButtonIconData(title: title, icon: currentData.icon, layoutType: currentData.layoutType, isEnabled: currentData.isEnabled, backgroundColor: currentData.backgroundColor, cornerRadius: currentData.cornerRadius, iconColor: currentData.iconColor)
        dataSubject.send(newData)
    }
    
    public func updateIcon(_ icon: String?) {
        let newData = ButtonIconData(title: currentData.title, icon: icon, layoutType: currentData.layoutType, isEnabled: currentData.isEnabled, backgroundColor: currentData.backgroundColor, cornerRadius: currentData.cornerRadius, iconColor: currentData.iconColor)
        dataSubject.send(newData)
    }
    
    public func updateLayoutType(_ layoutType: ButtonIconLayoutType) {
        let newData = ButtonIconData(title: currentData.title, icon: currentData.icon, layoutType: layoutType, isEnabled: currentData.isEnabled, backgroundColor: currentData.backgroundColor, cornerRadius: currentData.cornerRadius, iconColor: currentData.iconColor)
        dataSubject.send(newData)
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        dataSubject.send(ButtonIconData(
            title: currentData.title,
            icon: currentData.icon,
            layoutType: currentData.layoutType,
            isEnabled: isEnabled,
            backgroundColor: currentData.backgroundColor,
            cornerRadius: currentData.cornerRadius,
            iconColor: currentData.iconColor
        ))
    }

    public func updateBackgroundColor(_ color: UIColor?) {
        dataSubject.send(ButtonIconData(
            title: currentData.title,
            icon: currentData.icon,
            layoutType: currentData.layoutType,
            isEnabled: currentData.isEnabled,
            backgroundColor: color,
            cornerRadius: currentData.cornerRadius,
            iconColor: currentData.iconColor
        ))
    }

    public func updateCornerRadius(_ radius: CGFloat?) {
        dataSubject.send(ButtonIconData(
            title: currentData.title,
            icon: currentData.icon,
            layoutType: currentData.layoutType,
            isEnabled: currentData.isEnabled,
            backgroundColor: currentData.backgroundColor,
            cornerRadius: radius,
            iconColor: currentData.iconColor
        ))
    }
    
    public func updateIconColor(_ color: UIColor?) {
        dataSubject.send(ButtonIconData(
            title: currentData.title,
            icon: currentData.icon,
            layoutType: currentData.layoutType,
            isEnabled: currentData.isEnabled,
            backgroundColor: currentData.backgroundColor,
            cornerRadius: currentData.cornerRadius,
            iconColor: color
        ))
    }
    
    // MARK: - Callbacks
    public var onButtonTapped: (() -> Void)?
}

// MARK: - Factory Methods
public extension MockButtonIconViewModel {
    
    /// Creates a mock view model for booking code button
    static func bookingCodeMock() -> MockButtonIconViewModel {
        return MockButtonIconViewModel(
            title: "Booking Code",
            icon: "square.and.arrow.up",
            layoutType: .iconLeft
        )
    }
    
    /// Creates a mock view model for clear betslip button
    static func clearBetslipMock() -> MockButtonIconViewModel {
        return MockButtonIconViewModel(
            title: LocalizationProvider.string("clear_betslip"),
            icon: "trash",
            layoutType: .iconRight
        )
    }
    
    /// Creates a mock view model for disabled state
    static func disabledMock() -> MockButtonIconViewModel {
        return MockButtonIconViewModel(
            title: "Disabled Button",
            icon: "star",
            layoutType: .iconLeft,
            isEnabled: false
        )
    }
} 
