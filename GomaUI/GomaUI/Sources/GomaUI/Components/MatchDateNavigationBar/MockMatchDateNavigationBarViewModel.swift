import Foundation
import Combine

public final class MockMatchDateNavigationBarViewModel: MatchDateNavigationBarViewModelProtocol {
    
    private let dataSubject: CurrentValueSubject<MatchDateNavigationBarData, Never>
    
    public var data: MatchDateNavigationBarData {
        dataSubject.value
    }
    
    public var dataPublisher: AnyPublisher<MatchDateNavigationBarData, Never> {
        dataSubject.eraseToAnyPublisher()
    }
    
    public init(data: MatchDateNavigationBarData) {
        self.dataSubject = CurrentValueSubject(data)
    }
    
    public func configure(with data: MatchDateNavigationBarData) {
        dataSubject.send(data)
    }
}

// MARK: - Factory Methods
extension MockMatchDateNavigationBarViewModel {
    
    public static var defaultPreMatchMock: MockMatchDateNavigationBarViewModel {
        let futureDate = Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
        let data = MatchDateNavigationBarData(
            matchStatus: .preMatch(date: futureDate)
        )
        return MockMatchDateNavigationBarViewModel(data: data)
    }
    
    public static var liveMock: MockMatchDateNavigationBarViewModel {
        let data = MatchDateNavigationBarData(
            matchStatus: .live(period: "1st Half", time: "41mins")
        )
        return MockMatchDateNavigationBarViewModel(data: data)
    }
    
    public static var secondHalfMock: MockMatchDateNavigationBarViewModel {
        let data = MatchDateNavigationBarData(
            matchStatus: .live(period: "2nd Half", time: "67mins")
        )
        return MockMatchDateNavigationBarViewModel(data: data)
    }
    
    public static var halfTimeMock: MockMatchDateNavigationBarViewModel {
        let data = MatchDateNavigationBarData(
            matchStatus: .live(period: "Half Time", time: "")
        )
        return MockMatchDateNavigationBarViewModel(data: data)
    }
    
    public static var extraTimeMock: MockMatchDateNavigationBarViewModel {
        let data = MatchDateNavigationBarData(
            matchStatus: .live(period: "Extra Time", time: "105mins")
        )
        return MockMatchDateNavigationBarViewModel(data: data)
    }
    
    public static var noBackButtonMock: MockMatchDateNavigationBarViewModel {
        let data = MatchDateNavigationBarData(
            matchStatus: .live(period: "2nd Half", time: "89mins"),
            isBackButtonHidden: true
        )
        return MockMatchDateNavigationBarViewModel(data: data)
    }
    
    public static var customDateFormatMock: MockMatchDateNavigationBarViewModel {
        let futureDate = Calendar.current.date(byAdding: .hour, value: 5, to: Date()) ?? Date()
        let data = MatchDateNavigationBarData(
            matchStatus: .preMatch(date: futureDate),
            dateFormat: "EEEE, MMM d 'at' h:mm a"
        )
        return MockMatchDateNavigationBarViewModel(data: data)
    }
    
    // For demo purposes - cycles through different states
    public static func createAnimatedMock() -> MockMatchDateNavigationBarViewModel {
        let viewModel = liveMock
        
        // Simulate time progression
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            let currentData = viewModel.data
            
            switch currentData.matchStatus {
            case .preMatch:
                viewModel.configure(with: MatchDateNavigationBarData(
                    matchStatus: .live(period: "1st Half", time: "1min")
                ))
            case .live(let period, let time):
                if period == "1st Half" && time == "41mins" {
                    viewModel.configure(with: MatchDateNavigationBarData(
                        matchStatus: .live(period: "Half Time", time: "")
                    ))
                } else if period == "Half Time" {
                    viewModel.configure(with: MatchDateNavigationBarData(
                        matchStatus: .live(period: "2nd Half", time: "46mins")
                    ))
                } else if period == "2nd Half" && time == "89mins" {
                    viewModel.configure(with: MatchDateNavigationBarData(
                        matchStatus: .live(period: "Full Time", time: "")
                    ))
                } else {
                    // Increment time
                    if let currentMinutes = Int(time.replacingOccurrences(of: "mins", with: "").replacingOccurrences(of: "min", with: "")) {
                        let newMinutes = currentMinutes + 5
                        viewModel.configure(with: MatchDateNavigationBarData(
                            matchStatus: .live(period: period, time: "\(newMinutes)mins")
                        ))
                    }
                }
            }
        }
        
        return viewModel
    }
}