import Foundation
import Combine
import UIKit
import GomaUI

final class ButtonViewModel: ButtonViewModelProtocol {
    
    // MARK: - Properties
    
    private let dataSubject: CurrentValueSubject<ButtonData, Never>
    
    // MARK: - Publishers
    
    var buttonDataPublisher: AnyPublisher<ButtonData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Callbacks
    
    var onButtonTapped: (() -> Void)?
    
    // MARK: - Initialization
    
    init(
        id: String,
        title: String,
        style: ButtonStyle,
        backgroundColor: UIColor? = nil,
        disabledBackgroundColor: UIColor? = nil,
        isEnabled: Bool = true
    ) {
        let buttonData = ButtonData(
            id: id,
            title: title,
            style: style,
            backgroundColor: backgroundColor,
            disabledBackgroundColor: disabledBackgroundColor,
            isEnabled: isEnabled
        )
        self.dataSubject = CurrentValueSubject(buttonData)
    }
    
    // MARK: - Protocol Methods
    
    func buttonTapped() {
        onButtonTapped?()
    }
    
    func setEnabled(_ isEnabled: Bool) {
        let currentData = dataSubject.value
        let newData = ButtonData(
            id: currentData.id,
            title: currentData.title,
            style: currentData.style,
            backgroundColor: currentData.backgroundColor,
            disabledBackgroundColor: currentData.disabledBackgroundColor,
            isEnabled: isEnabled
        )
        dataSubject.send(newData)
    }
    
    func updateTitle(_ title: String) {
        let currentData = dataSubject.value
        let newData = ButtonData(
            id: currentData.id,
            title: title,
            style: currentData.style,
            backgroundColor: currentData.backgroundColor,
            disabledBackgroundColor: currentData.disabledBackgroundColor,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
    }
}

// MARK: - Factory Methods

extension ButtonViewModel {
    
    static func cashoutButton(id: String = "cashout", isEnabled: Bool = true) -> ButtonViewModel {
        return ButtonViewModel(
            id: id,
            title: "Cashout",
            style: .solidBackground,
            backgroundColor: UIColor.systemGreen,
            disabledBackgroundColor: UIColor.systemGray,
            isEnabled: isEnabled
        )
    }
    
    static func confirmButton(id: String = "confirm", title: String = "Confirm", isEnabled: Bool = true) -> ButtonViewModel {
        return ButtonViewModel(
            id: id,
            title: title,
            style: .solidBackground,
            backgroundColor: UIColor.systemBlue,
            disabledBackgroundColor: UIColor.systemGray,
            isEnabled: isEnabled
        )
    }
}