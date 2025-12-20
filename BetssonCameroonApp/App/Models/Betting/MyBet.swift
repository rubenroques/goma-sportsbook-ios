
import Foundation

struct MyBet: Codable, Equatable, Hashable {
    
    // MARK: - Core Properties
    
    let identifier: String
    let type: String
    let state: MyBetState
    let result: MyBetResult
    let globalState: MyBetState
    
    // MARK: - Financial Information
    
    let stake: Double
    let totalOdd: Double
    let potentialReturn: Double?
    let totalReturn: Double?
    let currency: String
    
    // MARK: - Selection Information
    
    let selections: [MyBetSelection]
    
    // MARK: - Timestamp Information
    
    let date: Date
    
    // MARK: - Additional Properties

    let freebet: Bool
    let partialCashoutReturn: Double?
    let partialCashoutStake: Double?
    let ticketCode: String?
    let partialCashOuts: [PartialCashOut]?

    // MARK: - Initialization
    
    init(
        identifier: String,
        type: String,
        state: MyBetState,
        result: MyBetResult,
        globalState: MyBetState,
        stake: Double,
        totalOdd: Double,
        potentialReturn: Double?,
        totalReturn: Double?,
        currency: String,
        selections: [MyBetSelection],
        date: Date,
        freebet: Bool = false,
        partialCashoutReturn: Double? = nil,
        partialCashoutStake: Double? = nil,
        ticketCode: String? = nil,
        partialCashOuts: [PartialCashOut]? = nil
    ) {
        self.identifier = identifier
        self.type = type
        self.state = state
        self.result = result
        self.globalState = globalState
        self.stake = stake
        self.totalOdd = totalOdd
        self.potentialReturn = potentialReturn
        self.totalReturn = totalReturn
        self.currency = currency
        self.selections = selections
        self.date = date
        self.freebet = freebet
        self.partialCashoutReturn = partialCashoutReturn
        self.partialCashoutStake = partialCashoutStake
        self.ticketCode = ticketCode
        self.partialCashOuts = partialCashOuts
    }

    // MARK: - Convenience Properties

    /// Returns the ticket reference for display (ticketCode if available, otherwise identifier)
    var displayTicketReference: String {
        return ticketCode ?? identifier
    }

    /// Returns true if this is a single bet (1 selection)
    var isSingle: Bool {
        return selections.count == 1
    }
    
    /// Returns true if this is a multiple/combination bet
    var isMultiple: Bool {
        return selections.count > 1
    }
    
    /// Returns the number of selections in this bet
    var selectionCount: Int {
        return selections.count
    }
    
    /// Returns a formatted string describing the bet type
    var typeDescription: String {
        switch type.lowercased() {
        case "single":
            return "Single"
        case "multiple", "combo", "combination":
            return "Multiple (\(selectionCount))"
        default:
            return type.capitalized
        }
    }
    
    
    /// Returns a short description of the first selection for display
    var primarySelectionDescription: String {
        guard let firstSelection = selections.first else {
            return "No selections"
        }
        return firstSelection.fullSelectionDescription
    }
    
    /// Returns a summary description of all selections
    var selectionsDescription: String {
        let descriptions = selections.prefix(2).map { $0.fullSelectionDescription }
        var result = descriptions.joined(separator: "\n")
        
        if selections.count > 2 {
            result += "\n... and \(selections.count - 2) more"
        }
        
        return result
    }
    
    /// Returns true if the bet can be cashed out
    var canCashOut: Bool {
        return state == .opened && partialCashoutReturn != nil && partialCashoutReturn! > 0
    }
    
    /// Returns true if this bet has been settled
    var isSettled: Bool {
        return state.isFinished
    }
    
    /// Returns true if this bet is still active
    var isActive: Bool {
        return state.isActive
    }
    
    /// Returns the profit/loss amount if the bet is settled
    var profitLoss: Double? {
        guard let totalReturn = totalReturn, isSettled else {
            return nil
        }
        return totalReturn - stake
    }

    // MARK: - Cashout History

    /// Returns the total amount already cashed out from previous partial cashouts
    var totalCashedOut: Double {
        partialCashOuts?.compactMap { $0.cashOutAmount }.reduce(0, +) ?? 0
    }

    /// Returns true if this bet has any previous partial cashouts
    var hasPreviousCashouts: Bool {
        totalCashedOut > 0
    }

}
