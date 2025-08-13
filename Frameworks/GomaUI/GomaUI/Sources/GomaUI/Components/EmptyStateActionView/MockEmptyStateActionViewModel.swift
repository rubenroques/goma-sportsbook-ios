//
//  MockEmptyStateActionViewModel.swift
//  GomaUI
//
//  Created by André Lascas on 06/08/2025.
//

import Foundation
import UIKit
import Combine

/// Mock implementation of EmptyStateActionViewModelProtocol for testing and previews
public final class MockEmptyStateActionViewModel: EmptyStateActionViewModelProtocol {
    
    // MARK: - Properties
    private let dataSubject: CurrentValueSubject<EmptyStateActionData, Never>
    
    // Callback closures
    public var onActionButtonTapped: (() -> Void)?
    
    public var dataPublisher: AnyPublisher<EmptyStateActionData, Never> {
        return dataSubject.eraseToAnyPublisher()
    }
    
    public var currentData: EmptyStateActionData {
        return dataSubject.value
    }
    
    // MARK: - Initialization
    public init(state: EmptyStateActionState, title: String, actionButtonTitle: String = "Log in to bet", image: UIImage? = nil, isEnabled: Bool = true) {
        let initialData = EmptyStateActionData(state: state, title: title, actionButtonTitle: actionButtonTitle, image: image, isEnabled: isEnabled)
        self.dataSubject = CurrentValueSubject(initialData)
    }
    
    // MARK: - Protocol Methods
    public func updateState(_ state: EmptyStateActionState) {
        let newData = EmptyStateActionData(state: state, title: currentData.title, actionButtonTitle: currentData.actionButtonTitle, image: currentData.image, isEnabled: currentData.isEnabled)
        dataSubject.send(newData)
    }
    
    public func updateTitle(_ title: String) {
        let newData = EmptyStateActionData(state: currentData.state, title: title, actionButtonTitle: currentData.actionButtonTitle, image: currentData.image, isEnabled: currentData.isEnabled)
        dataSubject.send(newData)
    }
    
    public func updateActionButtonTitle(_ title: String) {
        let newData = EmptyStateActionData(state: currentData.state, title: currentData.title, actionButtonTitle: title, image: currentData.image, isEnabled: currentData.isEnabled)
        dataSubject.send(newData)
    }
    
    public func updateImage(_ image: UIImage?) {
        let newData = EmptyStateActionData(state: currentData.state, title: currentData.title, actionButtonTitle: currentData.actionButtonTitle, image: image, isEnabled: currentData.isEnabled)
        dataSubject.send(newData)
    }
    
    public func setEnabled(_ isEnabled: Bool) {
        let newData = EmptyStateActionData(state: currentData.state, title: currentData.title, actionButtonTitle: currentData.actionButtonTitle, image: currentData.image, isEnabled: isEnabled)
        dataSubject.send(newData)
    }
}

// MARK: - Factory Methods
public extension MockEmptyStateActionViewModel {
    
    /// Creates a mock view model for logged out state
    static func loggedOutMock() -> MockEmptyStateActionViewModel {
        MockEmptyStateActionViewModel(
            state: .loggedOut,
            title: "You need at least 1 selection\nin your betslip to place a bet",
            actionButtonTitle: "Log in to bet",
            image: UIImage(systemName: "ticket") ?? UIImage()
        )
    }
    
    /// Creates a mock view model for logged in state
    static func loggedInMock() -> MockEmptyStateActionViewModel {
        MockEmptyStateActionViewModel(
            state: .loggedIn,
            title: "You need at least 1 selection\nin your betslip to place a bet",
            actionButtonTitle: "Start betting",
            image: UIImage(systemName: "ticket") ?? UIImage()
        )
    }
    
    /// Creates a mock view model for disabled state
    static func disabledMock() -> MockEmptyStateActionViewModel {
        MockEmptyStateActionViewModel(
            state: .loggedOut,
            title: "You need at least 1 selection\nin your betslip to place a bet",
            actionButtonTitle: "Log in to bet",
            image: UIImage(systemName: "ticket") ?? UIImage(),
            isEnabled: false
        )
    }
} 