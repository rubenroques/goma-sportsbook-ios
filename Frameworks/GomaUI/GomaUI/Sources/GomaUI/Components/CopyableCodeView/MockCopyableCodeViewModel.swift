import Foundation


/// Mock implementation of CopyableCodeViewModelProtocol for testing and previews
public struct MockCopyableCodeViewModel: CopyableCodeViewModelProtocol {
    public let code: String
    public let label: String
    public let copiedMessage: String

    public init(
        code: String,
        label: String = LocalizationProvider.string("copy_booking_code"),
        copiedMessage: String = "Copied to Clipboard"
    ) {
        self.code = code
        self.label = label
        self.copiedMessage = copiedMessage
    }

    public func onCopyTapped() {
        print("📋 Mock: Copied code '\(code)' to clipboard")
        // Real implementation would call UIPasteboard.general.string = code
    }
}

// MARK: - Factory Methods
public extension MockCopyableCodeViewModel {

    /// Default booking code mock
    static var bookingCodeMock: MockCopyableCodeViewModel {
        MockCopyableCodeViewModel(
            code: "ABCD1E2",
            label: LocalizationProvider.string("copy_booking_code")
        )
    }

    /// Promo code example
    static var promoCodeMock: MockCopyableCodeViewModel {
        MockCopyableCodeViewModel(
            code: "SUMMER2025",
            label: "Copy Promo Code"
        )
    }

    /// Long code to test layout
    static var longCodeMock: MockCopyableCodeViewModel {
        MockCopyableCodeViewModel(
            code: "ABCD1E2F3G4H5J6K7",
            label: "Copy Transaction ID"
        )
    }

    /// Referral code example
    static var referralCodeMock: MockCopyableCodeViewModel {
        MockCopyableCodeViewModel(
            code: "REF-XYZ789",
            label: "Copy Referral Code"
        )
    }
}
