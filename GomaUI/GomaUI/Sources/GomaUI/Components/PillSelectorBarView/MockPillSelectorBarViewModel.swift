import Combine
import UIKit

/// Mock implementation of `PillSelectorBarViewModelProtocol` for testing.
final public class MockPillSelectorBarViewModel: PillSelectorBarViewModelProtocol {
    
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<PillSelectorBarDisplayState, Never>
    private let selectionEventSubject = PassthroughSubject<PillSelectionEvent, Never>()
    
    public var displayStatePublisher: AnyPublisher<PillSelectorBarDisplayState, Never> {
        displayStateSubject.eraseToAnyPublisher()
    }
    
    public var selectionEventPublisher: AnyPublisher<PillSelectionEvent, Never> {
        selectionEventSubject.eraseToAnyPublisher()
    }
    
    // Internal state
    private var barData: PillSelectorBarData
    private var isVisible: Bool
    private var isUserInteractionEnabled: Bool
    
    // MARK: - Current State Access
    public var currentSelectedPillId: String? {
        barData.selectedPillId
    }
    
    public var currentPills: [PillData] {
        barData.pills
    }
    
    // MARK: - Initialization
    public init(
        barData: PillSelectorBarData,
        isVisible: Bool = true,
        isUserInteractionEnabled: Bool = true
    ) {
        self.barData = barData
        self.isVisible = isVisible
        self.isUserInteractionEnabled = isUserInteractionEnabled
        
        // Create initial display state
        let initialState = PillSelectorBarDisplayState(
            barData: barData,
            isVisible: isVisible,
            isUserInteractionEnabled: isUserInteractionEnabled
        )
        self.displayStateSubject = CurrentValueSubject(initialState)
    }
    
    // MARK: - PillSelectorBarViewModelProtocol
    public func selectPill(id: String) {
        let previouslySelectedId = barData.selectedPillId
        
        // Update internal state
        barData = PillSelectorBarData(
            id: barData.id,
            pills: barData.pills,
            selectedPillId: id,
            isScrollEnabled: barData.isScrollEnabled,
            allowsVisualStateChanges: barData.allowsVisualStateChanges
        )
        
        // Publish new state
        publishNewState()
        
        // Send selection event
        let selectionEvent = PillSelectionEvent(
            selectedId: id,
            previouslySelectedId: previouslySelectedId
        )
        selectionEventSubject.send(selectionEvent)
        
        print("MockPillSelectorBarViewModel: Pill selected: \(id)")
    }
    
    public func updatePills(_ pills: [PillData]) {
        barData = PillSelectorBarData(
            id: barData.id,
            pills: pills,
            selectedPillId: barData.selectedPillId,
            isScrollEnabled: barData.isScrollEnabled,
            allowsVisualStateChanges: barData.allowsVisualStateChanges
        )
        publishNewState()
    }
    
    public func addPill(_ pill: PillData) {
        var updatedPills = barData.pills
        updatedPills.append(pill)
        updatePills(updatedPills)
    }
    
    public func removePill(id: String) {
        let updatedPills = barData.pills.filter { $0.id != id }
        let newSelectedId = (barData.selectedPillId == id) ? nil : barData.selectedPillId
        
        barData = PillSelectorBarData(
            id: barData.id,
            pills: updatedPills,
            selectedPillId: newSelectedId,
            isScrollEnabled: barData.isScrollEnabled,
            allowsVisualStateChanges: barData.allowsVisualStateChanges
        )
        publishNewState()
    }
    
    public func updatePill(_ pill: PillData) {
        let updatedPills = barData.pills.map { existingPill in
            existingPill.id == pill.id ? pill : existingPill
        }
        updatePills(updatedPills)
    }
    
    public func clearSelection() {
        barData = PillSelectorBarData(
            id: barData.id,
            pills: barData.pills,
            selectedPillId: nil,
            isScrollEnabled: barData.isScrollEnabled,
            allowsVisualStateChanges: barData.allowsVisualStateChanges
        )
        publishNewState()
    }
    
    public func selectFirstAvailablePill() {
        guard let firstPill = barData.pills.first else { return }
        selectPill(id: firstPill.id)
    }
    
    public func setVisible(_ visible: Bool) {
        isVisible = visible
        publishNewState()
    }
    
    public func setUserInteractionEnabled(_ enabled: Bool) {
        isUserInteractionEnabled = enabled
        publishNewState()
    }
    
    // MARK: - Helper Methods
    private func publishNewState() {
        let newState = PillSelectorBarDisplayState(
            barData: barData,
            isVisible: isVisible,
            isUserInteractionEnabled: isUserInteractionEnabled
        )
        displayStateSubject.send(newState)
    }
}

// MARK: - Mock Factory
extension MockPillSelectorBarViewModel {
    
    /// Sports categories with icons
    public static var sportsCategories: MockPillSelectorBarViewModel {
        let pills = [
            PillData(
                id: "all",
                title: "All",
                leftIconName: "square.grid.3x3.fill",
                showExpandIcon: false,
                isSelected: true
            ),
            PillData(
                id: "football",
                title: "Football",
                leftIconName: "sportscourt.fill",
                showExpandIcon: true,
                isSelected: false
            ),
            PillData(
                id: "basketball",
                title: "Basketball",
                leftIconName: "basketball.fill",
                showExpandIcon: false,
                isSelected: false
            ),
            PillData(
                id: "baseball",
                title: "Baseball",
                leftIconName: "baseball.fill",
                showExpandIcon: false,
                isSelected: false
            ),
            PillData(
                id: "soccer",
                title: "Soccer",
                leftIconName: "soccerball",
                showExpandIcon: true,
                isSelected: false
            ),
            PillData(
                id: "tennis",
                title: "Tennis",
                leftIconName: "tennis.racket",
                showExpandIcon: false,
                isSelected: false
            )
        ]
        
        let barData = PillSelectorBarData(
            id: "sports_categories",
            pills: pills,
            selectedPillId: "all",
            isScrollEnabled: true,
            allowsVisualStateChanges: true
        )
        
        return MockPillSelectorBarViewModel(barData: barData)
    }
    
    /// Market filters for betting
    public static var marketFilters: MockPillSelectorBarViewModel {
        let pills = [
            PillData(
                id: "popular",
                title: "Popular",
                leftIconName: "flame.fill",
                showExpandIcon: false,
                isSelected: true
            ),
            PillData(
                id: "moneyline",
                title: "Moneyline",
                leftIconName: nil,
                showExpandIcon: false,
                isSelected: false
            ),
            PillData(
                id: "spread",
                title: "Spread",
                leftIconName: nil,
                showExpandIcon: false,
                isSelected: false
            ),
            PillData(
                id: "totals",
                title: "Totals",
                leftIconName: nil,
                showExpandIcon: false,
                isSelected: false
            ),
            PillData(
                id: "props",
                title: "Player Props",
                leftIconName: "person.fill",
                showExpandIcon: true,
                isSelected: false
            ),
            PillData(
                id: "live",
                title: "Live",
                leftIconName: "dot.radiowaves.left.and.right",
                showExpandIcon: false,
                isSelected: false
            )
        ]
        
        let barData = PillSelectorBarData(
            id: "market_filters",
            pills: pills,
            selectedPillId: "popular",
            isScrollEnabled: true,
            allowsVisualStateChanges: true
        )
        
        return MockPillSelectorBarViewModel(barData: barData)
    }
    
    /// Time periods for filtering
    public static var timePeriods: MockPillSelectorBarViewModel {
        let pills = [
            PillData(
                id: "today",
                title: "Today",
                leftIconName: "calendar",
                showExpandIcon: false,
                isSelected: false
            ),
            PillData(
                id: "tomorrow",
                title: "Tomorrow",
                leftIconName: nil,
                showExpandIcon: false,
                isSelected: true
            ),
            PillData(
                id: "week",
                title: "This Week",
                leftIconName: nil,
                showExpandIcon: false,
                isSelected: false
            ),
            PillData(
                id: "month",
                title: "This Month",
                leftIconName: nil,
                showExpandIcon: false,
                isSelected: false
            )
        ]
        
        let barData = PillSelectorBarData(
            id: "time_periods",
            pills: pills,
            selectedPillId: "tomorrow",
            isScrollEnabled: true,
            allowsVisualStateChanges: true
        )
        
        return MockPillSelectorBarViewModel(barData: barData)
    }
    
    /// Limited pills that don't need scrolling
    public static var limitedPills: MockPillSelectorBarViewModel {
        let pills = [
            PillData(
                id: "live",
                title: "Live",
                leftIconName: "dot.radiowaves.left.and.right",
                showExpandIcon: false,
                isSelected: true
            ),
            PillData(
                id: "upcoming",
                title: "Upcoming",
                leftIconName: "clock",
                showExpandIcon: false,
                isSelected: false
            )
        ]
        
        let barData = PillSelectorBarData(
            id: "limited_pills",
            pills: pills,
            selectedPillId: "live",
            isScrollEnabled: false,
            allowsVisualStateChanges: true
        )
        
        return MockPillSelectorBarViewModel(barData: barData)
    }
    
    /// Empty state for testing
    public static var emptyPills: MockPillSelectorBarViewModel {
        let barData = PillSelectorBarData(
            id: "empty_pills",
            pills: [],
            selectedPillId: nil,
            isScrollEnabled: false,
            allowsVisualStateChanges: true
        )
        
        return MockPillSelectorBarViewModel(barData: barData, isVisible: false)
    }
    
    /// Text-only pills without icons
    public static var textOnlyPills: MockPillSelectorBarViewModel {
        let pills = [
            PillData(
                id: "all",
                title: "All Sports",
                leftIconName: nil,
                showExpandIcon: false,
                isSelected: true
            ),
            PillData(
                id: "favorites",
                title: "My Favorites",
                leftIconName: nil,
                showExpandIcon: false,
                isSelected: false
            ),
            PillData(
                id: "trending",
                title: "Trending",
                leftIconName: nil,
                showExpandIcon: false,
                isSelected: false
            ),
            PillData(
                id: "ending_soon",
                title: "Ending Soon",
                leftIconName: nil,
                showExpandIcon: false,
                isSelected: false
            )
        ]
        
        let barData = PillSelectorBarData(
            id: "text_only_pills",
            pills: pills,
            selectedPillId: "all",
            isScrollEnabled: true,
            allowsVisualStateChanges: true
        )
        
        return MockPillSelectorBarViewModel(barData: barData)
    }
    
    /// Read-only pills that show states but don't change when tapped
    public static var readOnlyMarketFilters: MockPillSelectorBarViewModel {
        let pills = [
            PillData(
                id: "moneyline",
                title: "Moneyline",
                leftIconName: nil,
                showExpandIcon: false,
                isSelected: true  // This pill shows as selected
            ),
            PillData(
                id: "spread",
                title: "Spread",
                leftIconName: nil,
                showExpandIcon: false,
                isSelected: false  // This pill shows as unselected
            ),
            PillData(
                id: "totals",
                title: "Totals",
                leftIconName: nil,
                showExpandIcon: false,
                isSelected: true  // This pill shows as selected
            ),
            PillData(
                id: "props",
                title: "Props",
                leftIconName: "person.fill",
                showExpandIcon: false,
                isSelected: false  // This pill shows as unselected
            )
        ]
        
        let barData = PillSelectorBarData(
            id: "readonly_market_filters",
            pills: pills,
            selectedPillId: nil,  // No single selection - each pill has its own state
            isScrollEnabled: true,
            allowsVisualStateChanges: false  // Visual states don't change on tap
        )
        
        return MockPillSelectorBarViewModel(barData: barData)
    }
    
    /// Screenshot recreation - Football, Popular, Al, Filter All Popular Leagues
    public static var footballPopularLeagues: MockPillSelectorBarViewModel {
        let pills = [
            PillData(
                id: "football",
                title: "Football",
                leftIconName: "soccerball",
                showExpandIcon: true,
                isSelected: true  // Orange border - selected
            ),
            PillData(
                id: "popular",
                title: "Popular", 
                leftIconName: "flame.fill",
                showExpandIcon: false,
                isSelected: false  // Gray - unselected
            ),
            PillData(
                id: "all",
                title: "All",
                leftIconName: "trophy.fill",
                showExpandIcon: false,
                isSelected: false  // Gray - unselected
            ),
            PillData(
                id: "filter_leagues",
                title: "All Popular Leagues",
                leftIconName: "line.3.horizontal.decrease",
                showExpandIcon: false,
                isSelected: false  // Gray - unselected
            )
        ]
        
        let barData = PillSelectorBarData(
            id: "football_popular_leagues",
            pills: pills,
            selectedPillId: nil,  // Using individual pill states
            isScrollEnabled: true,
            allowsVisualStateChanges: false  // Read-only display like in screenshot
        )
        
        return MockPillSelectorBarViewModel(barData: barData)
    }
}
