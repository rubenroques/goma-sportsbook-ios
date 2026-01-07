import Foundation

public struct LeagueOption: Equatable {
    public let id: String
    public let icon: String?
    public let title: String
    public let count: Int
    public let isAllOption: Bool

    public init(id: String, icon: String?, title: String, count: Int, isAllOption: Bool = false) {
        self.id = id
        self.icon = icon
        self.title = title
        self.count = count
        self.isAllOption = isAllOption
    }
}
