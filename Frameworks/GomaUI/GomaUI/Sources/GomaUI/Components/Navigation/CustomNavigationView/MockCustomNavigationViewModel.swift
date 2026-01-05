import Foundation
import UIKit
import Combine

public final class MockCustomNavigationViewModel: CustomNavigationViewModelProtocol {
    
    private let dataSubject: CurrentValueSubject<CustomNavigationData, Never>
    
    public var data: CustomNavigationData {
        dataSubject.value
    }
    
    public var dataPublisher: AnyPublisher<CustomNavigationData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public init(data: CustomNavigationData) {
        self.dataSubject = CurrentValueSubject(data)
    }
    
    public func configure(with data: CustomNavigationData) {
        dataSubject.send(data)
    }
}

// MARK: - Factory Methods
extension MockCustomNavigationViewModel {
    public static var defaultMock: MockCustomNavigationViewModel {
        
        let data = CustomNavigationData(
            logoImage: "betsson_logo",
            closeIcon: nil
        )
        
        return MockCustomNavigationViewModel(data: data)
    }
    
    public static var blueMock: MockCustomNavigationViewModel {
        
        let data = CustomNavigationData(
            logoImage: "betsson_logo",
            closeIcon: nil,
            backgroundColor: UIColor.systemBlue,
            closeButtonBackgroundColor: .clear,
            closeIconTintColor: .white
        )
        
        return MockCustomNavigationViewModel(data: data)
    }
    
}
