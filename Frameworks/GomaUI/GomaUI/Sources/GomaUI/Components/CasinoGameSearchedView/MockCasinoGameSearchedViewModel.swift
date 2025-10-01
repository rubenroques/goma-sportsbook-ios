//
//  MockCasinoGameSearchedViewModel.swift
//  GomaUI
//
//  Created to provide a mock implementation for CasinoGameSearchedView
//

import Foundation
import Combine

public final class MockCasinoGameSearchedViewModel: CasinoGameSearchedViewModelProtocol {
    
    // MARK: - Publishers
    private let dataSubject: CurrentValueSubject<CasinoGameSearchedData, Never>
    private let displayStateSubject: CurrentValueSubject<CasinoGameSearchedDisplayState, Never>
    private let selectedSubject = PassthroughSubject<String, Never>()
    
    public var dataPublisher: AnyPublisher<CasinoGameSearchedData, Never> {
        return dataSubject.eraseToAnyPublisher()
    }
    
    public var displayStatePublisher: AnyPublisher<CasinoGameSearchedDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }
    
    public var onSelected: AnyPublisher<String, Never> {
        return selectedSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Init
    public init(data: CasinoGameSearchedData,
                state: CasinoGameSearchedDisplayState = .normal) {
        self.dataSubject = CurrentValueSubject<CasinoGameSearchedData, Never>(data)
        self.displayStateSubject = CurrentValueSubject<CasinoGameSearchedDisplayState, Never>(state)
    }
    
    // MARK: - Inputs
    public func didSelect() {
        selectedSubject.send(dataSubject.value.id)
    }
    
    public func imageLoadingSucceeded() {
        displayStateSubject.send(.normal)
    }
    
    public func imageLoadingFailed() {
        displayStateSubject.send(.imageError)
    }
}

// MARK: - Mock Presets
public extension MockCasinoGameSearchedViewModel {
    static var loading: MockCasinoGameSearchedViewModel {
        let data = CasinoGameSearchedData(
            id: "demo-id",
            title: "Demo Game",
            provider: "Demo Provider",
            imageURL: nil
        )
        return MockCasinoGameSearchedViewModel(data: data, state: .loading)
    }
    
    static var normal: MockCasinoGameSearchedViewModel {
        let data = CasinoGameSearchedData(
            id: "demo-id",
            title: "Demo Game",
            provider: "Demo Provider",
            imageURL: "https://example.com/demo.png"
        )
        return MockCasinoGameSearchedViewModel(data: data, state: .normal)
    }
    
    static var imageError: MockCasinoGameSearchedViewModel {
        let data = CasinoGameSearchedData(
            id: "demo-id",
            title: "Demo Game",
            provider: "Demo Provider",
            imageURL: "https://example.com/broken.png"
        )
        return MockCasinoGameSearchedViewModel(data: data, state: .imageError)
    }
}

