//
//  CasinoGameDetailViewModel.swift
//  Sportsbook
//
//  Created by Teresa on 14/06/2022.
//

import Foundation
import Combine

class CasinoGameDetailViewModel: NSObject {

    var userBalancePublisher: CurrentValueSubject<String, Never> = .init("-.--€")
    var userBonusBalancePublisher: CurrentValueSubject<String, Never> = .init("-.--€")
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()

        self.setupPublishers()
    }

    func setupPublishers() {

        Env.userSessionStore.userWalletPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userWallet in
                if let userWallet = userWallet,
                   let formattedTotalString = CurrencyFormater.defaultFormat.string(from: NSNumber(value: userWallet.total))
                {
                    self?.userBalancePublisher.send(formattedTotalString)
                }
                else {
                    self?.userBalancePublisher.send("-.--€")
                }
            }
            .store(in: &cancellables)
//
//        Env.userSessionStore.userBalanceWallet
//            .compactMap({$0})
//            .map(\.amount)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] value in
//                if let bonusWallet = Env.userSessionStore.userBonusBalanceWallet.value {
//                    let accountValue = bonusWallet.amount + value
//                    self?.userBalancePublisher.send(CurrencyFormater.defaultFormat.string(from: NSNumber(value: accountValue)) ?? "-.--€")
//
//                }
//                else {
//                    self?.userBalancePublisher.send(CurrencyFormater.defaultFormat.string(from: NSNumber(value: value)) ?? "-.--€")
//                }
//            }
//            .store(in: &cancellables)
//
//        Env.userSessionStore.userBonusBalanceWallet
//            .compactMap({$0})
//            .map(\.amount)
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] value in
//                if let currentWallet = Env.userSessionStore.userBalanceWallet.value {
//                    let accountValue = currentWallet.amount + value
//                    self?.userBonusBalancePublisher.send(CurrencyFormater.defaultFormat.string(from: NSNumber(value: accountValue)) ?? "-.--€")
//                }
//            }
//            .store(in: &cancellables)
//

    }

}
