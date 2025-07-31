import Combine
import UIKit

// MARK: - Data Models
public struct SliderConfiguration: Equatable {
    public let minimumValue: Float
    public let maximumValue: Float
    public let numberOfSteps: Int
    public let trackHeight: CGFloat
    public let trackCornerRadius: CGFloat
    public let thumbSize: CGFloat
    public let thumbImageName: String?
    public let thumbTintColor: UIColor?
    
    public init(
        minimumValue: Float = 0.0,
        maximumValue: Float = 1.0,
        numberOfSteps: Int = 5,
        trackHeight: CGFloat = 4.0,
        trackCornerRadius: CGFloat = 2.0,
        thumbSize: CGFloat = 24.0,
        thumbImageName: String? = nil,
        thumbTintColor: UIColor? = nil
    ) {
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        self.numberOfSteps = numberOfSteps
        self.trackHeight = trackHeight
        self.trackCornerRadius = trackCornerRadius
        self.thumbSize = thumbSize
        self.thumbImageName = thumbImageName
        self.thumbTintColor = thumbTintColor
    }
}

// MARK: - Display State
public struct CustomSliderDisplayState: Equatable {
    public let configuration: SliderConfiguration
    public let currentValue: Float
    public let isEnabled: Bool
    
    public init(configuration: SliderConfiguration, currentValue: Float, isEnabled: Bool = true) {
        self.configuration = configuration
        self.currentValue = currentValue
        self.isEnabled = isEnabled
    }
}

// MARK: - View Model Protocol
public protocol CustomSliderViewModelProtocol {
    // Publisher for reactive updates
    var displayStatePublisher: AnyPublisher<CustomSliderDisplayState, Never> { get }
    
    // User interaction methods
    func updateValue(_ value: Float)
    func snapToNearestStep()
    func setEnabled(_ enabled: Bool)
} 