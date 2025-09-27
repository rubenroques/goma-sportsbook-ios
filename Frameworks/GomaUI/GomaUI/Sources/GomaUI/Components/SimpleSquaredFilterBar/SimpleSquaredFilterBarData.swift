import Foundation

public struct SimpleSquaredFilterBarData: Equatable {
    public let items: [(id: String, title: String)]
    public let selectedId: String?

    public init(items: [(String, String)], selectedId: String? = nil) {
        self.items = items
        self.selectedId = selectedId ?? items.first?.0
    }

    public static func == (lhs: SimpleSquaredFilterBarData, rhs: SimpleSquaredFilterBarData) -> Bool {
        return lhs.items.count == rhs.items.count &&
               zip(lhs.items, rhs.items).allSatisfy { $0.0 == $1.0 && $0.1 == $1.1 } &&
               lhs.selectedId == rhs.selectedId
    }
}