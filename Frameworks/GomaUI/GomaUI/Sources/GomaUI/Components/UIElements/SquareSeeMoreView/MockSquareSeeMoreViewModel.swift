import Foundation

/// Mock implementation of SquareSeeMoreViewModelProtocol for testing and previews
public final class MockSquareSeeMoreViewModel: SquareSeeMoreViewModelProtocol {

    // MARK: - Callbacks

    public var onSeeMoreTapped: (() -> Void)?

    // MARK: - Initialization

    public init(onSeeMoreTapped: (() -> Void)? = nil) {
        self.onSeeMoreTapped = onSeeMoreTapped
    }

    // MARK: - Protocol Methods

    public func seeMoreTapped() {
        onSeeMoreTapped?()
    }
}

// MARK: - Factory Methods

extension MockSquareSeeMoreViewModel {

    /// Default mock for previews
    public static var `default`: MockSquareSeeMoreViewModel {
        MockSquareSeeMoreViewModel()
    }

    /// Interactive mock that prints when tapped
    public static var interactive: MockSquareSeeMoreViewModel {
        MockSquareSeeMoreViewModel {
            print("See More tapped")
        }
    }
}
