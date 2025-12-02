import Combine
import UIKit
import GomaUI

/// Simplified PillSelectorBarViewModel that only handles sport selector functionality
final class PillSelectorBarViewModel: PillSelectorBarViewModelProtocol {
    
    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<PillSelectorBarDisplayState, Never>
    private let selectionEventSubject = PassthroughSubject<PillSelectionEvent, Never>()
    
    // MARK: - PillSelectorBarViewModelProtocol
    public var displayStatePublisher: AnyPublisher<PillSelectorBarDisplayState, Never> {
        self.displayStateSubject.eraseToAnyPublisher()
    }
    
    public var selectionEventPublisher: AnyPublisher<PillSelectionEvent, Never> {
        self.selectionEventSubject.eraseToAnyPublisher()
    }
    
    public var currentSelectedPillId: String? { nil } // No selection tracking needed
    
    public var currentPills: [PillData] {
        displayStateSubject.value.barData.pills
    }
    
    // MARK: - Callbacks
    var onShowSportsSelector: (() -> Void)?
    
    // MARK: - Current Sport
    private var currentSport: Sport = Sport(
        id: "1",
        name: "Football",
        alphaId: "FBL",
        numericId: "1",
        showEventCategory: true,
        liveEventsCount: 0,
        outrightEventsCount: 0,
        eventsCount: 0
    )
    
    // MARK: - Initialization
    init() {
        let preferredIconName = "sport_type_icon_\(currentSport.id)"
        let iconName = UIImage(named: preferredIconName) != nil ? preferredIconName : "sport_type_icon_default"
        
        let staticPills = [
            PillData(
                id: "sport_selector",
                title: currentSport.name,
                leftIconName: iconName,
                showExpandIcon: true,
                isSelected: true
            ),
            PillData(
                id: "popular",
                title: "Popular",
                leftIconName: "flame_bar_icon",
                showExpandIcon: false,
                isSelected: false
            ),
            PillData(
                id: "all_popular",
                title: "All Popular Leagues",
                leftIconName: "trophy_winners_icon",
                showExpandIcon: false,
                isSelected: false,
                shouldApplyTintColor: false
            )
        ]
        
        let barData = PillSelectorBarData(
            id: "sport_popular_leagues",
            pills: staticPills,
            selectedPillId: "sport_selector",
            isScrollEnabled: true,
            allowsVisualStateChanges: false // Static display
        )
        
        let initialState = PillSelectorBarDisplayState(
            barData: barData,
            isVisible: true,
            isUserInteractionEnabled: true
        )
        
        self.displayStateSubject = CurrentValueSubject(initialState)
    }
    
    // MARK: - Core Functionality
    public func selectPill(id: String) {
        // Only handle sport_selector pill
        if id == "sport_selector" {
            onShowSportsSelector?()
        }
        // Other pills do nothing in this simplified version
    }
    
    public func updateCurrentSport(_ sport: Sport) {
        currentSport = sport
        
        let preferredIconName = "sport_type_icon_\(sport.id)"
        let iconName = UIImage(named: preferredIconName) != nil ? preferredIconName : "sport_type_icon_default"
        
        // Update only the sport_selector pill
        var updatedPills = currentPills
        updatedPills[0] = PillData(
            id: "sport_selector",
            title: sport.name,
            leftIconName: iconName,
            showExpandIcon: true,
            isSelected: true
        )
        
        let updatedBarData = PillSelectorBarData(
            id: "sport_popular_leagues",
            pills: updatedPills,
            selectedPillId: "sport_selector",
            isScrollEnabled: true,
            allowsVisualStateChanges: false
        )
        
        let newState = PillSelectorBarDisplayState(
            barData: updatedBarData,
            isVisible: true,
            isUserInteractionEnabled: true
        )
        
        displayStateSubject.send(newState)
    }
    
    // MARK: - Protocol Conformance (No-ops for unused functionality)
    public func updatePills(_ pills: [PillData]) {
        // No-op: Pills are static in this implementation
    }
    
    public func addPill(_ pill: PillData) {
        // No-op: Pills are static
    }
    
    public func removePill(id: String) {
        // No-op: Pills are static
    }
    
    public func updatePill(_ pill: PillData) {
        // No-op: Pills are static except sport_selector via updateCurrentSport
    }
    
    public func clearSelection() {
        // No-op: No selection state tracking
    }
    
    public func selectFirstAvailablePill() {
        // No-op: Selection is static
    }
    
    public func setVisible(_ visible: Bool) {
        // No-op: Always visible in this use case
    }
    
    public func setUserInteractionEnabled(_ enabled: Bool) {
        // No-op: Always enabled in this use case
    }
}
