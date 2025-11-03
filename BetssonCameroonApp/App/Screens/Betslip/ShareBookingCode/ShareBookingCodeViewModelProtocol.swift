//
//  ShareBookingCodeViewModelProtocol.swift
//  BetssonCameroonApp
//
//  Created by Assistant on 15/10/2025.
//

import Foundation
import Combine
import GomaUI

protocol ShareBookingCodeViewModelProtocol {
    var titlePublisher: AnyPublisher<String, Never> { get }
    var bookingCode: String { get }
    var codeClipboardViewModel: CodeClipboardViewModelProtocol { get }
    var shareButtonViewModel: ButtonIconViewModelProtocol { get }
    var onClose: (() -> Void)? { get set }
    var onShare: ((String) -> Void)? { get set }

    func closeRequested()
    func shareRequested()
}


