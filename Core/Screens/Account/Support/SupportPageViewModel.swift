//
//  SupportPageViewModel.swift
//  ShowcaseProd
//
//  Created by Teresa on 01/06/2022.
//

import Foundation
import Combine
import ServicesProvider

class SupportPageViewModel {

    var cancellables = Set<AnyCancellable>()
    var supportResponseAction: ((Bool, String?) -> Void)?
    var subjectTypes: [SubjectType]
    // MARK: - Life Cycle
    init() {
        self.subjectTypes = [.register,
                             .myAccount,
                             .bonusAndPromotions,
                             .deposits,
                             .withdraws,
                             .responsibleGaming,
                             .bettingRules,
                             .other]
    }
    
    func sendEmail(title: String, message: String, subjectType: String, firstName: String? = nil, lastName: String? = nil, email: String? = nil) {

        let userProfile = Env.userSessionStore.userProfilePublisher.value

        var userIdentifier = ""
        var subjectTypeTag = ""
        var name = ""
        var surname = ""
        var userEmail = ""
        var isLogged = false

        if let firstName,
           let lastName,
           let email {
            userIdentifier = "\(firstName) - \(lastName) - \(email)"
            name = firstName
            surname = lastName
            userEmail = email
        }
        else {
            // userIdentifier = "\(userProfile?.userIdentifier ?? "")_\(userProfile?.username ?? "")"
            userIdentifier = "\(userProfile?.firstName ?? "") \(userProfile?.lastName ?? "")"
            name = "\(userProfile?.firstName ?? "")"
            surname = "\(userProfile?.lastName ?? "")"
            userEmail = "\(userProfile?.email ?? "")"
            isLogged = true
        }

        if let filteredSubjectTypeTag = SubjectType.allCases.filter({
            $0.typeValue == subjectType
        }).first?.typeTag {
            subjectTypeTag = filteredSubjectTypeTag
        }

        Env.servicesProvider.contactSupport(userIdentifier: userIdentifier,
                                            firstName: name,
                                            lastName: surname,
                                            email: userEmail,
                                            subject: title,
                                            subjectType: subjectTypeTag,
                                            message: message,
                                            isLogged: isLogged)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    switch error {
                    case .errorMessage(let message):
                        self?.supportResponseAction?(false, message)

                    default:
                        ()
                    }
                }
            }, receiveValue: { [weak self] _ in
                self?.supportResponseAction?(true, nil)
            })
            .store(in: &cancellables)
        
//        Env.gomaNetworkClient.sendSupportTicket(deviceId: Env.deviceId, title: title, message: message)
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                switch completion {
//                case .failure:
//                    self.supportResponseAction?(false)
//                case .finished:
//                 ()
//                }
//            }, receiveValue: { [weak self] response in
//                self?.supportResponseAction?(true)
//            })
//            .store(in: &cancellables)
        
    }
       
}
