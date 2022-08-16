//
//  FilterHistoryViewModel.swift
//  Sportsbook
//
//  Created by Teresa on 26/07/2022.
//
import Foundation
import Combine

class FilterHistoryViewModel {
    
    // MARK: - Enums

    enum FilterValue: CaseIterable {

        case past30Days
        case past90Days
        case dateRange (startTime: String =  "2022-01-01T12:00:00Z", endTime: String =  "2022-01-01T12:00:00Z")
        
        var identifier: Int {
            switch self {
            case .past30Days: return 0
            case .past90Days:
                return 1
            default:
                return 2
            }
        }

        var key: String {
            switch self {
            case .past30Days: return "Past 30 days"
            case .past90Days: return "Past 90 days"
            default:
                return "Date range"
            }
        }

        static var allCases: [FilterValue] {
            return [.past30Days, .past90Days, .dateRange()]
        }
    }

    // MARK: - Publishers
    var selectedFilterPublisher: CurrentValueSubject<FilterValue, Never> = .init(.past30Days)
    private var cancellables = Set<AnyCancellable>()
    var startTimeFilterPublisher: CurrentValueSubject<String, Never> = .init("\(Date())")
    var endTimeFilterPublisher: CurrentValueSubject<String, Never> = .init("\(Date())")
    
    // MARK: - Life Cycle
     init() {
         print(self.selectedFilterPublisher.value)
      
             Publishers.CombineLatest(self.startTimeFilterPublisher, self.endTimeFilterPublisher)
                  .receive(on: DispatchQueue.main)
                  .sink(receiveValue: { [weak self] startTime, endTime in
                     
                      self?.selectedFilterPublisher.send(.dateRange(startTime: startTime, endTime: endTime))
                  })
                  .store(in: &cancellables)
       
     }
    
    func didSelectFilter(atIndex index: Int) {
        if let selectedFilter =  FilterValue.allCases[safe: index] {
            self.selectedFilterPublisher.send(selectedFilter)
        }
    }
    
    func setStartTime(dateString: String) {
        self.startTimeFilterPublisher.send(dateString)
        
    }
    
    func setEndTime(dateString: String) {
        self.endTimeFilterPublisher.send(dateString)
        
    }
    
    func formatDate(dateString: String) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString)
    }
                            
}
