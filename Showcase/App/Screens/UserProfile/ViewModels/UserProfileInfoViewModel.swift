//
//  UserProfileInfoViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 28/09/2022.
//

import Foundation
import Combine

class UserProfileInfoViewModel {

    var userId: String
    var userProfileInfo: UserProfileInfo?
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var userProfileInfoStatePublisher: CurrentValueSubject<UserProfileState, Never> = .init(.loading)

    private var cancellables = Set<AnyCancellable>()

    init(userId: String) {
        self.userId = userId

    }

    func setUserProfileInfoState(userProfileState: UserProfileState, userProfileInfo: UserProfileInfo? = nil) {

        switch userProfileState {
        case .loaded:
            self.userProfileInfo = userProfileInfo

            self.isLoadingPublisher.send(false)

            self.userProfileInfoStatePublisher.send(.loaded)
        case .failed:
            self.isLoadingPublisher.send(false)

            self.userProfileInfoStatePublisher.send(.failed)
        case .loading:
            self.isLoadingPublisher.send(true)
        }

    }

}
