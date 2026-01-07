import Foundation
import Combine
import CombineSchedulers
import UIKit

public final class MockToasterViewModel: ToasterViewModelProtocol {
    private let dataSubject: CurrentValueSubject<ToasterData, Never>
    public var dataPublisher: AnyPublisher<ToasterData, Never> { dataSubject.eraseToAnyPublisher() }
    public var currentData: ToasterData { dataSubject.value }

    /// Scheduler for receiving updates. Defaults to `.immediate` for synchronous test execution.
    public let scheduler: AnySchedulerOf<DispatchQueue>

    public init(
        data: ToasterData = ToasterData(
            title: "Booking Code Loaded",
            icon: "checkmark",
            backgroundColor: .white,
            titleColor: StyleProvider.Color.textPrimary,
            iconColor: UIColor.systemGreen,
            cornerRadius: 14
        ),
        scheduler: AnySchedulerOf<DispatchQueue> = .immediate
    ) {
        self.dataSubject = CurrentValueSubject(data)
        self.scheduler = scheduler
    }

    public func update(_ data: ToasterData) { dataSubject.send(data) }
}


