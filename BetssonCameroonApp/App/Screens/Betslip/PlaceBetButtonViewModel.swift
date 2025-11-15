import Foundation
import Combine
import GomaUI

/// Production implementation of ButtonViewModelProtocol
/// Specifically configured for the "Place Bet" button in betslip
final class PlaceBetButtonViewModel: ButtonViewModelProtocol {

    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<ButtonData, Never>

    var buttonDataPublisher: AnyPublisher<ButtonData, Never> {
        dataSubject.eraseToAnyPublisher()
    }

    var onButtonTapped: (() -> Void)?

    private var currentButtonData: ButtonData {
        dataSubject.value
    }

    // MARK: - Initialization
    init(buttonData: ButtonData) {
        self.dataSubject = CurrentValueSubject(buttonData)
    }

    // MARK: - Protocol Methods
    func buttonTapped() {
        onButtonTapped?()
    }

    func setEnabled(_ isEnabled: Bool) {
        let newData = ButtonData(
            id: currentButtonData.id,
            title: currentButtonData.title,
            style: currentButtonData.style,
            backgroundColor: currentButtonData.backgroundColor,
            disabledBackgroundColor: currentButtonData.disabledBackgroundColor,
            borderColor: currentButtonData.borderColor,
            textColor: currentButtonData.textColor,
            fontSize: currentButtonData.fontSize,
            fontType: currentButtonData.fontType,
            isEnabled: isEnabled
        )
        dataSubject.send(newData)
    }

    func updateTitle(_ title: String) {
        let newData = ButtonData(
            id: currentButtonData.id,
            title: title,
            style: currentButtonData.style,
            backgroundColor: currentButtonData.backgroundColor,
            disabledBackgroundColor: currentButtonData.disabledBackgroundColor,
            borderColor: currentButtonData.borderColor,
            textColor: currentButtonData.textColor,
            fontSize: currentButtonData.fontSize,
            fontType: currentButtonData.fontType,
            isEnabled: currentButtonData.isEnabled
        )
        dataSubject.send(newData)
    }
}

// MARK: - Factory Methods
extension PlaceBetButtonViewModel {

    /// Creates a PlaceBetButtonViewModel for the betslip "Place Bet" button
    /// - Parameter currency: The currency code (e.g., "XAF", "EUR")
    /// - Returns: Configured PlaceBetButtonViewModel with initial state
    static func placeBet(currency: String) -> PlaceBetButtonViewModel {
        return PlaceBetButtonViewModel(
            buttonData: ButtonData(
                id: "place_bet",
                title: LocalizationProvider.string("place_bet_with_amount")
                    .replacingOccurrences(of: "{currency}", with: currency)
                    .replacingOccurrences(of: "{amount}", with: "0"),
                style: .solidBackground,
                isEnabled: false
            )
        )
    }
}
