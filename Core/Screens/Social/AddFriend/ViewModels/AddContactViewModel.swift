//
//  AddContactViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 20/04/2022.
//

import Foundation
import Combine
import Contacts

class AddContactViewModel {
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var registeredUsers: [GomaContact] = []
    private var friendsList: [GomaFriend] = []
    // MARK: Public Properties
    var users: [UserContact] = []
    var sectionUsers: [Int: [UserContact]] = [:]
    var sectionUsersArray: [UserContactSectionData] = []
    var initialFullSectionUsers: [UserContactSectionData] = []
    var initialFullUsers: [UserContact] = []
    var contactsData: [ContactsData] = []
    var cachedFriendCellViewModels: [String: AddFriendCellViewModel] = [:]
    //var cachedUnregisteredFriendCellViewModels: [String: AddUnregisteredFriendCellViewModel] = [:]
    var hasDoneSearch: Bool = false
    var hasRegisteredFriends: Bool = false
    var selectedUsers: [UserContact] = []
    var isEmptySearchPublisher: CurrentValueSubject<Bool, Never> = .init(true)
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()
    var canAddFriendPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var shouldShowAlert: CurrentValueSubject<Bool, Never> = .init(false)
    var friendAlertType: FriendAlertType?

    init() {
        self.canAddFriendPublisher.send(false)

        self.getFriendsList()

    }

    func filterSearch(searchQuery: String) {

        var filteredSectionUsers: [UserContactSectionData] = []

        var registeredSection = self.initialFullSectionUsers.filter({
            $0.contactType == .registered
        })

        let unregisteredSection = self.initialFullSectionUsers.filter({
            $0.contactType == .unregistered
        })

        if registeredSection.isNotEmpty {

            var filteredRegisteredSection = registeredSection.filter({
                $0.userContacts.contains(where: {
                    $0.username.localizedCaseInsensitiveContains(searchQuery)
                })
            })

            for (index, filteredRegister) in filteredRegisteredSection.enumerated() {

                let filterUserContacts = filteredRegister.userContacts.filter({
                    $0.username.localizedCaseInsensitiveContains(searchQuery)
                })

                filteredRegisteredSection[index].userContacts = filterUserContacts

            }

            registeredSection = filteredRegisteredSection

            filteredSectionUsers.append(contentsOf: registeredSection)
        }

        filteredSectionUsers.append(contentsOf: unregisteredSection)

        self.sectionUsersArray = filteredSectionUsers

        self.dataNeedsReload.send()

    }

    func getUsers() {
        // TEST
        if self.users.isEmpty {
            for i in 0...20 {
                let user = UserContact(id: "\(i)", username: "@GOMA_User", phones: ["+351 999 888 777"])
                self.users.append(user)

            }

            self.isEmptySearchPublisher.send(false)
        }
        self.dataNeedsReload.send()
    }

    func clearUsers() {
        self.users = []
        self.selectedUsers = []
        self.cachedFriendCellViewModels = [:]
        // self.cachedUnregisteredFriendCellViewModels = [:]
        self.isEmptySearchPublisher.send(true)
        self.canAddFriendPublisher.send(false)
        self.dataNeedsReload.send()
    }

    func resetUsers() {
        
        self.sectionUsersArray = self.initialFullSectionUsers

        self.dataNeedsReload.send()
    }

    func checkSelectedUserContact(cellViewModel: AddFriendCellViewModel) {

        if cellViewModel.isCheckboxSelected {
            self.selectedUsers.append(cellViewModel.userContact)
        }
        else {
            let usersArray = self.selectedUsers.filter {$0.id != cellViewModel.userContact.id}
            self.selectedUsers = usersArray
        }

        if self.selectedUsers.isEmpty {
            self.canAddFriendPublisher.send(false)
        }
        else {
            self.canAddFriendPublisher.send(true)
        }

    }

    private func getFriendsList() {
        self.isLoadingPublisher.send(true)

        Env.gomaNetworkClient.requestFriends(deviceId: Env.deviceId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("LIST FRIEND ERROR: \(error)")
                case .finished:
                    ()
                }

                self?.getContactsData()

            }, receiveValue: { response in
                if let friends = response.data {
                    self.friendsList = friends
                    print("LIST FRIEND: \(friends)")
                }
            })
            .store(in: &cancellables)
    }

    private func getContactsData() {
        let contactStore = CNContactStore()

        let key = [CNContactGivenNameKey,
                   CNContactFamilyNameKey,
                   CNContactPhoneNumbersKey,
                   CNContactEmailAddressesKey] as [CNKeyDescriptor]

        let request = CNContactFetchRequest(keysToFetch: key)

        try? contactStore.enumerateContacts(with: request, usingBlock: { contact, _ in
            let givenName = contact.givenName

            let familyName = contact.familyName

            let emailAddress = contact.emailAddresses.first?.value ?? ""

            let phoneNumber: [String] = contact.phoneNumbers.map { $0.value.stringValue }

            let identifier = contact.identifier

            let contactData = ContactsData(givenName: givenName,
                                           familyName: familyName,
                                           phoneNumber: phoneNumber,
                                           emailAddress: emailAddress as String,
                                           identifier: identifier)

            self.contactsData.append(contactData)
        })

        self.isEmptySearchPublisher.send(false)

        self.getRegisteredUsers()
    }

    private func getRegisteredUsers() {
        var phones: [String] = []

        for contact in self.contactsData {
            if contact.phoneNumber.isNotEmpty {
                for phoneNumber in contact.phoneNumber {
                    phones.append(phoneNumber)
                }
            }
        }

        Env.gomaNetworkClient.lookupPhones(deviceId: Env.deviceId, phones: phones)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("PHONES ERROR: \(error)")
                    self?.isLoadingPublisher.send(false)
                    self?.dataNeedsReload.send()

                case .finished:
                    print("PHONES FINISHED")
                }

            }, receiveValue: { [weak self] registeredUsers in
                print("PHONES GOMA: \(registeredUsers)")
                self?.registeredUsers = registeredUsers
                self?.populateContactsData()

            })
            .store(in: &cancellables)
    }

    private func populateContactsData() {

        for contactData in self.contactsData {

            if contactData.phoneNumber.isNotEmpty {

                self.createUserContact(contactData: contactData)

            }
        }

        // Unregistered always visible
        let emptyUserContact = UserContact(id: "", username: "", phones: [])
        self.sectionUsers[UserContactType.unregistered.identifier] = [emptyUserContact]

        // Sort contacts for registered/unregistered sections
        for (key, userContact) in self.sectionUsers {
            let contactType = (key == 1) ? UserContactType.registered : UserContactType.unregistered
            let userContactSection = UserContactSectionData(contactType: contactType, userContacts: userContact)
            self.sectionUsersArray.append(userContactSection)
        }

        let sectionUsersSorted = self.sectionUsersArray.sorted {
            $0.contactType.identifier < $1.contactType.identifier
        }
        
        self.sectionUsersArray = sectionUsersSorted

        self.initialFullUsers = self.users

        self.initialFullSectionUsers = self.sectionUsersArray

        self.isLoadingPublisher.send(false)

        self.dataNeedsReload.send()
    }

    private func createUserContact(contactData: ContactsData) {

        let username = "\(contactData.givenName) \(contactData.familyName)"

        if contactData.phoneNumber.count >= 1 {

            let userContact = UserContact(id: contactData.identifier, username: username, phones: contactData.phoneNumber, emails: [contactData.emailAddress])

            self.verifyUserRegister(userContact: userContact)
        }

    }

    private func verifyUserRegister(userContact: UserContact) {
        // TEST PHONE

        var isRegistered = false
        var registeredPhone = ""

        for phone in userContact.phones {
            let userContactPhone = phone.replacingOccurrences(of: " ", with: "")

            if self.registeredUsers.isNotEmpty, self.registeredUsers.contains(where: {
                $0.phoneNumber == userContactPhone }) {
                isRegistered = true
                registeredPhone = userContactPhone
            }
            else {
                isRegistered = false
            }
        }

        if isRegistered {

            self.hasRegisteredFriends = true

            var newId = 0

            if let registerUser = self.registeredUsers.first(where: { $0.phoneNumber == registeredPhone}) {
                newId = registerUser.id
            }

            if !self.friendsList.contains(where: { $0.id == newId }) {

                let newUserContact = UserContact(id: "\(newId)", username: userContact.username, phones: userContact.phones)

                self.users.append(newUserContact)

                if self.sectionUsers[UserContactType.registered.identifier] != nil {

                    self.sectionUsers[UserContactType.registered.identifier]?.append(newUserContact)
                }
                else {
                    self.sectionUsers[UserContactType.registered.identifier] = [newUserContact]
                }
            }
        }
//        else {
//
//            self.users.append(userContact)
//
//            if self.sectionUsers[UserContactType.unregistered.identifier] != nil {
//
//                self.sectionUsers[UserContactType.unregistered.identifier]?.append(userContact)
//            }
//            else {
//                self.sectionUsers[UserContactType.unregistered.identifier] = [userContact]
//            }
//        }
    }

    func sendFriendRequest() {
        var userIds: [String] = []

        for selectedUser in self.selectedUsers {
            userIds.append(selectedUser.id)
        }

        Env.gomaNetworkClient.addFriends(deviceId: Env.deviceId, userIds: userIds)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("ADD FRIEND ERROR: \(error)")
                    self?.friendAlertType = .error
                case .finished:
                    print("ADD FRIEND FINISHED")
                }

                self?.shouldShowAlert.send(true)
            }, receiveValue: { [weak self] response in
                print("ADD FRIEND GOMA: \(response)")
                self?.friendAlertType = .success
            })
            .store(in: &cancellables)
    }

    func inviteFriendRequest(phoneNumber: String) {
        Env.gomaNetworkClient.inviteFriend(deviceId: Env.deviceId, phone: phoneNumber)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    print("INVITE FRIEND ERROR: \(error)")
                    self?.friendAlertType = .error
                case .finished:
                    print("INVITE FRIEND FINISHED")
                }

                self?.shouldShowAlert.send(true)
            }, receiveValue: { [weak self] response in
                print("INVITE FRIEND GOMA: \(response)")
                self?.friendAlertType = .success
            })
            .store(in: &cancellables)
    }
}

struct ContactsData {
    let givenName: String
    let familyName: String
    let phoneNumber: [String]
    let emailAddress: String
    var identifier: String

    init(givenName: String, familyName: String, phoneNumber: [String], emailAddress: String, identifier: String) {
        self.givenName = givenName
        self.familyName = familyName
        self.phoneNumber = phoneNumber
        self.emailAddress = emailAddress
        self.identifier = identifier
    }
}

struct UserContactSectionData {
    var contactType: UserContactType
    var userContacts: [UserContact]
}

enum UserContactType {
    case registered
    case unregistered

    var identifier: Int {
        switch self {
        case .registered:
            return 1
        case .unregistered:
            return 2
        }
    }
}

enum FriendAlertType {
    case success
    case error
}
