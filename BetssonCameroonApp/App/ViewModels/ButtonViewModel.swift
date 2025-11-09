//
//  ButtonViewModel.swift
//  BetssonCameroonApp
//
//  Created by Assistant on 02/09/2025.
//

import Foundation
import Combine
import GomaUI
import UIKit

final class ButtonViewModel: ButtonViewModelProtocol {
    
    // MARK: - Properties
    
    private let buttonDataSubject: CurrentValueSubject<ButtonData, Never>
    var buttonDataPublisher: AnyPublisher<ButtonData, Never> {
        buttonDataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Callback
    
    var onButtonTapped: (() -> Void)?
    
    // MARK: - Initialization
    
    init(buttonData: ButtonData) {
        self.buttonDataSubject = CurrentValueSubject(buttonData)
    }
    
    // MARK: - ButtonViewModelProtocol
    
    func buttonTapped() {
        let currentData = buttonDataSubject.value
        print("🔘 ButtonViewModel: Button tapped - \(currentData.id)")
        
        // Call the callback if set
        onButtonTapped?()
    }
    
    func setEnabled(_ isEnabled: Bool) {
        let currentData = buttonDataSubject.value
        let updatedData = ButtonData(
            id: currentData.id,
            title: currentData.title,
            style: currentData.style,
            backgroundColor: currentData.backgroundColor,
            disabledBackgroundColor: currentData.disabledBackgroundColor,
            borderColor: currentData.borderColor,
            textColor: currentData.textColor,
            fontSize: currentData.fontSize,
            fontType: currentData.fontType,
            isEnabled: isEnabled
        )
        buttonDataSubject.send(updatedData)
        print("🔘 ButtonViewModel: Enabled state updated - \(currentData.id): \(isEnabled)")
    }
    
    func updateTitle(_ title: String) {
        let currentData = buttonDataSubject.value
        let updatedData = ButtonData(
            id: currentData.id,
            title: title,
            style: currentData.style,
            backgroundColor: currentData.backgroundColor,
            disabledBackgroundColor: currentData.disabledBackgroundColor,
            borderColor: currentData.borderColor,
            textColor: currentData.textColor,
            fontSize: currentData.fontSize,
            fontType: currentData.fontType,
            isEnabled: currentData.isEnabled
        )
        buttonDataSubject.send(updatedData)
        print("🔘 ButtonViewModel: Title updated - \(currentData.id): \(title)")
    }
}

extension ButtonViewModel {
    
    static func cashoutButton(isEnabled: Bool = true) -> ButtonViewModel {
        let buttonData = ButtonData(
            id: "cashout",
            title: "Cashout",
            style: .solidBackground,
            backgroundColor: UIColor.systemGreen,
            disabledBackgroundColor: UIColor.systemGray,
            isEnabled: isEnabled
        )
        return ButtonViewModel(buttonData: buttonData)
    }
    
    static func confirmButton(isEnabled: Bool = true) -> ButtonViewModel {
        let buttonData = ButtonData(
            id: "confirm",
            title: "Confirm",
            style: .solidBackground,
            backgroundColor: UIColor.systemBlue,
            disabledBackgroundColor: UIColor.systemGray,
            isEnabled: isEnabled
        )
        return ButtonViewModel(buttonData: buttonData)
    }
    
    static func depositButton(isEnabled: Bool = true) -> ButtonViewModel {
        let buttonData = ButtonData(
            id: "deposit",
            title: localized("deposit"),
            style: .solidBackground,
            fontSize: 12,
            fontType: .bold,
            isEnabled: isEnabled
        )
        return ButtonViewModel(buttonData: buttonData)
    }
    
    static func withdrawButton(isEnabled: Bool = true) -> ButtonViewModel {
        let buttonData = ButtonData(
            id: "withdraw",
            title: localized("withdraw"),
            style: .bordered,
            fontSize: 12,
            fontType: .bold,
            isEnabled: isEnabled
        )
        return ButtonViewModel(buttonData: buttonData)
    }
}
