import Combine
import UIKit



// MARK: - Data Models
public struct PillData: Equatable, Hashable {
    public let id: String
    public let title: String
    public let leftIconName: String?
    public let type: PillItemViewType
    public let isSelected: Bool
    public let shouldApplyTintColor: Bool

    public init(
        id: String,
        title: String,
        leftIconName: String? = nil,
        type: PillItemViewType = .informative,
        isSelected: Bool = false,
        shouldApplyTintColor: Bool = true
    ) {
        self.id = id
        self.title = title
        self.leftIconName = leftIconName
        self.type = type
        self.isSelected = isSelected
        self.shouldApplyTintColor = shouldApplyTintColor
    }
    
    public enum PillItemViewType: Equatable, Hashable {
        case informative, expansible, countable(count: Int)
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
    // Synchronous state access (for immediate rendering)
    var currentDisplayState: PillDisplayState { get }

    // Reactive state publisher (for updates)
    var displayStatePublisher: AnyPublisher<PillDisplayState, Never> { get }

    // Individual publishers for each state property (legacy - kept for backward compatibility)
    var idPublisher: AnyPublisher<String, Never> { get }
    var titlePublisher: AnyPublisher<String, Never> { get }
    var leftIconNamePublisher: AnyPublisher<String?, Never> { get }
    var typePublisher: AnyPublisher<PillData.PillItemViewType, Never> { get }
    var isSelectedPublisher: AnyPublisher<Bool, Never> { get }
    var shouldApplyTintColorPublisher: AnyPublisher<Bool, Never> { get }

    // Read-only state - when true, selectPill() should not change the selection state
    var isReadOnly: Bool { get }

    // Actions
    func selectPill()
    func updateTitle(_ title: String)
    func updateLeftIcon(_ iconName: String?)
    func updateType(_ newType: PillData.PillItemViewType)
}
