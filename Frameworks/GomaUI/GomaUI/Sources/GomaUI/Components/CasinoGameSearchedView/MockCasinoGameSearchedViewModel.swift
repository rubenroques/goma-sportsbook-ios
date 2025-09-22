import Foundation
import Combine

public final class MockCasinoGameSearchedViewModel: CasinoGameSearchedViewModelProtocol {
    
    private let dataSubject: CurrentValueSubject<CasinoGameSearchedData, Never>
    private let stateSubject: CurrentValueSubject<CasinoGameSearchedDisplayState, Never>
    private let selectedSubject: PassthroughSubject<String, Never> = .init()
    public var onSelected: AnyPublisher<String, Never> { selectedSubject.eraseToAnyPublisher() }
    
    public var dataPublisher: AnyPublisher<CasinoGameSearchedData, Never> { dataSubject.eraseToAnyPublisher() }
    public var displayStatePublisher: AnyPublisher<CasinoGameSearchedDisplayState, Never> { stateSubject.eraseToAnyPublisher() }
    
    public init(data: CasinoGameSearchedData, state: CasinoGameSearchedDisplayState = .normal) {
        self.dataSubject = .init(data)
        self.stateSubject = .init(state)
    }
    
    // MARK: - Inputs
    public func didSelect() {
        selectedSubject.send(dataSubject.value.id)
    }
    
    public func imageLoadingSucceeded() {
        stateSubject.send(.normal)
    }
    
    public func imageLoadingFailed() {
        stateSubject.send(.imageError)
    }
}

// MARK: - Convenience Mocks
public extension MockCasinoGameSearchedViewModel {
    static let gonzo = MockCasinoGameSearchedViewModel(
        data: CasinoGameSearchedData(
            id: "gonzos-quest",
            title: "Gonzo’s Quest",
            provider: "Netent",
            imageURL: nil
        ),
        state: .imageError
    )
    
    static let aviator = MockCasinoGameSearchedViewModel(
        data: CasinoGameSearchedData(
            id: "aviator",
            title: "Aviator",
            provider: "Spribe",
            imageURL: "https://picsum.photos/seed/aviator/256/256"
        )
    )
}


