//
//  BetssonCameroonNavigationBarViewModel.swift
//  BetssonCameroonApp
//
//  Created on 10/11/2025.
//

import Foundation
import GomaUI

/// Reusable production ViewModel for SimpleNavigationBarView across BetssonCameroonApp.
///
/// This ViewModel provides consistent navigation bar configuration with localized
/// back button text and callback-based navigation for all screens.
///
/// ## Usage
/// ```swift
/// let viewModel = BetssonCameroonNavigationBarViewModel(
///     title: "Transaction History",
///     onBackTapped: { [weak self] in
///         self?.viewModel.didTapBack()
///     }
/// )
/// let navBar = SimpleNavigationBarView(viewModel: viewModel)
/// ```
///
/// ## Features
/// - Consistent localization via LocalizationProvider
/// - Icon + localized "Back" text for all navigation bars
/// - Optional centered title
/// - Callback-based navigation (coordinator-friendly)
final class BetssonCameroonNavigationBarViewModel: SimpleNavigationBarViewModelProtocol {

    // MARK: - SimpleNavigationBarViewModelProtocol

    let backButtonText: String?
    let title: String?
    let showBackButton: Bool
    let onBackTapped: () -> Void

    // MARK: - Initialization

    /// Creates a navigation bar view model for BetssonCameroonApp screens.
    ///
    /// - Parameters:
    ///   - title: Optional centered title text for the navigation bar.
    ///   - showBackText: Whether to show localized "Back" text next to the icon. Default `true`.
    ///   - showBackButton: Whether to display the back button. Default `true`.
    ///   - onBackTapped: Callback executed when back button is tapped.
    init(
        title: String? = nil,
        showBackText: Bool = true,
        showBackButton: Bool = true,
        onBackTapped: @escaping () -> Void
    ) {
        self.backButtonText = showBackText ? LocalizationProvider.string("back") : nil
        self.title = title
        self.showBackButton = showBackButton
        self.onBackTapped = onBackTapped
    }
}
