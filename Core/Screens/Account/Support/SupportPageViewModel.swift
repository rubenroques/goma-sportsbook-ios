//
//  SupportPageViewModel.swift
//  ShowcaseProd
//
//  Created by Teresa on 01/06/2022.
//

import Foundation
import Combine

class SupportPageViewModel {

    var cancellables = Set<AnyCancellable>()
    var supportResponseAction: ((Bool) -> Void)?
    // MARK: - Life Cycle
    init() {
        
    }
    
    func sendEmail(title: String, message: String) {
        
        Env.gomaNetworkClient.sendSupportTicket(deviceId: Env.deviceId, title: title, message: message)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure:
                    self.supportResponseAction?(false)
                case .finished:
                 ()
                }
            }, receiveValue: { [weak self] response in
                self?.supportResponseAction?(true)
            })
            .store(in: &cancellables)
        
    }
       
}
