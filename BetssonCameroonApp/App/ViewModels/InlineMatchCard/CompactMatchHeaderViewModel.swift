import Foundation
import Combine
import GomaUI
import ServicesProvider
import GomaLogger

/// Production implementation of CompactMatchHeaderViewModelProtocol
/// Displays date/time or LIVE badge + market count in compact format
final class CompactMatchHeaderViewModel: CompactMatchHeaderViewModelProtocol {

    // MARK: - Private Properties
    private let displayStateSubject: CurrentValueSubject<CompactMatchHeaderDisplayState, Never>
    private let matchId: String

    // MARK: - Protocol Properties
    public var displayStatePublisher: AnyPublisher<CompactMatchHeaderDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }

    public var currentDisplayState: CompactMatchHeaderDisplayState {
        displayStateSubject.value
    }

    // MARK: - Initialization

    init(
        matchId: String,
        mode: CompactMatchHeaderMode,
        icons: [CompactMatchHeaderIcon] = [],
        marketCount: Int? = nil,
        showMarketCountArrow: Bool = true
    ) {
        self.matchId = matchId
        let initialState = CompactMatchHeaderDisplayState(
            mode: mode,
            icons: icons,
            marketCount: marketCount,
            showMarketCountArrow: showMarketCountArrow
        )
        self.displayStateSubject = CurrentValueSubject(initialState)
    }

    // MARK: - Protocol Methods

    func updateMode(_ mode: CompactMatchHeaderMode) {
        let current = displayStateSubject.value
        let newState = CompactMatchHeaderDisplayState(
            mode: mode,
            icons: current.icons,
            marketCount: current.marketCount,
            showMarketCountArrow: current.showMarketCountArrow
        )
        displayStateSubject.send(newState)
    }

    func updateIcons(_ icons: [CompactMatchHeaderIcon]) {
        let current = displayStateSubject.value
        let newState = CompactMatchHeaderDisplayState(
            mode: current.mode,
            icons: icons,
            marketCount: current.marketCount,
            showMarketCountArrow: current.showMarketCountArrow
        )
        displayStateSubject.send(newState)
    }

    func updateMarketCount(_ count: Int?) {
        let current = displayStateSubject.value
        let newState = CompactMatchHeaderDisplayState(
            mode: current.mode,
            icons: current.icons,
            marketCount: count,
            showMarketCountArrow: current.showMarketCountArrow
        )
        displayStateSubject.send(newState)
    }

    func onMarketCountTapped() {
        GomaLogger.debug(.ui, category: "INLINE_HEADER", "Market count tapped for match: \(matchId)")
    }

    // MARK: - Live Data Updates

    /// Updates the header from live data updates
    func update(from eventLiveData: EventLiveData) {
        var newMode: CompactMatchHeaderMode

        if let status = eventLiveData.status {
            switch status {
            case .inProgress(let details):
                // Combine status + time if available
                if let matchTime = eventLiveData.matchTime {
                    newMode = .live(statusText: "\(details), \(matchTime)'")
                } else {
                    newMode = .live(statusText: details)
                }
            case .notStarted:
                // Keep pre-live mode, shouldn't change
                return
            case .ended:
                newMode = .live(statusText: "FT")
            case .unknown:
                return
            }

            updateMode(newMode)
        } else if let matchTime = eventLiveData.matchTime {
            // Just match time, no status
            newMode = .live(statusText: "\(matchTime)'")
            updateMode(newMode)
        }
    }
}

// MARK: - Factory Methods
extension CompactMatchHeaderViewModel {

    /// Creates a CompactMatchHeaderViewModel from Match data
    static func create(from match: Match) -> CompactMatchHeaderViewModel {
        let mode = createMode(from: match)
        let icons = createIcons(from: match)

        return CompactMatchHeaderViewModel(
            matchId: match.id,
            mode: mode,
            icons: icons,
            marketCount: match.numberTotalOfMarkets,
            showMarketCountArrow: true
        )
    }

    // MARK: - Helper Methods

    private static func createMode(from match: Match) -> CompactMatchHeaderMode {
        if match.status.isLive {
            // Live match - show status
            if let matchTime = match.matchTime {
                return .live(statusText: "\(matchTime)'")
            } else {
                return .live(statusText: "LIVE")
            }
        } else {
            // Pre-live - show date/time
            let dateText = formatDateText(from: match.date)
            return .preLive(dateText: dateText)
        }
    }

    private static func formatDateText(from date: Date?) -> String {
        guard let date = date else {
            return "-"
        }

        let calendar = Calendar.current
        let now = Date()

        // Check if today
        if calendar.isDateInToday(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            return "TODAY, \(timeFormatter.string(from: date))"
        }

        // Check if tomorrow
        if calendar.isDateInTomorrow(date) {
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            return "TOMORROW, \(timeFormatter.string(from: date))"
        }

        // Other dates - show date and time
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM, HH:mm"
        return dateFormatter.string(from: date)
    }

    private static func createIcons(from match: Match) -> [CompactMatchHeaderIcon] {
        // Currently no icons - can be extended for Express Pick, BetBuilder, etc.
        var icons: [CompactMatchHeaderIcon] = []

        // Placeholder for future icon support
        // icons.append(CompactMatchHeaderIcon(id: "ep", iconName: "icon_express_pick", isVisible: match.hasExpressPick))
        // icons.append(CompactMatchHeaderIcon(id: "betBuilder", iconName: "icon_bet_builder", isVisible: match.hasBetBuilder))

        return icons
    }
}
