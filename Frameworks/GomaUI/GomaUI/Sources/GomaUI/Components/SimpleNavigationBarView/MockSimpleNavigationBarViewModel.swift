import Foundation

/// Mock implementation of `SimpleNavigationBarViewModelProtocol` for testing and previews.
///
/// This mock provides configurable states for the navigation bar and is primarily
/// used in SwiftUI previews and unit tests.
///
/// ## Usage in SwiftUI Previews
/// ```swift
/// #Preview("Icon Only") {
///     PreviewUIView {
///         SimpleNavigationBarView(
///             viewModel: MockSimpleNavigationBarViewModel.iconOnly
///         )
///     }
/// }
/// ```
///
/// ## Custom Configuration
/// ```swift
/// let viewModel = MockSimpleNavigationBarViewModel(
///     backButtonText: "Back",
///     title: "Settings",
///     onBackTapped: { print("Back tapped") }
/// )
/// ```
public final class MockSimpleNavigationBarViewModel: SimpleNavigationBarViewModelProtocol {

    // MARK: - SimpleNavigationBarViewModelProtocol

    public let backButtonText: String?
    public let title: String?
    public let showBackButton: Bool
    public let onBackTapped: () -> Void

    // MARK: - Initialization

    /// Creates a mock navigation bar view model.
    ///
    /// - Parameters:
    ///   - backButtonText: Optional text next to back icon. `nil` shows icon only.
    ///   - title: Optional centered title text.
    ///   - showBackButton: Whether to display the back button. Default `true`.
    ///   - onBackTapped: Callback when back button is tapped. Default prints to console.
    public init(
        backButtonText: String? = nil,
        title: String? = nil,
        showBackButton: Bool = true,
        onBackTapped: @escaping () -> Void = { print("🔙 Mock: Back button tapped") }
    ) {
        self.backButtonText = backButtonText
        self.title = title
        self.showBackButton = showBackButton
        self.onBackTapped = onBackTapped
    }
}

// MARK: - Mock Factories

extension MockSimpleNavigationBarViewModel {

    /// Icon-only back button with no text or title.
    ///
    /// **Visual**: `← ` (chevron only)
    public static var iconOnly: MockSimpleNavigationBarViewModel {
        MockSimpleNavigationBarViewModel()
    }

    /// Back button with "Back" text label.
    ///
    /// **Visual**: `← Back`
    public static var withBackText: MockSimpleNavigationBarViewModel {
        MockSimpleNavigationBarViewModel(
            backButtonText: LocalizationProvider.string("back")
        )
    }

    /// Back button (icon only) with centered title.
    ///
    /// **Visual**: `←           Transaction History`
    public static var withTitle: MockSimpleNavigationBarViewModel {
        MockSimpleNavigationBarViewModel(
            title: LocalizationProvider.string("transaction_history")
        )
    }

    /// Back button with text + centered title.
    ///
    /// **Visual**: `← Back      Notifications`
    public static var withBackTextAndTitle: MockSimpleNavigationBarViewModel {
        MockSimpleNavigationBarViewModel(
            backButtonText: LocalizationProvider.string("back"),
            title: LocalizationProvider.string("notifications")
        )
    }

    /// Title-only navigation bar (no back button).
    ///
    /// **Visual**: `             Settings              `
    public static var titleOnly: MockSimpleNavigationBarViewModel {
        MockSimpleNavigationBarViewModel(
            title: LocalizationProvider.string("settings"),
            showBackButton: false
        )
    }

    /// Long title to test text truncation.
    ///
    /// **Visual**: `← Back      Very Long Title That...`
    public static var longTitle: MockSimpleNavigationBarViewModel {
        MockSimpleNavigationBarViewModel(
            backButtonText: LocalizationProvider.string("back"),
            title: "Very Long Navigation Bar Title That Should Truncate Properly"
        )
    }
}
