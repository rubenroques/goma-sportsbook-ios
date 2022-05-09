//
//  EditGroupViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 09/05/2022.
//

import Foundation
import Combine

class EditGroupViewModel {

    // MARK: Private Properties
    private var conversationData: ConversationData
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var usernamePublisher: CurrentValueSubject<String, Never> = .init("")
    var shouldCloseChat: CurrentValueSubject<Bool, Never> = .init(false)

    init(conversationData: ConversationData) {
        self.conversationData = conversationData

        self.setupPublishers()
    }

    private func setupPublishers() {

        self.usernamePublisher.value = self.conversationData.name

    }

    func deleteGroup() {
        print("DELETE GROUP")
    }
}
