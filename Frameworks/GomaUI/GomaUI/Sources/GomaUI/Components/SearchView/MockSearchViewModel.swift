import Foundation
import Combine
import UIKit

public final class MockSearchViewModel: SearchViewModelProtocol {
    // Publishers
    public var placeholderTextPublisher: AnyPublisher<String, Never> { placeholderText.eraseToAnyPublisher() }
    public var attributedPlaceholderPublisher: AnyPublisher<NSAttributedString?, Never> { attributedPlaceholder.eraseToAnyPublisher() }
    public var textPublisher: AnyPublisher<String, Never> { text.eraseToAnyPublisher() }
    public var isClearButtonVisiblePublisher: AnyPublisher<Bool, Never> { isClearButtonVisible.eraseToAnyPublisher() }
    public var isEnabledPublisher: AnyPublisher<Bool, Never> { isEnabled.eraseToAnyPublisher() }

    // Subjects
    private let placeholderText = CurrentValueSubject<String, Never>("Search in Sportsbook")
    private let attributedPlaceholder = CurrentValueSubject<NSAttributedString?, Never>(nil)
    private let text = CurrentValueSubject<String, Never>("")
    private let isClearButtonVisible = CurrentValueSubject<Bool, Never>(false)
    private let isEnabled = CurrentValueSubject<Bool, Never>(true)

    public init() {}

    // Inputs
    public func updateText(_ text: String) {
        self.text.send(text)
        self.isClearButtonVisible.send(!text.isEmpty)
    }

    public func clearText() {
        self.text.send("")
        self.isClearButtonVisible.send(false)
    }

    public func setFocused(_ isFocused: Bool) {
        // No-op for mock, could simulate analytics or state if needed
    }

    public func submit() {
        // No-op for mock
    }

    // Convenience presets
    public static var `default`: MockSearchViewModel {
        MockSearchViewModel()
    }
}


