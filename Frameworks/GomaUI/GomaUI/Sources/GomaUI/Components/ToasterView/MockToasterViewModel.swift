import Foundation
import Combine
import UIKit

public final class MockToasterViewModel: ToasterViewModelProtocol {
    private let dataSubject: CurrentValueSubject<ToasterData, Never>
    public var dataPublisher: AnyPublisher<ToasterData, Never> { dataSubject.eraseToAnyPublisher() }
    public var currentData: ToasterData { dataSubject.value }
    
    public init(data: ToasterData = ToasterData(title: "Booking Code Loaded", icon: "checkmark", backgroundColor: .white, titleColor: StyleProvider.Color.textPrimary, iconColor: UIColor.systemGreen, cornerRadius: 14)) {
        self.dataSubject = CurrentValueSubject(data)
    }
    
    public func update(_ data: ToasterData) { dataSubject.send(data) }
}


