import Combine
import UIKit

/// Mock implementation of `PillItemViewModelProtocol` for testing.
final public class MockPillItemViewModel: PillItemViewModelProtocol {

    // MARK: - Publishers
    private let idSubject: CurrentValueSubject<String, Never>
    private let titleSubject: CurrentValueSubject<String, Never>
    private let leftIconNameSubject: CurrentValueSubject<String?, Never>
    private let showExpandIconSubject: CurrentValueSubject<Bool, Never>
    private let isSelectedSubject: CurrentValueSubject<Bool, Never>

    public var idPublisher: AnyPublisher<String, Never> {
        return idSubject.eraseToAnyPublisher()
    }

    public var titlePublisher: AnyPublisher<String, Never> {
        return titleSubject.eraseToAnyPublisher()
    }

    public var leftIconNamePublisher: AnyPublisher<String?, Never> {
        return leftIconNameSubject.eraseToAnyPublisher()
    }

    public var showExpandIconPublisher: AnyPublisher<Bool, Never> {
        return showExpandIconSubject.eraseToAnyPublisher()
    }

    public var isSelectedPublisher: AnyPublisher<Bool, Never> {
        return isSelectedSubject.eraseToAnyPublisher()
    }

    // MARK: - Initialization
    public init(pillData: PillData) {
        self.idSubject = CurrentValueSubject(pillData.id)
        self.titleSubject = CurrentValueSubject(pillData.title)
        self.leftIconNameSubject = CurrentValueSubject(pillData.leftIconName)
        self.showExpandIconSubject = CurrentValueSubject(pillData.showExpandIcon)
        self.isSelectedSubject = CurrentValueSubject(pillData.isSelected)
    }

    // MARK: - PillItemViewModelProtocol
    public func selectPill() {
        isSelectedSubject.send(!isSelectedSubject.value)
    }

    public func updateTitle(_ title: String) {
        titleSubject.send(title)
    }

    public func updateLeftIcon(_ iconName: String?) {
        leftIconNameSubject.send(iconName)
    }

    public func updateExpandIconVisibility(_ show: Bool) {
        showExpandIconSubject.send(show)
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
                showExpandIcon: true,
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
                showExpandIcon: false,
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
                showExpandIcon: true,
                isSelected: false
            )
        )
    }
}