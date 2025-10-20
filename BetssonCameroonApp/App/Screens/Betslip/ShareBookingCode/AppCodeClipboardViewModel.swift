//
//  AppCodeClipboardViewModel.swift
//  BetssonCameroonApp
//
//  Created by Assistant on 15/10/2025.
//

import Foundation
import Combine
import UIKit
import GomaUI

/// Simple in-app implementation conforming to GomaUI's CodeClipboardViewModelProtocol
final class AppCodeClipboardViewModel: CodeClipboardViewModelProtocol {
    private let dataSubject: CurrentValueSubject<CodeClipboardData, Never>

    var dataPublisher: AnyPublisher<CodeClipboardData, Never> { dataSubject.eraseToAnyPublisher() }
    var currentData: CodeClipboardData { dataSubject.value }

    init(code: String, labelText: String = "Copy Booking Code", isEnabled: Bool = true) {
        let data = CodeClipboardData(state: .default, code: code, labelText: labelText, isEnabled: isEnabled)
        self.dataSubject = CurrentValueSubject(data)
    }

    func updateCode(_ code: String) {
        let old = dataSubject.value
        dataSubject.send(CodeClipboardData(state: old.state, code: code, labelText: old.labelText, isEnabled: old.isEnabled))
    }

    func setCopied(_ isCopied: Bool) {
        let old = dataSubject.value
        let state: CodeClipboardState = isCopied ? .copied : .default
        dataSubject.send(CodeClipboardData(state: state, code: old.code, labelText: old.labelText, isEnabled: old.isEnabled))
    }

    func setEnabled(_ isEnabled: Bool) {
        let old = dataSubject.value
        dataSubject.send(CodeClipboardData(state: old.state, code: old.code, labelText: old.labelText, isEnabled: isEnabled))
    }

    func onCopyTapped() {
        // Copy to system clipboard
        UIPasteboard.general.string = currentData.code
        
        // Provide UI feedback via state
        setCopied(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.setCopied(false)
        }
    }
}


