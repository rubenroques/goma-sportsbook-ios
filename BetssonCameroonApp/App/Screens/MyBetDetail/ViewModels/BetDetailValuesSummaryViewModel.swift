//
//  BetDetailValuesSummaryViewModel.swift
//  BetssonCameroonApp
//
//  Created on 04/09/2025.
//

import Foundation
import Combine
import GomaUI

final class BetDetailValuesSummaryViewModel: BetDetailValuesSummaryViewModelProtocol {
    
    // MARK: - Properties
    
    private let dataSubject: CurrentValueSubject<BetDetailValuesSummaryData, Never>
    
    var dataPublisher: AnyPublisher<BetDetailValuesSummaryData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Initialization
    
    init(data: BetDetailValuesSummaryData) {
        dataSubject = .init(data)
    }
    
    // MARK: - Public Methods
    
    func updateData(_ data: BetDetailValuesSummaryData) {
        dataSubject.send(data)
    }
    
    // MARK: - Factory Methods
    
    static func create(from myBet: MyBet) -> BetDetailValuesSummaryViewModel {
        
        // Format date for header
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        let formattedDate = dateFormatter.string(from: myBet.date)
        let headerLabel = localized("mybetdetail_bet_placed_on").replacingOccurrences(of: "{date}", with: formattedDate)
        let headerRow = BetDetailRowData(
            label: headerLabel,
            value: "",
            style: .header
        )

        // Create content rows from MyBet data (no calculations)
        var contentRows: [BetDetailRowData] = []

        // Ticket (first row)
        contentRows.append(BetDetailRowData(
            label: localized("mybetdetail_label_ticket"),
            value: "#\(myBet.displayTicketReference)",
            style: .standard
        ))

        // Odds
        contentRows.append(BetDetailRowData(
            label: localized("odds"),
            value: String(format: "%.2f", myBet.totalOdd),
            style: .standard
        ))

        // Amount (stake)
        contentRows.append(BetDetailRowData(
            label: localized("mybetdetail_label_amount"),
            value: formatCurrency(myBet.stake, currency: myBet.currency),
            style: .standard
        ))

        // Potential Return (if available)
        if let potentialReturn = myBet.potentialReturn {
            contentRows.append(BetDetailRowData(
                label: localized("mybetdetail_label_potential_return"),
                value: formatCurrency(potentialReturn, currency: myBet.currency),
                style: .standard
            ))
        }

        // Total Return (if available - for settled bets)
        if let totalReturn = myBet.totalReturn {
            contentRows.append(BetDetailRowData(
                label: localized("mybetdetail_label_total_return"),
                value: formatCurrency(totalReturn, currency: myBet.currency),
                style: .standard
            ))
        }

        // Partial cashout return (if available)
        if let partialCashoutReturn = myBet.partialCashoutReturn {
            contentRows.append(BetDetailRowData(
                label: localized("mybetdetail_label_partial_cashout"),
                value: formatCurrency(partialCashoutReturn, currency: myBet.currency),
                style: .standard
            ))
        }

        // Footer row - bet result (only show for settled bets)
        var footerRow: BetDetailRowData?
        if myBet.isSettled {
            footerRow = BetDetailRowData(
                label: localized("mybetdetail_label_bet_result"),
                value: myBet.result.displayName,
                style: .standard
            )
        }
        
        let data = BetDetailValuesSummaryData(
            headerRow: headerRow,
            contentRows: contentRows,
            footerRow: footerRow
        )
        
        let viewModel = BetDetailValuesSummaryViewModel(data: data)

        return viewModel
    }
    
    // MARK: - Helper Methods

    private static func formatCurrency(_ amount: Double, currency: String) -> String {
        // Use CurrencyHelper for consistent formatting across the app
        // This ensures all currency displays match web app behavior (e.g., "XAF 1,000.00")
        return CurrencyHelper.formatAmountWithCurrency(amount, currency: currency)
    }
}
