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
    private let placeholderText: CurrentValueSubject<String, Never>
    private let attributedPlaceholder: CurrentValueSubject<NSAttributedString?, Never>
    private let text = CurrentValueSubject<String, Never>("")
    private let isClearButtonVisible = CurrentValueSubject<Bool, Never>(false)
    private let isEnabled = CurrentValueSubject<Bool, Never>(true)

    public init(placeholder: String = "Search in Sportsbook", attributedPlaceholder: NSAttributedString? = nil) {
        self.placeholderText = CurrentValueSubject<String, Never>(placeholder)
        self.attributedPlaceholder = CurrentValueSubject<NSAttributedString?, Never>(attributedPlaceholder)
    }

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
    }

    public func submit() {
    }

    // Convenience presets
    public static var `default`: MockSearchViewModel {
        MockSearchViewModel()
    }

    // Convenience factory with placeholder
    public static func withPlaceholder(_ text: String) -> MockSearchViewModel {
        MockSearchViewModel(placeholder: text)
    }

    // Runtime update if needed
    public func updatePlaceholder(_ text: String) {
        self.placeholderText.send(text)
    }
}


