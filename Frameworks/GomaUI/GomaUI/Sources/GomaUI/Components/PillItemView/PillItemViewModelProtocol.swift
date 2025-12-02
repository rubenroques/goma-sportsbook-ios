import Combine
import UIKit

// MARK: - Data Models
public struct PillData: Equatable, Hashable {
    public let id: String
    public let title: String
    public let leftIconName: String?
    public let showExpandIcon: Bool
    public let isSelected: Bool
    public let shouldApplyTintColor: Bool

    public init(id: String, title: String, leftIconName: String? = nil, showExpandIcon: Bool = false, isSelected: Bool = false, shouldApplyTintColor: Bool = true) {
        self.id = id
        self.title = title
        self.leftIconName = leftIconName
        self.showExpandIcon = showExpandIcon
        self.isSelected = isSelected
        self.shouldApplyTintColor = shouldApplyTintColor
    }
}

// MARK: - Display State
public struct PillDisplayState: Equatable {
    public let pillData: PillData

    public init(pillData: PillData) {
        self.pillData = pillData
    }
}

// MARK: - View Model Protocol
public protocol PillItemViewModelProtocol {
    // Individual publishers for each state property
    var idPublisher: AnyPublisher<String, Never> { get }
    var titlePublisher: AnyPublisher<String, Never> { get }
    var leftIconNamePublisher: AnyPublisher<String?, Never> { get }
    var showExpandIconPublisher: AnyPublisher<Bool, Never> { get }
    var isSelectedPublisher: AnyPublisher<Bool, Never> { get }
    var shouldApplyTintColorPublisher: AnyPublisher<Bool, Never> { get }
    
    // Read-only state - when true, selectPill() should not change the selection state
    var isReadOnly: Bool { get }

    // Actions
    func selectPill()
    func updateTitle(_ title: String)
    func updateLeftIcon(_ iconName: String?)
    func updateExpandIconVisibility(_ show: Bool)
}
