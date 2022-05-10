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
    var users: [UserContact] = []
    var cachedUserCellViewModels: [String: GroupUserManagementCellViewModel] = [:]
    var groupNamePublisher: CurrentValueSubject<String, Never> = .init("")
    var groupInitialsPublisher: CurrentValueSubject<String, Never> = .init("")
    var needReloadData: PassthroughSubject<Void, Never> = .init()
    var shouldCloseChat: CurrentValueSubject<Bool, Never> = .init(false)
    var isGroupEdited: Bool = false

    init(conversationData: ConversationData) {
        self.conversationData = conversationData

        self.processGroupUsers()

        self.setupPublishers()
    }

    private func processGroupUsers() {

        if let groupUsers = self.conversationData.groupUsers {

            for user in groupUsers {
                let userContact = UserContact(id: "\(user.id)", username: user.username, phones: [])
                self.users.append(userContact)
            }
        }

        self.needReloadData.send()
    }

    private func setupPublishers() {

        self.groupNamePublisher.value = self.conversationData.name

        self.groupInitialsPublisher.value = self.getGroupInitials(text: self.conversationData.name)
    }

    func editGroupInfo(groupName: String) {
        let chatroomId = self.conversationData.id
        let groupName = groupName

        print("GROUP INFO:")
        print("CHATROOM ID: \(chatroomId)")
        print("NAME: \(groupName)")

        Env.gomaNetworkClient.editGroup(deviceId: Env.deviceId, chatroomId: chatroomId, groupName: groupName)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("EDIT GROUP ERROR: \(error)")
                case .finished:
                    print("EDIT GROUP FINISHED")
                }

            }, receiveValue: { [weak self] response in
                print("EDIT GROUP GOMA: \(response)")
                self?.isGroupEdited = true
            })
            .store(in: &cancellables)
    }

    func deleteGroup() {
        print("DELETE GROUP")
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
