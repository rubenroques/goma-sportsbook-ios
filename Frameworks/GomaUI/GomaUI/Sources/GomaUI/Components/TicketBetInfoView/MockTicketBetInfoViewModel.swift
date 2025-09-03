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
    public lazy var rebetButtonViewModel: ButtonIconViewModelProtocol = {
        let viewModel = MockButtonIconViewModel(
            title: "Rebet",
            icon: "arrow.clockwise",
            layoutType: .iconLeft
        )
        viewModel.onButtonTapped = { [weak self] in
            self?.handleRebetTap()
        }
        return viewModel
    }()
    
    public lazy var cashoutButtonViewModel: ButtonIconViewModelProtocol = {
        let viewModel = MockButtonIconViewModel(
            title: "Cashout",
            icon: "dollarsign.circle",
            layoutType: .iconLeft
        )
        viewModel.onButtonTapped = { [weak self] in
            self?.handleCashoutTap()
        }
        return viewModel
    }()
    
    // MARK: - Callbacks
    public var onNavigationTap: (() -> Void)?
    public var onRebetTap: (() -> Void)?
    public var onCashoutTap: (() -> Void)?
    
    // MARK: - Initialization
    public init() {}
    
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
                    competitionName: "Competition",
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
            cashoutTotalAmount: nil
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
            possibleWinnings: "XAF 115.75"
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
            possibleWinnings: "XAF 162.50"
        )
        viewModel.updateBetInfo(betInfo)
        return viewModel
    }

    public static func pendingMockWithCashout() -> MockTicketBetInfoViewModel {
        let viewModel = MockTicketBetInfoViewModel()
        let betInfo = TicketBetInfoData(
            id: "BET002",
            title: "Single Bet - Pending",
            betDetails: "00/00/0000 00:00 | Bet ID: 00001",
            tickets: [
                TicketSelectionData(
                    id: "TICKET001",
                    competitionName: "Competition",
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
            cashoutTotalAmount: nil
        )
        viewModel.updateBetInfo(betInfo)
        return viewModel
    }
    
    public static func pendingMockWithSlider() -> MockTicketBetInfoViewModel {
        let viewModel = MockTicketBetInfoViewModel()
        let betInfo = TicketBetInfoData(
            id: "BET003",
            title: "Single Bet - Pending",
            betDetails: "00/00/0000 00:00 | Bet ID: 00002",
            tickets: [
                TicketSelectionData(
                    id: "TICKET001",
                    competitionName: "Competition",
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
            cashoutTotalAmount: "200.0"
        )
        viewModel.updateBetInfo(betInfo)
        return viewModel
    }
    
    public static func pendingMockWithBoth() -> MockTicketBetInfoViewModel {
        let viewModel = MockTicketBetInfoViewModel()
        let betInfo = TicketBetInfoData(
            id: "BET004",
            title: "Single Bet - Pending",
            betDetails: "00/00/0000 00:00 | Bet ID: 00003",
            tickets: [
                TicketSelectionData(
                    id: "TICKET001",
                    competitionName: "Competition",
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
            cashoutTotalAmount: "200.0"
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
            cashoutTotalAmount: nil
        )
    }
} 
