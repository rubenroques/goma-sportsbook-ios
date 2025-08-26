import Foundation
import Combine

public protocol LeaguesFilterViewModelProtocol {
    var leagueOptions: [LeagueOption] { get }
    var selectedOptionId: CurrentValueSubject<String, Never> { get }
    var isCollapsed: CurrentValueSubject<Bool, Never> { get }
    
    func selectOption(withId id: String)
    func toggleCollapse()
}
