import Combine
import UIKit

public class MockMarketGroupTabItemViewModel: MarketGroupTabItemViewModelProtocol {
    
    // MARK: - Private Properties
    private let tabItemDataSubject: CurrentValueSubject<MarketGroupTabItemData, Never>
    private let onTapSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    public init(tabItemData: MarketGroupTabItemData) {
        self.tabItemDataSubject = CurrentValueSubject(tabItemData)
    }
    
    // MARK: - Content Publishers
    public var titlePublisher: AnyPublisher<String, Never> {
        tabItemDataSubject
            .map(\.title)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public var idPublisher: AnyPublisher<String, Never> {
        tabItemDataSubject
            .map(\.id)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    // MARK: - Visual State Publishers
    public var visualStatePublisher: AnyPublisher<MarketGroupTabItemVisualState, Never> {
        tabItemDataSubject
            .map(\.visualState)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public var currentVisualState: MarketGroupTabItemVisualState {
        tabItemDataSubject.value.visualState
    }
    
    // MARK: - Tap Handling
    public var onTapPublisher: AnyPublisher<String, Never> {
        onTapSubject.eraseToAnyPublisher()
    }
    
    public func handleTap() {
        onTapSubject.send(tabItemDataSubject.value.id)
    }
    
    // MARK: - Actions
    public func setVisualState(_ state: MarketGroupTabItemVisualState) {
        let currentData = tabItemDataSubject.value
        let updatedData = MarketGroupTabItemData(
            id: currentData.id,
            title: currentData.title,
            visualState: state
        )
        tabItemDataSubject.send(updatedData)
    }
    
    public func updateTitle(_ title: String) {
        let currentData = tabItemDataSubject.value
        let updatedData = MarketGroupTabItemData(
            id: currentData.id,
            title: title,
            visualState: currentData.visualState
        )
        tabItemDataSubject.send(updatedData)
    }
    
    public func updateTabItemData(_ tabItemData: MarketGroupTabItemData) {
        // Only update if the ID matches (safety check)
        guard tabItemData.id == tabItemDataSubject.value.id else { return }
        tabItemDataSubject.send(tabItemData)
    }
    
    // MARK: - Convenience Methods
    public func setSelected(_ selected: Bool) {
        let newState: MarketGroupTabItemVisualState = selected ? .selected : .idle
        setVisualState(newState)
    }
    
    public func setEnabled(_ enabled: Bool) {
        // Since we no longer have a disabled state, this method is a no-op
        // The tab is always enabled and clickable
    }
}

// MARK: - Factory Methods
extension MockMarketGroupTabItemViewModel {
    
    public static var oneXTwoTab: MockMarketGroupTabItemViewModel {
        return MockMarketGroupTabItemViewModel(
            tabItemData: MarketGroupTabItemData(
                id: "1x2",
                title: "1x2",
                visualState: .selected
            )
        )
    }
    
    public static var doubleChanceTab: MockMarketGroupTabItemViewModel {
        return MockMarketGroupTabItemViewModel(
            tabItemData: MarketGroupTabItemData(
                id: "double_chance",
                title: "Double Chance",
                visualState: .idle
            )
        )
    }
    
    public static var overUnderTab: MockMarketGroupTabItemViewModel {
        return MockMarketGroupTabItemViewModel(
            tabItemData: MarketGroupTabItemData(
                id: "over_under",
                title: "Over/Under",
                visualState: .idle
            )
        )
    }
    
    public static var anotherMarketTab: MockMarketGroupTabItemViewModel {
        return MockMarketGroupTabItemViewModel(
            tabItemData: MarketGroupTabItemData(
                id: "another_market",
                title: "Another market",
                visualState: .idle
            )
        )
    }
    
    public static var disabledTab: MockMarketGroupTabItemViewModel {
        return MockMarketGroupTabItemViewModel(
            tabItemData: MarketGroupTabItemData(
                id: "disabled",
                title: "Disabled",
                visualState: .idle // No longer have disabled state
            )
        )
    }
    
    public static func customTab(id: String, title: String, selected: Bool = false) -> MockMarketGroupTabItemViewModel {
        return MockMarketGroupTabItemViewModel(
            tabItemData: MarketGroupTabItemData(
                id: id,
                title: title,
                visualState: selected ? .selected : .idle
            )
        )
    }
    
    // MARK: - Collection Factory Methods
    public static var standardMarketTabs: [MockMarketGroupTabItemViewModel] {
        return [
            oneXTwoTab,
            doubleChanceTab,
            overUnderTab,
            anotherMarketTab
        ]
    }
    
    public static var mixedStateTabs: [MockMarketGroupTabItemViewModel] {
        return [
            oneXTwoTab,
            doubleChanceTab,
            disabledTab,
            overUnderTab
        ]
    }
} 
