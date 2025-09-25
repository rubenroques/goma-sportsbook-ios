//
//  TransactionHistoryViewModel.swift
//  BetssonCameroonApp
//
//  Created by Claude on 25/01/2025.
//

import Foundation
import Combine
import GomaUI
import ServicesProvider

final class TransactionHistoryViewModel {

    // MARK: - Published Properties

    @Published private var displayState = TransactionHistoryDisplayState.initial

    // MARK: - Publishers

    var displayStatePublisher: AnyPublisher<TransactionHistoryDisplayState, Never> {
        $displayState.eraseToAnyPublisher()
    }

    // MARK: - Properties

    private let servicesProvider: ServicesProvider.Client
    private var cancellables = Set<AnyCancellable>()

    let transactionTypePillSelectorViewModel: PillSelectorBarViewModelProtocol

    // MARK: - Callbacks

    var onDismiss: (() -> Void)?

    // MARK: - Initialization

    init(servicesProvider: ServicesProvider.Client) {
        self.servicesProvider = servicesProvider
        self.transactionTypePillSelectorViewModel = TransactionTypePillSelectorViewModel()

        setupBindings()
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // Listen to pill selector changes
        transactionTypePillSelectorViewModel.selectionEventPublisher
            .sink { [weak self] selectionEvent in
                guard let category = TransactionCategory(rawValue: selectionEvent.selectedId) else { return }
                self?.updateCategoryFilter(category)
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    func loadInitialData() {
        displayState = displayState.loading()
        loadTransactionsData()
    }

    func refreshData() {
        displayState = displayState.loading()
        loadTransactionsData()
    }

    func selectCategory(_ category: TransactionCategory) {
        transactionTypePillSelectorViewModel.selectPill(id: category.rawValue)
    }

    func selectDateFilter(_ filter: TransactionDateFilter) {
        displayState = displayState.dateFiltered(dateFilter: filter)
        loadTransactionsData()
    }

    func didTapBack() {
        onDismiss?()
    }

    // MARK: - Private Data Loading

    private func updateCategoryFilter(_ category: TransactionCategory) {
        displayState = displayState.filtered(category: category)
    }

    private func loadTransactionsData() {
        let dateFilter = displayState.selectedDateFilter

        // Load both banking and wagering transactions concurrently
        let bankingPublisher = servicesProvider.getBankingTransactionsHistory(filter: dateFilter, pageNumber: nil)
            .map { ServiceProviderModelMapper.bankingTransactions(from: $0) }
            .catch { error -> AnyPublisher<[BankingTransaction], Never> in
                print("Failed to load banking transactions: \(error)")
                return Just([]).eraseToAnyPublisher()
            }

        let wageringPublisher = servicesProvider.getWageringTransactionsHistory(filter: dateFilter, pageNumber: nil)
            .map { ServiceProviderModelMapper.wageringTransactions(from: $0) }
            .catch { error -> AnyPublisher<[WageringTransaction], Never> in
                print("Failed to load wagering transactions: \(error)")
                return Just([]).eraseToAnyPublisher()
            }

        Publishers.CombineLatest(bankingPublisher, wageringPublisher)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.displayState = self?.displayState.failed(error: error.localizedDescription) ?? .initial
                    }
                },
                receiveValue: { [weak self] (bankingTransactions, wageringTransactions) in
                    self?.handleTransactionsLoaded(
                        bankingTransactions: bankingTransactions,
                        wageringTransactions: wageringTransactions
                    )
                }
            )
            .store(in: &cancellables)
    }

    private func handleTransactionsLoaded(
        bankingTransactions: [BankingTransaction],
        wageringTransactions: [WageringTransaction]
    ) {
        // Convert to unified transaction items
        let bankingItems = bankingTransactions.map { TransactionHistoryItem.from(bankingTransaction: $0) }
        let wageringItems = wageringTransactions.map { TransactionHistoryItem.from(wageringTransaction: $0) }

        // Combine and sort by date (newest first)
        let allTransactions = (bankingItems + wageringItems).sorted { $0.date > $1.date }

        displayState = displayState.loaded(transactions: allTransactions, hasMoreData: false)
    }
}
