import Foundation
import Combine
import UIKit

// MARK: - SearchViewModelProtocol
public protocol SearchViewModelProtocol: AnyObject {
    // Content
    var placeholderTextPublisher: AnyPublisher<String, Never> { get }
    var attributedPlaceholderPublisher: AnyPublisher<NSAttributedString?, Never> { get }
    var textPublisher: AnyPublisher<String, Never> { get }

    // UI State
    var isClearButtonVisiblePublisher: AnyPublisher<Bool, Never> { get }
    var isEnabledPublisher: AnyPublisher<Bool, Never> { get }

    // Inputs
    func updateText(_ text: String)
    func clearText()
    func setFocused(_ isFocused: Bool)
    func submit()
}


