import Foundation
import Combine

/// Data model for ticket bet information
public struct TicketBetInfoData: Equatable {
    public let id: String
    public let title: String
    public let betDetails: String
    public let tickets: [TicketSelectionData]
    public let totalOdds: String
    public let betAmount: String
    public let possibleWinnings: String
    public let partialCashoutValue: String?
    public let cashoutTotalAmount: String?
    public let betStatus: BetTicketStatusData?
    public let isSettled: Bool
    
    public init(
        id: String,
        title: String,
        betDetails: String,
        tickets: [TicketSelectionData],
        totalOdds: String,
        betAmount: String,
        possibleWinnings: String,
        partialCashoutValue: String? = nil,
        cashoutTotalAmount: String? = nil,
        betStatus: BetTicketStatusData? = nil,
        isSettled: Bool = false
    ) {
        self.id = id
        self.title = title
        self.betDetails = betDetails
        self.tickets = tickets
        self.totalOdds = totalOdds
        self.betAmount = betAmount
        self.possibleWinnings = possibleWinnings
        self.partialCashoutValue = partialCashoutValue
        self.cashoutTotalAmount = cashoutTotalAmount
        self.betStatus = betStatus
        self.isSettled = isSettled
    }
}

/// Protocol defining the interface for TicketBetInfoView ViewModels
public protocol TicketBetInfoViewModelProtocol {
    /// Current bet info data for immediate access (required for table view sizing)
    var currentBetInfo: TicketBetInfoData { get }
    
    /// Publisher for dynamic bet info updates (optional for real-time changes)
    var betInfoPublisher: AnyPublisher<TicketBetInfoData, Never> { get }
    
    /// Button view models
    var rebetButtonViewModel: ButtonIconViewModelProtocol { get }
    var cashoutButtonViewModel: ButtonIconViewModelProtocol { get }

    /// ViewModel for cashout slider. When nil, slider is not shown.
    var cashoutSliderViewModel: CashoutSliderViewModelProtocol? { get }

    /// ViewModel for cashout amount display. When nil, amount view is not shown.
    var cashoutAmountViewModel: CashoutAmountViewModelProtocol? { get }

    /// Whether cashout is currently executing (for loading overlay)
    var isCashoutLoading: Bool { get }

    /// Publisher for cashout loading state changes
    var isCashoutLoadingPublisher: AnyPublisher<Bool, Never> { get }

    /// Handle navigation button tap
    func handleNavigationTap()
    
    /// Handle rebet button tap
    func handleRebetTap()
    
    /// Handle cashout button tap
    func handleCashoutTap()
} 
