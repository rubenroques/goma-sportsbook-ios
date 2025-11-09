import UIKit


public final class MockBetslipTypeTabItemViewModel: BetslipTypeTabItemViewModelProtocol {
    
    // MARK: - Properties
    public let title: String
    public let icon: String
    public let isSelected: Bool
    
    // MARK: - Actions
    public var onTabTapped: (() -> Void)?
    
    // MARK: - Initialization
    public init(title: String, icon: String, isSelected: Bool = false) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
    }
    
    // MARK: - Mock Factory Methods
    public static func sportsSelectedMock() -> MockBetslipTypeTabItemViewModel {
        return MockBetslipTypeTabItemViewModel(title: LocalizationProvider.string("sports"), icon: "soccerball", isSelected: true)
    }
    
    public static func sportsUnselectedMock() -> MockBetslipTypeTabItemViewModel {
        return MockBetslipTypeTabItemViewModel(title: LocalizationProvider.string("sports"), icon: "soccerball", isSelected: false)
    }
    
    public static func virtualsSelectedMock() -> MockBetslipTypeTabItemViewModel {
        return MockBetslipTypeTabItemViewModel(title: LocalizationProvider.string("virtuals"), icon: "virtuals", isSelected: true)
    }
    
    public static func virtualsUnselectedMock() -> MockBetslipTypeTabItemViewModel {
        return MockBetslipTypeTabItemViewModel(title: LocalizationProvider.string("virtuals"), icon: "virtuals", isSelected: false)
    }
} 
