import Foundation
import UIKit

public struct MainFilterItem: Equatable, Hashable {
    public let type: QuickLinkType
    public let title: String
    public let icon: String?
    public let actionIcon: String?
    
    public init(type: QuickLinkType, title: String, icon: String? = nil, actionIcon: String? = nil) {
        self.type = type
        self.title = title
        self.icon = icon
        self.actionIcon = actionIcon
    }
}

public enum MainFilterStateType {
    case notSelected
    case selected(selections: String)
}
