//
//  MockDepositBonusViewModel.swift
//  Sportsbook
//
//  Created by André Lascas on 01/07/2025.
//

import Foundation
import GomaUI
import Combine

class MockDepositBonusViewModel: DepositBonusViewModelProtocol {
    let headerViewModel: PromotionalHeaderViewModelProtocol
    let highlightedTextViewModel: HighlightedTextViewModelProtocol
    let amountFieldViewModel: BorderedTextFieldViewModelProtocol
    let amountPillsViewModel: AmountPillsViewModelProtocol
    let bonusInfoViewModel: DepositBonusBalanceViewModelProtocol
    let buttonViewModel: ButtonViewModelProtocol

    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    var isLoadingPublisher: AnyPublisher<Bool, Never> { isLoadingSubject.eraseToAnyPublisher() }
    
    let shouldVerifyTransaction = PassthroughSubject<Void, Never>()
    
    private var cancellables = Set<AnyCancellable>()
    
    var promotionalBonusCardData: PromotionalBonusCardData
    var bonusDepositData: BonusDepositData
    
    init(promotionalBonusCardData: PromotionalBonusCardData) {
        
        self.promotionalBonusCardData = promotionalBonusCardData
        
        self.bonusDepositData = BonusDepositData(id: promotionalBonusCardData.id, selectedAmount: 0, bonusAmount: promotionalBonusCardData.bonusAmount)
        
        headerViewModel = MockPromotionalHeaderViewModel(headerData: PromotionalHeaderData(id: "header",
                                                                                           icon: "deposit_gift_icon",
                                                                                           title: "Ready to make your first deposit?",
                                                                                           subtitle: nil))
        
        highlightedTextViewModel = MockHighlightedTextViewModel(data: HighlightedTextData(fullText: "Your deposit and bonus will be added to your Betsson wallet!",
                                                                                          highlights: []))
        
        amountFieldViewModel = MockBorderedTextFieldViewModel(textFieldData: BorderedTextFieldData(id: "amount",
                                                                                                  placeholder: "Enter amount",
                                                                                                  isSecure: false,
                                                                                                  visualState: .idle,
                                                                                                   keyboardType: .numberPad,
                                                                                                   textContentType: nil))
        
        amountPillsViewModel = MockAmountPillsViewModel(pillsData: AmountPillsData(id: "amount_pills", pills: [
            AmountPillData(id: "250", amount: "250"),
            AmountPillData(id: "500", amount: "500"),
            AmountPillData(id: "1000", amount: "1000"),
            AmountPillData(id: "2000", amount: "2000")
        ]))
        
        bonusInfoViewModel = MockDepositBonusInfoViewModel(depositBonusInfo: DepositBonusInfoData(id: "deposit_bonus",
                                                                                                  icon: "gift.fill",
                                                                                                  balanceText: "Your deposit + Bonus",
                                                                                                  currencyAmount: "XAF --"))
        
        buttonViewModel = MockButtonViewModel(buttonData: ButtonData(id: "deposit",
                                                                     title: "Deposit",
                                                                     style: .solidBackground,
                                                                     isEnabled: true))
        
        setupPublishers()
    }
    
    private func setupPublishers() {
        
        amountFieldViewModel.textPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] amountText in
                
                if amountText.isNotEmpty {
                    self?.buttonViewModel.setEnabled(true)
                }
                else {
                    self?.buttonViewModel.setEnabled(false)
                }
                
                self?.verifyPillsSelection(amountText: amountText)
                self?.updateBonusInfo(amountText: amountText)
            })
            .store(in: &cancellables)
        
        amountPillsViewModel.pillsDataPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] pillsData in
                
                if let selectedPillId = pillsData.selectedPillId,
                   let selectedPill = pillsData.pills.first(where: {
                        $0.id == selectedPillId
                   }) {
                    
                    self?.amountFieldViewModel.updateText(selectedPill.amount)
                }
            })
            .store(in: &cancellables)
    }
    
    private func verifyPillsSelection(amountText: String) {
        
        let pillsData = amountPillsViewModel.pillsDataSubject.value
        
        if let pillData = pillsData.pills.first(where: {
            $0.amount == amountText
        }) {
            if pillsData.selectedPillId != pillData.id {
                amountPillsViewModel.selectPill(withId: pillData.id)
            }
        }
        else {
            if pillsData.selectedPillId != nil {
                amountPillsViewModel.clearSelection()
            }
        }
    }
    
    private func updateBonusInfo(amountText: String) {
        
        let bonusAmount = self.promotionalBonusCardData.bonusAmount
        var bonusAmountText = "XAF \(bonusAmount)"
        if amountText.isEmpty {
            bonusInfoViewModel.updateAmount(bonusAmountText)
        }
        else {
            let amountInt = Int(amountText) ?? 0
            let bonusAmount = Int(bonusAmount)
            bonusAmountText = "XAF \(amountInt + bonusAmount)"
            bonusInfoViewModel.updateAmount(bonusAmountText)
        }
        
        bonusDepositData.selectedAmount = Double(amountText) ?? 0
    }
    
    func requestVerifyTransaction() {
        isLoadingSubject.send(true)
        // Simulate endpoint delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.isLoadingSubject.send(false)
            
            self?.shouldVerifyTransaction.send()
        }
    }
}

struct BonusDepositData {
    let id: String
    var selectedAmount: Double
    var bonusAmount: Double
}
