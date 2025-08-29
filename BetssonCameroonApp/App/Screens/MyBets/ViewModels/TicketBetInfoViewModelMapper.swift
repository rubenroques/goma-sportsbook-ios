import Foundation
import GomaUI

struct TicketBetInfoViewModelMapper {
    
    // MARK: - Main Mapping Function
    
    static func mapMyBetToTicketBetInfoData(_ myBet: MyBet) -> TicketBetInfoData {
        let ticketSelections = myBet.selections.map { mapMyBetSelectionToTicketSelectionData($0) }
        
        return TicketBetInfoData(
            id: myBet.identifier,
            title: formatBetTitle(myBet),
            betDetails: formatBetDetails(myBet),
            tickets: ticketSelections,
            totalOdds: formatOdds(myBet.totalOdd),
            betAmount: formatCurrency(myBet.stake, currency: myBet.currency),
            possibleWinnings: formatPossibleWinnings(myBet),
            partialCashoutValue: formatPartialCashoutValue(myBet),
            cashoutTotalAmount: formatCashoutTotalAmount(myBet)
        )
    }
    
    // MARK: - Selection Mapping
    
    static func mapMyBetSelectionToTicketSelectionData(_ selection: MyBetSelection) -> TicketSelectionData {
        return TicketSelectionData(
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
    }
    
    // MARK: - Private Helper Methods
    
    private static func formatBetTitle(_ myBet: MyBet) -> String {
        return myBet.typeDescription
    }
    
    private static func formatBetDetails(_ myBet: MyBet) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let dateString = dateFormatter.string(from: myBet.date)
        
        return "\(dateString) | Bet ID: \(myBet.identifier)"
    }
    
    private static func formatOdds(_ oddFormat: OddFormat) -> String {
        return OddConverter.stringForValue(oddFormat.decimalValue, format: .europe)
    }
    
    private static func formatOdds(_ odds: Double) -> String {
        return OddConverter.stringForValue(odds, format: .europe)
    }
    
    private static func formatCurrency(_ amount: Double, currency: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        
        if let formattedString = formatter.string(from: NSNumber(value: amount)) {
            return formattedString
        }
        
        // Fallback formatting
        let currencySymbol = getCurrencySymbol(for: currency)
        return "\(currencySymbol) \(String(format: "%.2f", amount))"
    }
    
    private static func formatPossibleWinnings(_ myBet: MyBet) -> String {
        guard let potentialReturn = myBet.potentialReturn else {
            return formatCurrency(0.0, currency: myBet.currency)
        }
        return formatCurrency(potentialReturn, currency: myBet.currency)
    }
    
    private static func formatPartialCashoutValue(_ myBet: MyBet) -> String? {
        // Hardcoded to never show cashout components
        return nil
    }
    
    private static func formatCashoutTotalAmount(_ myBet: MyBet) -> String? {
        // Hardcoded to never show cashout components
        return nil
    }
    
    // MARK: - Selection Helper Methods
    
    private static func parseScore(_ scoreString: String?) -> Int {
        guard let scoreString = scoreString else { return 0 }
        return Int(scoreString) ?? 0
    }
    
    private static func formatEventDate(_ eventDate: Date?) -> String {
        guard let eventDate = eventDate else {
            return "TBD"
        }
        
        let calendar = Calendar.current
        let now = Date()
        
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
    
    private static func getCurrencySymbol(for currency: String) -> String {
        switch currency.uppercased() {
        case "EUR":
            return "€"
        case "USD":
            return "$"
        case "GBP":
            return "£"
        case "XAF":
            return "XAF"
        default:
            return currency
        }
    }
}