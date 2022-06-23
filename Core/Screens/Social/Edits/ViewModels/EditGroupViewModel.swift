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
    var showErrorAlert: PassthroughSubject<Void, Never> = .init()
    var editGroupFinished: PassthroughSubject<Void, Never> = .init()
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var hasLeftGroupPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var isGroupEdited: Bool = false
    var adminUserId: Int?

    init(conversationData: ConversationData) {
        self.conversationData = conversationData

        self.processGroupUsers()

        self.setupPublishers()
    }

    private func processGroupUsers() {

        if let groupUsers = self.conversationData.groupUsers {

            // Sort for admin first
            let sortedGroupUsers = groupUsers.sorted {
                if let userAdminFirst = $0.isAdmin, let userAdminSecond = $1.isAdmin {
                    if userAdminFirst > userAdminSecond {
                        return true
                    }
                }
                return false
            }

            for user in sortedGroupUsers {
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
        // self.isLoadingPublisher.send(true)

        let chatroomId = self.conversationData.id
        let groupName = groupName

        Env.gomaNetworkClient.editGroup(deviceId: Env.deviceId, chatroomId: chatroomId, groupName: groupName)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("EDIT GROUP ERROR: \(error)")
                case .finished:
                    print("EDIT GROUP FINISHED")
                }
                // self?.isLoadingPublisher.send(false)

            }, receiveValue: { [weak self] response in
                self?.groupNamePublisher.value = groupName
                self?.isGroupEdited = true
                self?.editGroupFinished.send()
            })
            .store(in: &cancellables)
    }

    func removeUser(userId: String, userIndex: Int) {
        let chatroomId = self.conversationData.id

        Env.gomaNetworkClient.removeUser(deviceId: Env.deviceId, chatroomId: chatroomId, userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("REMOVE USER ERROR: \(error)")
                    self?.showErrorAlert.send()
                case .finished:
                    print("REMOVE USER FINISHED")
                }

            }, receiveValue: { [weak self] response in
                self?.isGroupEdited = true
                self?.users.remove(at: userIndex)
                self?.cachedUserCellViewModels[userId] = nil
                self?.needReloadData.send()
            })
            .store(in: &cancellables)

    }

    func deleteGroup() {
        print("DELETE GROUP")
    }

    func leaveGroup() {

        Env.gomaNetworkClient.leaveGroup(deviceId: Env.deviceId, chatroomId: self.getChatroomId())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("LEAVE GROUP ERROR: \(error)")
                case .finished:
                    ()
                }
            }, receiveValue: { [weak self] response in
                print("LEAVE GROUP GOMA: \(response)")
                self?.hasLeftGroupPublisher.send(true)
            })
            .store(in: &cancellables)
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

    func getChatroomId() -> Int {
        return self.conversationData.id
    }

    func addSelectedUsers(selectedUsers: [UserContact]) {

        for user in selectedUsers {
            self.users.append(user)
        }

        self.isGroupEdited = true
        self.needReloadData.send()
    }

    func getGroupInfo() -> GroupInfo {
        let groupName = self.groupNamePublisher.value
        let groupUsers = self.users

        let groupInfo = GroupInfo(name: groupName, users: groupUsers)

        return groupInfo
    }

    func getAdminUserId() -> Int {

        if let groupUsers = self.conversationData.groupUsers, let userAdmin = groupUsers.first(where: { $0.isAdmin == 1 }) {
            return userAdmin.id
        }

        return 0
    }
}

struct GroupInfo {
    var name: String
    var users: [UserContact]
}
