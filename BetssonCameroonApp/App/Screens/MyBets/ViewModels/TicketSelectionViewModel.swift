import Foundation
import Combine
import GomaUI

final class TicketSelectionViewModel: TicketSelectionViewModelProtocol {
    
    // MARK: - Properties
    
    private let ticketDataSubject: CurrentValueSubject<TicketSelectionData, Never>
    
    // MARK: - Publishers
    
    var currentTicketData: TicketSelectionData {
        ticketDataSubject.value
    }
    
    var ticketDataPublisher: AnyPublisher<TicketSelectionData, Never> {
        ticketDataSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Callbacks
    
    var onTicketTapped: (() -> Void)?
    
    // MARK: - Initialization
    
    init(ticketData: TicketSelectionData) {
        self.ticketDataSubject = CurrentValueSubject(ticketData)
    }
    
    // MARK: - Protocol Methods
    
    func handleTicketTap() {
        onTicketTapped?()
    }
    
    // MARK: - Public Methods
    
    func updateTicketData(_ ticketData: TicketSelectionData) {
        ticketDataSubject.send(ticketData)
    }
}

// MARK: - Factory Methods

extension TicketSelectionViewModel {
    
    static func create(from selection: MyBetSelection) -> TicketSelectionViewModel {
        let ticketData = TicketSelectionData(
            id: selection.identifier,
            competitionName: selection.tournamentName,
            homeTeamName: selection.homeTeamName ?? "",
            awayTeamName: selection.awayTeamName ?? "",
            homeScore: parseScore(selection.homeResult),
            awayScore: parseScore(selection.awayResult),
            matchDate: formatEventDate(selection.eventDate),
            isLive: isLiveMatch(selection),
            sportIcon: mapSportIcon(selection.sport),
            countryFlag: mapCountryFlag(selection.country),
            marketName: selection.marketName,
            selectionName: selection.outcomeName,
            oddsValue: formatOdds(selection.odd)
        )
        
        return TicketSelectionViewModel(ticketData: ticketData)
    }
    
    // MARK: - Private Helper Methods
    
    private static func parseScore(_ scoreString: String?) -> Int {
        guard let scoreString = scoreString else { return 0 }
        return Int(scoreString) ?? 0
    }
    
    private static func formatEventDate(_ eventDate: Date?) -> String {
        guard let eventDate = eventDate else {
            return "TBD"
        }
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(eventDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "Today \(formatter.string(from: eventDate))"
        } else if calendar.isDateInTomorrow(eventDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "Tomorrow \(formatter.string(from: eventDate))"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM HH:mm"
            return formatter.string(from: eventDate)
        }
    }
    
    private static func isLiveMatch(_ selection: MyBetSelection) -> Bool {
        return selection.state == .opened && 
               selection.homeResult != nil && 
               selection.awayResult != nil
    }
    
    private static func mapSportIcon(_ sport: Sport?) -> String? {
        guard let sport = sport else { return "soccerball" }
        
        switch sport.name.lowercased() {
        case "football", "soccer":
            return "soccerball"
        case "basketball":
            return "basketball"
        case "tennis":
            return "tennis.racket"
        case "ice hockey", "hockey":
            return "hockey.puck"
        case "baseball":
            return "baseball"
        case "volleyball":
            return "volleyball"
        default:
            return "soccerball"
        }
    }
    
    private static func mapCountryFlag(_ country: Country?) -> String? {
        guard let country = country else { return "flag.fill" }
        
        switch country.iso2Code.lowercased() {
        case "gb", "uk":
            return "🇬🇧"
        case "fr":
            return "🇫🇷"
        case "de":
            return "🇩🇪"
        case "es":
            return "🇪🇸"
        case "it":
            return "🇮🇹"
        case "us":
            return "🇺🇸"
        case "cm":
            return "🇨🇲"
        default:
            return "flag.fill"
        }
    }
    
    private static func formatOdds(_ odd: OddFormat) -> String {
        return OddConverter.stringForValue(odd.decimalValue, format: .europe)
    }
}
