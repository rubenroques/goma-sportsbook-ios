//
//  PaymentStatus.swift
//  Sportsbook
//
//  Created by André Lascas on 22/02/2023.
//

import Foundation

enum PaymentStatus {
    case authorised
    case refused
    case startedProcessing
}

enum BalanceErrorType {
    case wallet
    case deposit
    case withdraw
    case error(message: String)
    case bonus
}
