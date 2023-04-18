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

    // MARK: - Life Cycle
    init() {
        
    }
    
    func sendEmail(title: String, message: String, firstName: String? = nil, lastName: String? = nil, email: String? = nil) {

        let userProfile = Env.userSessionStore.userProfilePublisher.value

        var userIdentifier = ""

        if let firstName,
           let lastName,
           let email {
            userIdentifier = "\(firstName) - \(lastName) - \(email)"
        }
        else {
            userIdentifier = "\(userProfile?.userIdentifier ?? "")_\(userProfile?.username ?? "")"
        }

        Env.servicesProvider.contactSupport(userIdentifier: userIdentifier, subject: title, message: message)
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
            }, receiveValue: { [weak self] supportResponse in
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
