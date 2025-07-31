//
//  ResendCodeCountdownViewModelProtocol.swift
//  GomaUI
//
//  Created by André Lascas on 27/06/2025.
//

import Foundation
import Combine

public protocol ResendCodeCountdownViewModelProtocol {
    var countdownTextPublisher: AnyPublisher<String, Never> { get }
    func startCountdown()
    func resetCountdown()
}
