import Foundation

public class MockLeagueOptionSelectionRowViewModel: LeagueOptionSelectionRowViewModelProtocol {
    
    public var leagueOption: LeagueOption
    
    init(leagueOption: LeagueOption) {
        
        self.leagueOption = leagueOption
    }
    
}
