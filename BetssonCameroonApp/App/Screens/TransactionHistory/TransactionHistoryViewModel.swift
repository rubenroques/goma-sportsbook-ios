
import Foundation
import Combine
import GomaUI
import ServicesProvider

final class TransactionHistoryViewModel: TransactionHistoryViewModelProtocol {

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
    let gameTypeTabBarViewModel: MarketGroupSelectorTabViewModelProtocol

    // MARK: - Callbacks

    var onDismiss: (() -> Void)?

    // MARK: - Initialization

    init(servicesProvider: ServicesProvider.Client) {
        self.servicesProvider = servicesProvider
        self.transactionTypePillSelectorViewModel = TransactionTypePillSelectorViewModel()
        self.gameTypeTabBarViewModel = GameTypeTabBarViewModel()

        setupBindings()
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // Listen to pill selector changes (Level 0: All/Payments/Games)
        transactionTypePillSelectorViewModel.selectionEventPublisher
            .sink { [weak self] selectionEvent in
                guard let category = TransactionCategory(rawValue: selectionEvent.selectedId) else { return }
                self?.updateCategoryFilter(category)
            }
            .store(in: &cancellables)

        // Listen to game type selector changes (Level 1: All/Sportsbook/Casino)
        gameTypeTabBarViewModel.selectionEventPublisher
            .sink { [weak self] selectionEvent in
                guard let gameType = GameTransactionType(rawValue: selectionEvent.selectedId) else { return }
                self?.updateGameTypeFilter(gameType)
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    func loadInitialData() {
        displayState = displayState.loadingWithClearedData()
        loadTransactionsData()
    }

    func refreshData() {
        displayState = displayState.loadingWithClearedData()
        loadTransactionsData()
    }

    func selectCategory(_ category: TransactionCategory) {
        transactionTypePillSelectorViewModel.selectPill(id: category.rawValue)
    }

    func selectDateFilter(_ filter: TransactionDateFilter) {
        // Prevent concurrent requests (matches web implementation request locking)
        guard !displayState.isLoading else {
            print("Transaction loading in progress, ignoring filter change")
            return
        }

        displayState = displayState.dateFiltered(dateFilter: filter)
        displayState = displayState.loadingWithClearedData()
        loadTransactionsData()
    }

    func didTapBack() {
        onDismiss?()
    }

    // MARK: - Private Data Loading

    private func updateCategoryFilter(_ category: TransactionCategory) {
        displayState = displayState.filtered(category: category)
    }

    private func updateGameTypeFilter(_ gameType: GameTransactionType) {
        displayState = displayState.gameTypeFiltered(gameType: gameType)
    }

    private func loadTransactionsData() {
        let dateFilter = displayState.selectedDateFilter

        // Load both banking and wagering transactions concurrently
        let bankingPublisher = servicesProvider.getBankingTransactionsHistory(filter: dateFilter, pageNumber: nil)
            .catch { error -> AnyPublisher<ServicesProvider.BankingTransactionsResponse, Never> in
                print("Failed to load banking transactions: \(error)")
                // Return empty response on error
                return Just(ServicesProvider.BankingTransactionsResponse(
                    pagination: ServicesProvider.TransactionPagination(next: nil, previous: nil),
                    transactions: []
                )).eraseToAnyPublisher()
            }

        let wageringPublisher = servicesProvider.getWageringTransactionsHistory(filter: dateFilter, pageNumber: nil)
            .catch { error -> AnyPublisher<ServicesProvider.WageringTransactionsResponse, Never> in
                print("Failed to load wagering transactions: \(error)")
                // Return empty response on error
                return Just(ServicesProvider.WageringTransactionsResponse(
                    pagination: ServicesProvider.TransactionPagination(next: nil, previous: nil),
                    transactions: []
                )).eraseToAnyPublisher()
            }

        Publishers.CombineLatest(bankingPublisher, wageringPublisher)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.displayState = self?.displayState.failed(error: error.localizedDescription) ?? .initial
                    }
                },
                receiveValue: { [weak self] (bankingResponse, wageringResponse) in
                    self?.handleTransactionsLoaded(
                        bankingResponse: bankingResponse,
                        wageringResponse: wageringResponse
                    )
                }
            )
            .store(in: &cancellables)
    }

    private func handleTransactionsLoaded(
        bankingResponse: ServicesProvider.BankingTransactionsResponse,
        wageringResponse: ServicesProvider.WageringTransactionsResponse
    ) {
        // Map transactions to app models
        let bankingTransactions = ServiceProviderModelMapper.bankingTransactions(from: bankingResponse)
        let wageringTransactions = ServiceProviderModelMapper.wageringTransactions(from: wageringResponse)

        // Convert to unified transaction items
        let bankingItems = bankingTransactions.map { TransactionHistoryItem.from(bankingTransaction: $0) }
        let wageringItems = wageringTransactions.map { TransactionHistoryItem.from(wageringTransaction: $0) }

        // Combine and sort by date (newest first)
        let allTransactions = (bankingItems + wageringItems).sorted { $0.date > $1.date }

        // Determine if there's more data (matches web implementation: hasMore if either endpoint has more)
        let hasMoreData = bankingResponse.pagination.next != nil || wageringResponse.pagination.next != nil

        displayState = displayState.loaded(transactions: allTransactions, hasMoreData: hasMoreData)
    }
}
