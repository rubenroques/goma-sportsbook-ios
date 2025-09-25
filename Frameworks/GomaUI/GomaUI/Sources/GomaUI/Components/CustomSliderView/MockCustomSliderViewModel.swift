import Combine
import UIKit

/// Mock implementation of `CustomSliderViewModelProtocol` for testing.
final public class MockCustomSliderViewModel: CustomSliderViewModelProtocol {

    // MARK: - Properties
    private let displayStateSubject: CurrentValueSubject<CustomSliderDisplayState, Never>
    public var displayStatePublisher: AnyPublisher<CustomSliderDisplayState, Never> {
        return displayStateSubject.eraseToAnyPublisher()
    }

    // Internal state
    private var configuration: SliderConfiguration
    private var currentValue: Float
    private var isEnabled: Bool

    // MARK: - Initialization
    public init(configuration: SliderConfiguration, initialValue: Float, isEnabled: Bool = true) {
        self.configuration = configuration
        self.currentValue = max(configuration.minimumValue, min(configuration.maximumValue, initialValue))
        self.isEnabled = isEnabled

        // Create initial display state
        let initialState = CustomSliderDisplayState(
            configuration: configuration,
            currentValue: self.currentValue,
            isEnabled: isEnabled
        )
        self.displayStateSubject = CurrentValueSubject(initialState)
    }

    // MARK: - CustomSliderViewModelProtocol
    public func updateValue(_ value: Float) {
        let clampedValue = max(configuration.minimumValue, min(configuration.maximumValue, value))
        currentValue = clampedValue
        publishNewState()
    }

    public func snapToNearestStep() {
        let range = configuration.maximumValue - configuration.minimumValue
        let stepSize = range / Float(configuration.numberOfSteps - 1)
        let stepIndex = round((currentValue - configuration.minimumValue) / stepSize)
        currentValue = configuration.minimumValue + (stepIndex * stepSize)
        publishNewState()
    }

    public func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        publishNewState()
    }

    // MARK: - Helper Methods
    private func publishNewState() {
        let newState = CustomSliderDisplayState(
            configuration: configuration,
            currentValue: currentValue,
            isEnabled: isEnabled
        )
        displayStateSubject.send(newState)
    }
}

// MARK: - Mock Factory
extension MockCustomSliderViewModel {
    public static var defaultMock: MockCustomSliderViewModel {
        let configuration = SliderConfiguration(
            minimumValue: 0.0,
            maximumValue: 1.0,
            numberOfSteps: 5,
            trackHeight: 4.0,
            trackCornerRadius: 2.0,
            thumbSize: 24.0,
            thumbImageName: nil, // Uses default circular thumb
            thumbTintColor: nil  // Uses StyleProvider.Color.highlightPrimary
        )

        return MockCustomSliderViewModel(
            configuration: configuration,
            initialValue: 0.0,
            isEnabled: true
        )
    }

    public static var midPositionMock: MockCustomSliderViewModel {
        let configuration = SliderConfiguration(
            minimumValue: 0.0,
            maximumValue: 1.0,
            numberOfSteps: 5,
            trackHeight: 4.0,
            trackCornerRadius: 2.0,
            thumbSize: 24.0,
            thumbImageName: nil,
            thumbTintColor: nil
        )

        return MockCustomSliderViewModel(
            configuration: configuration,
            initialValue: 0.5,
            isEnabled: true
        )
    }

    public static var timeFilterMock: MockCustomSliderViewModel {
        let configuration = SliderConfiguration(
            minimumValue: 0.0,
            maximumValue: 1.0,
            numberOfSteps: 5, // For "All", "1h", "8h", "Today", "48h"
            trackHeight: 4.0,
            trackCornerRadius: 2.0,
            thumbSize: 24.0,
            thumbImageName: nil,
            thumbTintColor: nil
        )

        return MockCustomSliderViewModel(
            configuration: configuration,
            initialValue: 0.0, // Start at "All"
            isEnabled: true
        )
    }

    public static var disabledMock: MockCustomSliderViewModel {
        let configuration = SliderConfiguration(
            minimumValue: 0.0,
            maximumValue: 1.0,
            numberOfSteps: 5,
            trackHeight: 4.0,
            trackCornerRadius: 2.0,
            thumbSize: 24.0,
            thumbImageName: nil,
            thumbTintColor: nil
        )

        return MockCustomSliderViewModel(
            configuration: configuration,
            initialValue: 0.3,
            isEnabled: false
        )
    }

    public static var customImageMock: MockCustomSliderViewModel {
        let configuration = SliderConfiguration(
            minimumValue: 0.0,
            maximumValue: 1.0,
            numberOfSteps: 5,
            trackHeight: 4.0,
            trackCornerRadius: 2.0,
            thumbSize: 28.0,
            thumbImageName: "circle.fill", // SF Symbol
            thumbTintColor: UIColor.systemBlue
        )

        return MockCustomSliderViewModel(
            configuration: configuration,
            initialValue: 0.25,
            isEnabled: true
        )
    }

    public static var volumeSliderMock: MockCustomSliderViewModel {
        let configuration = SliderConfiguration(
            minimumValue: 0.0,
            maximumValue: 10.0,
            numberOfSteps: 11,
            trackHeight: 6.0,
            trackCornerRadius: 3.0,
            thumbSize: 32.0,
            thumbImageName: "speaker.wave.2.fill", // SF Symbol for volume
            thumbTintColor: UIColor.systemGreen
        )

        return MockCustomSliderViewModel(
            configuration: configuration,
            initialValue: 7.0,
            isEnabled: true
        )
    }

    public static func customMock(
        configuration: SliderConfiguration,
        initialValue: Float,
        isEnabled: Bool = true
    ) -> MockCustomSliderViewModel {
        return MockCustomSliderViewModel(
            configuration: configuration,
            initialValue: initialValue,
            isEnabled: isEnabled
        )
    }
} 
