import Foundation
import Combine
import GomaUI

final class ButtonIconViewModel: ButtonIconViewModelProtocol {
    
    // MARK: - Properties
    
    private let dataSubject: CurrentValueSubject<ButtonIconData, Never>
    
    // MARK: - Publishers
    
    var dataPublisher: AnyPublisher<ButtonIconData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    var currentData: ButtonIconData {
        dataSubject.value
    }
    
    // MARK: - Callback
    
    var onButtonTapped: (() -> Void)?
    
    // MARK: - Initialization
    
    init(title: String, icon: String?, layoutType: ButtonIconLayoutType = .iconLeft, isEnabled: Bool = true) {
        let initialData = ButtonIconData(
            title: title,
            icon: icon,
            layoutType: layoutType,
            isEnabled: isEnabled
        )
        self.dataSubject = CurrentValueSubject(initialData)
    }
    
    // MARK: - Protocol Methods
    
    func updateTitle(_ title: String) {
        let currentData = dataSubject.value
        let newData = ButtonIconData(
            title: title,
            icon: currentData.icon,
            layoutType: currentData.layoutType,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
    }
    
    func updateIcon(_ icon: String?) {
        let currentData = dataSubject.value
        let newData = ButtonIconData(
            title: currentData.title,
            icon: icon,
            layoutType: currentData.layoutType,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
    }
    
    func updateLayoutType(_ layoutType: ButtonIconLayoutType) {
        let currentData = dataSubject.value
        let newData = ButtonIconData(
            title: currentData.title,
            icon: currentData.icon,
            layoutType: layoutType,
            isEnabled: currentData.isEnabled
        )
        dataSubject.send(newData)
    }
    
    func setEnabled(_ isEnabled: Bool) {
        let currentData = dataSubject.value
        let newData = ButtonIconData(
            title: currentData.title,
            icon: currentData.icon,
            layoutType: currentData.layoutType,
            isEnabled: isEnabled
        )
        dataSubject.send(newData)
    }
}

// MARK: - Factory Methods

extension ButtonIconViewModel {
    
    static func rebetButton(isEnabled: Bool = true) -> ButtonIconViewModel {
        return ButtonIconViewModel(
            title: "Rebet",
            icon: "arrow.clockwise",
            layoutType: .iconLeft,
            isEnabled: isEnabled
        )
    }
    
    static func cashoutButton(isEnabled: Bool = true) -> ButtonIconViewModel {
        return ButtonIconViewModel(
            title: "Cashout",
            icon: "dollarsign.circle",
            layoutType: .iconLeft,
            isEnabled: isEnabled
        )
    }
}