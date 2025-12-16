import Foundation
import Combine


public class MockTicketBetInfoViewModel: TicketBetInfoViewModelProtocol {
    
    // MARK: - Properties
    private let betInfoSubject = CurrentValueSubject<TicketBetInfoData, Never>(TicketBetInfoData.empty)
    
    public var currentBetInfo: TicketBetInfoData {
        betInfoSubject.value
    }
    
    public var betInfoPublisher: AnyPublisher<TicketBetInfoData, Never> {
        betInfoSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Button View Models
    public var rebetButtonViewModel: ButtonIconViewModelProtocol

    public var cashoutButtonViewModel: ButtonIconViewModelProtocol

    // MARK: - Cashout Component ViewModels
    public var cashoutSliderViewModel: CashoutSliderViewModelProtocol?
    public var cashoutAmountViewModel: CashoutAmountViewModelProtocol?

    // MARK: - Callbacks
    public var onNavigationTap: (() -> Void)?
    public var onRebetTap: (() -> Void)?
    public var onCashoutTap: (() -> Void)?
    
    // MARK: - Initialization
    public init() {
        
        let rebetButtonViewModel = MockButtonIconViewModel(
            title: "Rebet",
            icon: "arrow.clockwise",
            layoutType: .iconLeft
        )
        self.rebetButtonViewModel = rebetButtonViewModel
        
        let cashoutButtonViewModel = MockButtonIconViewModel(
            title: LocalizationProvider.string("cashout"),
            icon: "dollarsign.circle",
            layoutType: .iconLeft
        )
        self.cashoutButtonViewModel = cashoutButtonViewModel
        
        self.setupBindings()
    }
    
    private func setupBindings() {
        
        rebetButtonViewModel.onButtonTapped = { [weak self] in
            self?.handleRebetTap()
        }
        
        cashoutButtonViewModel.onButtonTapped = { [weak self] in
            self?.handleCashoutTap()
        }
    }
    
    // MARK: - Public Methods
    public func handleNavigationTap() {
        print("Navigation tapped!")
        onNavigationTap?()
    }
    
    public func handleRebetTap() {
        print("Rebet tapped!")
        onRebetTap?()
    }
    
    public func handleCashoutTap() {
        print("Cashout tapped!")
        onCashoutTap?()
    }
    
    public func updateBetInfo(_ betInfo: TicketBetInfoData) {
        betInfoSubject.send(betInfo)
    }
    
    // MARK: - Mock Factory Methods
    public static func pendingMock() -> MockTicketBetInfoViewModel {
        let viewModel = MockTicketBetInfoViewModel()
        let betInfo = TicketBetInfoData(
            id: "BET001",
            title: "Single Bet - Pending",
            betDetails: "00/00/0000 00:00 | Bet ID: 00000",
            tickets: [
                TicketSelectionData(
                    id: "TICKET001",
                    competitionName: LocalizationProvider.string("competition"),
                    homeTeamName: "Team 1",
                    awayTeamName: "Team 2",
                    homeScore: 0,
                    awayScore: 0,
                    matchDate: "Today 15:30",
                    isLive: true,
                    sportIcon: "soccerball",
                    countryFlag: "flag.fill",
                    marketName: "Market",
                    selectionName: "Selection",
                    oddsValue: "0.00"
                )
            ],
            totalOdds: "7.84",
            betAmount: "XAF 10.00",
            possibleWinnings: "XAF 78.85",
            partialCashoutValue: nil,
            cashoutTotalAmount: nil,
            betStatus: nil,
            isSettled: false
        )
        viewModel.updateBetInfo(betInfo)
        return viewModel
    }
    
    public static func multipleTicketsMock() -> MockTicketBetInfoViewModel {
        let viewModel = MockTicketBetInfoViewModel()
        let betInfo = TicketBetInfoData(
            id: "BET002",
            title: "Multiple Bets - Pending",
            betDetails: "00/00/0000 00:00 | Bet ID: 00001",
            tickets: [
                TicketSelectionData(
                    id: "TICKET001",
                    competitionName: "Premier League",
                    homeTeamName: "Manchester United",
                    awayTeamName: "Liverpool",
                    homeScore: 2,
                    awayScore: 1,
                    matchDate: "Today 15:30",
                    isLive: true,
                    sportIcon: "soccerball",
                    countryFlag: "flag.fill",
                    marketName: "Match Winner",
                    selectionName: "Home",
                    oddsValue: "2.50"
                ),
                TicketSelectionData(
                    id: "TICKET002",
                    competitionName: "La Liga",
                    homeTeamName: "Barcelona",
                    awayTeamName: "Real Madrid",
                    homeScore: 0,
                    awayScore: 0,
                    matchDate: "Tomorrow 20:00",
                    isLive: false,
                    sportIcon: "soccerball",
                    countryFlag: "flag.fill",
                    marketName: "Total Goals",
                    selectionName: "Over 2.5",
                    oddsValue: "1.85"
                )
            ],
            totalOdds: "4.63",
            betAmount: "XAF 25.00",
            possibleWinnings: "XAF 115.75",
            partialCashoutValue: nil,
            cashoutTotalAmount: nil,
            betStatus: nil,
            isSettled: false
        )
        viewModel.updateBetInfo(betInfo)
        return viewModel
    }
    
    public static func longCompetitionNamesMock() -> MockTicketBetInfoViewModel {
        let viewModel = MockTicketBetInfoViewModel()
        let betInfo = TicketBetInfoData(
            id: "BET003",
            title: "Long Names Test - Pending",
            betDetails: "00/00/0000 00:00 | Bet ID: 00002",
            tickets: [
                TicketSelectionData(
                    id: "TICKET001",
                    competitionName: "Very Long Competition Name That Might Overflow",
                    homeTeamName: "Very Long Team Name That Might Cause Issues",
                    awayTeamName: "Another Very Long Team Name For Testing",
                    homeScore: 3,
                    awayScore: 2,
                    matchDate: "Today 15:30",
                    isLive: true,
                    sportIcon: "soccerball",
                    countryFlag: "flag.fill",
                    marketName: "Very Long Market Name",
                    selectionName: "Very Long Selection Name",
                    oddsValue: "3.25"
                )
            ],
            totalOdds: "3.25",
            betAmount: "XAF 50.00",
            possibleWinnings: "XAF 162.50",
            partialCashoutValue: nil,
            cashoutTotalAmount: nil,
            betStatus: nil,
            isSettled: false
        )
        viewModel.updateBetInfo(betInfo)
        return viewModel
    }

    public static func pendingMockWithCashout() -> MockTicketBetInfoViewModel {
        let viewModel = MockTicketBetInfoViewModel()

        // Create mock cashout amount ViewModel
        viewModel.cashoutAmountViewModel = MockCashoutAmountViewModel.customMock(
            title: "Partial Cashout",
            currency: "XAF",
            amount: "32.00"
        )

        let betInfo = TicketBetInfoData(
            id: "BET002",
            title: "Single Bet - Pending",
            betDetails: "00/00/0000 00:00 | Bet ID: 00001",
            tickets: [
                TicketSelectionData(
                    id: "TICKET001",
                    competitionName: LocalizationProvider.string("competition"),
                    homeTeamName: "Team 1",
                    awayTeamName: "Team 2",
                    homeScore: 0,
                    awayScore: 0,
                    matchDate: "Today 15:30",
                    isLive: true,
                    sportIcon: "soccerball",
                    countryFlag: "flag.fill",
                    marketName: "Market",
                    selectionName: "Selection",
                    oddsValue: "0.00"
                )
            ],
            totalOdds: "7.84",
            betAmount: "XAF 10.00",
            possibleWinnings: "XAF 78.85",
            partialCashoutValue: "32.00",
            cashoutTotalAmount: nil,
            betStatus: nil,
            isSettled: false
        )
        viewModel.updateBetInfo(betInfo)
        return viewModel
    }
    
    public static func pendingMockWithSlider() -> MockTicketBetInfoViewModel {
        let viewModel = MockTicketBetInfoViewModel()

        // Create mock slider ViewModel
        viewModel.cashoutSliderViewModel = MockCashoutSliderViewModel.customMock(
            title: LocalizationProvider.string("mybets_choose_cashout_amount"),
            minimumValue: 0.1,
            maximumValue: 200.0,
            currentValue: 160.0,  // 80% of max
            currency: "XAF"
        )

        let betInfo = TicketBetInfoData(
            id: "BET003",
            title: "Single Bet - Pending",
            betDetails: "00/00/0000 00:00 | Bet ID: 00002",
            tickets: [
                TicketSelectionData(
                    id: "TICKET001",
                    competitionName: LocalizationProvider.string("competition"),
                    homeTeamName: "Team 1",
                    awayTeamName: "Team 2",
                    homeScore: 0,
                    awayScore: 0,
                    matchDate: "Today 15:30",
                    isLive: true,
                    sportIcon: "soccerball",
                    countryFlag: "flag.fill",
                    marketName: "Market",
                    selectionName: "Selection",
                    oddsValue: "0.00"
                )
            ],
            totalOdds: "7.84",
            betAmount: "XAF 10.00",
            possibleWinnings: "XAF 78.85",
            partialCashoutValue: nil,
            cashoutTotalAmount: "200.0",
            betStatus: nil,
            isSettled: false
        )
        viewModel.updateBetInfo(betInfo)
        return viewModel
    }
    
    public static func pendingMockWithBoth() -> MockTicketBetInfoViewModel {
        let viewModel = MockTicketBetInfoViewModel()

        // Create mock cashout amount ViewModel
        viewModel.cashoutAmountViewModel = MockCashoutAmountViewModel.customMock(
            title: "Partial Cashout",
            currency: "XAF",
            amount: "32.00"
        )

        // Create mock slider ViewModel
        viewModel.cashoutSliderViewModel = MockCashoutSliderViewModel.customMock(
            title: LocalizationProvider.string("mybets_choose_cashout_amount"),
            minimumValue: 0.1,
            maximumValue: 200.0,
            currentValue: 160.0,  // 80% of max
            currency: "XAF"
        )

        let betInfo = TicketBetInfoData(
            id: "BET004",
            title: "Single Bet - Pending",
            betDetails: "00/00/0000 00:00 | Bet ID: 00003",
            tickets: [
                TicketSelectionData(
                    id: "TICKET001",
                    competitionName: LocalizationProvider.string("competition"),
                    homeTeamName: "Team 1",
                    awayTeamName: "Team 2",
                    homeScore: 0,
                    awayScore: 0,
                    matchDate: "Today 15:30",
                    isLive: true,
                    sportIcon: "soccerball",
                    countryFlag: "flag.fill",
                    marketName: "Market",
                    selectionName: "Selection",
                    oddsValue: "0.00"
                )
            ],
            totalOdds: "7.84",
            betAmount: "XAF 10.00",
            possibleWinnings: "XAF 78.85",
            partialCashoutValue: "32.00",
            cashoutTotalAmount: "200.0",
            betStatus: nil,
            isSettled: false
        )
        viewModel.updateBetInfo(betInfo)
        return viewModel
    }
    
    // MARK: - Settled Bet Mocks
    
    public static func wonBetMock() -> MockTicketBetInfoViewModel {
        let viewModel = MockTicketBetInfoViewModel()
        let betInfo = TicketBetInfoData(
            id: "BET_WON_001",
            title: "Single Bet - Won",
            betDetails: "20/08/2024 15:52 | Bet ID: 2159",
            tickets: [
                TicketSelectionData(
                    id: "TICKET_WON_001",
                    competitionName: "Brasileirão Série A",
                    homeTeamName: "Ceara SC CE",
                    awayTeamName: "CR Vasco da Gama RJ",
                    homeScore: 3,
                    awayScore: 0,
                    matchDate: "20/08/2024 15:30",
                    isLive: false,
                    sportIcon: "soccerball",
                    countryFlag: "🇧🇷",
                    marketName: "Double Chance",
                    selectionName: "Ceara SC CE",
                    oddsValue: "1.64"
                )
            ],
            totalOdds: "7.84",
            betAmount: "XAF 10.00",
            possibleWinnings: "XAF 78.85",
            partialCashoutValue: nil,
            cashoutTotalAmount: nil,
            betStatus: BetTicketStatusData(status: .won),
            isSettled: true
        )
        viewModel.updateBetInfo(betInfo)
        return viewModel
    }
    
    public static func lostBetMock() -> MockTicketBetInfoViewModel {
        let viewModel = MockTicketBetInfoViewModel()
        let betInfo = TicketBetInfoData(
            id: "BET_LOST_001",
            title: "Single Bet - Lost",
            betDetails: "20/08/2024 15:52 | Bet ID: 2160",
            tickets: [
                TicketSelectionData(
                    id: "TICKET_LOST_001",
                    competitionName: "Brasileirão Série A",
                    homeTeamName: "Ceara SC CE",
                    awayTeamName: "CR Vasco da Gama RJ",
                    homeScore: 0,
                    awayScore: 3,
                    matchDate: "20/08/2024 15:30",
                    isLive: false,
                    sportIcon: "soccerball",
                    countryFlag: "🇧🇷",
                    marketName: "Double Chance",
                    selectionName: "Ceara SC CE",
                    oddsValue: "1.64"
                )
            ],
            totalOdds: "7.84",
            betAmount: "XAF 10.00",
            possibleWinnings: "XAF 78.85",
            partialCashoutValue: nil,
            cashoutTotalAmount: nil,
            betStatus: BetTicketStatusData(status: .lost),
            isSettled: true
        )
        viewModel.updateBetInfo(betInfo)
        return viewModel
    }
    
    public static func drawBetMock() -> MockTicketBetInfoViewModel {
        let viewModel = MockTicketBetInfoViewModel()
        let betInfo = TicketBetInfoData(
            id: "BET_DRAW_001",
            title: "Single Bet - Draw",
            betDetails: "20/08/2024 15:52 | Bet ID: 2161",
            tickets: [
                TicketSelectionData(
                    id: "TICKET_DRAW_001",
                    competitionName: "Brasileirão Série A",
                    homeTeamName: "Ceara SC CE",
                    awayTeamName: "CR Vasco da Gama RJ",
                    homeScore: 1,
                    awayScore: 1,
                    matchDate: "20/08/2024 15:30",
                    isLive: false,
                    sportIcon: "soccerball",
                    countryFlag: "🇧🇷",
                    marketName: "Match Winner",
                    selectionName: "Draw",
                    oddsValue: "3.20"
                )
            ],
            totalOdds: "3.20",
            betAmount: "XAF 15.00",
            possibleWinnings: "XAF 48.00",
            partialCashoutValue: nil,
            cashoutTotalAmount: nil,
            betStatus: BetTicketStatusData(status: .draw),
            isSettled: true
        )
        viewModel.updateBetInfo(betInfo)
        return viewModel
    }
}

// MARK: - Extensions
extension TicketBetInfoData {
    static var empty: TicketBetInfoData {
        TicketBetInfoData(
            id: "",
            title: "",
            betDetails: "",
            tickets: [],
            totalOdds: "",
            betAmount: "",
            possibleWinnings: "",
            partialCashoutValue: nil,
            cashoutTotalAmount: nil,
            betStatus: nil,
            isSettled: false
        )
    }
} 
