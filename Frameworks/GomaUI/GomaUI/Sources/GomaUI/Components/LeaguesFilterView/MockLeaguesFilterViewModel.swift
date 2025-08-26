import Foundation
import UIKit
import Combine

public class MockLeaguesFilterViewModel: LeaguesFilterViewModelProtocol {
    public let leagueOptions: [LeagueOption]
    
    public var selectedOptionId: CurrentValueSubject<String, Never>
    public var isCollapsed: CurrentValueSubject<Bool, Never> = .init(false)
    
    public init(leagueOptions: [LeagueOption], selectedId: String = "1") {
        self.leagueOptions = leagueOptions
        self.selectedOptionId = .init(selectedId)
    }
    
    public func selectOption(withId id: String) {
        selectedOptionId.send(id)
    }
    
    public func toggleCollapse() {
        isCollapsed.send(!isCollapsed.value)
    }
}
