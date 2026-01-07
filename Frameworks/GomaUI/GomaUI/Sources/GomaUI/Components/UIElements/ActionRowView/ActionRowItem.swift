import Foundation

public struct ActionRowItem: Identifiable, Equatable, Codable {
    public let id: String
    public let icon: String
    public let title: String
    public let subtitle: String?
    public let type: ActionRowItemType
    public let action: ActionRowAction

    // Customization properties
    public let trailingIcon: String?
    public let isTappable: Bool

    public init(
        id: String = UUID().uuidString,
        icon: String,
        title: String,
        subtitle: String? = nil,
        type: ActionRowItemType,
        action: ActionRowAction,
        trailingIcon: String? = nil,
        isTappable: Bool = true
    ) {
        self.id = id
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.action = action
        self.trailingIcon = trailingIcon
        self.isTappable = isTappable
    }

    // Equatable conformance
    public static func == (lhs: ActionRowItem, rhs: ActionRowItem) -> Bool {
        return lhs.id == rhs.id &&
               lhs.icon == rhs.icon &&
               lhs.title == rhs.title &&
               lhs.subtitle == rhs.subtitle &&
               lhs.type == rhs.type &&
               lhs.action == rhs.action &&
               lhs.trailingIcon == rhs.trailingIcon &&
               lhs.isTappable == rhs.isTappable
    }
}
