//
//  PendingWithdrawViewModelProtocol.swift
//  GomaUI
//
//  Created by André on 17/11/2025.
//

import Combine

public protocol PendingWithdrawViewModelProtocol: AnyObject {
    var currentDisplayState: PendingWithdrawViewDisplayState { get }
    var displayStatePublisher: AnyPublisher<PendingWithdrawViewDisplayState, Never> { get }
    
    func handleCopyTransactionID()
}

public struct PendingWithdrawViewDisplayState {
    public let dateText: String
    public let statusText: String
    public let statusStyle: PendingWithdrawStatusStyle
    public let amountTitleText: String
    public let amountValueText: String
    public let transactionIdTitleText: String
    public let transactionIdValueText: String
    public let copyIconName: String?
    
    public init(
        dateText: String,
        statusText: String,
        statusStyle: PendingWithdrawStatusStyle = PendingWithdrawStatusStyle(),
        amountTitleText: String = "Amount",
        amountValueText: String,
        transactionIdTitleText: String = "Transaction ID",
        transactionIdValueText: String,
        copyIconName: String? = "doc.on.doc"
    ) {
        self.dateText = dateText
        self.statusText = statusText
        self.statusStyle = statusStyle
        self.amountTitleText = amountTitleText
        self.amountValueText = amountValueText
        self.transactionIdTitleText = transactionIdTitleText
        self.transactionIdValueText = transactionIdValueText
        self.copyIconName = copyIconName
    }
}

public extension PendingWithdrawViewDisplayState {
    static var samplePending: PendingWithdrawViewDisplayState {
        PendingWithdrawViewDisplayState(
            dateText: "05/08/2025, 11:17",
            statusText: "In Progress",
            statusStyle: PendingWithdrawStatusStyle(),
            amountTitleText: "Amount",
            amountValueText: "XAF 200,000",
            transactionIdTitleText: "Transaction ID",
            transactionIdValueText: "HFD90230NRF",
            copyIconName: "doc.on.doc.fill"
        )
    }
}

