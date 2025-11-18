//
//  PendingWithdrawViewModel.swift
//  BetssonCameroonApp
//
//  Created on 17/11/2025.
//

import Foundation
import Combine
import GomaUI

final class PendingWithdrawViewModel: PendingWithdrawViewModelProtocol {
    private let subject: CurrentValueSubject<PendingWithdrawViewDisplayState, Never>
    
    public var onCopyRequested: ((String) -> Void)?
    
    public var currentDisplayState: PendingWithdrawViewDisplayState {
        subject.value
    }
    
    public var displayStatePublisher: AnyPublisher<PendingWithdrawViewDisplayState, Never> {
        subject.eraseToAnyPublisher()
    }
    
    public init(displayState: PendingWithdrawViewDisplayState) {
        self.subject = CurrentValueSubject(displayState)
    }
    
    public func update(displayState: PendingWithdrawViewDisplayState) {
        subject.send(displayState)
    }
    
    public func handleCopyTransactionID() {
        onCopyRequested?(subject.value.transactionIdValueText)
    }
}


