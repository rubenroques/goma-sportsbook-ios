//
//  LanguageSelectorFullScreenViewModelProtocol.swift
//  BetssonCameroonApp
//

import Foundation
import Combine
import GomaUI

/// Protocol defining the interface for the full-screen language selector ViewModel
protocol LanguageSelectorFullScreenViewModelProtocol {

    // MARK: - Publishers

    /// Publisher for the display state
    var displayStatePublisher: AnyPublisher<LanguageSelectorFullScreenDisplayState, Never> { get }

    /// Current display state for synchronous access
    var currentDisplayState: LanguageSelectorFullScreenDisplayState { get }

    /// The underlying language selector ViewModel for the GomaUI component
    var languageSelectorViewModel: LanguageSelectorViewModelProtocol { get }

    // MARK: - Actions

    /// Called when the back button is tapped
    func didTapBack()
}

/// Display state for the full-screen language selector
struct LanguageSelectorFullScreenDisplayState: Equatable {
    let title: String
    let isLoading: Bool

    static let initial = LanguageSelectorFullScreenDisplayState(
        title: localized("change_language"),
        isLoading: false
    )
}
