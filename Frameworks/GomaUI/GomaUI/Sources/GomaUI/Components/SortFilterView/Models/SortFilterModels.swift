import Foundation

public struct SortOption: Equatable {
    public var id: String
    public var icon: String?
    public var title: String
    public var count: Int
    public var iconTintChange: Bool
    
    public init(id: String, icon: String?, title: String, count: Int, iconTintChange: Bool = true) {
        self.id = id
        self.icon = icon
        self.title = title
        self.count = count
        self.iconTintChange = iconTintChange
    }
}
