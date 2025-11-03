//
//  BetDetailValuesSummaryViewModel.swift
//  BetssonCameroonApp
//
//  Created by Assistant on 04/09/2025.
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
        let headerRow = BetDetailRowData(
            label: "Bet Placed on \(formattedDate)",
            value: "",
            style: .header
        )
        
        // Create content rows from MyBet data (no calculations)
        var contentRows: [BetDetailRowData] = []
        
        // Ticket (first row)
        contentRows.append(BetDetailRowData(
            label: "Ticket",
            value: "#\(myBet.displayTicketReference)",
            style: .standard
        ))
        
        // Odds
        contentRows.append(BetDetailRowData(
            label: "Odds",
            value: String(format: "%.2f", myBet.totalOdd),
            style: .standard
        ))
        
        // Amount (stake)
        contentRows.append(BetDetailRowData(
            label: "Amount",
            value: formatCurrency(myBet.stake, currency: myBet.currency),
            style: .standard
        ))
        
        // Potential Return (if available)
        if let potentialReturn = myBet.potentialReturn {
            contentRows.append(BetDetailRowData(
                label: "Potential Return",
                value: formatCurrency(potentialReturn, currency: myBet.currency),
                style: .standard
            ))
        }
        
        // Total Return (if available - for settled bets)
        if let totalReturn = myBet.totalReturn {
            contentRows.append(BetDetailRowData(
                label: "Total Return",
                value: formatCurrency(totalReturn, currency: myBet.currency),
                style: .standard
            ))
        }
        
        // Partial cashout return (if available)
        if let partialCashoutReturn = myBet.partialCashoutReturn {
            contentRows.append(BetDetailRowData(
                label: "Partial Cashout",
                value: formatCurrency(partialCashoutReturn, currency: myBet.currency),
                style: .standard
            ))
        }
        
        // Footer row - bet result (only show for settled bets)
        var footerRow: BetDetailRowData?
        if myBet.isSettled {
            footerRow = BetDetailRowData(
                label: "Bet result",
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
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        if let formattedString = formatter.string(from: NSNumber(value: amount)) {
            return formattedString
        }
        
        // Fallback formatting
        let currencySymbol = getCurrencySymbol(for: currency)
        return "\(currencySymbol) \(String(format: "%.2f", amount))"
    }
    
    private static func getCurrencySymbol(for currency: String) -> String {
        switch currency.uppercased() {
        case "EUR":
            return "€"
        case "USD":
            return "$"
        case "GBP":
            return "£"
        case "XAF":
            return "XAF"
        default:
            return currency
        }
    }
}
