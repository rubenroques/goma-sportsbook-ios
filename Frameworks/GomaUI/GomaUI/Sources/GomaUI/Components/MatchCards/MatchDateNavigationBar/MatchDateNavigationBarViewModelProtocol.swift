import Foundation
import Combine


// MARK: - Match Status
public enum MatchStatus: Equatable {
    case preMatch(date: Date)
    case live(period: String, time: String)
}

// MARK: - Data Models
public struct MatchDateNavigationBarData: Equatable {
    public let id: String
    public let matchStatus: MatchStatus
    public let backButtonText: String
    public let isBackButtonHidden: Bool
    public let dateFormat: String
    
    public init(
        id: String = UUID().uuidString,
        matchStatus: MatchStatus,
        backButtonText: String = LocalizationProvider.string("back"),
        isBackButtonHidden: Bool = false,
        dateFormat: String = "HH:mm EEE dd/MM"
    ) {
        self.id = id
        self.matchStatus = matchStatus
        self.backButtonText = backButtonText
        self.isBackButtonHidden = isBackButtonHidden
        self.dateFormat = dateFormat
    }
}

// MARK: - View Model Protocol
public protocol MatchDateNavigationBarViewModelProtocol {
    var dataPublisher: AnyPublisher<MatchDateNavigationBarData, Never> { get }
    var data: MatchDateNavigationBarData { get }
    
    func configure(with data: MatchDateNavigationBarData)
}
