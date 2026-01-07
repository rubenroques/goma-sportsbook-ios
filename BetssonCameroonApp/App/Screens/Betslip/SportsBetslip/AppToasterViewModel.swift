import Foundation
import Combine
import CombineSchedulers
import UIKit
import GomaUI

final class AppToasterViewModel: ToasterViewModelProtocol {
    
    private let dataSubject: CurrentValueSubject<ToasterData, Never>
    
    var dataPublisher: AnyPublisher<ToasterData, Never> { dataSubject.eraseToAnyPublisher() }
    var currentData: ToasterData { dataSubject.value }

    /// Scheduler for receiving updates. Defaults to main queue for production.
    let scheduler: AnySchedulerOf<DispatchQueue>

    init(
        initialData: ToasterData = ToasterData(
            title: localized("booking_code_loaded"),
            icon: "check_icon",
            backgroundColor: StyleProvider.Color.backgroundSecondary,
            titleColor: StyleProvider.Color.textPrimary,
            iconColor: StyleProvider.Color.highlightSecondary,
            cornerRadius: 16
        ),
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.dataSubject = CurrentValueSubject(initialData)
        self.scheduler = scheduler
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


