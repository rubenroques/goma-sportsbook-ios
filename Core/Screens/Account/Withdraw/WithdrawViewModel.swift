//
//  WithdrawViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 31/03/2022.
//

import Foundation
import Combine
import ServicesProvider

class WithdrawViewModel: NSObject {
    // MARK: Private Properties
    private var cancellables = Set<AnyCancellable>()

    // MARK: Public Properties
    var isLoadingPublisher: CurrentValueSubject<Bool, Never> = .init(false)
    var showErrorAlertTypePublisher: CurrentValueSubject<BalanceErrorType?, Never> = .init(nil)
    var cashierUrlPublisher: CurrentValueSubject<String?, Never> = .init(nil)

    var withdrawalMethods: [WithdrawalMethod] = []
    var minimumValue: CurrentValueSubject<String, Never> = .init("")
    var maximumValue: CurrentValueSubject<String, Never> = .init("")
    var showWithdrawalStatus: (() -> Void)?

    var ibanPaymentDetails: BankPaymentDetail?
    var shouldShowIbanScreen: (() -> Void)?

    // MARK: Lifetime and Cycle
    override init() {
        super.init()

        self.getWithdrawalMethods()
        self.getPaymentInfo()
    }

    // MARK: Functions
    private func getPaymentInfo() {

        Env.servicesProvider.getPaymentInformation()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("PAYMENT INFO ERROR: \(error)")

                }

            }, receiveValue: { [weak self] paymentInfo in
                print("PAYMENT INFO: \(paymentInfo)")

                let paymentDetails = paymentInfo.data.filter({
                    $0.details.isNotEmpty
                })

                if paymentDetails.isNotEmpty {

                    if let bankPaymentDetail = paymentDetails.filter({
                        $0.type == "BANK"
                    }).first,
                       let ibanPaymentDetail = bankPaymentDetail.details.filter({
                           $0.key == "IBAN"
                       }).first {

                        if ibanPaymentDetail.value != "" {
                            self?.ibanPaymentDetails = ibanPaymentDetail
                        }
                    }

                }

            })
            .store(in: &cancellables)
    }

    func getWithdrawInfo(amountText: String) {

//        if self.ibanPaymentDetails == nil,
//           let accountBalance = Env.userSessionStore.userWalletPublisher.value?.totalWithdrawable,
//           let kycStatus = Env.userSessionStore.isUserKycVerified.value,
//           accountBalance > 0 && kycStatus {
//
//            self.shouldShowIbanScreen?()
//
//        }
//        else {
            self.isLoadingPublisher.send(true)

            let amountText = amountText
            var amount = ""

            if amountText.contains(",") {
                amount = amountText.replacingOccurrences(of: ",", with: ".")
            }
            else {
                amount = amountText
            }

            if let withdrawalAmount = Double(amount),
               let withdrawalMethod = self.withdrawalMethods.first?.paymentMethod {

                Env.servicesProvider.processWithdrawal(paymentMethod: withdrawalMethod, amount: withdrawalAmount)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { [weak self] completion in
                        switch completion {
                        case .finished:
                            ()
                        case .failure(let error):
                            print("PROCESS WITHDRAWAL ERROR: \(error)")
                            switch error {
                            case .errorMessage(let message):
                                self?.showErrorAlertTypePublisher.send(.error(message: message))
                            default:
                                ()
                            }
                            self?.isLoadingPublisher.send(false)
                        }
                    }, receiveValue: { [weak self] processWithdrawalResponse in
                        self?.showWithdrawalStatus?()
                        self?.isLoadingPublisher.send(false)
                    })
                    .store(in: &cancellables)
            }
//        }

    }

    private func getWithdrawalMethods() {

        Env.servicesProvider.getWithdrawalMethods()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in

                switch completion {
                case .finished:
                    ()
                case .failure(let error):
                    print("WITHDRAWAL METHODS ERROR: \(error)")
                    self?.isLoadingPublisher.send(false)
                }

            }, receiveValue: { [weak self] withdrawalMethods in

                // Bank transfer only
                let methods = withdrawalMethods.filter({
                    $0.code == "ADYEN_BANK_TRANSFER"
                })

                self?.withdrawalMethods = methods

                if let method = methods.first {
                    self?.minimumValue.send(method.minimumWithdrawal.replacingFirstOccurrence(of: ",", with: ""))

                    self?.maximumValue.send(method.maximumWithdrawal.replacingFirstOccurrence(of: ",", with: ""))
                }

            })
            .store(in: &cancellables)
    }
}
