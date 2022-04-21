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

    // MARK: Public Properties
    var users: [UserContact] = []
    var sectionUsers: [Int: [UserContact]] = [:]
    var sectionUsersArray: [UserContactSectionData] = []
    var initialFullSectionUsers: [UserContactSectionData] = []
    var initialFullUsers: [UserContact] = []
    var contactsData: [ContactsData] = []
    var cachedFriendCellViewModels: [String: AddFriendCellViewModel] = [:]
    var cachedUnregisteredFriendCellViewModels: [String: AddUnregisteredFriendCellViewModel] = [:]
    var hasDoneSearch: Bool = false
    var selectedUsers: [UserContact] = []
    var isEmptySearchPublisher: CurrentValueSubject<Bool, Never> = .init(true)
    var isLoading: CurrentValueSubject<Bool, Never> = .init(false)
    var dataNeedsReload: PassthroughSubject<Void, Never> = .init()
    var canAddFriendPublisher: CurrentValueSubject<Bool, Never> = .init(false)

    init() {
        self.canAddFriendPublisher.send(false)

        self.getContactsData()
    }

    func filterSearch(searchQuery: String) {

        var filterUserSections = self.initialFullSectionUsers.filter {
            $0.userContacts.contains(where: {
                $0.username.localizedCaseInsensitiveContains(searchQuery)
            })

        }

        for (index, filterUserSection) in filterUserSections.enumerated() {

           let filterUserContacts = filterUserSection.userContacts.filter({
               $0.username.localizedCaseInsensitiveContains(searchQuery)
           })

            filterUserSections[index].userContacts = filterUserContacts

        }

        self.sectionUsersArray = filterUserSections

        self.dataNeedsReload.send()

    }

    func getUsers() {
        // TEST
        if self.users.isEmpty {
            for i in 0...20 {
                let user = UserContact(id: "\(i)", username: "@GOMA_User", phone: "+351 999 888 777")
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
        self.cachedUnregisteredFriendCellViewModels = [:]
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

            let phoneNumber: [String] = contact.phoneNumbers.map{ $0.value.stringValue }

            let identifier = contact.identifier

            let contactData = ContactsData(givenName: givenName,
                                           familyName: familyName,
                                           phoneNumber: phoneNumber,
                                           emailAddress: emailAddress as String,
                                           identifier: identifier)

            self.contactsData.append(contactData)
        })

        self.isEmptySearchPublisher.send(false)

        self.populateContactsData()
    }

    private func populateContactsData() {

        for contactData in self.contactsData {

            if contactData.phoneNumber.isNotEmpty {
                let identifier = contactData.identifier

                let username = "\(contactData.givenName) \(contactData.familyName)"

                let phoneNumber = contactData.phoneNumber.first ?? ""

                let user = UserContact(id: identifier, username: username, phone: phoneNumber)

                self.users.append(user)

                self.verifyUserRegistered(userContact: user)
            }
        }

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

        self.dataNeedsReload.send()
    }

    private func verifyUserRegistered(userContact: UserContact) {
        // TEST
        if userContact.username.contains("Carlos") || userContact.username.contains("Lascas") {

            if self.sectionUsers[UserContactType.unregistered.identifier] != nil {

                self.sectionUsers[UserContactType.unregistered.identifier]?.append(userContact)
            }
            else {
                self.sectionUsers[UserContactType.unregistered.identifier] = [userContact]
            }
        }
        else {
            if self.sectionUsers[UserContactType.registered.identifier] != nil {

                self.sectionUsers[UserContactType.registered.identifier]?.append(userContact)
            }
            else {
                self.sectionUsers[UserContactType.registered.identifier] = [userContact]
            }
        }

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
