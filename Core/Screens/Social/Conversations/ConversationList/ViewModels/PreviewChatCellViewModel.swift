//
//  PreviewChatCellViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 28/04/2022.
//

import Foundation
import Combine

class PreviewChatCellViewModel {
    var cellData: ConversationData
    var isOnlinePublisher: CurrentValueSubject<Bool, Never> = .init(false)

    private var cancellables = Set<AnyCancellable>()

    init(cellData: ConversationData) {
        self.cellData = cellData

        self.setupPublishers()
    }

    private func setupPublishers() {

        if let onlineUsersPublisher = Env.gomaSocialClient.onlineUsersPublisher() {

            onlineUsersPublisher
                .receive(on: DispatchQueue.main)
                .sink(receiveValue: { [weak self] onlineUsersResponse in
                    guard let self = self else {return}

                    let isUserOnline = onlineUsersResponse.values.contains { value -> Bool in

                        if let groupUsers = self.cellData.groupUsers,
                           let loggedUserId = Env.gomaNetworkClient.getCurrentToken()?.userId {

                            for groupUser in groupUsers {

                                if value.users.contains("\(groupUser.id)") && groupUser.id != loggedUserId {
                                    return true
                                }

                            }
                            return false

                        }

                        return false

                    }

                    if isUserOnline {

                        self.isOnlinePublisher.send(true)

                    }
                    else {
                        self.isOnlinePublisher.send(false)
                    }

                })
                .store(in: &cancellables)
        }
    }

    func getGroupInitials(text: String) -> String {
        var initials = ""

        for letter in text {
            if letter.isUppercase {
                if initials.count < 2 {
                    initials = "\(initials)\(letter)"
                }
            }
        }

        if initials == "" {
            if let firstChar = text.first {
                initials = "\(firstChar.uppercased())"
            }
        }

        return initials
    }
}
