import Foundation
import Combine
import UIKit


/// Mock implementation of `ButtonViewModelProtocol` for testing.
final public class MockButtonViewModel: ButtonViewModelProtocol {

    // MARK: - Properties
    private let buttonDataSubject: CurrentValueSubject<ButtonData, Never>

    public var currentButtonData: ButtonData {
        buttonDataSubject.value
    }

    public var buttonDataPublisher: AnyPublisher<ButtonData, Never> {
        buttonDataSubject.eraseToAnyPublisher()
    }

    // MARK: - Callback
    public var onButtonTapped: (() -> Void)?

    // MARK: - Initialization
    public init(buttonData: ButtonData) {
        self.buttonDataSubject = CurrentValueSubject(buttonData)
    }
    
    // MARK: - ButtonViewModelProtocol
    public func buttonTapped() {
        let currentData = buttonDataSubject.value
        print("Button tapped: \(currentData.id)")
        
        // Call the callback if set
        onButtonTapped?()
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        let currentData = buttonDataSubject.value
        let updatedData = ButtonData(
            id: currentData.id,
            title: currentData.title,
            style: currentData.style,
            backgroundColor: currentData.backgroundColor,
            disabledBackgroundColor: currentData.disabledBackgroundColor,
            borderColor: currentData.borderColor,
            textColor: currentData.textColor,
            fontSize: currentData.fontSize,
            fontType: currentData.fontType,
            isEnabled: isEnabled
        )
        buttonDataSubject.send(updatedData)
    }
    
    public func updateTitle(_ title: String) {
        let currentData = buttonDataSubject.value
        let updatedData = ButtonData(
            id: currentData.id,
            title: title,
            style: currentData.style,
            backgroundColor: currentData.backgroundColor,
            disabledBackgroundColor: currentData.disabledBackgroundColor,
            borderColor: currentData.borderColor,
            textColor: currentData.textColor,
            fontSize: currentData.fontSize,
            fontType: currentData.fontType,
            isEnabled: currentData.isEnabled
        )
        buttonDataSubject.send(updatedData)
    }
}

// MARK: - Mock Factory
extension MockButtonViewModel {
    
    // MARK: - Solid Background Buttons
    public static var solidBackgroundMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "confirm_payment",
            title: "Confirm Payment",
            style: .solidBackground,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var solidBackgroundDisabledMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "confirm_payment_disabled",
            title: "Confirm Payment",
            style: .solidBackground,
            isEnabled: false
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var claimBonusMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "claim_bonus",
            title: "Claim bonus",
            style: .solidBackground,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    // MARK: - Bordered Buttons
    public static var borderedMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "resend_ussd",
            title: "Resend USSD Push",
            style: .bordered,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var borderedDisabledMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "resend_ussd_disabled",
            title: "Resend USSD Push",
            style: .bordered,
            isEnabled: false
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    // MARK: - Transparent Buttons
    public static var transparentMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "terms_conditions",
            title: LocalizationProvider.string("terms_consent_popup_title"),
            style: .transparent,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var transparentDisabledMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "terms_conditions_disabled",
            title: LocalizationProvider.string("terms_consent_popup_title"),
            style: .transparent,
            isEnabled: false
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    // MARK: - Additional Common Buttons
    public static var submitMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "submit",
            title: LocalizationProvider.string("submit"),
            style: .solidBackground,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var cancelMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "cancel",
            title: LocalizationProvider.string("cancel"),
            style: .bordered,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var learnMoreMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "learn_more",
            title: "Learn More",
            style: .transparent,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    // MARK: - Custom Color Variants
    public static var solidBackgroundCustomColorMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "solid_custom_color",
            title: "Custom Solid Button",
            style: .solidBackground,
            backgroundColor: UIColor.systemRed,
            textColor: UIColor.white,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var borderedCustomColorMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "bordered_custom_color",
            title: "Custom Border Button",
            style: .bordered,
            borderColor: UIColor.systemBlue,
            textColor: UIColor.systemBlue,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var transparentCustomColorMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "transparent_custom_color",
            title: "Custom Transparent",
            style: .transparent,
            textColor: UIColor.systemPurple,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    // MARK: - Color Theme Variants
    public static var redThemeMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "red_theme",
            title: "Red Theme",
            style: .solidBackground,
            backgroundColor: UIColor.systemRed,
            textColor: UIColor.white,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var blueThemeMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "blue_theme",
            title: "Blue Theme",
            style: .bordered,
            borderColor: UIColor.systemBlue,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var greenThemeMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "green_theme",
            title: "Green Theme",
            style: .solidBackground,
            backgroundColor: UIColor.systemGreen,
            textColor: UIColor.black,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var orangeThemeMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "orange_theme",
            title: "Orange Border",
            style: .bordered,
            borderColor: UIColor.systemOrange,
            textColor: UIColor.systemOrange,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    // MARK: - Font Customization Variants
    public static var largeFontMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "large_font",
            title: "Large Button",
            style: .solidBackground,
            fontSize: 24.0,
            fontType: .bold,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var smallFontMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "small_font",
            title: "Small Button",
            style: .bordered,
            fontSize: 12.0,
            fontType: .medium,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var lightFontMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "light_font",
            title: "Light Font Button",
            style: .solidBackground,
            backgroundColor: UIColor.systemGray5,
            textColor: UIColor.systemGray,
            fontSize: 18.0,
            fontType: .light,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var heavyFontMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "heavy_font",
            title: "HEAVY FONT",
            style: .bordered,
            borderColor: UIColor.systemRed,
            textColor: UIColor.systemRed,
            fontSize: 20.0,
            fontType: .heavy,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
    
    public static var customFontStyleMock: MockButtonViewModel {
        let buttonData = ButtonData(
            id: "custom_font_style",
            title: "Custom Style",
            style: .transparent,
            textColor: UIColor.systemPurple,
            fontSize: 16.0,
            fontType: .semibold,
            isEnabled: true
        )
        return MockButtonViewModel(buttonData: buttonData)
    }
}
