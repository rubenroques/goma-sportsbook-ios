import Foundation
import Combine

public class MockTimeSliderViewModel: TimeSliderViewModelProtocol {
    public let title: String
    public var timeOptions = [TimeOption]()
    
    public var selectedTimeValue: CurrentValueSubject<Float, Never>
    
    public init(title: String, timeOptions: [TimeOption], selectedValue: Float = 0) {
        self.title = title
        self.timeOptions = timeOptions
        self.selectedTimeValue = .init(selectedValue)
    }
    
    public func didChangeValue(_ value: Float) {
        // Round to nearest integer since our options are whole numbers
        let roundedValue = round(value)
        selectedTimeValue.send(roundedValue)
    }
}
