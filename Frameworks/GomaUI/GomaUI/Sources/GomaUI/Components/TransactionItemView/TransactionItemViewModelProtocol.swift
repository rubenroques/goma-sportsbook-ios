import Foundation

public protocol TransactionItemViewModelProtocol {
    var data: TransactionItemData? { get }
    var balancePrefix: String { get } // "Balance: "
    var balanceAmount: String { get }  // "XAF 1,234.56"

    func copyTransactionId()
}