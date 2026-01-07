import Foundation
import Combine

final public class MockGeneralFilterBarViewModel: GeneralFilterBarViewModelProtocol {

    public let generalFilterItemsPublisher: CurrentValueSubject<GeneralFilterBarItems, Never>

    public init(items: [FilterOptionItem], mainFilterItem: MainFilterItem) {
        
        let barItems = GeneralFilterBarItems(
            items: items,
            mainFilterItem: mainFilterItem
        )
        self.generalFilterItemsPublisher = CurrentValueSubject(barItems)
    }
    
    public func updateFilterOptionItems(filterOptionItems: [FilterOptionItem]) {
        var currentItem = self.generalFilterItemsPublisher.value
        
        currentItem.items = filterOptionItems
        
        self.generalFilterItemsPublisher.send(currentItem)
    }
}

extension MockGeneralFilterBarViewModel {
    public static var defaultMock: MockGeneralFilterBarViewModel {
        let items = [
            FilterOptionItem(type: .sport, title: "Football", icon: "soccerball"),
            FilterOptionItem(type: .sortBy, title: "Popular", icon: "popular_icon"),
            FilterOptionItem(type: .league, title: "All Leagues", icon: "league_icon")
        ]
        let mainFilterItem = MainFilterItem(type: .mainFilter, title: "Filter")
        return MockGeneralFilterBarViewModel(items: items, mainFilterItem: mainFilterItem)
    }
}
