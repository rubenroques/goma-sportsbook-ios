import Foundation
import Combine

public protocol CountryLeagueOptionRowViewModelProtocol {
//    var leagues: [LeagueOption] { get }
    
    var countryLeagueOptions: CountryLeagueOptions { get }

    var selectedOptionId: CurrentValueSubject<String, Never> { get }
    var isCollapsed: CurrentValueSubject<Bool, Never> { get }

    func selectOption(withId id: String)
    func toggleCollapse()
}
