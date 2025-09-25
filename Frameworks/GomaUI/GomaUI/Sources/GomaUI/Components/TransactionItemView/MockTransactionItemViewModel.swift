import Foundation
import UIKit

public class MockTransactionItemViewModel: TransactionItemViewModelProtocol {

    // MARK: - Properties

    public var data: TransactionItemData?

    // MARK: - Initialization

    public init(data: TransactionItemData? = nil) {
        self.data = data
    }

    // MARK: - Protocol Properties

    public var balancePrefix: String {
        return "Balance: "
    }

    public var balanceAmount: String {
        guard let data = data, let balance = data.balance else { return "" }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        if let formattedNumber = formatter.string(from: NSNumber(value: balance)) {
            return "\(data.currency) \(formattedNumber)"
        }
        return "\(data.currency) \(balance)"
    }

    // MARK: - Protocol Methods

    public func copyTransactionId() {
        guard let transactionId = data?.transactionId else { return }
        UIPasteboard.general.string = transactionId
    }

    // MARK: - Factory Methods

    public static var defaultMock: MockTransactionItemViewModel {
        return MockTransactionItemViewModel(data: depositMockData)
    }

    public static var depositMock: MockTransactionItemViewModel {
        return MockTransactionItemViewModel(data: depositMockData)
    }

    public static var withdrawalMock: MockTransactionItemViewModel {
        return MockTransactionItemViewModel(data: withdrawalMockData)
    }

    public static var betPlacedMock: MockTransactionItemViewModel {
        return MockTransactionItemViewModel(data: betPlacedMockData)
    }

    public static var betWonMock: MockTransactionItemViewModel {
        return MockTransactionItemViewModel(data: betWonMockData)
    }

    public static var taxMock: MockTransactionItemViewModel {
        return MockTransactionItemViewModel(data: taxMockData)
    }

    public static var emptyMock: MockTransactionItemViewModel {
        return MockTransactionItemViewModel(data: nil)
    }

    public static var noBalanceMock: MockTransactionItemViewModel {
        return MockTransactionItemViewModel(data: noBalanceMockData)
    }

    // MARK: - Mock Data

    private static var depositMockData: TransactionItemData {
        return TransactionItemData(
            category: "Deposit",
            status: nil,
            amount: 50.00,
            currency: "XAF",
            transactionId: "#T123456789",
            date: Date(),
            balance: 1250.00
        )
    }

    private static var withdrawalMockData: TransactionItemData {
        return TransactionItemData(
            category: "Withdrawal",
            status: nil,
            amount: -25.00,
            currency: "XAF",
            transactionId: "#T987654321",
            date: Calendar.current.date(byAdding: .hour, value: -2, to: Date()) ?? Date(),
            balance: 1200.00
        )
    }

    private static var betPlacedMockData: TransactionItemData {
        return TransactionItemData(
            category: "Real Madrid vs Barcelona",
            status: .placed,
            amount: -100.00,
            currency: "XAF",
            transactionId: "#T555666777",
            date: Calendar.current.date(byAdding: .hour, value: -4, to: Date()) ?? Date(),
            balance: 1150.00
        )
    }

    private static var betWonMockData: TransactionItemData {
        return TransactionItemData(
            category: "Manchester City Manchester City Manchester City vs Arsenal",
            status: .won,
            amount: 250.00,
            currency: "XAF",
            transactionId: "#T111222333",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            balance: 1400.00
        )
    }

    private static var taxMockData: TransactionItemData {
        return TransactionItemData(
            category: "Win Tax Deduction",
            status: .tax,
            amount: -12.50,
            currency: "XAF",
            transactionId: "#T444555666",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            balance: 1387.50
        )
    }

    private static var noBalanceMockData: TransactionItemData {
        return TransactionItemData(
            category: "Pending Withdrawal",
            status: nil,
            amount: -50.00,
            currency: "XAF",
            transactionId: "#T999888777",
            date: Date(),
            balance: nil
        )
    }
}
