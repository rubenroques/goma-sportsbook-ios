import Foundation
import Combine

public class MockCountryLeaguesFilterViewModel: CountryLeaguesFilterViewModelProtocol {
    public var title: String
    public var countryLeagueOptions: [CountryLeagueOptions]
    public var selectedOptionId: CurrentValueSubject<String, Never>
    public var selectedLeaguesPublisher = CurrentValueSubject<[String], Never>([])
    public var isCollapsed: CurrentValueSubject<Bool, Never> = .init(false)
    public var shouldRefreshData: PassthroughSubject<Void, Never> = .init()

    public init(title: String,countryLeagueOptions: [CountryLeagueOptions], selectedId: String = "0") {
        self.title = title
        self.countryLeagueOptions = countryLeagueOptions
        self.selectedOptionId = .init(selectedId)
    }
    
    public func toggleCountryExpansion(at index: Int) {
        guard index < countryLeagueOptions.count else { return }
        countryLeagueOptions[index].isExpanded.toggle()
    }
    
    public func toggleCollapse() {
        isCollapsed.send(!isCollapsed.value)
    }
    
    public func updateCountryLeagueOptions(_ newSortOptions: [CountryLeagueOptions]) {
        self.countryLeagueOptions = newSortOptions
        
        self.shouldRefreshData.send()
    }
                
      
}
