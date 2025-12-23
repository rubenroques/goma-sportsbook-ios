import Combine
import UIKit

/// Mock implementation of `PillItemViewModelProtocol` for testing.
final public class MockPillItemViewModel: PillItemViewModelProtocol {

    // MARK: - Publishers
    private let idSubject: CurrentValueSubject<String, Never>
    private let titleSubject: CurrentValueSubject<String, Never>
    private let leftIconNameSubject: CurrentValueSubject<String?, Never>
    private let typeSubject: CurrentValueSubject<PillData.PillItemViewType, Never>
    private let isSelectedSubject: CurrentValueSubject<Bool, Never>
    private let shouldApplyTintColorSubject: CurrentValueSubject<Bool, Never>
    
    // MARK: - Read-only mode
    public let isReadOnly: Bool

    public var idPublisher: AnyPublisher<String, Never> {
        return idSubject.eraseToAnyPublisher()
    }

    public var titlePublisher: AnyPublisher<String, Never> {
        return titleSubject.eraseToAnyPublisher()
    }

    public var leftIconNamePublisher: AnyPublisher<String?, Never> {
        return leftIconNameSubject.eraseToAnyPublisher()
    }

    public var typePublisher: AnyPublisher<PillData.PillItemViewType, Never> {
        return typeSubject.eraseToAnyPublisher()
    }

    public var isSelectedPublisher: AnyPublisher<Bool, Never> {
        return isSelectedSubject.eraseToAnyPublisher()
    }
    
    public var shouldApplyTintColorPublisher: AnyPublisher<Bool, Never> {
        return shouldApplyTintColorSubject.eraseToAnyPublisher()
    }

    // MARK: - Synchronous State Access
    public var currentDisplayState: PillDisplayState {
        PillDisplayState(pillData: PillData(
            id: idSubject.value,
            title: titleSubject.value,
            leftIconName: leftIconNameSubject.value,
            type: typeSubject.value,
            isSelected: isSelectedSubject.value,
            shouldApplyTintColor: shouldApplyTintColorSubject.value
        ))
    }

    public var displayStatePublisher: AnyPublisher<PillDisplayState, Never> {
        Publishers.CombineLatest3(
            Publishers.CombineLatest3(idSubject, titleSubject, leftIconNameSubject),
            Publishers.CombineLatest(typeSubject, isSelectedSubject),
            shouldApplyTintColorSubject
        )
        .map { first, second, applyTint in
            let (id, title, icon) = first
            let (type, isSelected) = second
            return PillDisplayState(pillData: PillData(
                id: id,
                title: title,
                leftIconName: icon,
                type: type,
                isSelected: isSelected,
                shouldApplyTintColor: applyTint
            ))
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Initialization
    public init(pillData: PillData, isReadOnly: Bool = false) {
        self.idSubject = CurrentValueSubject(pillData.id)
        self.titleSubject = CurrentValueSubject(pillData.title)
        self.leftIconNameSubject = CurrentValueSubject(pillData.leftIconName)
        self.typeSubject = CurrentValueSubject(pillData.type)
        self.isSelectedSubject = CurrentValueSubject(pillData.isSelected)
        self.shouldApplyTintColorSubject = CurrentValueSubject<Bool, Never>(pillData.shouldApplyTintColor)
        self.isReadOnly = isReadOnly
    }

    // MARK: - PillItemViewModelProtocol
    public func selectPill() {
        // Don't change selection state if in read-only mode
        guard !isReadOnly else { return }
        isSelectedSubject.send(!isSelectedSubject.value)
    }

    public func updateTitle(_ title: String) {
        titleSubject.send(title)
    }

    public func updateLeftIcon(_ iconName: String?) {
        leftIconNameSubject.send(iconName)
    }

    public func updateType(_ newType: PillData.PillItemViewType) {
        typeSubject.send(newType)
    }
}

// MARK: - Mock Factory
extension MockPillItemViewModel {
    public static var footballPill: MockPillItemViewModel {
        return MockPillItemViewModel(
            pillData: PillData(
                id: "football",
                title: "Football",
                leftIconName: "sportscourt.fill",
                type: .expansible,
                isSelected: true
            )
        )
    }

    public static var popularPill: MockPillItemViewModel {
        return MockPillItemViewModel(
            pillData: PillData(
                id: "popular",
                title: "Popular",
                leftIconName: "flame.fill",
                type: .informative,
                isSelected: false
            )
        )
    }

    public static var allPill: MockPillItemViewModel {
        return MockPillItemViewModel(
            pillData: PillData(
                id: "all",
                title: "All",
                leftIconName: "trophy.fill",
                type: .expansible,
                isSelected: false
            )
        )
    }
}
