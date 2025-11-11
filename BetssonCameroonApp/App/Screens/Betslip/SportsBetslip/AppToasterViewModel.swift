import Foundation
import Combine
import UIKit
import GomaUI

final class AppToasterViewModel: ToasterViewModelProtocol {
    private let dataSubject: CurrentValueSubject<ToasterData, Never>
    var dataPublisher: AnyPublisher<ToasterData, Never> { dataSubject.eraseToAnyPublisher() }
    var currentData: ToasterData { dataSubject.value }
    
    init(initialData: ToasterData = ToasterData(
        title: localized("booking_code_loaded"),
        icon: "check_icon",
        backgroundColor: StyleProvider.Color.backgroundSecondary,
        titleColor: StyleProvider.Color.textPrimary,
        iconColor: StyleProvider.Color.highlightSecondary,
        cornerRadius: 16
    )) {
        self.dataSubject = CurrentValueSubject(initialData)
    }
    
    func updateTitle(_ title: String) {
        let current = dataSubject.value
        dataSubject.send(ToasterData(
            title: title,
            icon: current.icon,
            backgroundColor: current.backgroundColor,
            titleColor: current.titleColor,
            iconColor: current.iconColor,
            cornerRadius: current.cornerRadius
        ))
    }
    
    func updateColors(background: UIColor? = nil, title: UIColor? = nil, icon: UIColor? = nil) {
        let current = dataSubject.value
        dataSubject.send(ToasterData(
            title: current.title,
            icon: current.icon,
            backgroundColor: background ?? current.backgroundColor,
            titleColor: title ?? current.titleColor,
            iconColor: icon ?? current.iconColor,
            cornerRadius: current.cornerRadius
        ))
    }
}


