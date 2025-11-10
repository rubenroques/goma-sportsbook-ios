//
//  ShareBookingCodeViewModel.swift
//  BetssonCameroonApp
//
//  Created on 15/10/2025.
//

import Foundation
import Combine
import GomaUI

final class ShareBookingCodeViewModel: ShareBookingCodeViewModelProtocol {
    // MARK: - Outputs
    private let titleSubject = CurrentValueSubject<String, Never>("Share Betslip")
    var titlePublisher: AnyPublisher<String, Never> { titleSubject.eraseToAnyPublisher() }

    let bookingCode: String
    let codeClipboardViewModel: CodeClipboardViewModelProtocol
    let shareButtonViewModel: ButtonIconViewModelProtocol

    // MARK: - Callbacks
    var onClose: (() -> Void)?
    var onShare: ((String) -> Void)?

    // MARK: - Init
    init(bookingCode: String) {
        self.bookingCode = bookingCode

        // Code clipboard VM
        self.codeClipboardViewModel = AppCodeClipboardViewModel(
            code: bookingCode,
            labelText: "Copy Booking Code"
        )

        // Share button VM
        let shareVM = ButtonIconViewModel(
            title: localized("share_booking_code"),
            icon: "share_icon",
            layoutType: .iconLeft,
            isEnabled: true,
            backgroundColor: StyleProvider.Color.highlightPrimary,
            cornerRadius: 4,
            iconColor: StyleProvider.Color.allWhite
        )
        self.shareButtonViewModel = shareVM

        shareVM.onButtonTapped = { [weak self] in
            guard let self = self else { return }
            self.onShare?(self.bookingCode)
        }
    }

    // MARK: - Actions
    func closeRequested() {
        onClose?()
    }

    func shareRequested() {
        onShare?(bookingCode)
    }
}


