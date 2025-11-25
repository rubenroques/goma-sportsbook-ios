//
//  MockPendingWithdrawViewModel.swift
//  GomaUI
//
//  Created by André on 17/11/2025.
//

import Combine

public final class MockPendingWithdrawViewModel: PendingWithdrawViewModelProtocol {
    private let subject: CurrentValueSubject<PendingWithdrawViewDisplayState, Never>
    
    public var onCopyRequested: ((String) -> Void)?
    
    public var currentDisplayState: PendingWithdrawViewDisplayState {
        subject.value
    }
    
    public var displayStatePublisher: AnyPublisher<PendingWithdrawViewDisplayState, Never> {
        subject.eraseToAnyPublisher()
    }
    
    public init(displayState: PendingWithdrawViewDisplayState = .samplePending) {
        self.subject = CurrentValueSubject(displayState)
    }
    
    public func update(displayState: PendingWithdrawViewDisplayState) {
        subject.send(displayState)
    }
    
    public func handleCopyTransactionID() {
        onCopyRequested?(subject.value.transactionIdValueText)
    }
}


