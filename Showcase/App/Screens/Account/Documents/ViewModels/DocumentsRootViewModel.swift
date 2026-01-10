//
//  DocumentsRootViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 27/06/2023.
//

import Foundation
import Combine

class DocumentsRootViewModel {

    var kycStatusPublisher: AnyPublisher<KnowYourCustomerStatus?, Never> {
        return Env.userSessionStore.userKnowYourCustomerStatusPublisher.eraseToAnyPublisher()
    }

    var kycStatus: KnowYourCustomerStatus?

    var selectedDocumentTypeIndexPublisher: CurrentValueSubject<Int?, Never> = .init(nil)

    private var startTabIndex: Int

    init(startTabIndex: Int = 0) {

        self.startTabIndex = startTabIndex
        self.selectedDocumentTypeIndexPublisher.send(startTabIndex)

        self.getKYCStatus()

    }

    private func getKYCStatus() {
        Env.userSessionStore.refreshProfile()
    }

    func selectDocumentType(atIndex index: Int) {
        self.selectedDocumentTypeIndexPublisher.send(index)
    }
}
